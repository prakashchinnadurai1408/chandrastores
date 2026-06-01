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
      const BackendRequest(method: 'GET', path: '/audit/events'),
    );
    expect(audit.ok, isTrue);
    expect(audit.body['total'], greaterThanOrEqualTo(2));
  });
}
