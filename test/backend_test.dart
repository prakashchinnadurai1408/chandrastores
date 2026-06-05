import 'package:flutter_test/flutter_test.dart';
import 'package:smart_kirana/backend.dart';

void main() {
  test(
    'customer OTP and catalogue APIs return production-shaped responses',
    () {
      final backend = SmartKiranaBackend.seeded();

      final otp = backend.handle(
        const BackendRequest(
          method: 'POST',
          path: '/customers/login/start',
          body: {'mobile': '9876543210'},
        ),
      );
      expect(otp.statusCode, 202);

      final verified = backend.handle(
        BackendRequest(
          method: 'POST',
          path: '/customers/login/verify',
          body: {
            'mobile': '9876543210',
            'requestId': otp.body['requestId'],
            'otp': '123456',
          },
        ),
      );
      expect(verified.ok, isTrue);
      expect(verified.body['token'], isNotNull);

      final catalogue = backend.handle(
        const BackendRequest(method: 'GET', path: '/catalogue/products'),
      );
      expect(catalogue.ok, isTrue);
      expect(catalogue.body['products'], isA<List>());
    },
  );

  test(
    'order, payment, staff fulfilment, and QR verify flow work together',
    () {
      final backend = SmartKiranaBackend.seeded();

      final orderResponse = backend.handle(
        const BackendRequest(
          method: 'POST',
          path: '/orders',
          body: {
            'customerId': 'CUS9876543210',
            'items': {'rice_sona_5kg': 1, 'oil_groundnut_1l': 1},
            'slot': 'Store pickup counter',
            'fulfilmentMode': 'Store pickup',
            'paymentMethod': 'UPI',
          },
        ),
      );
      expect(orderResponse.statusCode, 201);
      final order = orderResponse.body['order']! as Map<String, Object?>;
      final orderId = order['orderId']! as String;
      final suffix = orderId.length <= 6
          ? orderId.padLeft(6, '0')
          : orderId.substring(orderId.length - 6);

      final payment = backend.handle(
        BackendRequest(
          method: 'POST',
          path: '/payments/create',
          body: {'orderId': orderId, 'amount': 605},
        ),
      );
      expect(payment.statusCode, 201);

      final staffUpdate = backend.handle(
        BackendRequest(
          method: 'POST',
          path: '/staff/orders/$orderId/status',
          headers: const {'x-role': 'staff'},
          body: const {'status': 'Ready for pickup'},
        ),
      );
      expect(staffUpdate.ok, isTrue);

      final qr = backend.handle(
        BackendRequest(
          method: 'POST',
          path: '/qr/verify',
          body: {'code': 'PU-$suffix'},
        ),
      );
      expect(qr.ok, isTrue);
      expect(qr.body['orderId'], orderId);
      expect(qr.body['status'], 'Ready for pickup');
    },
  );

  test(
    'invoice, WhatsApp, notification, and admin dashboard services respond',
    () {
      final backend = SmartKiranaBackend.seeded();
      final orderResponse = backend.orderCreationApi.create(const {
        'customerId': 'CUS9876543210',
        'items': {'milk_toned_1l': 2},
        'slot': 'Today 6 PM - 8 PM',
        'fulfilmentMode': 'Home delivery',
      });
      final order = orderResponse.body['order']! as Map<String, Object?>;
      final orderId = order['orderId']! as String;

      expect(
        backend.invoiceService.generate({'orderId': orderId}).statusCode,
        201,
      );
      expect(
        backend.whatsAppBusinessBackend.sendTemplate({
          'to': '919876543210',
          'template': 'order_received',
        }).statusCode,
        202,
      );
      expect(
        backend.notificationService.enqueue({
          'customerId': 'CUS9876543210',
          'message': 'Order received',
        }).statusCode,
        202,
      );

      final dashboard = backend.adminDashboardService.summary();
      expect(dashboard.ok, isTrue);
      expect(dashboard.body['ordersToday'], 1);
      expect(dashboard.body['openOrders'], 1);
    },
  );

  test(
    'remaining production services cover messaging qr wallet support tracking and plans',
    () {
      final backend = SmartKiranaBackend.seeded();

      final qrDownload = backend.handle(
        const BackendRequest(
          method: 'GET',
          path: '/qr/app-download',
          headers: {'x-channel': 'counter-poster'},
        ),
      );
      expect(qrDownload.ok, isTrue);
      expect(qrDownload.body['qrPayload'], contains('counter-poster'));

      final transactional = backend.handle(
        const BackendRequest(
          method: 'POST',
          path: '/whatsapp/transactional',
          body: {'to': '919876543210', 'event': 'pickup_ready'},
        ),
      );
      expect(transactional.statusCode, 202);
      final message = transactional.body['message']! as Map<String, Object?>;
      expect(message['template'], 'pickup_ready_v1');

      final credit = backend.handle(
        const BackendRequest(
          method: 'POST',
          path: '/wallet/rewards/credit',
          body: {'customerId': 'CUS9876543210', 'points': 100},
        ),
      );
      expect(credit.statusCode, 201);
      final redeem = backend.handle(
        const BackendRequest(
          method: 'POST',
          path: '/wallet/rewards/redeem',
          body: {'customerId': 'CUS9876543210', 'points': 250, 'discount': 50},
        ),
      );
      expect(redeem.statusCode, 201);

      final ticket = backend.handle(
        const BackendRequest(
          method: 'POST',
          path: '/support/tickets',
          body: {
            'customerId': 'CUS9876543210',
            'orderId': 'ORD1',
            'priority': 'High',
            'issueType': 'Missing item',
          },
        ),
      );
      expect(ticket.statusCode, 201);
      final ticketBody = ticket.body['ticket']! as Map<String, Object?>;
      expect(ticketBody['slaHours'], 4);

      final tracking = backend.handle(
        const BackendRequest(
          method: 'POST',
          path: '/tracking/events',
          body: {
            'orderId': 'ORD1',
            'status': 'Out for delivery',
            'actor': 'rider',
          },
        ),
      );
      expect(tracking.statusCode, 201);
      final timeline = backend.handle(
        const BackendRequest(method: 'GET', path: '/tracking/ORD1/timeline'),
      );
      expect((timeline.body['timeline']! as List), hasLength(1));

      final plan = backend.handle(
        const BackendRequest(
          method: 'POST',
          path: '/recurring-plans',
          body: {
            'customerId': 'CUS9876543210',
            'frequency': 'Biweekly',
            'items': {'rice_sona_5kg': 1},
          },
        ),
      );
      expect(plan.statusCode, 201);
      final due = backend.handle(
        const BackendRequest(method: 'GET', path: '/recurring-plans/due'),
      );
      expect((due.body['plans']! as List), hasLength(1));
    },
  );

  test('payment refund and pickup verification complete operational loops', () {
    final backend = SmartKiranaBackend.seeded();
    final orderResponse = backend.handle(
      const BackendRequest(
        method: 'POST',
        path: '/orders',
        body: {
          'customerId': 'CUS9876543210',
          'items': {'rice_sona_5kg': 1},
          'slot': 'Store pickup counter',
          'fulfilmentMode': 'Store pickup',
        },
      ),
    );
    final order = orderResponse.body['order']! as Map<String, Object?>;
    final orderId = order['orderId']! as String;
    final suffix = orderId.length <= 6
        ? orderId.padLeft(6, '0')
        : orderId.substring(orderId.length - 6);

    final payment = backend.handle(
      BackendRequest(
        method: 'POST',
        path: '/payments/create',
        body: {'orderId': orderId, 'amount': 420},
      ),
    );
    final paymentBody = payment.body['payment']! as Map<String, Object?>;
    final refund = backend.handle(
      BackendRequest(
        method: 'POST',
        path: '/payments/refund',
        body: {'paymentId': paymentBody['paymentId'], 'amount': 420},
      ),
    );
    expect(refund.statusCode, 202);

    final verify = backend.handle(
      BackendRequest(
        method: 'POST',
        path: '/qr/verify',
        body: {'code': 'PU-$suffix', 'staffId': 'STAFF1', 'markComplete': true},
      ),
    );
    expect(verify.ok, isTrue);
    expect(verify.body['status'], 'Picked up');
    expect(backend.qrScanVerifyApi.scanAudit, hasLength(1));
  });

  test(
    'idempotency replays duplicate order creation without duplicate orders',
    () {
      final backend = SmartKiranaBackend.seeded();
      const request = BackendRequest(
        method: 'POST',
        path: '/orders',
        headers: {
          'x-idempotency-key': 'order-repeat-1',
          'x-actor': 'CUS9876543210',
        },
        body: {
          'customerId': 'CUS9876543210',
          'items': {'rice_sona_5kg': 1},
          'slot': 'Today 6 PM - 8 PM',
          'fulfilmentMode': 'Home delivery',
        },
      );

      final first = backend.handle(request);
      final second = backend.handle(request);

      expect(first.statusCode, 201);
      expect(second.body, first.body);
      expect(backend.orderCreationApi.orders, hasLength(1));
      expect(backend.idempotencyStore.size, 1);
      expect(backend.auditLogService.events.last['replay'], isTrue);
    },
  );

  test('health and audit endpoints expose operational readiness', () {
    final backend = SmartKiranaBackend.seeded();
    backend.handle(
      const BackendRequest(method: 'GET', path: '/catalogue/products'),
    );

    final health = backend.handle(
      const BackendRequest(method: 'GET', path: '/health'),
    );
    expect(health.ok, isTrue);
    expect(health.body['status'], 'ready');
    expect(health.body['products'], 3);

    final audit = backend.handle(
      const BackendRequest(
        method: 'GET',
        path: '/audit/events',
        headers: {'x-role': 'admin'},
      ),
    );
    expect(audit.ok, isTrue);
    expect(audit.body['total'], greaterThanOrEqualTo(2));
  });

  test(
    'admin alerts surface low stock payments WhatsApp support and open orders',
    () {
      final backend = SmartKiranaBackend.seeded();
      backend.products['milk_toned_1l'] =
          backend.products['milk_toned_1l']!.copyWith(stockQty: 10);
      final orderResponse = backend.handle(
        const BackendRequest(
          method: 'POST',
          path: '/orders',
          body: {
            'customerId': 'CUS9876543210',
            'items': {'rice_sona_5kg': 1},
            'slot': 'Today 6 PM - 8 PM',
            'fulfilmentMode': 'Home delivery',
          },
        ),
      );
      final order = orderResponse.body['order']! as Map<String, Object?>;
      final orderId = order['orderId']! as String;
      final payment = backend.paymentGatewayBackend.createAttempt({
        'orderId': orderId,
        'amount': 420,
      });
      final paymentBody = payment.body['payment']! as Map<String, Object?>;
      backend.paymentGatewayBackend.webhook({
        'paymentId': paymentBody['paymentId'],
        'status': 'failed',
      });
      backend.whatsAppBusinessBackend.sendTemplate({
        'to': '919876543210',
        'template': 'pickup_ready_v1',
      });
      backend.whatsAppBusinessBackend.outbox.last['status'] = 'failed';
      backend.supportTicketBackend.create({
        'orderId': orderId,
        'customerId': 'CUS9876543210',
        'priority': 'High',
        'issueType': 'Payment failed',
      });

      final alerts = backend.handle(
        const BackendRequest(
          method: 'GET',
          path: '/admin/alerts',
          headers: {'x-role': 'admin'},
        ),
      );
      expect(alerts.ok, isTrue);
      final alertList = alerts.body['alerts']! as List;
      expect(
        alertList.map((alert) => alert['type']),
        containsAll([
          'low_stock',
          'payment_attention',
          'whatsapp_failed',
          'support_sla',
          'open_order',
        ]),
      );
      expect(alerts.body['criticalCount'], greaterThanOrEqualTo(2));
    },
  );

  test('admin alert notification queues owner message when alerts exist', () {
    final backend = SmartKiranaBackend.seeded();
    backend.products['milk_toned_1l'] =
        backend.products['milk_toned_1l']!.copyWith(stockQty: 1);

    final notify = backend.handle(
      const BackendRequest(
        method: 'POST',
        path: '/admin/alerts/notify',
        headers: {'x-role': 'admin'},
        body: {'ownerId': 'OWNER1'},
      ),
    );

    expect(notify.statusCode, 202);
    expect(backend.notificationService.notifications, hasLength(1));
    expect(
      backend.notificationService.notifications.first['customerId'],
      'OWNER1',
    );
  });

  test('admin alert lifecycle acknowledges and resolves active alerts', () {
    final backend = SmartKiranaBackend.seeded();
    backend.products['milk_toned_1l'] =
        backend.products['milk_toned_1l']!.copyWith(stockQty: 0);
    const alertId = 'LOW_STOCK_milk_toned_1l';

    final acknowledge = backend.handle(
      const BackendRequest(
        method: 'POST',
        path: '/admin/alerts/acknowledge',
        headers: {'x-role': 'admin'},
        body: {
          'alertId': alertId,
          'assignee': 'STORE_OWNER',
          'note': 'Calling supplier now',
        },
      ),
    );
    expect(acknowledge.ok, isTrue);

    final acknowledgedAlerts = backend.handle(
      const BackendRequest(
        method: 'GET',
        path: '/admin/alerts',
        headers: {'x-role': 'admin'},
      ),
    );
    expect(acknowledgedAlerts.body['acknowledgedCount'], 1);
    final activeAlerts = acknowledgedAlerts.body['alerts']! as List;
    final lowStock = activeAlerts.firstWhere(
      (alert) => alert['alertId'] == alertId,
    );
    expect(lowStock['status'], 'acknowledged');
    expect(lowStock['assignee'], 'STORE_OWNER');

    final resolve = backend.handle(
      const BackendRequest(
        method: 'POST',
        path: '/admin/alerts/resolve',
        headers: {'x-role': 'admin'},
        body: {'alertId': alertId, 'resolution': 'Supplier confirmed refill'},
      ),
    );
    expect(resolve.ok, isTrue);

    final resolvedAlerts = backend.handle(
      const BackendRequest(
        method: 'GET',
        path: '/admin/alerts',
        headers: {'x-role': 'admin'},
      ),
    );
    final remainingIds = (resolvedAlerts.body['alerts']! as List).map(
      (alert) => alert['alertId'],
    );
    expect(remainingIds, isNot(contains(alertId)));
  });

  test('role access guard protects admin audit and staff routes', () {
    final backend = SmartKiranaBackend.seeded();

    final deniedAdmin = backend.handle(
      const BackendRequest(method: 'GET', path: '/admin/alerts'),
    );
    expect(deniedAdmin.statusCode, 403);
    expect(deniedAdmin.body['requiredRole'], 'admin');

    final allowedAdmin = backend.handle(
      const BackendRequest(
        method: 'GET',
        path: '/admin/alerts',
        headers: {'x-role': 'admin'},
      ),
    );
    expect(allowedAdmin.ok, isTrue);

    final deniedStaff = backend.handle(
      const BackendRequest(
        method: 'POST',
        path: '/staff/orders/ORD-MISSING/status',
        body: {'status': 'Packing'},
      ),
    );
    expect(deniedStaff.statusCode, 403);
    expect(deniedStaff.body['requiredRole'], 'staff');
  });

  test('staff fulfilment queue assigns and packs open orders', () {
    final backend = SmartKiranaBackend.seeded();
    final orderResponse = backend.handle(
      const BackendRequest(
        method: 'POST',
        path: '/orders',
        body: {
          'customerId': 'CUS9876543210',
          'items': {'rice_sona_5kg': 1, 'milk_toned_1l': 2},
          'slot': 'Today 6 PM - 8 PM',
          'fulfilmentMode': 'Home delivery',
          'paymentMethod': 'UPI',
        },
      ),
    );
    final order = orderResponse.body['order']! as Map<String, Object?>;
    final orderId = order['orderId']! as String;

    final deniedQueue = backend.handle(
      const BackendRequest(method: 'GET', path: '/staff/orders/queue'),
    );
    expect(deniedQueue.statusCode, 403);

    final queue = backend.handle(
      const BackendRequest(
        method: 'GET',
        path: '/staff/orders/queue',
        headers: {'x-role': 'staff'},
      ),
    );
    expect(queue.ok, isTrue);
    final queueOrders = queue.body['orders']! as List;
    expect(queueOrders, hasLength(1));
    expect((queueOrders.single as Map)['assignmentStatus'], 'unassigned');

    final assign = backend.handle(
      BackendRequest(
        method: 'POST',
        path: '/staff/orders/$orderId/assign',
        headers: const {'x-role': 'staff'},
        body: const {'staffId': 'PICKER-01', 'role': 'picker'},
      ),
    );
    expect(assign.statusCode, 200);
    expect((assign.body['assignment']! as Map)['staffId'], 'PICKER-01');
    expect((assign.body['order']! as Map)['status'], 'Assigned to picker');

    final pack = backend.handle(
      BackendRequest(
        method: 'POST',
        path: '/staff/orders/$orderId/pack',
        headers: const {'x-role': 'staff'},
        body: const {'packedBy': 'PICKER-01', 'bagCount': 2},
      ),
    );
    expect(pack.ok, isTrue);
    expect((pack.body['assignment']! as Map)['assignmentId'], isNotNull);
    expect((pack.body['assignment']! as Map)['bagCount'], 2);
    expect((pack.body['order']! as Map)['status'], 'Packed');

    final packedQueue = backend.handle(
      const BackendRequest(
        method: 'GET',
        path: '/staff/orders/queue',
        headers: {'x-role': 'staff'},
      ),
    );
    final packedOrder = (packedQueue.body['orders']! as List).single as Map;
    expect(packedOrder['assignedTo'], 'PICKER-01');
    expect(packedOrder['assignmentStatus'], 'packed');
  });

  test('delivery route planning dispatches packed home delivery orders', () {
    final backend = SmartKiranaBackend.seeded();
    final orderResponse = backend.handle(
      const BackendRequest(
        method: 'POST',
        path: '/orders',
        body: {
          'customerId': 'CUS9876543210',
          'items': {'oil_groundnut_1l': 1, 'milk_toned_1l': 2},
          'slot': 'Today 6 PM - 8 PM',
          'fulfilmentMode': 'Home delivery',
          'deliveryAddress': {'line1': '12 Market Street', 'area': 'Mylapore'},
        },
      ),
    );
    final order = orderResponse.body['order']! as Map<String, Object?>;
    final orderId = order['orderId']! as String;

    final noReadyOrders = backend.handle(
      const BackendRequest(method: 'POST', path: '/delivery/routes/plan'),
    );
    expect(noReadyOrders.statusCode, 422);

    backend.handle(
      BackendRequest(
        method: 'POST',
        path: '/staff/orders/$orderId/pack',
        headers: const {'x-role': 'staff'},
        body: const {'packedBy': 'PICKER-02', 'bagCount': 1},
      ),
    );

    final routePlan = backend.handle(
      BackendRequest(
        method: 'POST',
        path: '/delivery/routes/plan',
        body: {
          'riderId': 'RIDER-07',
          'orderIds': [orderId],
        },
      ),
    );
    expect(routePlan.statusCode, 201);
    final route = routePlan.body['route']! as Map<String, Object?>;
    final routeId = route['routeId']! as String;
    expect(route['stopCount'], 1);
    expect((route['stops']! as List).single['orderId'], orderId);
    expect(
      backend.orderCreationApi.orders[orderId]!['status'],
      'Assigned to rider',
    );

    final dispatch = backend.handle(
      BackendRequest(
        method: 'POST',
        path: '/delivery/routes/$routeId/dispatch',
        body: const {'riderId': 'RIDER-07'},
      ),
    );
    expect(dispatch.ok, isTrue);
    expect((dispatch.body['route']! as Map)['status'], 'out_for_delivery');
    expect(
      backend.orderCreationApi.orders[orderId]!['status'],
      'Out for delivery',
    );

    final timeline = backend.handle(
      BackendRequest(method: 'GET', path: '/tracking/$orderId/timeline'),
    );
    final events = timeline.body['timeline']! as List;
    expect(events.single['status'], 'Out for delivery');

    final routes = backend.handle(
      const BackendRequest(method: 'GET', path: '/delivery/routes'),
    );
    expect(routes.body['count'], 1);
  });

  test('recurring grocery run creates orders and customer messages', () {
    final backend = SmartKiranaBackend.seeded();
    final planResponse = backend.handle(
      const BackendRequest(
        method: 'POST',
        path: '/recurring-plans',
        body: {
          'customerId': 'CUS9876543210',
          'frequency': 'Weekly',
          'items': {'milk_toned_1l': 2, 'rice_sona_5kg': 1},
          'whatsAppTo': '919876543210',
        },
      ),
    );
    expect(planResponse.statusCode, 201);
    final plan = planResponse.body['plan']! as Map<String, Object?>;
    final planId = plan['planId']! as String;

    final run = backend.handle(
      const BackendRequest(
        method: 'POST',
        path: '/recurring-plans/run-due',
        body: {'customerId': 'CUS9876543210', 'slot': 'Sunday weekly delivery'},
      ),
    );
    expect(run.statusCode, 201);
    final runs = run.body['runs']! as List;
    expect(runs, hasLength(1));
    final createdRun = runs.single as Map<String, Object?>;
    expect(createdRun['planId'], planId);
    expect(createdRun['status'], 'created');
    expect(backend.orderCreationApi.orders, hasLength(1));

    final refreshedPlan = backend.recurringPlanService.plans[planId]!;
    expect(refreshedPlan['lastOrderId'], createdRun['orderId']);
    expect(refreshedPlan['runCount'], 1);
    expect(refreshedPlan['nextRunAt'], isNotNull);
    expect(backend.notificationService.notifications, hasLength(1));
    expect(
      backend.whatsAppBusinessBackend.outbox.last['template'],
      'order_received_v1',
    );
  });

  test('admin reconciliation summarizes payments refunds and invoices', () {
    final backend = SmartKiranaBackend.seeded();
    final orderResponse = backend.handle(
      const BackendRequest(
        method: 'POST',
        path: '/orders',
        body: {
          'customerId': 'CUS9876543210',
          'items': {'oil_groundnut_1l': 1, 'milk_toned_1l': 2},
          'slot': 'Today 6 PM - 8 PM',
          'fulfilmentMode': 'Home delivery',
        },
      ),
    );
    final order = orderResponse.body['order']! as Map<String, Object?>;
    final orderId = order['orderId']! as String;
    final payable = (order['quote']! as Map<String, Object?>)['payable'];

    final payment = backend.handle(
      BackendRequest(
        method: 'POST',
        path: '/payments/create',
        body: {'orderId': orderId, 'amount': payable},
      ),
    );
    final paymentId = (payment.body['payment']! as Map)['paymentId'];
    backend.handle(
      BackendRequest(
        method: 'POST',
        path: '/payments/webhook',
        body: {'paymentId': paymentId, 'status': 'captured'},
      ),
    );
    backend.handle(
      BackendRequest(
        method: 'POST',
        path: '/payments/refund',
        body: {'paymentId': paymentId, 'amount': 25, 'reason': 'item_shortage'},
      ),
    );
    backend.handle(
      BackendRequest(
        method: 'POST',
        path: '/invoices',
        body: {'orderId': orderId, 'billingName': 'Prakash'},
      ),
    );

    final denied = backend.handle(
      const BackendRequest(method: 'GET', path: '/admin/reconciliation'),
    );
    expect(denied.statusCode, 403);

    final reconciliation = backend.handle(
      const BackendRequest(
        method: 'GET',
        path: '/admin/reconciliation',
        headers: {'x-role': 'admin'},
      ),
    );
    expect(reconciliation.ok, isTrue);
    expect(reconciliation.body['orderCount'], 1);
    expect(reconciliation.body['invoiceCount'], 1);
    expect(reconciliation.body['refundedAmount'], 25);
    expect(reconciliation.body['netCollected'], (payable as int) - 25);
    expect(reconciliation.body['pendingCount'], 0);
    final row = (reconciliation.body['rows']! as List).single as Map;
    expect(row['paymentStatus'], 'settled');
    expect(row['invoiceStatus'], 'generated');
  });

  test('production config drives providers and webhook safety', () {
    final backend = SmartKiranaBackend.production(
      config: SmartKiranaBackendConfig.production(
        apiBaseUrl: 'https://api.chandrastores.in',
        appDownloadUrl: 'https://chandrastores.in/app',
        storeUpiId: 'chandrastores@okaxis',
        paymentGateway: 'cashfree',
        jwtIssuer: 'chandrastores',
      )
        ..paymentWebhookSecretConfigured = true
        ..databaseUrlConfigured = true
        ..jwtSecretConfigured = true,
    );

    final health = backend.handle(
      const BackendRequest(method: 'GET', path: '/health'),
    );
    expect(health.statusCode, 200);
    expect(health.body['environment'], 'production');
    expect(health.body['demoMode'], isFalse);

    final otp = backend.handle(
      const BackendRequest(
        method: 'POST',
        path: '/customers/login/start',
        body: {'mobile': '9876543210'},
      ),
    );
    expect(otp.statusCode, 202);
    expect(otp.body.containsKey('otp'), isFalse);
    expect(backend.whatsAppBusinessBackend.outbox, hasLength(1));

    final payment = backend.handle(
      const BackendRequest(
        method: 'POST',
        path: '/payments/create',
        body: {'orderId': 'ORD1', 'amount': 499},
      ),
    );
    final paymentBody = payment.body['payment']! as Map<String, Object?>;
    expect(paymentBody['gateway'], 'cashfree');
    expect(paymentBody['upiIntent'], contains('chandrastores@okaxis'));

    final unsignedWebhook = backend.handle(
      BackendRequest(
        method: 'POST',
        path: '/payments/webhook',
        body: {'paymentId': paymentBody['paymentId'], 'status': 'captured'},
      ),
    );
    expect(unsignedWebhook.statusCode, 401);

    final signedWebhook = backend.handle(
      BackendRequest(
        method: 'POST',
        path: '/payments/webhook',
        body: {
          'paymentId': paymentBody['paymentId'],
          'status': 'captured',
          'signature': 'signed-by-provider',
        },
      ),
    );
    expect(signedWebhook.ok, isTrue);
  });

  test('admin config updates production providers and credentials safely', () {
    final backend = SmartKiranaBackend.seeded();

    final update = backend.handle(
      const BackendRequest(
        method: 'PUT',
        path: '/admin/config',
        headers: {'x-role': 'admin', 'x-actor': 'owner'},
        body: {
          'apiBaseUrl': 'https://api.chandrastores.in',
          'appDownloadUrl': 'https://chandrastores.in/app',
          'storeUpiId': 'chandrastores@okaxis',
          'paymentGateway': 'cashfree',
          'cashfreeClientId': 'CF_CLIENT_123456',
          'whatsAppPhoneNumberId': '919876543210',
          'whatsAppTemplateNamespace': 'chandra_stores',
          'paymentWebhookSecretConfigured': true,
          'databaseUrlConfigured': true,
          'storageProvider': 'postgres',
          'jwtSecretConfigured': true,
          'requireWebhookSignature': true,
        },
      ),
    );
    expect(update.ok, isTrue);
    final config = update.body['config']! as Map<String, Object?>;
    expect(config['cashfreeClientId'], '****3456');
    expect(config['storageProvider'], 'postgres');

    final payment = backend.handle(
      const BackendRequest(
        method: 'POST',
        path: '/payments/create',
        body: {'orderId': 'ORD1', 'amount': 499},
      ),
    );
    final paymentBody = payment.body['payment']! as Map<String, Object?>;
    expect(paymentBody['gateway'], 'cashfree');
    expect(paymentBody['gatewayCredentialConfigured'], isTrue);
    expect(paymentBody['upiIntent'], contains('chandrastores@okaxis'));

    final message = backend.handle(
      const BackendRequest(
        method: 'POST',
        path: '/whatsapp/send',
        body: {'to': '919876543210', 'template': 'order_received_v1'},
      ),
    );
    final messageBody = message.body['message']! as Map<String, Object?>;
    expect(messageBody['phoneNumberId'], '919876543210');
    expect(messageBody['templateNamespace'], 'chandra_stores');

    final health = backend.handle(
      const BackendRequest(method: 'GET', path: '/health'),
    );
    expect(health.statusCode, 200);
  });

  test('admin catalogue state and auth token routes support production data',
      () {
    final backend = SmartKiranaBackend.seeded();

    final product = backend.handle(
      const BackendRequest(
        method: 'POST',
        path: '/admin/catalogue/products',
        headers: {'x-role': 'admin'},
        body: {
          'id': 'atta_10kg',
          'name': 'Whole Wheat Atta',
          'category': 'Staples',
          'packSize': '10 kg',
          'price': 520,
          'mrp': 560,
          'stockQty': 75,
          'reorderLevel': 12,
        },
      ),
    );
    expect(product.statusCode, 201);
    expect(backend.products['atta_10kg']?.price, 520);

    final export = backend.handle(
      const BackendRequest(
        method: 'GET',
        path: '/admin/state/export',
        headers: {'x-role': 'admin'},
      ),
    );
    expect(export.ok, isTrue);
    expect(export.body['products'], isA<List>());

    final otp = backend.handle(
      const BackendRequest(
        method: 'POST',
        path: '/customers/login/start',
        body: {'mobile': '9876543210'},
      ),
    );
    final verified = backend.handle(
      BackendRequest(
        method: 'POST',
        path: '/customers/login/verify',
        body: {
          'mobile': '9876543210',
          'requestId': otp.body['requestId'],
          'otp': '123456',
        },
      ),
    );
    final tokenCheck = backend.handle(
      BackendRequest(
        method: 'POST',
        path: '/auth/token/verify',
        body: {'token': verified.body['token']},
      ),
    );
    expect(tokenCheck.statusCode, 200);
    final claims = tokenCheck.body['claims']! as Map<String, Object?>;
    expect(claims['role'], 'customer');
  });
}
