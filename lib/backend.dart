import 'dart:math';

class BackendRequest {
  const BackendRequest({
    required this.method,
    required this.path,
    this.body = const {},
    this.headers = const {},
  });

  final String method;
  final String path;
  final Map<String, Object?> body;
  final Map<String, String> headers;
}

class ApiResponse {
  const ApiResponse(this.statusCode, this.body);

  final int statusCode;
  final Map<String, Object?> body;

  bool get ok => statusCode >= 200 && statusCode < 300;
}

class ProductRecord {
  const ProductRecord({
    required this.id,
    required this.name,
    required this.category,
    required this.packSize,
    required this.price,
    required this.mrp,
    required this.stockQty,
    required this.reorderLevel,
    this.active = true,
  });

  final String id;
  final String name;
  final String category;
  final String packSize;
  final int price;
  final int mrp;
  final int stockQty;
  final int reorderLevel;
  final bool active;

  ProductRecord copyWith({int? stockQty, bool? active}) => ProductRecord(
        id: id,
        name: name,
        category: category,
        packSize: packSize,
        price: price,
        mrp: mrp,
        stockQty: stockQty ?? this.stockQty,
        reorderLevel: reorderLevel,
        active: active ?? this.active,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'packSize': packSize,
        'price': price,
        'mrp': mrp,
        'stockQty': stockQty,
        'reorderLevel': reorderLevel,
        'active': active,
        'lowStock': stockQty <= reorderLevel,
      };
}

class CustomerApi {
  final Map<String, Map<String, Object?>> _customersByMobile = {};
  final Map<String, String> _otpByRequestId = {};
  int _sequence = 1000;

  ApiResponse startOtp(Map<String, Object?> body) {
    final mobile = '${body['mobile'] ?? ''}'.trim();
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(mobile)) {
      return const ApiResponse(400, {'error': 'VALID_MOBILE_REQUIRED'});
    }
    final requestId = 'OTP${_sequence++}';
    _otpByRequestId[requestId] = '123456';
    _customersByMobile.putIfAbsent(
      mobile,
      () => {
        'customerId': 'CUS$mobile',
        'mobile': mobile,
        'name': 'Smart Kirana Customer',
        'segment': 'regular',
      },
    );
    return ApiResponse(202, {
      'requestId': requestId,
      'channel': 'whatsapp',
      'template': 'login_otp',
    });
  }

  ApiResponse verifyOtp(Map<String, Object?> body) {
    final mobile = '${body['mobile'] ?? ''}'.trim();
    final requestId = '${body['requestId'] ?? ''}'.trim();
    final otp = '${body['otp'] ?? ''}'.trim();
    if (_otpByRequestId[requestId] != otp) {
      return const ApiResponse(401, {'error': 'INVALID_OTP'});
    }
    _otpByRequestId.remove(requestId);
    return ApiResponse(200, {
      'token': 'demo.jwt.$requestId',
      'customer': _customersByMobile[mobile],
    });
  }
}

class CatalogueApi {
  CatalogueApi(this._products);

  final Map<String, ProductRecord> _products;

  ApiResponse list({String? category, String? query}) {
    final normalizedQuery = query?.toLowerCase().trim() ?? '';
    final records = _products.values
        .where((product) {
          if (!product.active) return false;
          if (category != null &&
              category != 'All' &&
              product.category != category) {
            return false;
          }
          if (normalizedQuery.isEmpty) return true;
          return '${product.name} ${product.category} ${product.packSize}'
              .toLowerCase()
              .contains(normalizedQuery);
        })
        .map((product) => product.toJson())
        .toList();
    return ApiResponse(200, {'products': records});
  }

  ApiResponse getById(String id) {
    final product = _products[id];
    if (product == null || !product.active) {
      return const ApiResponse(404, {'error': 'PRODUCT_NOT_FOUND'});
    }
    return ApiResponse(200, {'product': product.toJson()});
  }
}

class InventoryService {
  InventoryService(this._products);

  final Map<String, ProductRecord> _products;
  final Map<String, Map<String, int>> _reservations = {};

