import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_kirana/main.dart';

void main() {
  testWidgets('shows login screen for Smart Kirana customers', (tester) async {
    await tester.pumpWidget(const SmartKiranaApp());

    expect(find.text('Smart Kirana'), findsOneWidget);
    expect(
      find.text(
        'Order daily essentials, plan weekly groceries, and pay with UPI, cards, QR, GPay, PhonePe, or Paytm.',
      ),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Send WhatsApp OTP'), findsOneWidget);
  });

  testWidgets('mobile OTP flow moves customer into shop shell', (tester) async {
    await tester.pumpWidget(const SmartKiranaApp());

    await tester.enterText(find.byType(TextField), '9876543210');
    await tester.tap(find.text('Send WhatsApp OTP'));
    await tester.pumpAndSettle();

    expect(find.text('WhatsApp OTP'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, '123456');
    await tester.tap(find.text('Verify and continue'));
    await tester.pumpAndSettle();

    expect(find.text('Shop'), findsWidgets);
    expect(find.text('Search rice, oil, milk...'), findsOneWidget);
    expect(find.text('Planner'), findsWidgets);
    expect(find.text('Cart'), findsWidgets);
    expect(find.text('Account'), findsWidgets);
  });

  testWidgets('approval summary card triggers household approval callback', (
    tester,
  ) async {
    var requested = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ApprovalSummaryCard(
            approvalRequests: [
              ApprovalRequest(
                requestId: 'APR1',
                member: householdMembers.first,
                cartTotal: products.first.price,
                note: 'Please review this cart.',
                createdAt: DateTime(2026, 6, 1),
              ),
            ],
            onRequestApproval: () => requested = true,
          ),
        ),
      ),
    );

    expect(find.text('Family approval'), findsOneWidget);
    expect(find.text('1 pending'), findsOneWidget);

    await tester.tap(find.text('Request approval'));
    await tester.pump();

    expect(requested, isTrue);
  });

  testWidgets('reward center redeems eligible voucher', (tester) async {
    RewardVoucher? redeemed;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RewardCenterCard(
            availablePoints: 1000,
            redeemedRewardCodes: const {},
            onRedeemReward: (voucher) => redeemed = voucher,
            onShareReward: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Reward center'), findsOneWidget);
    expect(find.text('1000 pts'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Redeem').first);
    await tester.pump();

    expect(redeemed?.code, rewardVouchers.first.code);
  });

  testWidgets('invoice request sheet saves billing details', (tester) async {
    InvoiceRequest? saved;
    final order = KiranaOrder(
      id: 'SKTEST',
      items: [CartLine(products.first, 2)],
      total: products.first.price * 2,
      discount: 0,
      deliveryFee: 0,
      payable: products.first.price * 2,
      slot: 'Today 6 PM - 8 PM',
      paymentMethod: 'UPI',
      deliveryAddress: customerAddress,
      deliveryInstruction: 'Ring bell and hand over',
      substitutionPreference: 'Call before replacing',
      reservationExpiresAt: DateTime(2026, 6, 1, 18),
      createdAt: DateTime(2026, 6, 1, 17),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InvoiceRequestSheet(
            order: order,
            existingRequest: null,
            onSubmit: (request) => saved = request,
            onWhatsApp: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Invoice for SKTEST'), findsOneWidget);
    await tester.enterText(
      find.byType(TextField).first,
      'Chandra Retail Buyer',
    );
    await tester.tap(find.text('Save request'));
    await tester.pump();

    expect(saved?.orderId, 'SKTEST');
    expect(saved?.billingName, 'Chandra Retail Buyer');
    expect(saved?.invoiceType, 'Retail bill');
  });

  testWidgets('address book switches selected delivery address', (
    tester,
  ) async {
    CustomerAddress selected = customerAddress;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => AddressBookCard(
              selectedAddress: selected,
              savedAddresses: savedCustomerAddresses,
              onAddressChanged: (address) => setState(() => selected = address),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Delivery address book'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);

    await tester.tap(find.text('Office'));
    await tester.pump();

    expect(selected.label, 'Office');
    expect(
      find.text('22, Bazaar Main Road, Shop Office • Opposite bus stand'),
      findsOneWidget,
    );
  });

  testWidgets('account recent order exposes repeat action', (tester) async {
    KiranaOrder? repeated;
    final order = KiranaOrder(
      id: 'SKREPEAT',
      items: [CartLine(products.first, 1)],
      total: products.first.price,
      discount: 0,
      deliveryFee: 0,
      payable: products.first.price,
      slot: 'Today 6 PM - 8 PM',
      paymentMethod: 'UPI',
      deliveryAddress: customerAddress,
      deliveryInstruction: 'Ring bell and hand over',
      substitutionPreference: 'Call before replacing',
      reservationExpiresAt: DateTime(2026, 6, 1, 18),
      createdAt: DateTime(2026, 6, 1, 17),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountPage(
            orders: [order],
            plans: const [],
            onShareOrder: (_) {},
            onRepeatOrder: (value) => repeated = value,
            onTrackOrder: (_) {},
            onAdvanceOrder: (_) {},
            onFeedbackOrder: (_) {},
            feedbackByOrderId: const {},
            onSupportOrder: (_) {},
            supportTicketsByOrderId: const {},
            onInvoiceOrder: (_) {},
            invoiceRequestsByOrderId: const {},
            onPaymentProofOrder: (_) {},
            paymentProofsByOrderId: const {},
            onRescheduleOrder: (_) {},
            deliveryChangeRequestsByOrderId: const {},
            onCancelOrder: (_) {},
            cancellationsByOrderId: const {},
            selectedAddress: customerAddress,
            savedAddresses: savedCustomerAddresses,
            onAddressChanged: (_) {},
            onAddSavedPlan: (_) {},
            preferences: const CustomerPreferences(
              languageCode: 'en',
              easyMode: false,
              voiceOrdering: true,
            ),
            onLanguageChanged: (_) {},
            onEasyModeChanged: (_) {},
            onVoiceOrderingChanged: (_) {},
            onStartVoiceOrder: () {},
            onShareInvite: () {},
            onShareStatement: () {},
            onShareNotificationDigest: () {},
            approvalRequests: const [],
            onShareApprovalRequest: (_) {},
            availableRewardPoints: 420,
            redeemedRewardCodes: const {},
            onRedeemReward: (_) {},
            onShareReward: (_) {},
          ),
        ),
      ),
    );

    await tester.scrollUntilVisible(find.text('Repeat'), 500);
    await tester.tap(find.text('Repeat'));
    await tester.pump();

    expect(repeated?.id, 'SKREPEAT');
  });

  testWidgets('payment proof sheet saves reference details', (tester) async {
    PaymentProof? saved;
    final order = KiranaOrder(
      id: 'SKPAY',
      items: [CartLine(products.first, 1)],
      total: products.first.price,
      discount: 0,
      deliveryFee: 0,
      payable: products.first.price,
      slot: 'Today 6 PM - 8 PM',
      paymentMethod: 'UPI',
      deliveryAddress: customerAddress,
      deliveryInstruction: 'Ring bell and hand over',
      substitutionPreference: 'Call before replacing',
      reservationExpiresAt: DateTime(2026, 6, 1, 18),
      createdAt: DateTime(2026, 6, 1, 17),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PaymentProofSheet(
            order: order,
            existingProof: null,
            onSubmit: (proof) => saved = proof,
            onWhatsApp: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Payment proof for SKPAY'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'UPI123456789');
    await tester.tap(find.text('Save proof'));
    await tester.pump();

    expect(saved?.orderId, 'SKPAY');
    expect(saved?.reference, 'UPI123456789');
    expect(saved?.method, 'UPI');
  });

  testWidgets('budget guard shows over budget guidance', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BudgetGuardCard(
            monthlySpend: 9500,
            cartPayable: 800,
            monthlyBudgetLimit: 10000,
          ),
        ),
      ),
    );

    expect(find.text('Monthly budget guard'), findsOneWidget);
    expect(find.text('Over budget'), findsOneWidget);
    expect(find.text('Budget overrun'), findsOneWidget);
  });

  testWidgets('delivery change sheet saves requested slot', (tester) async {
    DeliveryChangeRequest? saved;
    final order = KiranaOrder(
      id: 'SKSLOT',
      items: [CartLine(products.first, 1)],
      total: products.first.price,
      discount: 0,
      deliveryFee: 0,
      payable: products.first.price,
      slot: 'Today 6 PM - 8 PM',
      paymentMethod: 'UPI',
      deliveryAddress: customerAddress,
      deliveryInstruction: 'Ring bell and hand over',
      substitutionPreference: 'Call before replacing',
      reservationExpiresAt: DateTime(2026, 6, 1, 18),
      createdAt: DateTime(2026, 6, 1, 17),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DeliveryChangeSheet(
            order: order,
            existingRequest: null,
            onSubmit: (request) => saved = request,
            onWhatsApp: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Reschedule SKSLOT'), findsOneWidget);
    await tester.tap(find.text('Save request'));
    await tester.pump();

    expect(saved?.orderId, 'SKSLOT');
    expect(saved?.requestedSlot, 'Tomorrow 8 AM - 10 AM');
    expect(saved?.reason, 'Need a different time');
  });
}
