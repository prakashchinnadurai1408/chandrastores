import 'dart:convert';
import 'dart:math';

class SmartKiranaBackendConfig {
  SmartKiranaBackendConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.appDownloadUrl,
    required this.storeUpiId,
    required this.paymentGateway,
    required this.whatsAppProvider,
    required this.jwtIssuer,
    this.whatsAppPhoneNumberId = '',
    this.whatsAppTemplateNamespace = '',
    this.razorpayKeyId = '',
    this.cashfreeClientId = '',
    this.paymentWebhookSecretConfigured = false,
    this.settlementCron = '0 22 * * *',
    this.databaseUrlConfigured = false,
    this.storageProvider = 'in-memory-uAT',
    this.jwtAudience = 'smart-kirana-users',
    this.jwtSecretConfigured = false,
    this.androidPackageId = 'com.chandrastores.smartkirana',
    this.iosBundleId = 'in.chandrastores.smartkirana',
    this.playStoreUrl =
        'https://play.google.com/store/apps/details?id=com.chandrastores.smartkirana',
    this.appStoreUrl =
        'https://apps.apple.com/app/smart-kirana-chandra-stores/id0000000000',
    this.demoMode = false,
    this.requireWebhookSignature = true,
  });

  factory SmartKiranaBackendConfig.demo() => SmartKiranaBackendConfig(
        environment: 'demo',
        apiBaseUrl: 'https://api.chandrastores.example',
        appDownloadUrl: 'https://chandrastores.example/app',
        storeUpiId: 'chandrastores@upi',
        paymentGateway: 'razorpay',
        whatsAppProvider: 'meta-whatsapp-business',
        jwtIssuer: 'smart-kirana-demo',
        demoMode: true,
        requireWebhookSignature: false,
      );

  factory SmartKiranaBackendConfig.production({
    required String apiBaseUrl,
    required String appDownloadUrl,
    required String storeUpiId,
    String paymentGateway = 'razorpay',
    String whatsAppProvider = 'meta-whatsapp-business',
    String jwtIssuer = 'smart-kirana',
  }) =>
      SmartKiranaBackendConfig(
        environment: 'production',
        apiBaseUrl: apiBaseUrl,
        appDownloadUrl: appDownloadUrl,
        storeUpiId: storeUpiId,
        paymentGateway: paymentGateway,
        whatsAppProvider: whatsAppProvider,
        jwtIssuer: jwtIssuer,
      );

  String environment;
  String apiBaseUrl;
  String appDownloadUrl;
  String storeUpiId;
  String paymentGateway;
  String whatsAppProvider;
  String jwtIssuer;
  String whatsAppPhoneNumberId;
  String whatsAppTemplateNamespace;
  String razorpayKeyId;
  String cashfreeClientId;
  bool paymentWebhookSecretConfigured;
  String settlementCron;
  bool databaseUrlConfigured;
  String storageProvider;
  String jwtAudience;
  bool jwtSecretConfigured;
  String androidPackageId;
  String iosBundleId;
  String playStoreUrl;
  String appStoreUrl;
  final bool demoMode;
  bool requireWebhookSignature;

  Map<String, Object?> toJson() => {
        'environment': environment,
        'apiBaseUrl': apiBaseUrl,
        'appDownloadUrl': appDownloadUrl,
        'storeUpiId': storeUpiId,
        'paymentGateway': paymentGateway,
        'whatsAppProvider': whatsAppProvider,
        'whatsAppPhoneNumberId': whatsAppPhoneNumberId,
        'whatsAppTemplateNamespace': whatsAppTemplateNamespace,
        'razorpayKeyId': _redact(razorpayKeyId),
        'cashfreeClientId': _redact(cashfreeClientId),
        'paymentWebhookSecretConfigured': paymentWebhookSecretConfigured,
        'settlementCron': settlementCron,
        'databaseUrlConfigured': databaseUrlConfigured,
        'storageProvider': storageProvider,
        'jwtIssuer': jwtIssuer,
        'jwtAudience': jwtAudience,
        'jwtSecretConfigured': jwtSecretConfigured,
        'androidPackageId': androidPackageId,
        'iosBundleId': iosBundleId,
        'playStoreUrl': playStoreUrl,
        'appStoreUrl': appStoreUrl,
        'demoMode': demoMode,
        'requireWebhookSignature': requireWebhookSignature,
      };

  void update(Map<String, Object?> body) {
    environment = _string(body, 'environment', environment);
    apiBaseUrl = _string(body, 'apiBaseUrl', apiBaseUrl);
    appDownloadUrl = _string(body, 'appDownloadUrl', appDownloadUrl);
    storeUpiId = _string(body, 'storeUpiId', storeUpiId);
    paymentGateway = _string(body, 'paymentGateway', paymentGateway);
    whatsAppProvider = _string(body, 'whatsAppProvider', whatsAppProvider);
    whatsAppPhoneNumberId = _string(
      body,
      'whatsAppPhoneNumberId',
      whatsAppPhoneNumberId,
    );
    whatsAppTemplateNamespace = _string(
      body,
      'whatsAppTemplateNamespace',
      whatsAppTemplateNamespace,
    );
    razorpayKeyId = _string(body, 'razorpayKeyId', razorpayKeyId);
    cashfreeClientId = _string(body, 'cashfreeClientId', cashfreeClientId);
    paymentWebhookSecretConfigured = _bool(
      body,
      'paymentWebhookSecretConfigured',
      paymentWebhookSecretConfigured,
    );
    settlementCron = _string(body, 'settlementCron', settlementCron);
    databaseUrlConfigured = _bool(
      body,
      'databaseUrlConfigured',
      databaseUrlConfigured,
    );
    storageProvider = _string(body, 'storageProvider', storageProvider);
    jwtIssuer = _string(body, 'jwtIssuer', jwtIssuer);
    jwtAudience = _string(body, 'jwtAudience', jwtAudience);
    jwtSecretConfigured = _bool(
      body,
      'jwtSecretConfigured',
      jwtSecretConfigured,
    );
    androidPackageId = _string(body, 'androidPackageId', androidPackageId);
    iosBundleId = _string(body, 'iosBundleId', iosBundleId);
    playStoreUrl = _string(body, 'playStoreUrl', playStoreUrl);
    appStoreUrl = _string(body, 'appStoreUrl', appStoreUrl);
    requireWebhookSignature = _bool(
      body,
      'requireWebhookSignature',
      requireWebhookSignature,
    );
  }

  List<String> validate() {
    final issues = <String>[];
    final httpsUrl = RegExp(r'^https://');
    if (!demoMode && !httpsUrl.hasMatch(apiBaseUrl)) {
      issues.add('API_BASE_URL must be HTTPS in production.');
    }
    if (!demoMode && !httpsUrl.hasMatch(appDownloadUrl)) {
      issues.add('APP_DOWNLOAD_URL must be HTTPS in production.');
    }
    if (!RegExp(r'^[\w.\-]+@[\w.\-]+$').hasMatch(storeUpiId)) {
      issues.add('STORE_UPI_ID must be a valid UPI VPA.');
    }
    if (paymentGateway.trim().isEmpty) {
      issues.add('PAYMENT_GATEWAY is required.');
    }
    if (whatsAppProvider.trim().isEmpty) {
      issues.add('WHATSAPP_PROVIDER is required.');
    }
    if (jwtIssuer.trim().isEmpty) {
      issues.add('JWT_ISSUER is required.');
    }
    if (!demoMode &&
        requireWebhookSignature &&
        !paymentWebhookSecretConfigured) {
      issues.add('PAYMENT_WEBHOOK_SECRET must be configured in production.');
    }
    if (!demoMode && !databaseUrlConfigured) {
      issues.add('DATABASE_URL must be configured for production storage.');
    }
    if (!demoMode && !jwtSecretConfigured) {
      issues.add('JWT_SECRET must be configured for production auth.');
    }
    return issues;
  }

  static String _string(
    Map<String, Object?> body,
    String key,
    String fallback,
  ) {
    final value = body[key];
    if (value == null) return fallback;
    return '$value'.trim();
  }

  static bool _bool(Map<String, Object?> body, String key, bool fallback) {
    final value = body[key];
    if (value == null) return fallback;
    if (value is bool) return value;
    return '$value'.toLowerCase() == 'true';
  }

  static String _redact(String value) {
    if (value.isEmpty) return '';
    if (value.length <= 4) return '****';
    return '****${value.substring(value.length - 4)}';
  }
}

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

  ProductRecord copyWith({
    String? name,
    String? category,
    String? packSize,
    int? price,
    int? mrp,
    int? stockQty,
    int? reorderLevel,
    bool? active,
  }) =>
      ProductRecord(
        id: id,
        name: name ?? this.name,
        category: category ?? this.category,
        packSize: packSize ?? this.packSize,
        price: price ?? this.price,
        mrp: mrp ?? this.mrp,
        stockQty: stockQty ?? this.stockQty,
        reorderLevel: reorderLevel ?? this.reorderLevel,
        active: active ?? this.active,
      );

  factory ProductRecord.fromJson(Map<String, Object?> json) => ProductRecord(
        id: '${json['id']}',
        name: '${json['name']}',
        category: '${json['category']}',
        packSize: '${json['packSize']}',
        price: _int(json['price']),
        mrp: _int(json['mrp']),
        stockQty: _int(json['stockQty']),
        reorderLevel: _int(json['reorderLevel']),
        active: json['active'] is bool ? json['active']! as bool : true,
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
  CustomerApi(
      {required this.config, required this.whatsApp, required this.auth});

  final SmartKiranaBackendConfig config;
  final WhatsAppBusinessBackend whatsApp;
  final AuthTokenService auth;
  final Map<String, Map<String, Object?>> _customersByMobile = {};
  final Map<String, String> _otpByRequestId = {};
  int _sequence = 1000;

  List<Map<String, Object?>> get customers =>
      _customersByMobile.values.toList();

  ApiResponse startOtp(Map<String, Object?> body) {
    final mobile = '${body['mobile'] ?? ''}'.trim();
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(mobile)) {
      return const ApiResponse(400, {'error': 'VALID_MOBILE_REQUIRED'});
    }
    final requestId = 'OTP${_sequence++}';
    final otp = config.demoMode ? '123456' : _generateOtp();
    _otpByRequestId[requestId] = otp;
    _customersByMobile.putIfAbsent(
      mobile,
      () => {
        'customerId': 'CUS$mobile',
        'mobile': mobile,
        'name': 'Smart Kirana Customer',
        'segment': 'regular',
      },
    );
    whatsApp.sendTemplate({
      'to': '91$mobile',
      'template': 'login_otp',
      'parameters': {
        'requestId': requestId,
        if (config.demoMode) 'otp': otp,
      },
    });
    return ApiResponse(202, {
      'requestId': requestId,
      'channel': 'whatsapp',
      'template': 'login_otp',
      'deliveryStatus': 'queued',
      if (config.demoMode) 'otp': otp,
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
    final customer = _customersByMobile[mobile];
    return ApiResponse(200, {
      'token': auth.issueToken(
        subject: '${customer?['customerId'] ?? 'guest'}',
        role: 'customer',
      ),
      'customer': customer,
    });
  }

  String _generateOtp() {
    final value = Random.secure().nextInt(900000) + 100000;
    return '$value';
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

  ApiResponse upsert(Map<String, Object?> body) {
    final productId = '${body['id'] ?? body['productId'] ?? ''}'.trim();
    if (productId.isEmpty) {
      return const ApiResponse(400, {'error': 'PRODUCT_ID_REQUIRED'});
    }
    final current = _products[productId];
    final record = current == null
        ? ProductRecord.fromJson({...body, 'id': productId})
        : current.copyWith(
            name: body['name'] == null ? null : '${body['name']}',
            category: body['category'] == null ? null : '${body['category']}',
            packSize: body['packSize'] == null ? null : '${body['packSize']}',
            price: body['price'] == null ? null : _int(body['price']),
            mrp: body['mrp'] == null ? null : _int(body['mrp']),
            stockQty: body['stockQty'] == null ? null : _int(body['stockQty']),
            reorderLevel: body['reorderLevel'] == null
                ? null
                : _int(body['reorderLevel']),
            active: body['active'] is bool ? body['active']! as bool : null,
          );
    _products[productId] = record;
    return ApiResponse(
        current == null ? 201 : 200, {'product': record.toJson()});
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
  PaymentGatewayBackend(this.config);

  final SmartKiranaBackendConfig config;
  final Map<String, Map<String, Object?>> attempts = {};
  final Map<String, Map<String, Object?>> refunds = {};

  ApiResponse createAttempt(Map<String, Object?> body) {
    final paymentId = _nextId('PAY');
    final amount = body['amount'] ?? body['payable'] ?? 0;
    final attempt = {
      'paymentId': paymentId,
      'orderId': body['orderId'],
      'amount': amount,
      'gateway': body['gateway'] ?? config.paymentGateway,
      'gatewayMode': config.paymentGateway == 'cashfree'
          ? 'cashfree_orders'
          : 'razorpay_standard_checkout',
      'gatewayCredentialConfigured': config.paymentGateway == 'cashfree'
          ? config.cashfreeClientId.isNotEmpty
          : config.razorpayKeyId.isNotEmpty,
      'status': 'created',
      'upiIntent': 'upi://pay?pa=${config.storeUpiId}&am=$amount&cu=INR',
      'webhookRequired': config.requireWebhookSignature,
      'webhookSecretConfigured': config.paymentWebhookSecretConfigured,
      'settlementCron': config.settlementCron,
    };
    attempts[paymentId] = attempt;
    return ApiResponse(201, {'payment': attempt});
  }

  ApiResponse webhook(Map<String, Object?> body) {
    if (config.requireWebhookSignature &&
        '${body['signature'] ?? ''}'.trim().isEmpty) {
      return const ApiResponse(401, {'error': 'WEBHOOK_SIGNATURE_REQUIRED'});
    }
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
  WhatsAppBusinessBackend(this.config);

  final SmartKiranaBackendConfig config;
  final List<Map<String, Object?>> outbox = [];

  ApiResponse sendTemplate(Map<String, Object?> body) {
    final message = {
      'messageId': _nextId('WAM'),
      'to': body['to'],
      'template': body['template'] ?? 'order_update',
      'parameters': body['parameters'] ?? {},
      'provider': config.whatsAppProvider,
      'phoneNumberId': config.whatsAppPhoneNumberId,
      'templateNamespace': config.whatsAppTemplateNamespace,
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
  InvoiceService(this.config);

  final SmartKiranaBackendConfig config;
  final Map<String, Map<String, Object?>> invoices = {};

  ApiResponse generate(Map<String, Object?> body) {
    final invoiceId = _nextId('INV');
    final invoice = {
      'invoiceId': invoiceId,
      'orderId': body['orderId'],
      'type': body['type'] ?? 'Retail bill',
      'billingName': body['billingName'] ?? 'Customer',
      'status': 'generated',
      'downloadUrl': '${config.apiBaseUrl}/invoices/$invoiceId.pdf',
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

class StoreAlertService {
  StoreAlertService({
    required this.orders,
    required this.products,
    required this.payments,
    required this.whatsApp,
    required this.support,
    required this.notifications,
  });

  final OrderCreationApi orders;
  final Map<String, ProductRecord> products;
  final PaymentGatewayBackend payments;
  final WhatsAppBusinessBackend whatsApp;
  final SupportTicketBackend support;
  final NotificationService notifications;
  final Map<String, Map<String, Object?>> alertStates = {};

  Map<String, Object?> _stateFor(String alertId) =>
      alertStates[alertId] ?? {'status': 'open'};

  Map<String, Object?> _mergeState(Map<String, Object?> alert) => {
        ...alert,
        ..._stateFor('${alert['alertId']}'),
      };

  ApiResponse evaluate() {
    final alerts = <Map<String, Object?>>[];
    for (final product in products.values) {
      if (product.stockQty <= product.reorderLevel) {
        alerts.add({
          'alertId': 'LOW_STOCK_${product.id}',
          'type': 'low_stock',
          'severity': product.stockQty == 0 ? 'critical' : 'warning',
          'title': '${product.name} below reorder level',
          'message':
              '${product.stockQty} ${product.packSize} units left; reorder level is ${product.reorderLevel}.',
          'productId': product.id,
        });
      }
    }
    for (final payment in payments.attempts.values) {
      if (payment['status'] == 'failed' ||
          payment['status'] == 'refund_initiated') {
        alerts.add({
          'alertId': 'PAYMENT_${payment['paymentId']}',
          'type': 'payment_attention',
          'severity': payment['status'] == 'failed' ? 'critical' : 'warning',
          'title': 'Payment ${payment['status']}',
          'message':
              'Review payment ${payment['paymentId']} for order ${payment['orderId']}.',
          'paymentId': payment['paymentId'],
        });
      }
    }
    for (final message in whatsApp.outbox) {
      if (message['status'] == 'failed') {
        alerts.add({
          'alertId': 'WA_${message['messageId']}',
          'type': 'whatsapp_failed',
          'severity': 'warning',
          'title': 'WhatsApp template failed',
          'message':
              'Template ${message['template']} to ${message['to']} needs retry.',
          'messageId': message['messageId'],
        });
      }
    }
    for (final ticket in support.tickets.values) {
      if (ticket['status'] != 'Closed' && ticket['priority'] == 'High') {
        alerts.add({
          'alertId': 'TICKET_${ticket['ticketId']}',
          'type': 'support_sla',
          'severity': 'critical',
          'title': 'High priority support open',
          'message':
              'Ticket ${ticket['ticketId']} for order ${ticket['orderId']} has ${ticket['slaHours']} hour SLA.',
          'ticketId': ticket['ticketId'],
        });
      }
    }
    for (final order in orders.orders.values) {
      if (!{'Delivered', 'Picked up', 'Cancelled'}.contains(order['status'])) {
        alerts.add({
          'alertId': 'ORDER_${order['orderId']}',
          'type': 'open_order',
          'severity': 'info',
          'title': 'Open order awaiting fulfilment',
          'message':
              'Order ${order['orderId']} is currently ${order['status']}.',
          'orderId': order['orderId'],
        });
      }
    }
    final visibleAlerts = alerts
        .map(_mergeState)
        .where((alert) => alert['status'] != 'resolved')
        .toList();
    return ApiResponse(200, {
      'alerts': visibleAlerts,
      'criticalCount': visibleAlerts
          .where((alert) => alert['severity'] == 'critical')
          .length,
      'warningCount':
          visibleAlerts.where((alert) => alert['severity'] == 'warning').length,
      'acknowledgedCount': visibleAlerts
          .where((alert) => alert['status'] == 'acknowledged')
          .length,
    });
  }

  ApiResponse acknowledge(Map<String, Object?> body) {
    final alertId = '${body['alertId'] ?? ''}';
    if (alertId.isEmpty) {
      return const ApiResponse(400, {'error': 'ALERT_ID_REQUIRED'});
    }
    final state = {
      'status': 'acknowledged',
      'assignee': body['assignee'] ?? 'store-owner',
      'note': body['note'] ?? '',
      'acknowledgedAt': DateTime.now().toIso8601String(),
    };
    alertStates[alertId] = state;
    return ApiResponse(200, {'alertId': alertId, 'state': state});
  }

  ApiResponse resolve(Map<String, Object?> body) {
    final alertId = '${body['alertId'] ?? ''}';
    if (alertId.isEmpty) {
      return const ApiResponse(400, {'error': 'ALERT_ID_REQUIRED'});
    }
    final state = {
      ..._stateFor(alertId),
      'status': 'resolved',
      'resolution': body['resolution'] ?? 'Resolved by store owner',
      'resolvedAt': DateTime.now().toIso8601String(),
    };
    alertStates[alertId] = state;
    return ApiResponse(200, {'alertId': alertId, 'state': state});
  }

  ApiResponse notifyStoreOwner({String ownerId = 'STORE_OWNER'}) {
    final response = evaluate();
    final alerts = response.body['alerts']! as List<Map<String, Object?>>;
    if (alerts.isEmpty) {
      return const ApiResponse(200, {'queued': false, 'reason': 'NO_ALERTS'});
    }
    final critical = response.body['criticalCount'];
    return notifications.enqueue({
      'customerId': ownerId,
      'channel': 'admin_push',
      'title': 'Smart Kirana alerts: ${alerts.length}',
      'message': '$critical critical alerts need store review.',
    });
  }
}

class StaffFulfilmentService {
  StaffFulfilmentService(this.orders);

  final OrderCreationApi orders;
  final Map<String, Map<String, Object?>> assignments = {};

  ApiResponse queue({String? status}) {
    final orderRows = orders.orders.values
        .where((order) => !_isTerminal('${order['status']}'))
        .where((order) => status == null || '${order['status']}' == status)
        .map((order) {
      final orderId = '${order['orderId']}';
      final quote = order['quote']! as Map<String, Object?>;
      final items = quote['lines']! as List<Map<String, Object?>>;
      final assignment = assignments[orderId];
      return {
        'orderId': orderId,
        'status': order['status'],
        'customerId': order['customerId'],
        'fulfilmentMode': quote['fulfilmentMode'],
        'slot': quote['slot'],
        'payable': quote['payable'],
        'itemCount': items.length,
        'assignedTo': assignment?['staffId'],
        'assignmentStatus': assignment?['status'] ?? 'unassigned',
      };
    }).toList();
    return ApiResponse(200, {'orders': orderRows, 'count': orderRows.length});
  }

  ApiResponse assign(String orderId, Map<String, Object?> body) {
    final order = orders.orders[orderId];
    if (order == null) {
      return const ApiResponse(404, {'error': 'ORDER_NOT_FOUND'});
    }
    final assignment = {
      'assignmentId': _nextId('ASN'),
      'orderId': orderId,
      'staffId': body['staffId'] ?? 'staff-demo',
      'role': body['role'] ?? 'picker',
      'status': 'assigned',
      'assignedAt': DateTime.now().toIso8601String(),
    };
    assignments[orderId] = assignment;
    if (order['status'] == 'Received') {
      order['status'] = 'Assigned to picker';
    }
    return ApiResponse(200, {'assignment': assignment, 'order': order});
  }

  ApiResponse pack(String orderId, Map<String, Object?> body) {
    final order = orders.orders[orderId];
    if (order == null) {
      return const ApiResponse(404, {'error': 'ORDER_NOT_FOUND'});
    }
    final existingAssignment = assignments[orderId] ??
        {
          'assignmentId': _nextId('ASN'),
          'orderId': orderId,
          'staffId': body['packedBy'] ?? 'staff-demo',
          'role': 'picker',
        };
    final assignment = {
      ...existingAssignment,
      'status': 'packed',
      'packedBy': body['packedBy'] ?? body['staffId'] ?? 'staff-demo',
      'packedAt': DateTime.now().toIso8601String(),
      'bagCount': body['bagCount'] ?? 1,
    };
    assignments[orderId] = assignment;
    final quote = order['quote']! as Map<String, Object?>;
    order['status'] = quote['fulfilmentMode'] == 'Store pickup'
        ? 'Ready for pickup'
        : 'Packed';
    return ApiResponse(200, {'assignment': assignment, 'order': order});
  }

  ApiResponse update(String orderId, String status) =>
      orders.updateStatus(orderId, status);

  bool _isTerminal(String status) =>
      status == 'Delivered' || status == 'Picked up' || status == 'Cancelled';
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
  QrDownloadService(this.config);

  final SmartKiranaBackendConfig config;

  ApiResponse appDownloadQr({String channel = 'counter'}) => ApiResponse(200, {
        'landingUrl': '${config.appDownloadUrl}?channel=$channel',
        'qrPayload': 'smartkirana://download?channel=$channel',
        'playStoreUrl': config.playStoreUrl,
        'appStoreUrl': config.appStoreUrl,
        'androidPackageId': config.androidPackageId,
        'iosBundleId': config.iosBundleId,
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

class DeliveryDispatchService {
  DeliveryDispatchService({required this.orders, required this.tracking});

  final OrderCreationApi orders;
  final DeliveryTrackingService tracking;
  final Map<String, Map<String, Object?>> routes = {};

  ApiResponse plan(Map<String, Object?> body) {
    final requestedIds = body['orderIds'] is List
        ? (body['orderIds']! as List).map((id) => '$id').toSet()
        : <String>{};
    final candidates = orders.orders.values.where((order) {
      final orderId = '${order['orderId']}';
      final quote = order['quote']! as Map<String, Object?>;
      final isHomeDelivery = quote['fulfilmentMode'] == 'Home delivery';
      final isReady = order['status'] == 'Packed' ||
          order['status'] == 'Assigned to rider' ||
          order['status'] == 'Out for delivery';
      final included = requestedIds.isEmpty || requestedIds.contains(orderId);
      return included && isHomeDelivery && isReady;
    }).toList();
    if (candidates.isEmpty) {
      return const ApiResponse(422, {'error': 'NO_DELIVERY_READY_ORDERS'});
    }

    final routeId = _nextId('RTE');
    final stops = <Map<String, Object?>>[];
    for (var index = 0; index < candidates.length; index += 1) {
      final order = candidates[index];
      final quote = order['quote']! as Map<String, Object?>;
      order['status'] = 'Assigned to rider';
      stops.add({
        'sequence': index + 1,
        'orderId': order['orderId'],
        'customerId': order['customerId'],
        'slot': quote['slot'],
        'payable': quote['payable'],
        'address': order['deliveryAddress'],
        'status': 'pending_dispatch',
      });
    }

    final route = {
      'routeId': routeId,
      'riderId': body['riderId'] ?? 'RIDER-DEMO',
      'status': 'planned',
      'plannedAt': DateTime.now().toIso8601String(),
      'stopCount': stops.length,
      'stops': stops,
    };
    routes[routeId] = route;
    return ApiResponse(201, {'route': route});
  }

  ApiResponse dispatch(String routeId, Map<String, Object?> body) {
    final route = routes[routeId];
    if (route == null) {
      return const ApiResponse(404, {'error': 'ROUTE_NOT_FOUND'});
    }
    route['status'] = 'out_for_delivery';
    route['dispatchedAt'] = DateTime.now().toIso8601String();
    route['riderId'] = body['riderId'] ?? route['riderId'];
    final stops = route['stops']! as List<Map<String, Object?>>;
    for (final stop in stops) {
      stop['status'] = 'out_for_delivery';
      final orderId = '${stop['orderId']}';
      orders.orders[orderId]?['status'] = 'Out for delivery';
      tracking.addEvent({
        'orderId': orderId,
        'status': 'Out for delivery',
        'actor': route['riderId'],
        'note': 'Route $routeId dispatched',
      });
    }
    return ApiResponse(200, {'route': route});
  }

  ApiResponse list() => ApiResponse(200, {
        'routes': routes.values.toList(),
        'count': routes.length,
      });
}

class RecurringPlanService {
  RecurringPlanService({
    required this.orders,
    required this.notifications,
    required this.whatsApp,
  });

  final OrderCreationApi orders;
  final NotificationService notifications;
  final WhatsAppBusinessBackend whatsApp;
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

  ApiResponse runDue(Map<String, Object?> body) {
    final customerId = body['customerId'];
    final duePlans = plans.values.where((plan) {
      final matchesCustomer =
          customerId == null || plan['customerId'] == customerId;
      return plan['status'] == 'active' && matchesCustomer;
    }).toList();
    if (duePlans.isEmpty) {
      return const ApiResponse(200, {'runs': [], 'count': 0});
    }

    final runs = <Map<String, Object?>>[];
    for (final plan in duePlans) {
      final orderResponse = orders.create({
        'customerId': plan['customerId'],
        'items': plan['items'],
        'slot': body['slot'] ?? 'Sunday weekly delivery',
        'fulfilmentMode': body['fulfilmentMode'] ?? 'Home delivery',
        'paymentMethod': body['paymentMethod'] ?? 'UPI',
        'deliveryAddress':
            body['deliveryAddress'] ?? plan['deliveryAddress'] ?? {},
        'offerCode': body['offerCode'] ?? plan['offerCode'] ?? '',
      });
      if (!orderResponse.ok) {
        runs.add({
          'planId': plan['planId'],
          'status': 'failed',
          'error': orderResponse.body['error'],
        });
        continue;
      }
      final order = orderResponse.body['order']! as Map<String, Object?>;
      plan['lastOrderId'] = order['orderId'];
      plan['lastRunAt'] = DateTime.now().toIso8601String();
      plan['nextRunAt'] = _nextRunAt('${plan['frequency']}').toIso8601String();
      plan['runCount'] = (plan['runCount'] as int? ?? 0) + 1;
      notifications.enqueue({
        'customerId': plan['customerId'],
        'channel': 'push',
        'title': 'Recurring grocery order created',
        'message':
            'Order ${order['orderId']} was created from ${plan['frequency']} plan.',
      });
      whatsApp.sendTransactional({
        'to': body['whatsAppTo'] ?? plan['whatsAppTo'] ?? '919876543210',
        'event': 'order_received',
        'parameters': {'orderId': order['orderId'], 'planId': plan['planId']},
      });
      runs.add({
        'planId': plan['planId'],
        'status': 'created',
        'orderId': order['orderId'],
        'nextRunAt': plan['nextRunAt'],
      });
    }
    return ApiResponse(201, {'runs': runs, 'count': runs.length});
  }

  DateTime _nextRunAt(String frequency) {
    final now = DateTime.now();
    if (frequency == 'Biweekly') return now.add(const Duration(days: 14));
    if (frequency == 'Monthly') return now.add(const Duration(days: 30));
    return now.add(const Duration(days: 7));
  }
}

class RoleAccessService {
  ApiResponse? guard(BackendRequest request) {
    final role = request.headers['x-role'] ?? 'anonymous';
    final segments =
        request.path.split('/').where((segment) => segment.isNotEmpty).toList();
    if (request.path == '/audit/events' ||
        segments.isNotEmpty && segments.first == 'admin') {
      if (role != 'admin' && role != 'owner') {
        return ApiResponse(403, {
          'error': 'FORBIDDEN',
          'requiredRole': 'admin',
          'actualRole': role,
        });
      }
    }
    if (segments.isNotEmpty && segments.first == 'staff') {
      if (role != 'staff' && role != 'admin' && role != 'owner') {
        return ApiResponse(403, {
          'error': 'FORBIDDEN',
          'requiredRole': 'staff',
          'actualRole': role,
        });
      }
    }
    return null;
  }
}

class IdempotencyStore {
  final Map<String, ApiResponse> _responses = {};

  ApiResponse? read(String key) => _responses[key];

  void save(String key, ApiResponse response) {
    if (response.ok) _responses[key] = response;
  }

  int get size => _responses.length;
}

class AuditLogService {
  final List<Map<String, Object?>> events = [];

  void record(
    BackendRequest request,
    ApiResponse response, {
    bool replay = false,
  }) {
    events.add({
      'auditId': _nextId('AUD'),
      'method': request.method.toUpperCase(),
      'path': request.path,
      'statusCode': response.statusCode,
      'idempotencyKey': request.headers['x-idempotency-key'],
      'replay': replay,
      'actor': request.headers['x-actor'] ??
          request.body['customerId'] ??
          'anonymous',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  ApiResponse list({int limit = 50}) => ApiResponse(200, {
        'events': events.reversed.take(limit).toList(),
        'total': events.length,
      });
}

class HealthCheckService {
  ApiResponse ready({required SmartKiranaBackend backend}) {
    final configIssues = backend.config.validate();
    final ready = configIssues.isEmpty;
    return ApiResponse(ready ? 200 : 503, {
      'status': ready ? 'ready' : 'misconfigured',
      'environment': backend.config.environment,
      'demoMode': backend.config.demoMode,
      'configIssues': configIssues,
      'providers': {
        'paymentGateway': backend.config.paymentGateway,
        'whatsAppProvider': backend.config.whatsAppProvider,
        'paymentCredentialConfigured':
            backend.config.razorpayKeyId.isNotEmpty ||
                backend.config.cashfreeClientId.isNotEmpty,
        'databaseUrlConfigured': backend.config.databaseUrlConfigured,
        'storageProvider': backend.config.storageProvider,
        'jwtSecretConfigured': backend.config.jwtSecretConfigured,
        'webhookSignatureRequired': backend.config.requireWebhookSignature,
      },
      'products': backend.products.length,
      'orders': backend.orderCreationApi.orders.length,
      'auditEvents': backend.auditLogService.events.length,
      'idempotencyKeys': backend.idempotencyStore.size,
    });
  }
}

class PaymentReconciliationService {
  PaymentReconciliationService({
    required this.orders,
    required this.payments,
    required this.invoices,
  });

  final OrderCreationApi orders;
  final PaymentGatewayBackend payments;
  final InvoiceService invoices;

  ApiResponse summary() {
    final rows = <Map<String, Object?>>[];
    final unmatchedPayments = <Map<String, Object?>>[];
    var capturedAmount = 0;
    var refundedAmount = 0;

    for (final refund in payments.refunds.values) {
      refundedAmount += _asInt(refund['amount']);
    }

    for (final attempt in payments.attempts.values) {
      final orderId = '${attempt['orderId'] ?? ''}';
      if (!orders.orders.containsKey(orderId)) {
        unmatchedPayments.add(attempt);
      }
      if (_isCapturedStatus('${attempt['status']}')) {
        capturedAmount += _asInt(attempt['amount']);
      }
    }

    for (final order in orders.orders.values) {
      final orderId = '${order['orderId']}';
      final quote = order['quote']! as Map<String, Object?>;
      final payable = _asInt(quote['payable']);
      final orderPayments = payments.attempts.values
          .where((attempt) => attempt['orderId'] == orderId)
          .toList();
      final paid = orderPayments
          .where((attempt) => _isCapturedStatus('${attempt['status']}'))
          .fold<int>(0, (total, attempt) => total + _asInt(attempt['amount']));
      final orderInvoices = invoices.invoices.values
          .where((invoice) => invoice['orderId'] == orderId)
          .toList();
      rows.add({
        'orderId': orderId,
        'customerId': order['customerId'],
        'payable': payable,
        'paid': paid,
        'balance': max(0, payable - paid),
        'paymentStatus': paid >= payable ? 'settled' : 'pending',
        'invoiceStatus': orderInvoices.isEmpty ? 'missing' : 'generated',
        'invoiceIds':
            orderInvoices.map((invoice) => invoice['invoiceId']).toList(),
      });
    }

    final pendingRows = rows
        .where(
          (row) =>
              row['paymentStatus'] == 'pending' ||
              row['invoiceStatus'] == 'missing',
        )
        .toList();
    return ApiResponse(200, {
      'orderCount': orders.orders.length,
      'paymentAttemptCount': payments.attempts.length,
      'invoiceCount': invoices.invoices.length,
      'capturedAmount': capturedAmount,
      'refundedAmount': refundedAmount,
      'netCollected': capturedAmount - refundedAmount,
      'pendingCount': pendingRows.length,
      'pendingOrderIds': pendingRows.map((row) => row['orderId']).toList(),
      'unmatchedPaymentCount': unmatchedPayments.length,
      'rows': rows,
    });
  }

  bool _isCapturedStatus(String status) =>
      status == 'captured' || status == 'refund_initiated';

  int _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    return int.tryParse('$value') ?? 0;
  }
}

class AuthTokenService {
  AuthTokenService(this.config);

  final SmartKiranaBackendConfig config;

  String issueToken({
    required String subject,
    required String role,
    Duration ttl = const Duration(hours: 12),
  }) {
    final now = DateTime.now();
    final header = _base64Json({'alg': 'HS256', 'typ': 'JWT'});
    final payload = _base64Json({
      'iss': config.jwtIssuer,
      'aud': config.jwtAudience,
      'sub': subject,
      'role': role,
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': now.add(ttl).millisecondsSinceEpoch ~/ 1000,
    });
    final signature = config.jwtSecretConfigured || config.demoMode
        ? _base64Url('$header.$payload.${config.jwtIssuer}.$role')
        : 'unsigned-production-token';
    return '$header.$payload.$signature';
  }

  ApiResponse verify(Map<String, Object?> body) {
    final token = '${body['token'] ?? ''}';
    final parts = token.split('.');
    if (parts.length != 3) {
      return const ApiResponse(401, {'error': 'INVALID_TOKEN'});
    }
    final claims = _decodeBase64Json(parts[1]);
    if (claims['iss'] != config.jwtIssuer ||
        claims['aud'] != config.jwtAudience) {
      return const ApiResponse(401, {'error': 'TOKEN_CONTEXT_MISMATCH'});
    }
    final expiresAt =
        claims['exp'] is num ? (claims['exp']! as num).toInt() : 0;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (expiresAt < now) {
      return const ApiResponse(401, {'error': 'TOKEN_EXPIRED'});
    }
    return ApiResponse(200, {'claims': claims});
  }

  String _base64Json(Map<String, Object?> data) => _base64Url(jsonEncode(data));

  Map<String, Object?> _decodeBase64Json(String encoded) {
    try {
      final normalized = base64Url.normalize(encoded);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final value = jsonDecode(decoded);
      if (value is Map<String, Object?>) return value;
      if (value is Map) {
        return value.map((key, value) => MapEntry('$key', value));
      }
    } catch (_) {
      return const {};
    }
    return const {};
  }

  String _base64Url(String value) =>
      base64Url.encode(utf8.encode(value)).replaceAll('=', '');
}

class AdminConfigService {
  AdminConfigService(this.config);

  final SmartKiranaBackendConfig config;
  final List<Map<String, Object?>> changes = [];

  ApiResponse read() => ApiResponse(200, {
        'config': config.toJson(),
        'issues': config.validate(),
      });

  ApiResponse update(Map<String, Object?> body, {String actor = 'admin'}) {
    final before = config.toJson();
    config.update(body);
    final after = config.toJson();
    final changedKeys =
        after.keys.where((key) => before[key] != after[key]).toList();
    final change = {
      'changeId': _nextId('CFG'),
      'actor': actor,
      'changedKeys': changedKeys,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    changes.add(change);
    return ApiResponse(200, {
      'config': after,
      'issues': config.validate(),
      'change': change,
    });
  }

  ApiResponse history() => ApiResponse(200, {
        'changes': changes.reversed.toList(),
        'count': changes.length,
      });
}

class BackendStateStore {
  BackendStateStore(this.backend);

  final SmartKiranaBackend backend;

  ApiResponse exportSnapshot() => ApiResponse(200, {
        'storageProvider': backend.config.storageProvider,
        'databaseUrlConfigured': backend.config.databaseUrlConfigured,
        'exportedAt': DateTime.now().toIso8601String(),
        'products':
            backend.products.values.map((product) => product.toJson()).toList(),
        'orders': backend.orderCreationApi.orders.values.toList(),
        'payments': backend.paymentGatewayBackend.attempts.values.toList(),
        'refunds': backend.paymentGatewayBackend.refunds.values.toList(),
        'customers': backend.customerApi.customers,
        'supportTickets': backend.supportTicketBackend.tickets.values.toList(),
        'recurringPlans': backend.recurringPlanService.plans.values.toList(),
      });

  ApiResponse importSnapshot(Map<String, Object?> body) {
    final products = body['products'];
    if (products is List) {
      backend.products
        ..clear()
        ..addEntries(
          products.whereType<Map>().map((item) {
            final record = ProductRecord.fromJson(
              item.map((key, value) => MapEntry('$key', value)),
            );
            return MapEntry(record.id, record);
          }),
        );
    }
    return ApiResponse(202, {
      'imported': true,
      'products': backend.products.length,
      'storageProvider': backend.config.storageProvider,
    });
  }
}

class SmartKiranaBackend {
  SmartKiranaBackend.seeded({
    SmartKiranaBackendConfig? config,
  })  : config = config ?? SmartKiranaBackendConfig.demo(),
        products = _seedProducts() {
    _wireServices(this.config);
  }

  SmartKiranaBackend.production({
    required SmartKiranaBackendConfig config,
  })  : config = config,
        products = _seedProducts() {
    _wireServices(config);
  }

  void _wireServices(SmartKiranaBackendConfig runtimeConfig) {
    authTokenService = AuthTokenService(runtimeConfig);
    adminConfigService = AdminConfigService(runtimeConfig);
    whatsAppBusinessBackend = WhatsAppBusinessBackend(runtimeConfig);
    customerApi = CustomerApi(
      config: runtimeConfig,
      whatsApp: whatsAppBusinessBackend,
      auth: authTokenService,
    );
    catalogueApi = CatalogueApi(products);
    inventoryService = InventoryService(products);
    pricingOfferEngine = PricingOfferEngine(products);
    orderCreationApi = OrderCreationApi(
      inventory: inventoryService,
      pricing: pricingOfferEngine,
    );
    paymentGatewayBackend = PaymentGatewayBackend(runtimeConfig);
    deliverySlotService = DeliverySlotService();
    invoiceService = InvoiceService(runtimeConfig);
    notificationService = NotificationService();
    adminDashboardService = AdminDashboardService(
      orders: orderCreationApi,
      products: products,
    );
    staffFulfilmentService = StaffFulfilmentService(orderCreationApi);
    qrScanVerifyApi = QrScanVerifyApi(orderCreationApi);
    qrDownloadService = QrDownloadService(runtimeConfig);
    rewardWalletService = RewardWalletService();
    supportTicketBackend = SupportTicketBackend();
    deliveryTrackingService = DeliveryTrackingService();
    deliveryDispatchService = DeliveryDispatchService(
      orders: orderCreationApi,
      tracking: deliveryTrackingService,
    );
    recurringPlanService = RecurringPlanService(
      orders: orderCreationApi,
      notifications: notificationService,
      whatsApp: whatsAppBusinessBackend,
    );
    idempotencyStore = IdempotencyStore();
    auditLogService = AuditLogService();
    healthCheckService = HealthCheckService();
    paymentReconciliationService = PaymentReconciliationService(
      orders: orderCreationApi,
      payments: paymentGatewayBackend,
      invoices: invoiceService,
    );
    roleAccessService = RoleAccessService();
    storeAlertService = StoreAlertService(
      orders: orderCreationApi,
      products: products,
      payments: paymentGatewayBackend,
      whatsApp: whatsAppBusinessBackend,
      support: supportTicketBackend,
      notifications: notificationService,
    );
    backendStateStore = BackendStateStore(this);
  }

  final SmartKiranaBackendConfig config;
  final Map<String, ProductRecord> products;
  late final CustomerApi customerApi;
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
  late final DeliveryDispatchService deliveryDispatchService;
  late final RecurringPlanService recurringPlanService;
  late final IdempotencyStore idempotencyStore;
  late final AuditLogService auditLogService;
  late final HealthCheckService healthCheckService;
  late final PaymentReconciliationService paymentReconciliationService;
  late final RoleAccessService roleAccessService;
  late final StoreAlertService storeAlertService;
  late final AuthTokenService authTokenService;
  late final AdminConfigService adminConfigService;
  late final BackendStateStore backendStateStore;

  ApiResponse handle(BackendRequest request) {
    final method = request.method.toUpperCase();
    final idempotencyKey = request.headers['x-idempotency-key'];
    final cacheKey = '$method ${request.path} $idempotencyKey';
    if (idempotencyKey != null && method != 'GET') {
      final cached = idempotencyStore.read(cacheKey);
      if (cached != null) {
        auditLogService.record(request, cached, replay: true);
        return cached;
      }
    }
    final response = _dispatch(request);
    if (idempotencyKey != null && method != 'GET') {
      idempotencyStore.save(cacheKey, response);
    }
    auditLogService.record(request, response);
    return response;
  }

  ApiResponse _dispatch(BackendRequest request) {
    final method = request.method.toUpperCase();
    final segments =
        request.path.split('/').where((segment) => segment.isNotEmpty).toList();
    final denied = roleAccessService.guard(request);
    if (denied != null) {
      return denied;
    }
    if (method == 'GET' && request.path == '/health') {
      return healthCheckService.ready(backend: this);
    }
    if (method == 'GET' && request.path == '/audit/events') {
      return auditLogService.list();
    }
    if (method == 'POST' && request.path == '/customers/login/start') {
      return customerApi.startOtp(request.body);
    }
    if (method == 'POST' && request.path == '/customers/login/verify') {
      return customerApi.verifyOtp(request.body);
    }
    if (method == 'POST' && request.path == '/auth/token/verify') {
      return authTokenService.verify(request.body);
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
    if (method == 'GET' && request.path == '/admin/config') {
      return adminConfigService.read();
    }
    if ((method == 'POST' || method == 'PUT') &&
        request.path == '/admin/config') {
      return adminConfigService.update(
        request.body,
        actor: request.headers['x-actor'] ?? 'admin',
      );
    }
    if (method == 'GET' && request.path == '/admin/config/history') {
      return adminConfigService.history();
    }
    if (method == 'POST' && request.path == '/admin/catalogue/products') {
      return catalogueApi.upsert(request.body);
    }
    if (method == 'GET' && request.path == '/admin/state/export') {
      return backendStateStore.exportSnapshot();
    }
    if (method == 'POST' && request.path == '/admin/state/import') {
      return backendStateStore.importSnapshot(request.body);
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
    if (method == 'GET' && request.path == '/admin/alerts') {
      return storeAlertService.evaluate();
    }
    if (method == 'GET' && request.path == '/admin/reconciliation') {
      return paymentReconciliationService.summary();
    }
    if (method == 'POST' && request.path == '/admin/alerts/notify') {
      return storeAlertService.notifyStoreOwner(
        ownerId: '${request.body['ownerId'] ?? 'STORE_OWNER'}',
      );
    }
    if (method == 'POST' && request.path == '/admin/alerts/acknowledge') {
      return storeAlertService.acknowledge(request.body);
    }
    if (method == 'POST' && request.path == '/admin/alerts/resolve') {
      return storeAlertService.resolve(request.body);
    }
    if (method == 'GET' && request.path == '/staff/orders/queue') {
      return staffFulfilmentService.queue(status: request.headers['x-status']);
    }
    if (method == 'POST' &&
        segments.length == 4 &&
        segments[0] == 'staff' &&
        segments[1] == 'orders' &&
        segments[3] == 'assign') {
      return staffFulfilmentService.assign(segments[2], request.body);
    }
    if (method == 'POST' &&
        segments.length == 4 &&
        segments[0] == 'staff' &&
        segments[1] == 'orders' &&
        segments[3] == 'pack') {
      return staffFulfilmentService.pack(segments[2], request.body);
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
    if (method == 'POST' && request.path == '/delivery/routes/plan') {
      return deliveryDispatchService.plan(request.body);
    }
    if (method == 'GET' && request.path == '/delivery/routes') {
      return deliveryDispatchService.list();
    }
    if (method == 'POST' &&
        segments.length == 4 &&
        segments[0] == 'delivery' &&
        segments[1] == 'routes' &&
        segments[3] == 'dispatch') {
      return deliveryDispatchService.dispatch(segments[2], request.body);
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
    if (method == 'POST' && request.path == '/recurring-plans/run-due') {
      return recurringPlanService.runDue(request.body);
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

int _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse('$value') ?? 0;
}

String _nextId(String prefix) =>
    '$prefix${DateTime.now().microsecondsSinceEpoch}';