  ApiResponse reserve(Map<String, Object?> body) {
    final orderId = '${body['orderId'] ?? _nextId('RSV')}';
    final items = _decodeItems(body['items']);
    for (final entry in items.entries) {
      final product = _products[entry.key];
      if (product == null || !product.active) {
        return ApiResponse(404, {
          'error': 'PRODUCT_NOT_FOUND',
          'productId': entry.key,
        });
      }
      if (entry.value <= 0 || product.stockQty < entry.value) {
        return ApiResponse(409, {
          'error': 'INSUFFICIENT_STOCK',
          'productId': entry.key,
          'available': product.stockQty,
        });
      }
    }
    for (final entry in items.entries) {
      final product = _products[entry.key]!;
      _products[entry.key] = product.copyWith(
        stockQty: product.stockQty - entry.value,
      );
    }
    _reservations[orderId] = items;
    return ApiResponse(201, {
      'reservationId': 'RSV$orderId',
      'orderId': orderId,
      'reservedItems': items,
      'expiresInMinutes': 15,
    });
  }

  ApiResponse release(String orderId) {
    final items = _reservations.remove(orderId);
    if (items == null) {
      return const ApiResponse(404, {'error': 'RESERVATION_NOT_FOUND'});
    }
    for (final entry in items.entries) {
      final product = _products[entry.key]!;
      _products[entry.key] = product.copyWith(
        stockQty: product.stockQty + entry.value,
      );
    }
    return const ApiResponse(200, {'released': true});
  }
}

class PricingOfferEngine {
  PricingOfferEngine(this._products);

  final Map<String, ProductRecord> _products;

  ApiResponse quote(Map<String, Object?> body) {
    final items = _decodeItems(body['items']);
    final fulfilmentMode = '${body['fulfilmentMode'] ?? 'Home delivery'}';
    final slot = '${body['slot'] ?? 'Today 6 PM - 8 PM'}';
    var subtotal = 0;
    final lines = <Map<String, Object?>>[];
    for (final entry in items.entries) {
      final product = _products[entry.key];
      if (product == null || !product.active) {
        return ApiResponse(404, {
          'error': 'PRODUCT_NOT_FOUND',
          'productId': entry.key,
        });
      }
      final lineTotal = product.price * entry.value;
      subtotal += lineTotal;
      lines.add({
        'productId': product.id,
        'name': product.name,
        'quantity': entry.value,
        'unitPrice': product.price,
        'lineTotal': lineTotal,
      });
    }
    final discount = _discountFor(subtotal, '${body['offerCode'] ?? ''}');
    final deliveryFee = _deliveryFeeFor(slot, subtotal, fulfilmentMode);
    final payable = max(0, subtotal - discount + deliveryFee);
    return ApiResponse(200, {
      'lines': lines,
      'subtotal': subtotal,
      'discount': discount,
      'deliveryFee': deliveryFee,
      'payable': payable,
      'currency': 'INR',
      'fulfilmentMode': fulfilmentMode,
      'slot': slot,
    });
  }

  int _discountFor(int subtotal, String offerCode) {
    if (offerCode == 'WEEKLY100' && subtotal >= 999) return 100;
    if (offerCode == 'MONTHLY250' && subtotal >= 2499) return 250;
    if (offerCode == 'LOYAL50' && subtotal >= 499) return 50;
    return 0;
  }

  int _deliveryFeeFor(String slot, int subtotal, String fulfilmentMode) {
    if (fulfilmentMode == 'Store pickup' || subtotal >= 999) return 0;
    if (slot == 'Tomorrow 8 AM - 10 AM') return 19;
    if (slot == 'Sunday weekly delivery') return 0;
    return 29;
  }
}

class OrderCreationApi {
  OrderCreationApi({required this.inventory, required this.pricing});

  final InventoryService inventory;
  final PricingOfferEngine pricing;
  final Map<String, Map<String, Object?>> orders = {};

  ApiResponse create(Map<String, Object?> body) {
    final orderId = _nextId('ORD');
    final quote = pricing.quote(body);
    if (!quote.ok) return quote;
    final reservation = inventory.reserve({
      'orderId': orderId,
      'items': body['items'],
    });
    if (!reservation.ok) return reservation;
    final order = {
      'orderId': orderId,
      'customerId': body['customerId'] ?? 'guest',
      'status': 'Received',
      'quote': quote.body,
      'reservation': reservation.body,
      'deliveryAddress': body['deliveryAddress'] ?? {},
      'paymentMethod': body['paymentMethod'] ?? 'UPI',
      'createdAt': DateTime.now().toIso8601String(),
    };
    orders[orderId] = order;
    return ApiResponse(201, {'order': order});
  }

  ApiResponse updateStatus(String orderId, String status) {
    final order = orders[orderId];
    if (order == null) {
      return const ApiResponse(404, {'error': 'ORDER_NOT_FOUND'});
    }
    order['status'] = status;
    order['updatedAt'] = DateTime.now().toIso8601String();
    return ApiResponse(200, {'order': order});
  }
}

class PaymentGatewayBackend {
  final Map<String, Map<String, Object?>> attempts = {};
  final Map<String, Map<String, Object?>> refunds = {};

  ApiResponse createAttempt(Map<String, Object?> body) {
    final paymentId = _nextId('PAY');
    final amount = body['amount'] ?? body['payable'] ?? 0;
    final attempt = {
      'paymentId': paymentId,
      'orderId': body['orderId'],
      'amount': amount,
      'gateway': body['gateway'] ?? 'razorpay',
      'status': 'created',
      'upiIntent': 'upi://pay?pa=chandrastores@upi&am=$amount&cu=INR',
    };
    attempts[paymentId] = attempt;
    return ApiResponse(201, {'payment': attempt});
  }

  ApiResponse webhook(Map<String, Object?> body) {
    final paymentId = '${body['paymentId'] ?? ''}';
    final attempt = attempts[paymentId];
    if (attempt == null) {
      return const ApiResponse(404, {'error': 'PAYMENT_NOT_FOUND'});
    }
    attempt['status'] = body['status'] ?? 'captured';
    attempt['gatewayReference'] = body['gatewayReference'] ?? _nextId('GWR');
    return ApiResponse(200, {'payment': attempt});
  }

  ApiResponse refund(Map<String, Object?> body) {
    final paymentId = '${body['paymentId'] ?? ''}';
    final attempt = attempts[paymentId];
    if (attempt == null) {
      return const ApiResponse(404, {'error': 'PAYMENT_NOT_FOUND'});
    }
    final refundId = _nextId('RFD');
    final refund = {
      'refundId': refundId,
      'paymentId': paymentId,
      'amount': body['amount'] ?? attempt['amount'],
      'status': 'initiated',
      'reason': body['reason'] ?? 'customer_request',
    };
    refunds[refundId] = refund;
    attempt['status'] = 'refund_initiated';
    return ApiResponse(202, {'refund': refund, 'payment': attempt});
  }
}

class WhatsAppBusinessBackend {
  final List<Map<String, Object?>> outbox = [];

  ApiResponse sendTemplate(Map<String, Object?> body) {
    final message = {
      'messageId': _nextId('WAM'),
      'to': body['to'],
      'template': body['template'] ?? 'order_update',
      'parameters': body['parameters'] ?? {},
      'status': 'queued',
    };
    outbox.add(message);
    return ApiResponse(202, {'message': message});
  }

  ApiResponse sendTransactional(Map<String, Object?> body) {
    final event = '${body['event'] ?? 'order_received'}';
    final template = {
          'order_received': 'order_received_v1',
          'payment_captured': 'payment_success_v1',
          'pickup_ready': 'pickup_ready_v1',
          'out_for_delivery': 'out_for_delivery_v1',
          'invoice_ready': 'invoice_ready_v1',
        }[event] ??
        'order_update_v1';
    return sendTemplate({...body, 'template': template});
  }
}

class DeliverySlotService {
  final List<Map<String, Object?>> slots = [
    {
      'slotId': 'today_18_20',
      'label': 'Today 6 PM - 8 PM',
      'capacity': 40,
      'booked': 0,
    },
    {
      'slotId': 'tomorrow_08_10',
      'label': 'Tomorrow 8 AM - 10 AM',
      'capacity': 35,
      'booked': 0,
    },
    {
      'slotId': 'sunday_weekly',
      'label': 'Sunday weekly delivery',
      'capacity': 80,
      'booked': 0,
    },
    {
      'slotId': 'pickup_counter',
      'label': 'Store pickup counter',
      'capacity': 120,
      'booked': 0,
    },
  ];

  ApiResponse available({String fulfilmentMode = 'Home delivery'}) {
    final filtered = slots.where((slot) {
      final label = '${slot['label']}';
      if (fulfilmentMode == 'Store pickup') return label.contains('pickup');
      return !label.contains('pickup');
    }).map((slot) {
      final capacity = slot['capacity'] as int;
      final booked = slot['booked'] as int;
      return {...slot, 'available': capacity - booked};
    }).toList();
    return ApiResponse(200, {'slots': filtered});
  }
}

class InvoiceService {
  final Map<String, Map<String, Object?>> invoices = {};

  ApiResponse generate(Map<String, Object?> body) {
    final invoiceId = _nextId('INV');
    final invoice = {
      'invoiceId': invoiceId,
      'orderId': body['orderId'],
      'type': body['type'] ?? 'Retail bill',
      'billingName': body['billingName'] ?? 'Customer',
      'status': 'generated',
      'downloadUrl':
          'https://api.chandrastores.example/invoices/$invoiceId.pdf',
    };
    invoices[invoiceId] = invoice;
    return ApiResponse(201, {'invoice': invoice});
  }
}

class NotificationService {
  final List<Map<String, Object?>> notifications = [];

  ApiResponse enqueue(Map<String, Object?> body) {
    final notification = {
      'notificationId': _nextId('NTF'),
      'customerId': body['customerId'],
      'channel': body['channel'] ?? 'push',
      'title': body['title'] ?? 'Smart Kirana update',
      'message': body['message'] ?? '',
      'status': 'queued',
    };
    notifications.add(notification);
    return ApiResponse(202, {'notification': notification});
  }
}

class AdminDashboardService {
  AdminDashboardService({required this.orders, required this.products});

  final OrderCreationApi orders;
  final Map<String, ProductRecord> products;

  ApiResponse summary() {
    final lowStock = products.values
        .where((product) => product.stockQty <= product.reorderLevel)
        .length;
    final totalRevenue = orders.orders.values.fold<int>(0, (sum, order) {
      final quote = order['quote'] as Map<String, Object?>;
      return sum + (quote['payable'] as int);
    });
    return ApiResponse(200, {
      'ordersToday': orders.orders.length,
      'revenueToday': totalRevenue,
      'lowStockProducts': lowStock,
      'openOrders': orders.orders.values
          .where((order) => order['status'] != 'Delivered')
          .length,
    });
  }
}

class StaffFulfilmentService {
  StaffFulfilmentService(this.orders);

  final OrderCreationApi orders;

  ApiResponse update(String orderId, String status) =>
      orders.updateStatus(orderId, status);
}

class QrScanVerifyApi {
  QrScanVerifyApi(this.orders);

  final OrderCreationApi orders;
  final List<Map<String, Object?>> scanAudit = [];

  ApiResponse verify(Map<String, Object?> body) {
    final code = '${body['code'] ?? ''}'.toUpperCase();
    for (final order in orders.orders.values) {
      final orderId = '${order['orderId']}';
      final suffix = orderId.length <= 6
          ? orderId.padLeft(6, '0')
          : orderId.substring(orderId.length - 6);
      final fulfilmentMode =
          '${(order['quote'] as Map<String, Object?>)['fulfilmentMode']}';
      final expected =
          fulfilmentMode == 'Store pickup' ? 'PU-$suffix' : 'DL-$suffix';
      if (code == expected) {
        final audit = {
          'scanId': _nextId('SCN'),
          'orderId': orderId,
          'code': code,
          'staffId': body['staffId'] ?? 'staff-demo',
          'scannedAt': DateTime.now().toIso8601String(),
        };
        scanAudit.add(audit);
        if (body['markComplete'] == true) {
          order['status'] =
              fulfilmentMode == 'Store pickup' ? 'Picked up' : 'Delivered';
        }
        return ApiResponse(200, {
          'valid': true,
          'orderId': orderId,
          'fulfilmentMode': fulfilmentMode,
          'status': order['status'],
          'audit': audit,
        });
      }
    }
    return const ApiResponse(404, {'valid': false, 'error': 'CODE_NOT_FOUND'});
  }
}

class QrDownloadService {
  ApiResponse appDownloadQr({String channel = 'counter'}) => ApiResponse(200, {
        'landingUrl': 'https://chandrastores.example/app?channel=$channel',
        'qrPayload': 'smartkirana://download?channel=$channel',
        'playStoreUrl':
            'https://play.google.com/store/apps/details?id=com.chandrastores.smartkirana',
        'appStoreUrl':
            'https://apps.apple.com/app/smart-kirana-chandra-stores/id0000000000',
      });
}

class RewardWalletService {
  final Map<String, Map<String, Object?>> wallets = {};
  final List<Map<String, Object?>> ledger = [];

  Map<String, Object?> _wallet(String customerId) => wallets.putIfAbsent(
        customerId,
        () => {
          'customerId': customerId,
          'points': 420,
          'storeCreditLimit': 5000,
          'storeCreditUsed': 1250,
        },
      );

  ApiResponse summary(String customerId) =>
      ApiResponse(200, {'wallet': _wallet(customerId)});

  ApiResponse credit(Map<String, Object?> body) {
    final customerId = '${body['customerId'] ?? 'guest'}';
    final points = (body['points'] as num? ?? 0).toInt();
    final wallet = _wallet(customerId);
    wallet['points'] = (wallet['points'] as int) + points;
    final entry = {
      'ledgerId': _nextId('RWD'),
      'customerId': customerId,
      'type': 'credit',
      'points': points,
      'reason': body['reason'] ?? 'order_reward',
    };
    ledger.add(entry);
    return ApiResponse(201, {'wallet': wallet, 'ledger': entry});
  }

  ApiResponse redeem(Map<String, Object?> body) {
    final customerId = '${body['customerId'] ?? 'guest'}';
    final points = (body['points'] as num? ?? 0).toInt();
    final wallet = _wallet(customerId);
    final available = wallet['points'] as int;
    if (available < points) {
      return ApiResponse(409, {
        'error': 'INSUFFICIENT_REWARD_POINTS',
        'available': available,
      });
    }
    wallet['points'] = available - points;
    final voucher = {
      'voucherId': _nextId('VCH'),
      'customerId': customerId,
      'pointsDebited': points,
      'discount': body['discount'] ?? 0,
      'status': 'issued',
    };
    ledger.add({...voucher, 'type': 'debit'});
    return ApiResponse(201, {'wallet': wallet, 'voucher': voucher});
  }
}

class SupportTicketBackend {
  final Map<String, Map<String, Object?>> tickets = {};

  ApiResponse create(Map<String, Object?> body) {
    final ticketId = _nextId('TKT');
    final priority = '${body['priority'] ?? 'Medium'}';
    final ticket = {
      'ticketId': ticketId,
      'orderId': body['orderId'],
      'customerId': body['customerId'],
      'issueType': body['issueType'] ?? 'General support',
      'priority': priority,
      'description': body['description'] ?? '',
      'status': 'Open',
      'slaHours': priority == 'High' ? 4 : 24,
      'createdAt': DateTime.now().toIso8601String(),
    };
    tickets[ticketId] = ticket;
    return ApiResponse(201, {'ticket': ticket});
  }

  ApiResponse update(String ticketId, Map<String, Object?> body) {
    final ticket = tickets[ticketId];
    if (ticket == null) {
      return const ApiResponse(404, {'error': 'TICKET_NOT_FOUND'});
    }
    ticket['status'] = body['status'] ?? ticket['status'];
    ticket['resolution'] = body['resolution'] ?? ticket['resolution'];
    ticket['updatedAt'] = DateTime.now().toIso8601String();
    return ApiResponse(200, {'ticket': ticket});
  }
}

class DeliveryTrackingService {
  final Map<String, List<Map<String, Object?>>> timelines = {};

  ApiResponse addEvent(Map<String, Object?> body) {
    final orderId = '${body['orderId'] ?? ''}';
    final event = {
      'eventId': _nextId('TRK'),
      'orderId': orderId,
      'status': body['status'] ?? 'Received',
      'note': body['note'] ?? '',
      'actor': body['actor'] ?? 'system',
      'createdAt': DateTime.now().toIso8601String(),
    };
    timelines.putIfAbsent(orderId, () => []).add(event);
    return ApiResponse(201, {'event': event, 'timeline': timelines[orderId]});
  }

  ApiResponse timeline(String orderId) => ApiResponse(200, {
        'orderId': orderId,
        'timeline': timelines[orderId] ?? [],
      });
}

class RecurringPlanService {
  final Map<String, Map<String, Object?>> plans = {};

  ApiResponse create(Map<String, Object?> body) {
    final planId = _nextId('PLAN');
    final frequency = '${body['frequency'] ?? 'Weekly'}';
    final plan = {
      'planId': planId,
      'customerId': body['customerId'] ?? 'guest',
      'frequency': frequency,
      'items': body['items'] ?? {},
      'status': 'active',
      'nextRunAt': _nextRunAt(frequency).toIso8601String(),
      'reminderChannel': body['reminderChannel'] ?? 'whatsapp',
    };
    plans[planId] = plan;
    return ApiResponse(201, {'plan': plan});
  }

  ApiResponse pause(String planId) {
    final plan = plans[planId];
    if (plan == null) {
      return const ApiResponse(404, {'error': 'PLAN_NOT_FOUND'});
    }
    plan['status'] = 'paused';
    return ApiResponse(200, {'plan': plan});
  }

  ApiResponse due() {
    final active =
        plans.values.where((plan) => plan['status'] == 'active').toList();
    return ApiResponse(200, {'plans': active});
  }

  DateTime _nextRunAt(String frequency) {
    final now = DateTime.now();
    if (frequency == 'Biweekly') return now.add(const Duration(days: 14));
    if (frequency == 'Monthly') return now.add(const Duration(days: 30));
    return now.add(const Duration(days: 7));
  }
}

class SmartKiranaBackend {
  SmartKiranaBackend.seeded()
      : products = _seedProducts(),
        customerApi = CustomerApi() {
    catalogueApi = CatalogueApi(products);
    inventoryService = InventoryService(products);
    pricingOfferEngine = PricingOfferEngine(products);
    orderCreationApi = OrderCreationApi(
      inventory: inventoryService,
      pricing: pricingOfferEngine,
    );
    paymentGatewayBackend = PaymentGatewayBackend();
    whatsAppBusinessBackend = WhatsAppBusinessBackend();
    deliverySlotService = DeliverySlotService();
    invoiceService = InvoiceService();
    notificationService = NotificationService();
    adminDashboardService = AdminDashboardService(
      orders: orderCreationApi,
      products: products,
    );
    staffFulfilmentService = StaffFulfilmentService(orderCreationApi);
    qrScanVerifyApi = QrScanVerifyApi(orderCreationApi);
    qrDownloadService = QrDownloadService();
    rewardWalletService = RewardWalletService();
    supportTicketBackend = SupportTicketBackend();
    deliveryTrackingService = DeliveryTrackingService();
    recurringPlanService = RecurringPlanService();
  }

  final Map<String, ProductRecord> products;
  final CustomerApi customerApi;
  late final CatalogueApi catalogueApi;
  late final InventoryService inventoryService;
  late final PricingOfferEngine pricingOfferEngine;
  late final OrderCreationApi orderCreationApi;
  late final PaymentGatewayBackend paymentGatewayBackend;
  late final WhatsAppBusinessBackend whatsAppBusinessBackend;
  late final DeliverySlotService deliverySlotService;
  late final InvoiceService invoiceService;
  late final NotificationService notificationService;
  late final AdminDashboardService adminDashboardService;
  late final StaffFulfilmentService staffFulfilmentService;
  late final QrScanVerifyApi qrScanVerifyApi;
  late final QrDownloadService qrDownloadService;
  late final RewardWalletService rewardWalletService;
  late final SupportTicketBackend supportTicketBackend;
  late final DeliveryTrackingService deliveryTrackingService;
  late final RecurringPlanService recurringPlanService;

  ApiResponse handle(BackendRequest request) {
    final method = request.method.toUpperCase();
    final segments =
        request.path.split('/').where((segment) => segment.isNotEmpty).toList();
    if (method == 'POST' && request.path == '/customers/login/start') {
      return customerApi.startOtp(request.body);
    }
    if (method == 'POST' && request.path == '/customers/login/verify') {
      return customerApi.verifyOtp(request.body);
    }
    if (method == 'GET' && request.path == '/catalogue/products') {
      return catalogueApi.list();
    }
    if (method == 'GET' &&
        segments.length == 3 &&
        segments[0] == 'catalogue' &&
        segments[1] == 'products') {
      return catalogueApi.getById(segments[2]);
    }
    if (method == 'POST' && request.path == '/inventory/reserve') {
      return inventoryService.reserve(request.body);
    }
    if (method == 'POST' && request.path == '/pricing/quote') {
      return pricingOfferEngine.quote(request.body);
    }
    if (method == 'POST' && request.path == '/orders') {
      return orderCreationApi.create(request.body);
    }
    if (method == 'POST' && request.path == '/payments/create') {
      return paymentGatewayBackend.createAttempt(request.body);
    }
    if (method == 'POST' && request.path == '/payments/webhook') {
      return paymentGatewayBackend.webhook(request.body);
    }
    if (method == 'POST' && request.path == '/whatsapp/send') {
      return whatsAppBusinessBackend.sendTemplate(request.body);
    }
    if (method == 'GET' && request.path == '/delivery-slots') {
      return deliverySlotService.available();
    }
    if (method == 'POST' && request.path == '/invoices') {
      return invoiceService.generate(request.body);
    }
    if (method == 'POST' && request.path == '/notifications') {
      return notificationService.enqueue(request.body);
    }
    if (method == 'GET' && request.path == '/admin/dashboard') {
      return adminDashboardService.summary();
    }
    if (method == 'POST' &&
        segments.length == 4 &&
        segments[0] == 'staff' &&
        segments[1] == 'orders' &&
        segments[3] == 'status') {
      return staffFulfilmentService.update(
        segments[2],
        '${request.body['status'] ?? 'Packing'}',
      );
    }
    if (method == 'POST' && request.path == '/qr/verify') {
      return qrScanVerifyApi.verify(request.body);
    }
    if (method == 'GET' && request.path == '/qr/app-download') {
      return qrDownloadService.appDownloadQr(
        channel: request.headers['x-channel'] ?? 'counter',
      );
    }
    if (method == 'POST' && request.path == '/payments/refund') {
      return paymentGatewayBackend.refund(request.body);
    }
    if (method == 'POST' && request.path == '/whatsapp/transactional') {
      return whatsAppBusinessBackend.sendTransactional(request.body);
    }
    if (method == 'GET' &&
        segments.length == 3 &&
        segments[0] == 'wallet' &&
        segments[2] == 'summary') {
      return rewardWalletService.summary(segments[1]);
    }
    if (method == 'POST' && request.path == '/wallet/rewards/credit') {
      return rewardWalletService.credit(request.body);
    }
    if (method == 'POST' && request.path == '/wallet/rewards/redeem') {
      return rewardWalletService.redeem(request.body);
    }
    if (method == 'POST' && request.path == '/support/tickets') {
      return supportTicketBackend.create(request.body);
    }
    if (method == 'POST' &&
        segments.length == 3 &&
        segments[0] == 'support' &&
        segments[1] == 'tickets') {
      return supportTicketBackend.update(segments[2], request.body);
    }
    if (method == 'POST' && request.path == '/tracking/events') {
      return deliveryTrackingService.addEvent(request.body);
    }
    if (method == 'GET' &&
        segments.length == 3 &&
        segments[0] == 'tracking' &&
        segments[2] == 'timeline') {
      return deliveryTrackingService.timeline(segments[1]);
    }
    if (method == 'POST' && request.path == '/recurring-plans') {
      return recurringPlanService.create(request.body);
    }
    if (method == 'POST' &&
        segments.length == 3 &&
        segments[0] == 'recurring-plans' &&
        segments[2] == 'pause') {
      return recurringPlanService.pause(segments[1]);
    }
    if (method == 'GET' && request.path == '/recurring-plans/due') {
      return recurringPlanService.due();
    }
    return const ApiResponse(404, {'error': 'ROUTE_NOT_FOUND'});
  }
}

Map<String, ProductRecord> _seedProducts() => {
      'rice_sona_5kg': const ProductRecord(
        id: 'rice_sona_5kg',
        name: 'Sona Masoori Rice',
        category: 'Staples',
        packSize: '5 kg',
        price: 420,
        mrp: 465,
        stockQty: 120,
        reorderLevel: 20,
      ),
      'oil_groundnut_1l': const ProductRecord(
        id: 'oil_groundnut_1l',
        name: 'Groundnut Oil',
        category: 'Oils',
        packSize: '1 L',
        price: 185,
        mrp: 210,
        stockQty: 80,
        reorderLevel: 15,
      ),
      'milk_toned_1l': const ProductRecord(
        id: 'milk_toned_1l',
        name: 'Toned Milk',
        category: 'Dairy',
        packSize: '1 L',
        price: 62,
        mrp: 64,
        stockQty: 45,
        reorderLevel: 25,
      ),
    };

Map<String, int> _decodeItems(Object? raw) {
  if (raw is Map) {
    return raw.map((key, value) => MapEntry('$key', (value as num).toInt()));
  }
  if (raw is List) {
    return {
      for (final item in raw.whereType<Map>())
        '${item['productId']}': (item['quantity'] as num).toInt(),
    };
  }
  return const {};
}

String _nextId(String prefix) =>
    '$prefix${DateTime.now().microsecondsSinceEpoch}';
