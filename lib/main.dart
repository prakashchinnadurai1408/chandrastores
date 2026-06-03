import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const SmartKiranaApp());

class SmartKiranaApp extends StatelessWidget {
  const SmartKiranaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Kirana',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0E7A3D)),
        useMaterial3: true,
        cardTheme: const CardThemeData(margin: EdgeInsets.zero),
      ),
      home: const LoginScreen(),
    );
  }
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.packSize,
    required this.price,
    required this.mrp,
    required this.inStock,
    required this.stockQty,
    required this.reorderLevel,
    required this.icon,
  });

  final String id;
  final String name;
  final String brand;
  final String category;
  final String packSize;
  final int price;
  final int mrp;
  final bool inStock;
  final int stockQty;
  final int reorderLevel;
  final IconData icon;

  int get saving => mrp - price;
  bool get lowStock => inStock && stockQty <= reorderLevel;
  String get stockLabel {
    if (!inStock || stockQty == 0) return 'Out of stock';
    if (lowStock) return 'Only $stockQty left';
    return 'In stock';
  }
}

class CartLine {
  CartLine(this.product, this.quantity);

  final Product product;
  int quantity;

  int get total => product.price * quantity;
}

class PlannerItem {
  const PlannerItem({
    required this.label,
    required this.frequency,
    required this.budget,
    required this.products,
  });

  final String label;
  final String frequency;
  final int budget;
  final List<String> products;
}

class SavedPlan {
  const SavedPlan({
    required this.id,
    required this.name,
    required this.frequency,
    required this.nextDelivery,
    required this.budget,
    required this.products,
    this.autoReminder = true,
  });

  final String id;
  final String name;
  final String frequency;
  final DateTime nextDelivery;
  final int budget;
  final List<String> products;
  final bool autoReminder;
}

class CustomerAddress {
  const CustomerAddress({
    required this.label,
    required this.line1,
    required this.landmark,
  });

  final String label;
  final String line1;
  final String landmark;
}

class CustomerWallet {
  const CustomerWallet({
    required this.baseLoyaltyPoints,
    required this.storeCreditLimit,
    required this.storeCreditUsed,
  });

  final int baseLoyaltyPoints;
  final int storeCreditLimit;
  final int storeCreditUsed;

  int get availableStoreCredit => storeCreditLimit - storeCreditUsed;
}

class CustomerPreferences {
  const CustomerPreferences({
    required this.languageCode,
    required this.easyMode,
    required this.voiceOrdering,
  });

  final String languageCode;
  final bool easyMode;
  final bool voiceOrdering;

  CustomerPreferences copyWith({
    String? languageCode,
    bool? easyMode,
    bool? voiceOrdering,
  }) => CustomerPreferences(
    languageCode: languageCode ?? this.languageCode,
    easyMode: easyMode ?? this.easyMode,
    voiceOrdering: voiceOrdering ?? this.voiceOrdering,
  );
}

class StoreInvite {
  const StoreInvite({
    required this.landingUrl,
    required this.referralCode,
    required this.rewardText,
  });

  final String landingUrl;
  final String referralCode;
  final String rewardText;
}

class HouseholdMember {
  const HouseholdMember({
    required this.name,
    required this.relation,
    required this.mobile,
    required this.role,
    required this.monthlyLimit,
  });

  final String name;
  final String relation;
  final String mobile;
  final String role;
  final int monthlyLimit;
}

class ApprovalRequest {
  const ApprovalRequest({
    required this.requestId,
    required this.member,
    required this.cartTotal,
    required this.note,
    required this.createdAt,
    this.status = 'Pending',
  });

  final String requestId;
  final HouseholdMember member;
  final int cartTotal;
  final String note;
  final DateTime createdAt;
  final String status;
}

class RewardVoucher {
  const RewardVoucher({
    required this.code,
    required this.title,
    required this.description,
    required this.pointsRequired,
    required this.discount,
    required this.validUntil,
  });

  final String code;
  final String title;
  final String description;
  final int pointsRequired;
  final int discount;
  final DateTime validUntil;

  bool canRedeem(int points) => points >= pointsRequired;
}

class KiranaOrder {
  const KiranaOrder({
    required this.id,
    required this.items,
    required this.total,
    required this.discount,
    required this.deliveryFee,
    required this.payable,
    required this.slot,
    required this.deliveryMode,
    required this.paymentMethod,
    required this.deliveryAddress,
    required this.deliveryInstruction,
    required this.substitutionPreference,
    required this.reservationExpiresAt,
    required this.createdAt,
    this.status = 'Received',
  });

  final String id;
  final List<CartLine> items;
  final int total;
  final int discount;
  final int deliveryFee;
  final int payable;
  final String slot;
  final String deliveryMode;
  final String paymentMethod;
  final CustomerAddress deliveryAddress;
  final String deliveryInstruction;
  final String substitutionPreference;
  final DateTime reservationExpiresAt;
  final DateTime createdAt;
  final String status;

  KiranaOrder copyWith({String? status}) => KiranaOrder(
    id: id,
    items: items,
    total: total,
    discount: discount,
    deliveryFee: deliveryFee,
    payable: payable,
    slot: slot,
    deliveryMode: deliveryMode,
    paymentMethod: paymentMethod,
    deliveryAddress: deliveryAddress,
    deliveryInstruction: deliveryInstruction,
    substitutionPreference: substitutionPreference,
    reservationExpiresAt: reservationExpiresAt,
    createdAt: createdAt,
    status: status ?? this.status,
  );

  int get itemCount => items.fold(0, (sum, line) => sum + line.quantity);
  int get reservedItemCount =>
      items.fold(0, (sum, line) => sum + line.quantity);
  bool get isStorePickup => deliveryMode == 'Store pickup';
  String get handoffCode {
    final cleaned = id.replaceAll(RegExp('[^A-Za-z0-9]'), '').toUpperCase();
    final suffix = cleaned.length <= 6
        ? cleaned.padLeft(6, '0')
        : cleaned.substring(cleaned.length - 6);
    return isStorePickup ? 'PU-$suffix' : 'DL-$suffix';
  }

  String get handoffCodeLabel =>
      isStorePickup ? 'Pickup code' : 'Delivery code';
  int get statusIndex {
    if (status == 'Cancelled') return orderStatusSteps.length - 1;
    return orderStatusSteps
        .indexOf(status)
        .clamp(0, orderStatusSteps.length - 1)
        .toInt();
  }
}

class OrderFeedback {
  const OrderFeedback({
    required this.orderId,
    required this.rating,
    required this.issueTag,
    required this.note,
    required this.createdAt,
  });

  final String orderId;
  final int rating;
  final String issueTag;
  final String note;
  final DateTime createdAt;
}

class SupportTicket {
  const SupportTicket({
    required this.ticketId,
    required this.orderId,
    required this.issueType,
    required this.priority,
    required this.description,
    required this.createdAt,
    this.status = 'Open',
  });

  final String ticketId;
  final String orderId;
  final String issueType;
  final String priority;
  final String description;
  final DateTime createdAt;
  final String status;
}

class OrderCancellation {
  const OrderCancellation({
    required this.orderId,
    required this.reason,
    required this.refundMode,
    required this.createdAt,
  });

  final String orderId;
  final String reason;
  final String refundMode;
  final DateTime createdAt;
}

class InvoiceRequest {
  const InvoiceRequest({
    required this.orderId,
    required this.invoiceType,
    required this.billingName,
    required this.gstin,
    required this.email,
    required this.createdAt,
  });

  final String orderId;
  final String invoiceType;
  final String billingName;
  final String gstin;
  final String email;
  final DateTime createdAt;
}

class PaymentProof {
  const PaymentProof({
    required this.orderId,
    required this.method,
    required this.reference,
    required this.amount,
    required this.createdAt,
  });

  final String orderId;
  final String method;
  final String reference;
  final int amount;
  final DateTime createdAt;
}

class DeliveryChangeRequest {
  const DeliveryChangeRequest({
    required this.orderId,
    required this.requestedSlot,
    required this.reason,
    required this.note,
    required this.createdAt,
  });

  final String orderId;
  final String requestedSlot;
  final String reason;
  final String note;
  final DateTime createdAt;
}

class AppNotification {
  const AppNotification({
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
  });

  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
}

List<AppNotification> buildNotifications({
  required List<KiranaOrder> orders,
  required List<SavedPlan> plans,
  required Map<String, SupportTicket> tickets,
}) {
  final notifications = <AppNotification>[];
  final now = DateTime.now();
  for (final ticket in tickets.values) {
    notifications.add(
      AppNotification(
        title: 'Support ${ticket.status}',
        message:
            '${ticket.issueType} for ${ticket.orderId} • ${ticket.priority}',
        type: 'Support',
        createdAt: ticket.createdAt,
      ),
    );
  }
  for (final order in orders.take(3)) {
    notifications.add(
      AppNotification(
        title: 'Order ${order.status}',
        message:
            '${order.id} • ${currency.format(order.payable)} • ${order.slot}',
        type: 'Order',
        createdAt: order.createdAt,
      ),
    );
  }
  for (final plan in plans.where((plan) => plan.autoReminder).take(3)) {
    notifications.add(
      AppNotification(
        title: 'Plan reminder',
        message:
            '${plan.name} due ${DateFormat('d MMM').format(plan.nextDelivery)}',
        type: 'Planner',
        createdAt: plan.nextDelivery.isBefore(now) ? now : plan.nextDelivery,
      ),
    );
  }
  if (notifications.isEmpty) {
    notifications.add(
      AppNotification(
        title: 'Welcome to Smart Kirana',
        message:
            'Place an order or schedule a basket to receive reminders here.',
        type: 'Info',
        createdAt: now,
      ),
    );
  }
  notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return notifications;
}

class GroceryStatement {
  const GroceryStatement({
    required this.monthLabel,
    required this.orderCount,
    required this.totalSpend,
    required this.digitalPayments,
    required this.topCategories,
  });

  final String monthLabel;
  final int orderCount;
  final int totalSpend;
  final int digitalPayments;
  final Map<String, int> topCategories;
}

GroceryStatement buildStatement(List<KiranaOrder> orders) {
  final now = DateTime.now();
  final monthLabel = DateFormat('MMMM yyyy').format(now);
  final categoryTotals = <String, int>{};
  for (final order in orders) {
    for (final line in order.items) {
      categoryTotals.update(
        line.product.category,
        (value) => value + line.total,
        ifAbsent: () => line.total,
      );
    }
  }
  final sortedEntries = categoryTotals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return GroceryStatement(
    monthLabel: monthLabel,
    orderCount: orders.length,
    totalSpend: orders.fold(0, (sum, order) => sum + order.payable),
    digitalPayments: orders
        .where((order) => order.paymentMethod != 'Cash')
        .length,
    topCategories: Map.fromEntries(sortedEntries.take(3)),
  );
}

class SmartOffer {
  const SmartOffer({
    required this.code,
    required this.title,
    required this.description,
    required this.minimumOrderValue,
    required this.discount,
  });

  final String code;
  final String title;
  final String description;
  final int minimumOrderValue;
  final int discount;

  bool isEligible(int subtotal) => subtotal >= minimumOrderValue;
}

const storeWhatsAppNumber = '919876543210';
const storeUpiId = 'chandrastores@upi';
const appInvite = StoreInvite(
  landingUrl: 'https://chandrastores.example/app',
  referralCode: 'CHANDRA50',
  rewardText: 'Get ₹50 grocery savings after your first app order',
);
const customerAddress = CustomerAddress(
  label: 'Home',
  line1: '12, Market Street, Near Temple Road',
  landmark: 'Green gate, 2nd floor',
);
const savedCustomerAddresses = <CustomerAddress>[
  customerAddress,
  CustomerAddress(
    label: 'Parents',
    line1: '4, Lake View Colony, West Gate',
    landmark: 'Blue door, ground floor',
  ),
  CustomerAddress(
    label: 'Office',
    line1: '22, Bazaar Main Road, Shop Office',
    landmark: 'Opposite bus stand',
  ),
];
const customerWallet = CustomerWallet(
  baseLoyaltyPoints: 420,
  storeCreditLimit: 5000,
  storeCreditUsed: 1250,
);
final currency = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);
const householdMembers = <HouseholdMember>[
  HouseholdMember(
    name: 'Priya',
    relation: 'Spouse',
    mobile: '919812345601',
    role: 'Approver',
    monthlyLimit: 7000,
  ),
  HouseholdMember(
    name: 'Ravi',
    relation: 'Father',
    mobile: '919812345602',
    role: 'Khata reviewer',
    monthlyLimit: 5000,
  ),
  HouseholdMember(
    name: 'Meena',
    relation: 'Daughter',
    mobile: '919812345603',
    role: 'List contributor',
    monthlyLimit: 1500,
  ),
];

final rewardVouchers = <RewardVoucher>[
  RewardVoucher(
    code: 'LOYAL50',
    title: '₹50 loyalty cashback',
    description: 'Redeem on any app order above ₹499.',
    pointsRequired: 250,
    discount: 50,
    validUntil: DateTime(2026, 7, 31),
  ),
  RewardVoucher(
    code: 'FAMILY100',
    title: 'Family basket reward',
    description: 'Use after household approval for baskets above ₹1,999.',
    pointsRequired: 500,
    discount: 100,
    validUntil: DateTime(2026, 8, 31),
  ),
  RewardVoucher(
    code: 'MONTHLY200',
    title: 'Monthly grocery bonus',
    description: 'Best for monthly stock-up orders above ₹4,999.',
    pointsRequired: 900,
    discount: 200,
    validUntil: DateTime(2026, 9, 30),
  ),
];

const orderStatusSteps = [
  'Received',
  'Packing',
  'Ready for dispatch',
  'Out for delivery',
  'Delivered',
];
const terminalOrderStatuses = ['Delivered', 'Cancelled'];
const fulfilmentModes = ['Home delivery', 'Store pickup'];
const supportedLanguages = {
  'en': 'English',
  'ta': 'தமிழ்',
  'hi': 'हिन्दी',
  'kn': 'ಕನ್ನಡ',
};
const freeDeliveryThreshold = 999;
const deliverySlotFees = {
  'Today 6 PM - 8 PM': 29,
  'Tomorrow 8 AM - 10 AM': 19,
  'Sunday weekly delivery': 0,
};
const defaultMonthlyBudgetLimit = 10000;

int deliveryFeeFor(
  String slot,
  int subtotal, [
  String mode = 'Home delivery',
]) => mode == 'Store pickup' || subtotal >= freeDeliveryThreshold
    ? 0
    : deliverySlotFees[slot] ?? 0;

const smartOffers = <SmartOffer>[
  SmartOffer(
    code: 'WEEKLY100',
    title: 'Weekly basket reward',
    description: 'Save ₹100 on planned grocery baskets above ₹1,999.',
    minimumOrderValue: 1999,
    discount: 100,
  ),
  SmartOffer(
    code: 'MONTHLY250',
    title: 'Monthly stock-up bonus',
    description: 'Save ₹250 when your monthly staples cart crosses ₹4,999.',
    minimumOrderValue: 4999,
    discount: 250,
  ),
  SmartOffer(
    code: 'LOYAL50',
    title: 'Loyal customer thank-you',
    description: 'Use 50 loyalty points as instant grocery savings.',
    minimumOrderValue: 799,
    discount: 50,
  ),
];

const products = <Product>[
  Product(
    id: 'rice-sona-25',
    name: 'Sona Masoori Rice',
    brand: 'Store Select',
    category: 'Staples',
    packSize: '25 kg',
    price: 1399,
    mrp: 1499,
    inStock: true,
    stockQty: 9,
    reorderLevel: 6,
    icon: Icons.rice_bowl,
  ),
  Product(
    id: 'atta-10',
    name: 'Whole Wheat Atta',
    brand: 'Aashirvaad',
    category: 'Staples',
    packSize: '10 kg',
    price: 469,
    mrp: 520,
    inStock: true,
    stockQty: 18,
    reorderLevel: 8,
    icon: Icons.bakery_dining,
  ),
  Product(
    id: 'toor-2',
    name: 'Toor Dal',
    brand: 'Tata Sampann',
    category: 'Pulses',
    packSize: '2 kg',
    price: 339,
    mrp: 380,
    inStock: true,
    stockQty: 5,
    reorderLevel: 6,
    icon: Icons.grain,
  ),
  Product(
    id: 'oil-5',
    name: 'Sunflower Oil',
    brand: 'Fortune',
    category: 'Oil & Ghee',
    packSize: '5 L',
    price: 745,
    mrp: 820,
    inStock: true,
    stockQty: 4,
    reorderLevel: 5,
    icon: Icons.water_drop,
  ),
  Product(
    id: 'milk-1',
    name: 'Toned Milk',
    brand: 'Daily Fresh',
    category: 'Dairy',
    packSize: '1 L',
    price: 58,
    mrp: 60,
    inStock: true,
    stockQty: 24,
    reorderLevel: 10,
    icon: Icons.local_drink,
  ),
  Product(
    id: 'curd-500',
    name: 'Fresh Curd',
    brand: 'Nandini',
    category: 'Dairy',
    packSize: '500 g',
    price: 34,
    mrp: 36,
    inStock: true,
    stockQty: 7,
    reorderLevel: 8,
    icon: Icons.icecream,
  ),
  Product(
    id: 'tea-1',
    name: 'Premium Tea',
    brand: 'Tata Tea',
    category: 'Beverages',
    packSize: '1 kg',
    price: 489,
    mrp: 540,
    inStock: true,
    stockQty: 12,
    reorderLevel: 5,
    icon: Icons.coffee,
  ),
  Product(
    id: 'sugar-5',
    name: 'Sugar',
    brand: 'Store Select',
    category: 'Staples',
    packSize: '5 kg',
    price: 245,
    mrp: 270,
    inStock: true,
    stockQty: 20,
    reorderLevel: 8,
    icon: Icons.cake,
  ),
  Product(
    id: 'detergent-4',
    name: 'Detergent Powder',
    brand: 'Surf Excel',
    category: 'Home Care',
    packSize: '4 kg',
    price: 699,
    mrp: 760,
    inStock: true,
    stockQty: 6,
    reorderLevel: 4,
    icon: Icons.local_laundry_service,
  ),
  Product(
    id: 'soap-4',
    name: 'Bath Soap Combo',
    brand: 'Pears',
    category: 'Personal Care',
    packSize: '4 x 125 g',
    price: 219,
    mrp: 248,
    inStock: false,
    stockQty: 0,
    reorderLevel: 5,
    icon: Icons.soap,
  ),
];

const plannerPresets = <PlannerItem>[
  PlannerItem(
    label: 'Weekly Fresh Basket',
    frequency: 'Every Monday',
    budget: 1200,
    products: ['Toned Milk', 'Fresh Curd', 'Whole Wheat Atta', 'Sugar'],
  ),
  PlannerItem(
    label: 'Biweekly Staples Refill',
    frequency: '1st and 15th',
    budget: 2400,
    products: ['Sona Masoori Rice', 'Toor Dal', 'Sunflower Oil', 'Premium Tea'],
  ),
  PlannerItem(
    label: 'Monthly Home Care',
    frequency: 'Monthly',
    budget: 1400,
    products: ['Detergent Powder', 'Bath Soap Combo'],
  ),
];

List<Product> substituteProducts(Product product) => products
    .where(
      (candidate) =>
          candidate.id != product.id &&
          candidate.category == product.category &&
          candidate.inStock,
    )
    .take(3)
    .toList(growable: false);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final mobileController = TextEditingController();
  final otpController = TextEditingController();
  bool otpSent = false;

  @override
  void dispose() {
    mobileController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(18),
                child: Icon(
                  Icons.storefront,
                  size: 56,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Smart Kirana',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Order daily essentials, plan weekly groceries, and pay with UPI, cards, QR, GPay, PhonePe, or Paytm.',
              ),
              const SizedBox(height: 32),
              TextField(
                controller: mobileController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  prefixText: '+91 ',
                  labelText: 'Mobile / WhatsApp number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (otpSent)
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'WhatsApp OTP',
                    helperText: 'Use 123456 for demo login',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  if (!otpSent) {
                    setState(() => otpSent = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Demo WhatsApp OTP sent: 123456'),
                      ),
                    );
                    return;
                  }
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const ShopShell()),
                  );
                },
                icon: Icon(otpSent ? Icons.verified_user : Icons.message),
                label: Text(
                  otpSent ? 'Verify and continue' : 'Send WhatsApp OTP',
                ),
              ),
              const SizedBox(height: 24),
              const InfoTile(
                icon: Icons.qr_code_2,
                title: 'Download using store QR',
                subtitle:
                    'The same app link can be printed on bills, delivery bags, and shop posters.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShopShell extends StatefulWidget {
  const ShopShell({super.key});

  @override
  State<ShopShell> createState() => _ShopShellState();
}

class _ShopShellState extends State<ShopShell> {
  final Map<String, CartLine> cart = {};
  final List<KiranaOrder> orderHistory = [];
  final List<SavedPlan> savedPlans = [];
  final Map<String, OrderFeedback> feedbackByOrderId = {};
  final Map<String, SupportTicket> supportTicketsByOrderId = {};
  final Map<String, OrderCancellation> cancellationsByOrderId = {};
  final Map<String, InvoiceRequest> invoiceRequestsByOrderId = {};
  final Map<String, PaymentProof> paymentProofsByOrderId = {};
  final Map<String, DeliveryChangeRequest> deliveryChangeRequestsByOrderId = {};
  final List<ApprovalRequest> approvalRequests = [];
  final Set<String> redeemedRewardCodes = {};
  SmartOffer? appliedOffer;
  CustomerPreferences preferences = const CustomerPreferences(
    languageCode: 'en',
    easyMode: false,
    voiceOrdering: true,
  );
  int tabIndex = 0;
  String query = '';
  String category = 'All';
  String deliverySlot = 'Today 6 PM - 8 PM';
  String fulfilmentMode = 'Home delivery';
  String paymentMethod = 'UPI';
  CustomerAddress selectedAddress = customerAddress;
  String deliveryInstruction = 'Ring bell and hand over';
  String substitutionPreference = 'Call before replacing';

  List<String> get categories => [
    'All',
    ...{for (final product in products) product.category},
  ];
  int get cartCount => cart.values.fold(0, (sum, line) => sum + line.quantity);
  int get subtotal => cart.values.fold(0, (sum, line) => sum + line.total);
  int get offerDiscount => (appliedOffer?.isEligible(subtotal) ?? false)
      ? appliedOffer!.discount
      : 0;
  int get deliveryFee => deliveryFeeFor(deliverySlot, subtotal, fulfilmentMode);
  int get payable => (subtotal - offerDiscount + deliveryFee)
      .clamp(0, subtotal + deliveryFee)
      .toInt();
  int get savings =>
      cart.values.fold(
        0,
        (sum, line) => sum + line.product.saving * line.quantity,
      ) +
      offerDiscount;
  int get monthlySpend =>
      orderHistory.fold(0, (sum, order) => sum + order.payable);
  int get earnedRewardPoints =>
      orderHistory.fold(0, (sum, order) => sum + order.payable ~/ 100);
  int get redeemedRewardPoints => rewardVouchers
      .where((voucher) => redeemedRewardCodes.contains(voucher.code))
      .fold(0, (sum, voucher) => sum + voucher.pointsRequired);
  int get availableRewardPoints =>
      customerWallet.baseLoyaltyPoints +
      earnedRewardPoints -
      redeemedRewardPoints;

  void addToCart(Product product, [int quantity = 1]) {
    if (!product.inStock) {
      final substitutes = substituteProducts(
        product,
      ).map((candidate) => candidate.name).join(', ');
      final suffix = substitutes.isEmpty
          ? 'No substitute is available right now.'
          : 'Try: $substitutes.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} is currently out of stock. $suffix'),
        ),
      );
      return;
    }
    final currentQuantity = cart[product.id]?.quantity ?? 0;
    if (currentQuantity + quantity > product.stockQty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Only ${product.stockQty} ${product.name} available right now',
          ),
        ),
      );
      return;
    }
    setState(() {
      cart.update(
        product.id,
        (line) => line..quantity += quantity,
        ifAbsent: () => CartLine(product, quantity),
      );
    });
  }

  void changeQuantity(String productId, int delta) {
    setState(() {
      final line = cart[productId];
      if (line == null) return;
      if (delta > 0 && line.quantity >= line.product.stockQty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Only ${line.product.stockQty} ${line.product.name} available right now',
            ),
          ),
        );
        return;
      }
      line.quantity += delta;
      if (line.quantity <= 0) cart.remove(productId);
      if (!(appliedOffer?.isEligible(subtotal) ?? true)) appliedOffer = null;
    });
  }

  void addPlanner(PlannerItem item) {
    for (final name in item.products) {
      final product = products.firstWhere(
        (candidate) => candidate.name == name,
      );
      addToCart(product);
    }
    setState(() => tabIndex = 2);
  }

  void repeatOrder(KiranaOrder order) {
    var addedLines = 0;
    setState(() {
      for (final line in order.items) {
        final quantity = line.quantity.clamp(0, line.product.stockQty).toInt();
        if (quantity <= 0 || !line.product.inStock) continue;
        cart[line.product.id] = CartLine(line.product, quantity);
        addedLines += 1;
      }
      selectedAddress = order.deliveryAddress;
      deliverySlot = order.slot;
      fulfilmentMode = order.deliveryMode;
      deliveryInstruction = order.deliveryInstruction;
      substitutionPreference = order.substitutionPreference;
      tabIndex = 2;
    });
    final message = addedLines == 0
        ? 'No repeatable items are in stock for ${order.id}'
        : 'Repeated $addedLines items from ${order.id}';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void schedulePlan(PlannerItem item) {
    final plan = SavedPlan(
      id: 'PLAN${DateTime.now().millisecondsSinceEpoch}',
      name: item.label,
      frequency: item.frequency,
      nextDelivery: nextDeliveryFor(item.frequency),
      budget: item.budget,
      products: item.products,
    );
    setState(() => savedPlans.insert(0, plan));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.label} scheduled with WhatsApp reminders'),
      ),
    );
  }

  DateTime nextDeliveryFor(String frequency) {
    final now = DateTime.now();
    if (frequency.contains('15th')) return now.add(const Duration(days: 14));
    if (frequency == 'Monthly') return now.add(const Duration(days: 30));
    return now.add(const Duration(days: 7));
  }

  void addSavedPlanToCart(SavedPlan plan) {
    for (final name in plan.products) {
      final product = products.firstWhere(
        (candidate) => candidate.name == name,
      );
      addToCart(product);
    }
    setState(() => tabIndex = 2);
  }

  void applyOffer(SmartOffer offer) {
    if (!offer.isEligible(subtotal)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Add ${currency.format(offer.minimumOrderValue - subtotal)} more to unlock ${offer.code}',
          ),
        ),
      );
      return;
    }
    setState(() => appliedOffer = offer);
  }

  Future<void> placeOrder() async {
    final order = KiranaOrder(
      id: 'SK${DateTime.now().millisecondsSinceEpoch}',
      items: cart.values
          .map((line) => CartLine(line.product, line.quantity))
          .toList(growable: false),
      total: subtotal,
      discount: offerDiscount,
      deliveryFee: deliveryFee,
      payable: payable,
      slot: deliverySlot,
      deliveryMode: fulfilmentMode,
      paymentMethod: paymentMethod,
      deliveryAddress: selectedAddress,
      deliveryInstruction: deliveryInstruction,
      substitutionPreference: substitutionPreference,
      reservationExpiresAt: DateTime.now().add(const Duration(minutes: 15)),
      createdAt: DateTime.now(),
    );
    setState(() {
      orderHistory.insert(0, order);
      cart.clear();
      appliedOffer = null;
    });

    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => OrderConfirmationSheet(
        order: order,
        onPay: () => openPayment(order),
        onShareWhatsApp: () => shareOrderOnWhatsApp(order),
      ),
    );
  }

  Future<void> shareOrderOnWhatsApp(KiranaOrder order) async {
    final summary = order.items
        .map(
          (line) =>
              '${line.quantity} x ${line.product.name} (${line.product.packSize})',
        )
        .join(', ');
    final message = Uri.encodeComponent(
      'Smart Kirana order ${order.id}: $summary. Total: ${currency.format(order.payable)} including delivery fee ${currency.format(order.deliveryFee)}. Fulfilment: ${order.deliveryMode}. ${order.handoffCodeLabel}: ${order.handoffCode}. Slot: ${order.slot}. Payment: ${order.paymentMethod}. Delivery: ${order.deliveryInstruction}. Substitution: ${order.substitutionPreference}. Stock reserved until ${DateFormat('hh:mm a').format(order.reservationExpiresAt)}. Address: ${order.deliveryAddress.label} - ${order.deliveryAddress.line1}, ${order.deliveryAddress.landmark}.',
    );
    final uri = Uri.parse('https://wa.me/$storeWhatsAppNumber?text=$message');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> openPayment(KiranaOrder order) async {
    final upiUri = Uri.parse(
      'upi://pay?pa=$storeUpiId&pn=Chandra%20Stores&am=${order.payable}&cu=INR&tn=${order.id}',
    );
    await launchUrl(upiUri, mode: LaunchMode.externalApplication);
  }

  Future<void> showOrderTracking(KiranaOrder order) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => OrderTrackingSheet(order: order),
    );
  }

  Future<void> showHandoffPass(KiranaOrder order) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => OrderHandoffPassSheet(order: order),
    );
  }

  void advanceOrderStatus(KiranaOrder order) {
    if (terminalOrderStatuses.contains(order.status)) return;
    final current = orderStatusSteps.indexOf(order.status);
    if (current < 0 || current >= orderStatusSteps.length - 1) return;
    final next = orderStatusSteps[current + 1];
    setState(() {
      final index = orderHistory.indexWhere(
        (candidate) => candidate.id == order.id,
      );
      if (index != -1) orderHistory[index] = order.copyWith(status: next);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${order.id} moved to $next')));
  }

  Future<void> showCancellationSheet(KiranaOrder order) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => CancellationSheet(
        order: order,
        existingCancellation: cancellationsByOrderId[order.id],
        onSubmit: (cancellation) {
          setState(() {
            cancellationsByOrderId[order.id] = cancellation;
            final index = orderHistory.indexWhere(
              (candidate) => candidate.id == order.id,
            );
            if (index != -1) {
              orderHistory[index] = order.copyWith(status: 'Cancelled');
            }
          });
          Navigator.of(context).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${order.id} cancelled')));
        },
        onWhatsApp: shareCancellationOnWhatsApp,
      ),
    );
  }

  Future<void> shareCancellationOnWhatsApp(
    OrderCancellation cancellation,
  ) async {
    final message = Uri.encodeComponent(
      'Smart Kirana cancellation request for order ${cancellation.orderId}. Reason: ${cancellation.reason}. Refund mode: ${cancellation.refundMode}.',
    );
    final uri = Uri.parse('https://wa.me/$storeWhatsAppNumber?text=$message');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> showFeedbackSheet(KiranaOrder order) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => FeedbackSheet(
        order: order,
        initialFeedback: feedbackByOrderId[order.id],
        onSubmit: (feedback) {
          setState(() => feedbackByOrderId[order.id] = feedback);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Thanks for rating ${order.id}')),
          );
        },
      ),
    );
  }

  Future<void> showSupportTicketSheet(KiranaOrder order) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SupportTicketSheet(
        order: order,
        existingTicket: supportTicketsByOrderId[order.id],
        onSubmit: (ticket) {
          setState(() => supportTicketsByOrderId[order.id] = ticket);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Support ticket ${ticket.ticketId} created'),
            ),
          );
        },
        onWhatsApp: shareSupportTicketOnWhatsApp,
      ),
    );
  }

  Future<void> shareSupportTicketOnWhatsApp(SupportTicket ticket) async {
    final message = Uri.encodeComponent(
      'Smart Kirana support ticket ${ticket.ticketId} for order ${ticket.orderId}. Issue: ${ticket.issueType}. Priority: ${ticket.priority}. Details: ${ticket.description}.',
    );
    final uri = Uri.parse('https://wa.me/$storeWhatsAppNumber?text=$message');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> showInvoiceRequestSheet(KiranaOrder order) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => InvoiceRequestSheet(
        order: order,
        existingRequest: invoiceRequestsByOrderId[order.id],
        onSubmit: (request) {
          setState(() => invoiceRequestsByOrderId[order.id] = request);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invoice request saved for ${order.id}')),
          );
        },
        onWhatsApp: shareInvoiceRequestOnWhatsApp,
      ),
    );
  }

  Future<void> shareInvoiceRequestOnWhatsApp(InvoiceRequest request) async {
    final message = Uri.encodeComponent(
      'Smart Kirana invoice request for order ${request.orderId}. Type: ${request.invoiceType}. Billing name: ${request.billingName}. GSTIN: ${request.gstin.isEmpty ? 'Not provided' : request.gstin}. Email: ${request.email.isEmpty ? 'WhatsApp only' : request.email}.',
    );
    final uri = Uri.parse('https://wa.me/$storeWhatsAppNumber?text=$message');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> showPaymentProofSheet(KiranaOrder order) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => PaymentProofSheet(
        order: order,
        existingProof: paymentProofsByOrderId[order.id],
        onSubmit: (proof) {
          setState(() => paymentProofsByOrderId[order.id] = proof);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment proof saved for ${order.id}')),
          );
        },
        onWhatsApp: sharePaymentProofOnWhatsApp,
      ),
    );
  }

  Future<void> sharePaymentProofOnWhatsApp(PaymentProof proof) async {
    final message = Uri.encodeComponent(
      'Smart Kirana payment proof for order ${proof.orderId}. Method: ${proof.method}. Reference: ${proof.reference}. Amount: ${currency.format(proof.amount)}.',
    );
    final uri = Uri.parse('https://wa.me/$storeWhatsAppNumber?text=$message');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> showDeliveryChangeSheet(KiranaOrder order) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => DeliveryChangeSheet(
        order: order,
        existingRequest: deliveryChangeRequestsByOrderId[order.id],
        onSubmit: (request) {
          setState(() => deliveryChangeRequestsByOrderId[order.id] = request);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Delivery change requested for ${order.id}'),
            ),
          );
        },
        onWhatsApp: shareDeliveryChangeOnWhatsApp,
      ),
    );
  }

  Future<void> shareDeliveryChangeOnWhatsApp(
    DeliveryChangeRequest request,
  ) async {
    final message = Uri.encodeComponent(
      'Smart Kirana delivery change for order ${request.orderId}. Requested slot: ${request.requestedSlot}. Reason: ${request.reason}. Note: ${request.note.isEmpty ? 'No note' : request.note}.',
    );
    final uri = Uri.parse('https://wa.me/$storeWhatsAppNumber?text=$message');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void updateLanguage(String languageCode) => setState(
    () => preferences = preferences.copyWith(languageCode: languageCode),
  );

  void toggleEasyMode(bool value) =>
      setState(() => preferences = preferences.copyWith(easyMode: value));

  void toggleVoiceOrdering(bool value) =>
      setState(() => preferences = preferences.copyWith(voiceOrdering: value));

  Future<void> startVoiceOrder() async {
    final language = supportedLanguages[preferences.languageCode] ?? 'English';
    final message = Uri.encodeComponent(
      'Smart Kirana voice order request. Please call/WhatsApp me in $language and help build my grocery basket.',
    );
    final uri = Uri.parse('https://wa.me/$storeWhatsAppNumber?text=$message');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> shareAppInvite() async {
    final message = Uri.encodeComponent(
      'Download Smart Kirana for Chandra Stores: ${appInvite.landingUrl}. Use referral code ${appInvite.referralCode}. ${appInvite.rewardText}.',
    );
    final uri = Uri.parse('https://wa.me/?text=$message');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> shareMonthlyStatement() async {
    final statement = buildStatement(orderHistory);
    final categories = statement.topCategories.entries
        .map((entry) => '${entry.key}: ${currency.format(entry.value)}')
        .join(', ');
    final message = Uri.encodeComponent(
      'Smart Kirana ${statement.monthLabel} statement: ${statement.orderCount} orders, spend ${currency.format(statement.totalSpend)}, digital payments ${statement.digitalPayments}/${statement.orderCount}. Top categories: ${categories.isEmpty ? 'No orders yet' : categories}.',
    );
    final uri = Uri.parse('https://wa.me/?text=$message');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> shareNotificationDigest() async {
    final notifications = buildNotifications(
      orders: orderHistory,
      plans: savedPlans,
      tickets: supportTicketsByOrderId,
    );
    final digest = notifications
        .take(5)
        .map(
          (notification) =>
              '${notification.type}: ${notification.title} - ${notification.message}',
        )
        .join(' | ');
    final message = Uri.encodeComponent(
      'Smart Kirana notification digest: $digest',
    );
    final uri = Uri.parse('https://wa.me/?text=$message');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> showApprovalRequestSheet() async {
    if (cart.isEmpty) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => ApprovalRequestSheet(
        cartTotal: payable,
        onSubmit: (request) {
          setState(() => approvalRequests.insert(0, request));
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Approval requested from ${request.member.name}'),
            ),
          );
        },
        onWhatsApp: shareApprovalRequest,
      ),
    );
  }

  Future<void> shareApprovalRequest(ApprovalRequest request) async {
    final message = Uri.encodeComponent(
      'Smart Kirana family approval ${request.requestId}: cart total ${currency.format(request.cartTotal)}. Note: ${request.note}. Please approve before checkout.',
    );
    final uri = Uri.parse(
      'https://wa.me/${request.member.mobile}?text=$message',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void redeemRewardVoucher(RewardVoucher voucher) {
    if (redeemedRewardCodes.contains(voucher.code)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${voucher.code} already redeemed')),
      );
      return;
    }
    if (!voucher.canRedeem(availableRewardPoints)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Need ${voucher.pointsRequired - availableRewardPoints} more points for ${voucher.code}',
          ),
        ),
      );
      return;
    }
    setState(() => redeemedRewardCodes.add(voucher.code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${voucher.code} saved for checkout')),
    );
  }

  Future<void> shareRewardVoucher(RewardVoucher voucher) async {
    final message = Uri.encodeComponent(
      'Smart Kirana reward ${voucher.code}: ${voucher.title}, ${currency.format(voucher.discount)} value, valid until ${DateFormat('d MMM yyyy').format(voucher.validUntil)}.',
    );
    final uri = Uri.parse('https://wa.me/?text=$message');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      CataloguePage(
        categories: categories,
        category: category,
        query: query,
        onQueryChanged: (value) => setState(() => query = value),
        onCategoryChanged: (value) => setState(() => category = value),
        onAdd: addToCart,
      ),
      PlannerPage(
        activePlans: savedPlans,
        onAddPlan: addPlanner,
        onSchedulePlan: schedulePlan,
        onAddSavedPlan: addSavedPlanToCart,
      ),
      CartPage(
        lines: cart.values.toList(),
        subtotal: subtotal,
        offerDiscount: offerDiscount,
        deliveryFee: deliveryFee,
        savings: savings,
        monthlySpend: monthlySpend,
        monthlyBudgetLimit: defaultMonthlyBudgetLimit,
        appliedOffer: appliedOffer,
        deliverySlot: deliverySlot,
        fulfilmentMode: fulfilmentMode,
        paymentMethod: paymentMethod,
        selectedAddress: selectedAddress,
        savedAddresses: savedCustomerAddresses,
        deliveryInstruction: deliveryInstruction,
        substitutionPreference: substitutionPreference,
        onQuantity: changeQuantity,
        onSlotChanged: (value) => setState(() => deliverySlot = value),
        onFulfilmentModeChanged: (value) =>
            setState(() => fulfilmentMode = value),
        onPaymentChanged: (value) => setState(() => paymentMethod = value),
        onAddressChanged: (value) => setState(() => selectedAddress = value),
        onDeliveryInstructionChanged: (value) =>
            setState(() => deliveryInstruction = value),
        onSubstitutionPreferenceChanged: (value) =>
            setState(() => substitutionPreference = value),
        onApplyOffer: applyOffer,
        onRequestApproval: cart.isEmpty ? null : showApprovalRequestSheet,
        approvalRequests: approvalRequests,
        onCheckout: cart.isEmpty ? null : placeOrder,
      ),
      AccountPage(
        orders: orderHistory,
        plans: savedPlans,
        onShareOrder: shareOrderOnWhatsApp,
        onRepeatOrder: repeatOrder,
        onTrackOrder: showOrderTracking,
        onShowHandoffPass: showHandoffPass,
        onAdvanceOrder: advanceOrderStatus,
        onFeedbackOrder: showFeedbackSheet,
        feedbackByOrderId: feedbackByOrderId,
        onSupportOrder: showSupportTicketSheet,
        supportTicketsByOrderId: supportTicketsByOrderId,
        onInvoiceOrder: showInvoiceRequestSheet,
        invoiceRequestsByOrderId: invoiceRequestsByOrderId,
        onPaymentProofOrder: showPaymentProofSheet,
        paymentProofsByOrderId: paymentProofsByOrderId,
        onRescheduleOrder: showDeliveryChangeSheet,
        deliveryChangeRequestsByOrderId: deliveryChangeRequestsByOrderId,
        onCancelOrder: showCancellationSheet,
        cancellationsByOrderId: cancellationsByOrderId,
        selectedAddress: selectedAddress,
        savedAddresses: savedCustomerAddresses,
        onAddressChanged: (value) => setState(() => selectedAddress = value),
        onAddSavedPlan: addSavedPlanToCart,
        preferences: preferences,
        onLanguageChanged: updateLanguage,
        onEasyModeChanged: toggleEasyMode,
        onVoiceOrderingChanged: toggleVoiceOrdering,
        onStartVoiceOrder: startVoiceOrder,
        onShareInvite: shareAppInvite,
        onShareStatement: shareMonthlyStatement,
        onShareNotificationDigest: shareNotificationDigest,
        approvalRequests: approvalRequests,
        onShareApprovalRequest: shareApprovalRequest,
        availableRewardPoints: availableRewardPoints,
        redeemedRewardCodes: redeemedRewardCodes,
        onRedeemReward: redeemRewardVoucher,
        onShareReward: shareRewardVoucher,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Kirana'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Badge(
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
        ],
      ),
      body: pages[tabIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tabIndex,
        onDestinationSelected: (index) => setState(() => tabIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Shop',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Planner',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

class CataloguePage extends StatelessWidget {
  const CataloguePage({
    required this.categories,
    required this.category,
    required this.query,
    required this.onQueryChanged,
    required this.onCategoryChanged,
    required this.onAdd,
    super.key,
  });

  final List<String> categories;
  final String category;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<Product> onAdd;

  @override
  Widget build(BuildContext context) {
    final filtered = products.where((product) {
      final matchesCategory = category == 'All' || product.category == category;
      final text = '${product.name} ${product.brand} ${product.category}'
          .toLowerCase();
      return matchesCategory && text.contains(query.toLowerCase());
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          onChanged: onQueryChanged,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            labelText: 'Search rice, oil, milk...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final item = categories[index];
              return ChoiceChip(
                label: Text(item),
                selected: item == category,
                onSelected: (_) => onCategoryChanged(item),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: categories.length,
          ),
        ),
        const SizedBox(height: 16),
        const InfoTile(
          icon: Icons.auto_awesome,
          title: 'Smart reorder suggestions',
          subtitle:
              'Weekly staples and frequently bought products are highlighted first for faster ordering.',
        ),
        const SizedBox(height: 12),
        InfoTile(
          icon: Icons.inventory_2_outlined,
          title: 'Live stock confidence',
          subtitle:
              '${products.where((product) => product.lowStock).length} low-stock essentials and ${products.where((product) => !product.inStock).length} unavailable items are highlighted before checkout.',
        ),
        const SizedBox(height: 16),
        ...filtered.map(
          (product) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ProductCard(product: product, onAdd: () => onAdd(product)),
          ),
        ),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({required this.product, required this.onAdd, super.key});

  final Product product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(radius: 28, child: Icon(product.icon)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${product.brand} • ${product.packSize} • ${product.category}',
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        currency.format(product.price),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        currency.format(product.mrp),
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      if (product.saving > 0)
                        Text(
                          '  Save ${currency.format(product.saving)}',
                          style: const TextStyle(color: Colors.green),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: [
                      Chip(
                        label: Text(product.stockLabel),
                        visualDensity: VisualDensity.compact,
                      ),
                      if (!product.inStock &&
                          substituteProducts(product).isNotEmpty)
                        const Chip(
                          label: Text('Substitute available'),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: onAdd,
              icon: Icon(product.inStock ? Icons.add : Icons.swap_horiz),
              label: Text(product.inStock ? 'Add' : 'Swap'),
            ),
          ],
        ),
      ),
    );
  }
}

class PlannerPage extends StatelessWidget {
  const PlannerPage({
    required this.activePlans,
    required this.onAddPlan,
    required this.onSchedulePlan,
    required this.onAddSavedPlan,
    super.key,
  });

  final List<SavedPlan> activePlans;
  final ValueChanged<PlannerItem> onAddPlan;
  final ValueChanged<PlannerItem> onSchedulePlan;
  final ValueChanged<SavedPlan> onAddSavedPlan;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Plan groceries ahead',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'Create weekly, biweekly, or monthly baskets so the family never misses essentials.',
        ),
        const SizedBox(height: 16),
        const InfoTile(
          icon: Icons.savings_outlined,
          title: 'Budget guardrails',
          subtitle:
              'Each plan shows an estimated spend before you add it to cart.',
        ),
        const SizedBox(height: 16),
        Text(
          'Recurring plans',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        if (activePlans.isEmpty)
          const InfoTile(
            icon: Icons.event_repeat,
            title: 'No recurring grocery plan yet',
            subtitle:
                'Schedule a basket below to receive WhatsApp reminders before each delivery.',
          ),
        ...activePlans.map(
          (plan) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SavedPlanCard(
              plan: plan,
              onAddToCart: () => onAddSavedPlan(plan),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Suggested baskets',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        ...plannerPresets.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.label,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Chip(label: Text(item.frequency)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(item.products.join(' • ')),
                    const SizedBox(height: 8),
                    Text('Estimated budget ${currency.format(item.budget)}'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => onSchedulePlan(item),
                            icon: const Icon(Icons.event_repeat),
                            label: const Text('Schedule'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => onAddPlan(item),
                            icon: const Icon(Icons.playlist_add_check),
                            label: const Text('Add now'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SavedPlanCard extends StatelessWidget {
  const SavedPlanCard({
    required this.plan,
    required this.onAddToCart,
    super.key,
  });

  final SavedPlan plan;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.event_repeat)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    plan.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Chip(label: Text(plan.frequency)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Next delivery ${DateFormat('EEE, d MMM').format(plan.nextDelivery)} • Budget ${currency.format(plan.budget)}',
            ),
            const SizedBox(height: 6),
            Text(plan.products.join(' • ')),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: onAddToCart,
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Add plan to cart'),
            ),
          ],
        ),
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  const CartPage({
    required this.lines,
    required this.subtotal,
    required this.offerDiscount,
    required this.deliveryFee,
    required this.savings,
    required this.monthlySpend,
    required this.monthlyBudgetLimit,
    required this.appliedOffer,
    required this.deliverySlot,
    required this.fulfilmentMode,
    required this.paymentMethod,
    required this.selectedAddress,
    required this.savedAddresses,
    required this.deliveryInstruction,
    required this.substitutionPreference,
    required this.onQuantity,
    required this.onSlotChanged,
    required this.onFulfilmentModeChanged,
    required this.onPaymentChanged,
    required this.onAddressChanged,
    required this.onDeliveryInstructionChanged,
    required this.onSubstitutionPreferenceChanged,
    required this.onApplyOffer,
    required this.onRequestApproval,
    required this.approvalRequests,
    required this.onCheckout,
    super.key,
  });

  final List<CartLine> lines;
  final int subtotal;
  final int offerDiscount;
  final int deliveryFee;
  final int savings;
  final int monthlySpend;
  final int monthlyBudgetLimit;
  final SmartOffer? appliedOffer;
  final String deliverySlot;
  final String fulfilmentMode;
  final String paymentMethod;
  final CustomerAddress selectedAddress;
  final List<CustomerAddress> savedAddresses;
  final String deliveryInstruction;
  final String substitutionPreference;
  final void Function(String productId, int delta) onQuantity;
  final ValueChanged<String> onSlotChanged;
  final ValueChanged<String> onFulfilmentModeChanged;
  final ValueChanged<String> onPaymentChanged;
  final ValueChanged<CustomerAddress> onAddressChanged;
  final ValueChanged<String> onDeliveryInstructionChanged;
  final ValueChanged<String> onSubstitutionPreferenceChanged;
  final ValueChanged<SmartOffer> onApplyOffer;
  final VoidCallback? onRequestApproval;
  final List<ApprovalRequest> approvalRequests;
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context) {
    const slots = [
      'Today 6 PM - 8 PM',
      'Tomorrow 8 AM - 10 AM',
      'Sunday weekly delivery',
    ];
    const payments = [
      'UPI',
      'GPay',
      'PhonePe',
      'Paytm',
      'Credit card',
      'Debit card',
      'QR pay',
      'Cash',
    ];
    const deliveryInstructions = [
      'Ring bell and hand over',
      'Leave at doorstep',
      'Call on arrival',
      'Deliver to security',
    ];
    const substitutionPreferences = [
      'Call before replacing',
      'WhatsApp photo before replacing',
      'Use same brand only',
      'No substitutions',
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Your cart',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        if (lines.isEmpty)
          const InfoTile(
            icon: Icons.shopping_basket_outlined,
            title: 'Cart is empty',
            subtitle: 'Add products from the shop or weekly planner.',
          ),
        ...lines.map(
          (line) => Card(
            child: ListTile(
              leading: CircleAvatar(child: Icon(line.product.icon)),
              title: Text(line.product.name),
              subtitle: Text(
                '${line.product.packSize} • ${currency.format(line.product.price)} each • ${line.product.stockQty} available${line.quantity == line.product.stockQty ? ' • max in cart' : ''}',
              ),
              trailing: QuantityStepper(
                quantity: line.quantity,
                onMinus: () => onQuantity(line.product.id, -1),
                onPlus: () => onQuantity(line.product.id, 1),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Fulfilment mode',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: fulfilmentModes
              .map(
                (mode) => ChoiceChip(
                  label: Text(mode),
                  selected: mode == fulfilmentMode,
                  onSelected: (_) => onFulfilmentModeChanged(mode),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: deliverySlot,
          items: slots.map((slot) {
            final fee = deliveryFeeFor(slot, subtotal, fulfilmentMode);
            return DropdownMenuItem(
              value: slot,
              child: Text(
                '$slot • ${fee == 0 ? 'Free delivery' : currency.format(fee)}',
              ),
            );
          }).toList(),
          onChanged: (value) => value == null ? null : onSlotChanged(value),
          decoration: const InputDecoration(
            labelText: 'Delivery slot',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.schedule),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<CustomerAddress>(
          isExpanded: true,
          initialValue: selectedAddress,
          items: savedAddresses
              .map(
                (address) => DropdownMenuItem(
                  value: address,
                  child: Text('${address.label} • ${address.line1}'),
                ),
              )
              .toList(),
          onChanged: (value) => value == null ? null : onAddressChanged(value),
          decoration: const InputDecoration(
            labelText: 'Delivery address',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: deliveryInstruction,
          items: deliveryInstructions
              .map(
                (instruction) => DropdownMenuItem(
                  value: instruction,
                  child: Text(instruction),
                ),
              )
              .toList(),
          onChanged: (value) =>
              value == null ? null : onDeliveryInstructionChanged(value),
          decoration: const InputDecoration(
            labelText: 'Delivery instruction',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.delivery_dining),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: substitutionPreference,
          items: substitutionPreferences
              .map(
                (preference) => DropdownMenuItem(
                  value: preference,
                  child: Text(preference),
                ),
              )
              .toList(),
          onChanged: (value) =>
              value == null ? null : onSubstitutionPreferenceChanged(value),
          decoration: const InputDecoration(
            labelText: 'Substitution preference',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.swap_horiz),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Payment method',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: payments
              .map(
                (payment) => ChoiceChip(
                  label: Text(payment),
                  selected: payment == paymentMethod,
                  onSelected: (_) => onPaymentChanged(payment),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),
        BudgetGuardCard(
          monthlySpend: monthlySpend,
          cartPayable: subtotal - offerDiscount + deliveryFee,
          monthlyBudgetLimit: monthlyBudgetLimit,
        ),
        const SizedBox(height: 20),
        Text(
          'Smart offers',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        ...smartOffers.map(
          (offer) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OfferTile(
              offer: offer,
              subtotal: subtotal,
              selected: appliedOffer?.code == offer.code,
              onApply: () => onApplyOffer(offer),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (lines.isNotEmpty)
          const InfoTile(
            icon: Icons.lock_clock,
            title: 'Stock reservation',
            subtitle:
                'Checkout reserves available stock for 15 minutes while payment and WhatsApp confirmation complete.',
          ),
        if (lines.isNotEmpty) const SizedBox(height: 12),
        if (lines.isNotEmpty)
          ApprovalSummaryCard(
            approvalRequests: approvalRequests,
            onRequestApproval: onRequestApproval,
          ),
        if (lines.isNotEmpty) const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SummaryRow(label: 'Subtotal', value: currency.format(subtotal)),
                if (offerDiscount > 0)
                  SummaryRow(
                    label: 'Offer discount',
                    value: '-${currency.format(offerDiscount)}',
                  ),
                SummaryRow(
                  label: 'Delivery fee',
                  value: deliveryFee == 0
                      ? 'Free'
                      : currency.format(deliveryFee),
                ),
                if (subtotal < freeDeliveryThreshold)
                  SummaryRow(
                    label: 'Free delivery unlock',
                    value:
                        'Add ${currency.format(freeDeliveryThreshold - subtotal)}',
                  ),
                SummaryRow(label: 'You save', value: currency.format(savings)),
                const Divider(),
                SummaryRow(
                  label: 'Payable',
                  value: currency.format(
                    subtotal - offerDiscount + deliveryFee,
                  ),
                  bold: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onCheckout,
          icon: const Icon(Icons.chat),
          label: const Text('Review and place order'),
        ),
      ],
    );
  }
}

class ApprovalSummaryCard extends StatelessWidget {
  const ApprovalSummaryCard({
    required this.approvalRequests,
    required this.onRequestApproval,
    super.key,
  });

  final List<ApprovalRequest> approvalRequests;
  final VoidCallback? onRequestApproval;

  @override
  Widget build(BuildContext context) {
    final pendingCount = approvalRequests
        .where((request) => request.status == 'Pending')
        .length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: const Icon(Icons.family_restroom),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Family approval',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Chip(label: Text('$pendingCount pending')),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Ask a household approver before placing large weekly or monthly grocery baskets.',
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: onRequestApproval,
              icon: const Icon(Icons.verified_user_outlined),
              label: const Text('Request approval'),
            ),
          ],
        ),
      ),
    );
  }
}

class ApprovalRequestSheet extends StatefulWidget {
  const ApprovalRequestSheet({
    required this.cartTotal,
    required this.onSubmit,
    required this.onWhatsApp,
    super.key,
  });

  final int cartTotal;
  final ValueChanged<ApprovalRequest> onSubmit;
  final ValueChanged<ApprovalRequest> onWhatsApp;

  @override
  State<ApprovalRequestSheet> createState() => _ApprovalRequestSheetState();
}

class _ApprovalRequestSheetState extends State<ApprovalRequestSheet> {
  HouseholdMember member = householdMembers.first;
  late final TextEditingController noteController = TextEditingController(
    text: 'Please review this grocery cart before checkout.',
  );

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  ApprovalRequest buildRequest() => ApprovalRequest(
    requestId: 'APR${DateTime.now().millisecondsSinceEpoch}',
    member: member,
    cartTotal: widget.cartTotal,
    note: noteController.text.trim().isEmpty
        ? 'Please approve this Smart Kirana cart.'
        : noteController.text.trim(),
    createdAt: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.group_add),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Request family approval',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Cart total ${currency.format(widget.cartTotal)}'),
          const SizedBox(height: 16),
          DropdownButtonFormField<HouseholdMember>(
            initialValue: member,
            items: householdMembers
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text('${item.name} • ${item.role}'),
                  ),
                )
                .toList(),
            onChanged: (value) =>
                value == null ? null : setState(() => member = value),
            decoration: const InputDecoration(
              labelText: 'Approver',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_add_alt),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Approval note',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes),
            ),
          ),
          const SizedBox(height: 12),
          InfoTile(
            icon: Icons.account_balance_wallet_outlined,
            title: '${member.relation} monthly limit',
            subtitle:
                '${member.role} • ${currency.format(member.monthlyLimit)} approval comfort limit',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => widget.onWhatsApp(buildRequest()),
                  icon: const Icon(Icons.chat),
                  label: const Text('WhatsApp'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => widget.onSubmit(buildRequest()),
                  icon: const Icon(Icons.verified),
                  label: const Text('Save request'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BudgetGuardCard extends StatelessWidget {
  const BudgetGuardCard({
    required this.monthlySpend,
    required this.cartPayable,
    required this.monthlyBudgetLimit,
    super.key,
  });

  final int monthlySpend;
  final int cartPayable;
  final int monthlyBudgetLimit;

  @override
  Widget build(BuildContext context) {
    final projectedSpend = monthlySpend + cartPayable;
    final remaining = monthlyBudgetLimit - projectedSpend;
    final progress = monthlyBudgetLimit == 0
        ? 0.0
        : (projectedSpend / monthlyBudgetLimit).clamp(0.0, 1.0).toDouble();
    final overBudget = remaining < 0;
    return Card(
      color: overBudget ? Theme.of(context).colorScheme.errorContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: const Icon(Icons.savings_outlined),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Monthly budget guard',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    overBudget
                        ? 'Over budget'
                        : '${(progress * 100).round()}% used',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 12),
            SummaryRow(
              label: 'Current month spend',
              value: currency.format(monthlySpend),
            ),
            SummaryRow(
              label: 'This cart projection',
              value: currency.format(cartPayable),
            ),
            SummaryRow(
              label: overBudget ? 'Budget overrun' : 'Remaining budget',
              value: currency.format(remaining.abs()),
              bold: true,
            ),
            const SizedBox(height: 8),
            Text(
              overBudget
                  ? 'Consider moving non-urgent items to next week or using planner reminders.'
                  : 'You are within the monthly grocery budget before checkout.',
            ),
          ],
        ),
      ),
    );
  }
}

class OfferTile extends StatelessWidget {
  const OfferTile({
    required this.offer,
    required this.subtotal,
    required this.selected,
    required this.onApply,
    super.key,
  });

  final SmartOffer offer;
  final int subtotal;
  final bool selected;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final eligible = offer.isEligible(subtotal);
    final unlockAmount = (offer.minimumOrderValue - subtotal)
        .clamp(0, offer.minimumOrderValue)
        .toInt();
    return Card(
      color: selected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(selected ? Icons.check : Icons.local_offer_outlined),
        ),
        title: Text('${offer.title} • ${currency.format(offer.discount)} off'),
        subtitle: Text(
          eligible
              ? '${offer.code}: ${offer.description}'
              : 'Add ${currency.format(unlockAmount)} more to unlock ${offer.code}.',
        ),
        trailing: TextButton(
          onPressed: eligible ? onApply : null,
          child: Text(selected ? 'Applied' : 'Apply'),
        ),
      ),
    );
  }
}

class OrderConfirmationSheet extends StatelessWidget {
  const OrderConfirmationSheet({
    required this.order,
    required this.onPay,
    required this.onShareWhatsApp,
    super.key,
  });

  final KiranaOrder order;
  final VoidCallback onPay;
  final VoidCallback onShareWhatsApp;

  @override
  Widget build(BuildContext context) {
    final isDigitalPayment = order.paymentMethod != 'Cash';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.check),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Order received',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SummaryRow(label: 'Order ID', value: order.id),
          SummaryRow(label: 'Items', value: '${order.itemCount}'),
          SummaryRow(label: 'Fulfilment', value: order.deliveryMode),
          SummaryRow(label: order.handoffCodeLabel, value: order.handoffCode),
          SummaryRow(label: 'Delivery slot', value: order.slot),
          SummaryRow(label: 'Instruction', value: order.deliveryInstruction),
          SummaryRow(
            label: 'Substitution',
            value: order.substitutionPreference,
          ),
          SummaryRow(label: 'Payment', value: order.paymentMethod),
          SummaryRow(
            label: 'Delivery fee',
            value: order.deliveryFee == 0
                ? 'Free'
                : currency.format(order.deliveryFee),
          ),
          SummaryRow(
            label: 'Reserved items',
            value:
                '${order.reservedItemCount} until ${DateFormat('hh:mm a').format(order.reservationExpiresAt)}',
          ),
          const Divider(height: 24),
          if (order.discount > 0)
            SummaryRow(
              label: 'Offer discount',
              value: '-${currency.format(order.discount)}',
            ),
          SummaryRow(
            label: 'Total payable',
            value: currency.format(order.payable),
            bold: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onShareWhatsApp,
                  icon: const Icon(Icons.chat),
                  label: const Text('Send WhatsApp'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: isDigitalPayment ? onPay : null,
                  icon: const Icon(Icons.payments),
                  label: Text(isDigitalPayment ? 'Pay now' : 'Cash order'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Production builds will replace this with Razorpay/Cashfree payment confirmation webhooks and automated WhatsApp templates.',
          ),
        ],
      ),
    );
  }
}

class CancellationSheet extends StatefulWidget {
  const CancellationSheet({
    required this.order,
    required this.existingCancellation,
    required this.onSubmit,
    required this.onWhatsApp,
    super.key,
  });

  final KiranaOrder order;
  final OrderCancellation? existingCancellation;
  final ValueChanged<OrderCancellation> onSubmit;
  final ValueChanged<OrderCancellation> onWhatsApp;

  @override
  State<CancellationSheet> createState() => _CancellationSheetState();
}

class _CancellationSheetState extends State<CancellationSheet> {
  late String reason =
      widget.existingCancellation?.reason ?? 'Ordered by mistake';
  late String refundMode =
      widget.existingCancellation?.refundMode ?? 'Original payment method';

  OrderCancellation buildCancellation() => OrderCancellation(
    orderId: widget.order.id,
    reason: reason,
    refundMode: refundMode,
    createdAt: widget.existingCancellation?.createdAt ?? DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    const reasons = [
      'Ordered by mistake',
      'Need to change items',
      'Delivery slot not suitable',
      'Found alternate product',
      'Payment issue',
    ];
    const refundModes = [
      'Original payment method',
      'Store credit / khata',
      'UPI refund',
      'No refund needed',
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                child: const Icon(Icons.cancel_outlined),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Cancel ${widget.order.id}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.order.itemCount} items • ${currency.format(widget.order.payable)} • ${widget.order.status}',
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: reason,
            items: reasons
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) =>
                value == null ? null : setState(() => reason = value),
            decoration: const InputDecoration(
              labelText: 'Cancellation reason',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.help_outline),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: refundMode,
            items: refundModes
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) =>
                value == null ? null : setState(() => refundMode = value),
            decoration: const InputDecoration(
              labelText: 'Refund preference',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.currency_rupee),
            ),
          ),
          const SizedBox(height: 12),
          const InfoTile(
            icon: Icons.info_outline,
            title: 'Cancellation window',
            subtitle:
                'Orders can be cancelled before packing is complete. Refund handling will be confirmed by the store.',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => widget.onWhatsApp(buildCancellation()),
                  icon: const Icon(Icons.chat),
                  label: const Text('WhatsApp'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => widget.onSubmit(buildCancellation()),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel order'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DeliveryChangeSheet extends StatefulWidget {
  const DeliveryChangeSheet({
    required this.order,
    required this.existingRequest,
    required this.onSubmit,
    required this.onWhatsApp,
    super.key,
  });

  final KiranaOrder order;
  final DeliveryChangeRequest? existingRequest;
  final ValueChanged<DeliveryChangeRequest> onSubmit;
  final ValueChanged<DeliveryChangeRequest> onWhatsApp;

  @override
  State<DeliveryChangeSheet> createState() => _DeliveryChangeSheetState();
}

class _DeliveryChangeSheetState extends State<DeliveryChangeSheet> {
  late String requestedSlot =
      widget.existingRequest?.requestedSlot ?? 'Tomorrow 8 AM - 10 AM';
  late String reason =
      widget.existingRequest?.reason ?? 'Need a different time';
  late final TextEditingController noteController = TextEditingController(
    text: widget.existingRequest?.note ?? '',
  );

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  DeliveryChangeRequest buildRequest() => DeliveryChangeRequest(
    orderId: widget.order.id,
    requestedSlot: requestedSlot,
    reason: reason,
    note: noteController.text.trim(),
    createdAt: widget.existingRequest?.createdAt ?? DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    const slots = [
      'Today 6 PM - 8 PM',
      'Tomorrow 8 AM - 10 AM',
      'Sunday weekly delivery',
    ];
    const reasons = [
      'Need a different time',
      'Not at home',
      'Add more items first',
      'Prefer store pickup',
      'Other',
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: const Icon(Icons.edit_calendar),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Reschedule ${widget.order.id}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Current slot ${widget.order.slot} • ${widget.order.status}'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: requestedSlot,
              items: slots
                  .map(
                    (slot) => DropdownMenuItem(value: slot, child: Text(slot)),
                  )
                  .toList(),
              onChanged: (value) =>
                  value == null ? null : setState(() => requestedSlot = value),
              decoration: const InputDecoration(
                labelText: 'Requested delivery slot',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.schedule),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: reason,
              items: reasons
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: (value) =>
                  value == null ? null : setState(() => reason = value),
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.help_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Note for store (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
            ),
            const SizedBox(height: 12),
            const InfoTile(
              icon: Icons.info_outline,
              title: 'Store confirmation needed',
              subtitle:
                  'The store will confirm whether the new slot is available before changing fulfilment.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => widget.onWhatsApp(buildRequest()),
                    icon: const Icon(Icons.chat),
                    label: const Text('WhatsApp'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => widget.onSubmit(buildRequest()),
                    icon: const Icon(Icons.save),
                    label: const Text('Save request'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentProofSheet extends StatefulWidget {
  const PaymentProofSheet({
    required this.order,
    required this.existingProof,
    required this.onSubmit,
    required this.onWhatsApp,
    super.key,
  });

  final KiranaOrder order;
  final PaymentProof? existingProof;
  final ValueChanged<PaymentProof> onSubmit;
  final ValueChanged<PaymentProof> onWhatsApp;

  @override
  State<PaymentProofSheet> createState() => _PaymentProofSheetState();
}

class _PaymentProofSheetState extends State<PaymentProofSheet> {
  late String method =
      widget.existingProof?.method ?? widget.order.paymentMethod;
  late final TextEditingController referenceController = TextEditingController(
    text: widget.existingProof?.reference ?? '',
  );
  late final TextEditingController amountController = TextEditingController(
    text: '${widget.existingProof?.amount ?? widget.order.payable}',
  );

  @override
  void dispose() {
    referenceController.dispose();
    amountController.dispose();
    super.dispose();
  }

  PaymentProof buildProof() => PaymentProof(
    orderId: widget.order.id,
    method: method,
    reference: referenceController.text.trim().isEmpty
        ? 'Pending reference'
        : referenceController.text.trim(),
    amount: int.tryParse(amountController.text.trim()) ?? widget.order.payable,
    createdAt: widget.existingProof?.createdAt ?? DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    const methods = [
      'UPI',
      'GPay',
      'PhonePe',
      'Paytm',
      'Credit card',
      'Debit card',
      'QR pay',
      'Cash',
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: const Icon(Icons.payments_outlined),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Payment proof for ${widget.order.id}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Payable ${currency.format(widget.order.payable)} • ${widget.order.status}',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: method,
              items: methods
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: (value) =>
                  value == null ? null : setState(() => method = value),
              decoration: const InputDecoration(
                labelText: 'Payment method',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: referenceController,
              decoration: const InputDecoration(
                labelText: 'UPI / card / cash reference',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount paid',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_rupee),
              ),
            ),
            const SizedBox(height: 12),
            const InfoTile(
              icon: Icons.verified,
              title: 'Store reconciliation',
              subtitle:
                  'The store will verify payment reference and amount before marking the order paid in production.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => widget.onWhatsApp(buildProof()),
                    icon: const Icon(Icons.chat),
                    label: const Text('WhatsApp'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => widget.onSubmit(buildProof()),
                    icon: const Icon(Icons.save),
                    label: const Text('Save proof'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InvoiceRequestSheet extends StatefulWidget {
  const InvoiceRequestSheet({
    required this.order,
    required this.existingRequest,
    required this.onSubmit,
    required this.onWhatsApp,
    super.key,
  });

  final KiranaOrder order;
  final InvoiceRequest? existingRequest;
  final ValueChanged<InvoiceRequest> onSubmit;
  final ValueChanged<InvoiceRequest> onWhatsApp;

  @override
  State<InvoiceRequestSheet> createState() => _InvoiceRequestSheetState();
}

class _InvoiceRequestSheetState extends State<InvoiceRequestSheet> {
  late String invoiceType =
      widget.existingRequest?.invoiceType ?? 'Retail bill';
  late final TextEditingController billingNameController =
      TextEditingController(
        text: widget.existingRequest?.billingName ?? 'Chandra Stores customer',
      );
  late final TextEditingController gstinController = TextEditingController(
    text: widget.existingRequest?.gstin ?? '',
  );
  late final TextEditingController emailController = TextEditingController(
    text: widget.existingRequest?.email ?? '',
  );

  @override
  void dispose() {
    billingNameController.dispose();
    gstinController.dispose();
    emailController.dispose();
    super.dispose();
  }

  InvoiceRequest buildRequest() => InvoiceRequest(
    orderId: widget.order.id,
    invoiceType: invoiceType,
    billingName: billingNameController.text.trim().isEmpty
        ? 'Chandra Stores customer'
        : billingNameController.text.trim(),
    gstin: gstinController.text.trim().toUpperCase(),
    email: emailController.text.trim(),
    createdAt: widget.existingRequest?.createdAt ?? DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    const invoiceTypes = [
      'Retail bill',
      'GST invoice',
      'Monthly statement copy',
      'Khata ledger copy',
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: const Icon(Icons.receipt_long),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Invoice for ${widget.order.id}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.order.itemCount} items • ${currency.format(widget.order.payable)} • ${widget.order.paymentMethod}',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: invoiceType,
              items: invoiceTypes
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
              onChanged: (value) =>
                  value == null ? null : setState(() => invoiceType = value),
              decoration: const InputDecoration(
                labelText: 'Invoice type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: billingNameController,
              decoration: const InputDecoration(
                labelText: 'Billing name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: gstinController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'GSTIN (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 12),
            const InfoTile(
              icon: Icons.verified_outlined,
              title: 'Store verification',
              subtitle:
                  'The store will confirm GST details, payment status, and delivery before issuing the final bill.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => widget.onWhatsApp(buildRequest()),
                    icon: const Icon(Icons.chat),
                    label: const Text('WhatsApp'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => widget.onSubmit(buildRequest()),
                    icon: const Icon(Icons.save),
                    label: const Text('Save request'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SupportTicketSheet extends StatefulWidget {
  const SupportTicketSheet({
    required this.order,
    required this.existingTicket,
    required this.onSubmit,
    required this.onWhatsApp,
    super.key,
  });

  final KiranaOrder order;
  final SupportTicket? existingTicket;
  final ValueChanged<SupportTicket> onSubmit;
  final ValueChanged<SupportTicket> onWhatsApp;

  @override
  State<SupportTicketSheet> createState() => _SupportTicketSheetState();
}

class _SupportTicketSheetState extends State<SupportTicketSheet> {
  late String issueType = widget.existingTicket?.issueType ?? 'Missing item';
  late String priority = widget.existingTicket?.priority ?? 'Normal';
  late final TextEditingController descriptionController =
      TextEditingController(text: widget.existingTicket?.description ?? '');

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  SupportTicket buildTicket() => SupportTicket(
    ticketId:
        widget.existingTicket?.ticketId ??
        'SUP${DateTime.now().millisecondsSinceEpoch}',
    orderId: widget.order.id,
    issueType: issueType,
    priority: priority,
    description: descriptionController.text.trim().isEmpty
        ? 'Customer requested support from app.'
        : descriptionController.text.trim(),
    createdAt: widget.existingTicket?.createdAt ?? DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    const issueTypes = [
      'Missing item',
      'Wrong item',
      'Damaged/quality issue',
      'Late delivery',
      'Payment issue',
      'Refund request',
    ];
    const priorities = ['Normal', 'Urgent', 'Refund needed'];
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.support_agent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Support for ${widget.order.id}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.order.itemCount} items • ${currency.format(widget.order.payable)} • ${widget.order.status}',
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: issueType,
            items: issueTypes
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (value) =>
                value == null ? null : setState(() => issueType = value),
            decoration: const InputDecoration(
              labelText: 'Support issue',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.report_problem_outlined),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: priority,
            items: priorities
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) =>
                value == null ? null : setState(() => priority = value),
            decoration: const InputDecoration(
              labelText: 'Priority',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.priority_high),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descriptionController,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Describe the issue',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => widget.onWhatsApp(buildTicket()),
                  icon: const Icon(Icons.chat),
                  label: const Text('WhatsApp'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => widget.onSubmit(buildTicket()),
                  icon: const Icon(Icons.confirmation_number),
                  label: const Text('Save ticket'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FeedbackSheet extends StatefulWidget {
  const FeedbackSheet({
    required this.order,
    required this.initialFeedback,
    required this.onSubmit,
    super.key,
  });

  final KiranaOrder order;
  final OrderFeedback? initialFeedback;
  final ValueChanged<OrderFeedback> onSubmit;

  @override
  State<FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<FeedbackSheet> {
  late int rating = widget.initialFeedback?.rating ?? 5;
  late String issueTag =
      widget.initialFeedback?.issueTag ?? 'Everything was good';
  late final TextEditingController noteController = TextEditingController(
    text: widget.initialFeedback?.note ?? '',
  );

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const issueTags = [
      'Everything was good',
      'Late delivery',
      'Missing item',
      'Wrong item',
      'Quality issue',
      'Substitution issue',
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.rate_review),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Rate ${widget.order.id}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.order.itemCount} items • ${currency.format(widget.order.payable)}',
          ),
          const SizedBox(height: 16),
          Text(
            'Delivery rating',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(5, (index) {
              final value = index + 1;
              return ChoiceChip(
                label: Text('$value ★'),
                selected: rating == value,
                onSelected: (_) => setState(() => rating = value),
              );
            }),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: issueTag,
            items: issueTags
                .map((tag) => DropdownMenuItem(value: tag, child: Text(tag)))
                .toList(),
            onChanged: (value) =>
                value == null ? null : setState(() => issueTag = value),
            decoration: const InputDecoration(
              labelText: 'Feedback reason',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.feedback_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Optional note for store owner',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => widget.onSubmit(
              OrderFeedback(
                orderId: widget.order.id,
                rating: rating,
                issueTag: issueTag,
                note: noteController.text.trim(),
                createdAt: DateTime.now(),
              ),
            ),
            icon: const Icon(Icons.send),
            label: const Text('Submit feedback'),
          ),
        ],
      ),
    );
  }
}

class OrderHandoffPassSheet extends StatelessWidget {
  const OrderHandoffPassSheet({required this.order, super.key});

  final KiranaOrder order;

  @override
  Widget build(BuildContext context) {
    final title = order.isStorePickup ? 'Pickup pass' : 'Delivery pass';
    final guidance = order.isStorePickup
        ? 'Show this pass at the store counter when your basket is ready.'
        : 'Share this delivery code with the rider only after receiving the order.';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.qr_code_2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Theme.of(context).colorScheme.primary),
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              children: [
                const Icon(Icons.qr_code_2, size: 72),
                const SizedBox(height: 8),
                Text(
                  order.handoffCode,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(order.handoffCodeLabel),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(guidance),
          const SizedBox(height: 12),
          SummaryRow(label: 'Order ID', value: order.id),
          SummaryRow(label: 'Fulfilment', value: order.deliveryMode),
          SummaryRow(label: 'Slot', value: order.slot),
          SummaryRow(
            label: 'Address',
            value:
                '${order.deliveryAddress.label} • ${order.deliveryAddress.line1}',
          ),
          SummaryRow(label: 'Payment', value: order.paymentMethod),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.check),
              label: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderTrackingSheet extends StatelessWidget {
  const OrderTrackingSheet({required this.order, super.key});

  final KiranaOrder order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.delivery_dining),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Track ${order.id}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${order.itemCount} items • ${order.deliveryMode} • ${order.slot} • ${currency.format(order.payable)}',
          ),
          const SizedBox(height: 4),
          Text('${order.handoffCodeLabel}: ${order.handoffCode}'),
          const SizedBox(height: 4),
          Text(
            'Delivery fee: ${order.deliveryFee == 0 ? 'Free' : currency.format(order.deliveryFee)}',
          ),
          const SizedBox(height: 4),
          Text(
            'Delivery: ${order.deliveryInstruction} • Substitution: ${order.substitutionPreference}',
          ),
          const SizedBox(height: 4),
          Text(
            'Stock reserved until ${DateFormat('hh:mm a').format(order.reservationExpiresAt)}',
          ),
          const SizedBox(height: 16),
          ...orderStatusSteps.asMap().entries.map(
            (entry) => OrderTimelineStep(
              label: entry.value,
              completed: entry.key <= order.statusIndex,
              isCurrent: entry.key == order.statusIndex,
            ),
          ),
          const SizedBox(height: 12),
          const InfoTile(
            icon: Icons.swap_horiz,
            title: 'Substitution approval',
            subtitle:
                'If an item is unavailable, the store will confirm replacements on WhatsApp before dispatch.',
          ),
        ],
      ),
    );
  }
}

class OrderTimelineStep extends StatelessWidget {
  const OrderTimelineStep({
    required this.label,
    required this.completed,
    required this.isCurrent,
    super.key,
  });

  final String label;
  final bool completed;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final color = completed
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.outline;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                color: isCurrent ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
    super.key,
  });

  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onMinus,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text('$quantity', style: const TextStyle(fontWeight: FontWeight.w800)),
        IconButton(
          onPressed: onPlus,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}

class PreferenceCard extends StatelessWidget {
  const PreferenceCard({
    required this.preferences,
    required this.onLanguageChanged,
    required this.onEasyModeChanged,
    required this.onVoiceOrderingChanged,
    required this.onStartVoiceOrder,
    super.key,
  });

  final CustomerPreferences preferences;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<bool> onEasyModeChanged;
  final ValueChanged<bool> onVoiceOrderingChanged;
  final VoidCallback onStartVoiceOrder;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: const Icon(Icons.translate),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Accessibility & language',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: preferences.languageCode,
              items: supportedLanguages.entries
                  .map(
                    (entry) => DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  value == null ? null : onLanguageChanged(value),
              decoration: const InputDecoration(
                labelText: 'Preferred language',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.language),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: preferences.easyMode,
              onChanged: onEasyModeChanged,
              title: const Text('Senior-friendly easy mode'),
              subtitle: const Text(
                'Prioritise larger controls, repeat baskets, and simplified checkout copy.',
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: preferences.voiceOrdering,
              onChanged: onVoiceOrderingChanged,
              title: const Text('Voice ordering support'),
              subtitle: const Text(
                'Ask the store to help create a basket from a WhatsApp voice note or call.',
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: preferences.voiceOrdering ? onStartVoiceOrder : null,
              icon: const Icon(Icons.record_voice_over),
              label: const Text('Start voice order on WhatsApp'),
            ),
          ],
        ),
      ),
    );
  }
}

class HouseholdApprovalCard extends StatelessWidget {
  const HouseholdApprovalCard({
    required this.approvalRequests,
    required this.onShareApprovalRequest,
    super.key,
  });

  final List<ApprovalRequest> approvalRequests;
  final ValueChanged<ApprovalRequest> onShareApprovalRequest;

  @override
  Widget build(BuildContext context) {
    final recentRequests = approvalRequests.take(3).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: const Icon(Icons.family_restroom),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Household approvals',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Chip(label: Text('${approvalRequests.length}')),
              ],
            ),
            const SizedBox(height: 12),
            if (recentRequests.isEmpty)
              const Text(
                'Family approval requests from large grocery carts will appear here.',
              )
            else
              ...recentRequests.map(
                (request) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.verified_user_outlined),
                  title: Text(
                    '${request.member.name} • ${currency.format(request.cartTotal)}',
                  ),
                  subtitle: Text(
                    '${request.status} • ${DateFormat('d MMM, h:mm a').format(request.createdAt)}',
                  ),
                  trailing: IconButton(
                    onPressed: () => onShareApprovalRequest(request),
                    icon: const Icon(Icons.chat),
                    tooltip: 'Share on WhatsApp',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class NotificationCenterCard extends StatelessWidget {
  const NotificationCenterCard({
    required this.orders,
    required this.plans,
    required this.tickets,
    required this.onShareDigest,
    super.key,
  });

  final List<KiranaOrder> orders;
  final List<SavedPlan> plans;
  final Map<String, SupportTicket> tickets;
  final VoidCallback onShareDigest;

  @override
  Widget build(BuildContext context) {
    final notifications = buildNotifications(
      orders: orders,
      plans: plans,
      tickets: tickets,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: const Icon(Icons.notifications_active),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Notification center',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Chip(label: Text('${notifications.length}')),
              ],
            ),
            const SizedBox(height: 12),
            ...notifications
                .take(4)
                .map(
                  (notification) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.circle_notifications),
                    title: Text(notification.title),
                    subtitle: Text(notification.message),
                    trailing: Text(notification.type),
                  ),
                ),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: onShareDigest,
              icon: const Icon(Icons.share),
              label: const Text('Share notification digest'),
            ),
          ],
        ),
      ),
    );
  }
}

class AddressBookCard extends StatelessWidget {
  const AddressBookCard({
    required this.selectedAddress,
    required this.savedAddresses,
    required this.onAddressChanged,
    super.key,
  });

  final CustomerAddress selectedAddress;
  final List<CustomerAddress> savedAddresses;
  final ValueChanged<CustomerAddress> onAddressChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: const Icon(Icons.location_on_outlined),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Delivery address book',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Chip(label: Text(selectedAddress.label)),
              ],
            ),
            const SizedBox(height: 8),
            Text('${selectedAddress.line1} • ${selectedAddress.landmark}'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: savedAddresses
                  .map(
                    (address) => ChoiceChip(
                      label: Text(address.label),
                      selected: address == selectedAddress,
                      onSelected: (_) => onAddressChanged(address),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            const Text(
              'Selected address is used for checkout, WhatsApp order handoff, and store delivery planning.',
            ),
          ],
        ),
      ),
    );
  }
}

class InviteCard extends StatelessWidget {
  const InviteCard({required this.onShareInvite, super.key});

  final VoidCallback onShareInvite;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: const Icon(Icons.qr_code_2),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Invite family to Smart Kirana',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('App link: ${appInvite.landingUrl}'),
            const SizedBox(height: 6),
            Text(
              'Referral code ${appInvite.referralCode} • ${appInvite.rewardText}',
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: onShareInvite,
              icon: const Icon(Icons.ios_share),
              label: const Text('Share app link on WhatsApp'),
            ),
          ],
        ),
      ),
    );
  }
}

class StatementCard extends StatelessWidget {
  const StatementCard({
    required this.orders,
    required this.onShareStatement,
    super.key,
  });

  final List<KiranaOrder> orders;
  final VoidCallback onShareStatement;

  @override
  Widget build(BuildContext context) {
    final statement = buildStatement(orders);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: const Icon(Icons.summarize),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${statement.monthLabel} grocery statement',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SummaryRow(label: 'Orders', value: '${statement.orderCount}'),
            SummaryRow(
              label: 'Total spend',
              value: currency.format(statement.totalSpend),
            ),
            SummaryRow(
              label: 'Digital payments',
              value: '${statement.digitalPayments}/${statement.orderCount}',
            ),
            const Divider(height: 24),
            if (statement.topCategories.isEmpty)
              const Text(
                'Place app orders to build category-wise monthly grocery insights.',
              )
            else
              ...statement.topCategories.entries.map(
                (entry) => SummaryRow(
                  label: entry.key,
                  value: currency.format(entry.value),
                ),
              ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: onShareStatement,
              icon: const Icon(Icons.share),
              label: const Text('Share monthly statement'),
            ),
          ],
        ),
      ),
    );
  }
}

class RewardCenterCard extends StatelessWidget {
  const RewardCenterCard({
    required this.availablePoints,
    required this.redeemedRewardCodes,
    required this.onRedeemReward,
    required this.onShareReward,
    super.key,
  });

  final int availablePoints;
  final Set<String> redeemedRewardCodes;
  final ValueChanged<RewardVoucher> onRedeemReward;
  final ValueChanged<RewardVoucher> onShareReward;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: const Icon(Icons.redeem),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Reward center',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Chip(label: Text('$availablePoints pts')),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Redeem loyalty points for store-managed grocery vouchers before checkout.',
            ),
            const SizedBox(height: 8),
            ...rewardVouchers.map((voucher) {
              final redeemed = redeemedRewardCodes.contains(voucher.code);
              final canRedeem = voucher.canRedeem(availablePoints) && !redeemed;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Text('${voucher.discount}')),
                title: Text('${voucher.title} • ${voucher.code}'),
                subtitle: Text(
                  '${voucher.description} • ${voucher.pointsRequired} pts • Valid ${DateFormat('d MMM').format(voucher.validUntil)}',
                ),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      onPressed: () => onShareReward(voucher),
                      icon: const Icon(Icons.chat),
                      tooltip: 'Share reward',
                    ),
                    redeemed
                        ? const Chip(label: Text('Redeemed'))
                        : TextButton(
                            onPressed: canRedeem
                                ? () => onRedeemReward(voucher)
                                : null,
                            child: const Text('Redeem'),
                          ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class WalletSummaryCard extends StatelessWidget {
  const WalletSummaryCard({required this.orders, super.key});

  final List<KiranaOrder> orders;

  int get monthlySpend => orders.fold(0, (sum, order) => sum + order.payable);
  int get earnedPoints => monthlySpend ~/ 100;
  int get availablePoints => customerWallet.baseLoyaltyPoints + earnedPoints;
  int get digitalOrders =>
      orders.where((order) => order.paymentMethod != 'Cash').length;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: const Icon(Icons.account_balance_wallet),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Grocery wallet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SummaryRow(
              label: 'Monthly app spend',
              value: currency.format(monthlySpend),
            ),
            SummaryRow(label: 'Loyalty points', value: '$availablePoints pts'),
            SummaryRow(
              label: 'Store credit available',
              value: currency.format(customerWallet.availableStoreCredit),
            ),
            SummaryRow(
              label: 'Digital payment orders',
              value: '$digitalOrders/${orders.length}',
            ),
            const Divider(height: 24),
            Text(
              orders.isEmpty
                  ? 'Place your first app order to start earning loyalty points and monthly spend insights.'
                  : 'You earned $earnedPoints points from app orders. Redeem points with LOYAL50 during checkout.',
            ),
          ],
        ),
      ),
    );
  }
}

class AccountPage extends StatelessWidget {
  const AccountPage({
    required this.orders,
    required this.plans,
    required this.onShareOrder,
    required this.onRepeatOrder,
    required this.onTrackOrder,
    required this.onShowHandoffPass,
    required this.onAdvanceOrder,
    required this.onFeedbackOrder,
    required this.feedbackByOrderId,
    required this.onSupportOrder,
    required this.supportTicketsByOrderId,
    required this.onInvoiceOrder,
    required this.invoiceRequestsByOrderId,
    required this.onPaymentProofOrder,
    required this.paymentProofsByOrderId,
    required this.onRescheduleOrder,
    required this.deliveryChangeRequestsByOrderId,
    required this.onCancelOrder,
    required this.cancellationsByOrderId,
    required this.selectedAddress,
    required this.savedAddresses,
    required this.onAddressChanged,
    required this.onAddSavedPlan,
    required this.preferences,
    required this.onLanguageChanged,
    required this.onEasyModeChanged,
    required this.onVoiceOrderingChanged,
    required this.onStartVoiceOrder,
    required this.onShareInvite,
    required this.onShareStatement,
    required this.onShareNotificationDigest,
    required this.approvalRequests,
    required this.onShareApprovalRequest,
    required this.availableRewardPoints,
    required this.redeemedRewardCodes,
    required this.onRedeemReward,
    required this.onShareReward,
    super.key,
  });

  final List<KiranaOrder> orders;
  final List<SavedPlan> plans;
  final ValueChanged<KiranaOrder> onShareOrder;
  final ValueChanged<KiranaOrder> onRepeatOrder;
  final ValueChanged<KiranaOrder> onTrackOrder;
  final ValueChanged<KiranaOrder> onShowHandoffPass;
  final ValueChanged<KiranaOrder> onAdvanceOrder;
  final ValueChanged<KiranaOrder> onFeedbackOrder;
  final Map<String, OrderFeedback> feedbackByOrderId;
  final ValueChanged<KiranaOrder> onSupportOrder;
  final Map<String, SupportTicket> supportTicketsByOrderId;
  final ValueChanged<KiranaOrder> onInvoiceOrder;
  final Map<String, InvoiceRequest> invoiceRequestsByOrderId;
  final ValueChanged<KiranaOrder> onPaymentProofOrder;
  final Map<String, PaymentProof> paymentProofsByOrderId;
  final ValueChanged<KiranaOrder> onRescheduleOrder;
  final Map<String, DeliveryChangeRequest> deliveryChangeRequestsByOrderId;
  final ValueChanged<KiranaOrder> onCancelOrder;
  final Map<String, OrderCancellation> cancellationsByOrderId;
  final CustomerAddress selectedAddress;
  final List<CustomerAddress> savedAddresses;
  final ValueChanged<CustomerAddress> onAddressChanged;
  final ValueChanged<SavedPlan> onAddSavedPlan;
  final CustomerPreferences preferences;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<bool> onEasyModeChanged;
  final ValueChanged<bool> onVoiceOrderingChanged;
  final VoidCallback onStartVoiceOrder;
  final VoidCallback onShareInvite;
  final VoidCallback onShareStatement;
  final VoidCallback onShareNotificationDigest;
  final List<ApprovalRequest> approvalRequests;
  final ValueChanged<ApprovalRequest> onShareApprovalRequest;
  final int availableRewardPoints;
  final Set<String> redeemedRewardCodes;
  final ValueChanged<RewardVoucher> onRedeemReward;
  final ValueChanged<RewardVoucher> onShareReward;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const InfoTile(
          icon: Icons.person,
          title: 'Chandra Stores customer',
          subtitle: '+91 98765 43210 • 420 loyalty points',
        ),
        const SizedBox(height: 12),
        AddressBookCard(
          selectedAddress: selectedAddress,
          savedAddresses: savedAddresses,
          onAddressChanged: onAddressChanged,
        ),
        const SizedBox(height: 12),
        InviteCard(onShareInvite: onShareInvite),
        const SizedBox(height: 12),
        WalletSummaryCard(orders: orders),
        const SizedBox(height: 12),
        RewardCenterCard(
          availablePoints: availableRewardPoints,
          redeemedRewardCodes: redeemedRewardCodes,
          onRedeemReward: onRedeemReward,
          onShareReward: onShareReward,
        ),
        const SizedBox(height: 12),
        StatementCard(orders: orders, onShareStatement: onShareStatement),
        const SizedBox(height: 12),
        PreferenceCard(
          preferences: preferences,
          onLanguageChanged: onLanguageChanged,
          onEasyModeChanged: onEasyModeChanged,
          onVoiceOrderingChanged: onVoiceOrderingChanged,
          onStartVoiceOrder: onStartVoiceOrder,
        ),
        const SizedBox(height: 12),
        const InfoTile(
          icon: Icons.support_agent,
          title: 'WhatsApp support',
          subtitle:
              'Ask for substitutions, credit account support, and delivery updates from the store.',
        ),
        const SizedBox(height: 12),
        NotificationCenterCard(
          orders: orders,
          plans: plans,
          tickets: supportTicketsByOrderId,
          onShareDigest: onShareNotificationDigest,
        ),
        const SizedBox(height: 12),
        HouseholdApprovalCard(
          approvalRequests: approvalRequests,
          onShareApprovalRequest: onShareApprovalRequest,
        ),
        const SizedBox(height: 24),
        Text(
          'Active grocery plans',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        if (plans.isEmpty)
          const InfoTile(
            icon: Icons.event_repeat,
            title: 'No active recurring plan',
            subtitle:
                'Recurring weekly, biweekly, and monthly plans will appear here.',
          ),
        ...plans.map(
          (plan) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.event_repeat)),
                title: Text(plan.name),
                subtitle: Text(
                  '${plan.frequency} • Next ${DateFormat('d MMM').format(plan.nextDelivery)} • ${currency.format(plan.budget)}',
                ),
                trailing: TextButton(
                  onPressed: () => onAddSavedPlan(plan),
                  child: const Text('Add'),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Recent orders',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        if (orders.isEmpty)
          const InfoTile(
            icon: Icons.receipt_long_outlined,
            title: 'No app orders yet',
            subtitle:
                'Completed checkout orders will appear here with status and repeat actions.',
          ),
        ...orders.map(
          (order) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.receipt_long),
                      ),
                      title: Text(
                        '${order.id} • ${currency.format(order.payable)}',
                      ),
                      subtitle: Text(
                        '${order.itemCount} items • ${order.slot} • ${order.status}',
                      ),
                    ),
                    if (feedbackByOrderId[order.id] != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Chip(
                            label: Text(
                              '${feedbackByOrderId[order.id]!.rating}★ • ${feedbackByOrderId[order.id]!.issueTag}',
                            ),
                          ),
                        ),
                      ),
                    if (supportTicketsByOrderId[order.id] != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Chip(
                            label: Text(
                              '${supportTicketsByOrderId[order.id]!.ticketId} • ${supportTicketsByOrderId[order.id]!.status}',
                            ),
                          ),
                        ),
                      ),
                    if (paymentProofsByOrderId[order.id] != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Chip(
                            label: Text(
                              'Paid • ${paymentProofsByOrderId[order.id]!.reference}',
                            ),
                          ),
                        ),
                      ),
                    if (invoiceRequestsByOrderId[order.id] != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Chip(
                            label: Text(
                              'Invoice • ${invoiceRequestsByOrderId[order.id]!.invoiceType}',
                            ),
                          ),
                        ),
                      ),
                    if (deliveryChangeRequestsByOrderId[order.id] != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Chip(
                            label: Text(
                              'Reschedule • ${deliveryChangeRequestsByOrderId[order.id]!.requestedSlot}',
                            ),
                          ),
                        ),
                      ),
                    if (cancellationsByOrderId[order.id] != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Chip(
                            label: Text(
                              'Cancelled • ${cancellationsByOrderId[order.id]!.refundMode}',
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Chip(
                          avatar: const Icon(Icons.qr_code_2, size: 18),
                          label: Text(
                            '${order.handoffCodeLabel} • ${order.handoffCode}',
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => onTrackOrder(order),
                            icon: const Icon(Icons.delivery_dining),
                            label: const Text('Track'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => onShowHandoffPass(order),
                            icon: const Icon(Icons.qr_code_2),
                            label: Text(
                              order.isStorePickup
                                  ? 'Pickup pass'
                                  : 'Delivery pass',
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => onShareOrder(order),
                            icon: const Icon(Icons.chat),
                            label: const Text('WhatsApp'),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: () => onRepeatOrder(order),
                            icon: const Icon(Icons.replay),
                            label: const Text('Repeat'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => onFeedbackOrder(order),
                            icon: const Icon(Icons.rate_review),
                            label: Text(
                              feedbackByOrderId[order.id] == null
                                  ? 'Feedback'
                                  : 'Edit feedback',
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => onSupportOrder(order),
                            icon: const Icon(Icons.support_agent),
                            label: Text(
                              supportTicketsByOrderId[order.id] == null
                                  ? 'Support'
                                  : 'View ticket',
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => onPaymentProofOrder(order),
                            icon: const Icon(Icons.payments_outlined),
                            label: Text(
                              paymentProofsByOrderId[order.id] == null
                                  ? 'Payment proof'
                                  : 'Edit payment',
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => onInvoiceOrder(order),
                            icon: const Icon(Icons.receipt),
                            label: Text(
                              invoiceRequestsByOrderId[order.id] == null
                                  ? 'Invoice'
                                  : 'Edit invoice',
                            ),
                          ),
                          if (!terminalOrderStatuses.contains(order.status))
                            OutlinedButton.icon(
                              onPressed: () => onRescheduleOrder(order),
                              icon: const Icon(Icons.edit_calendar),
                              label: Text(
                                deliveryChangeRequestsByOrderId[order.id] ==
                                        null
                                    ? 'Reschedule'
                                    : 'Edit slot',
                              ),
                            ),
                          if (!terminalOrderStatuses.contains(order.status))
                            OutlinedButton.icon(
                              onPressed: () => onCancelOrder(order),
                              icon: const Icon(Icons.cancel_outlined),
                              label: const Text('Cancel'),
                            ),
                          if (!terminalOrderStatuses.contains(order.status))
                            FilledButton.tonalIcon(
                              onPressed: () => onAdvanceOrder(order),
                              icon: const Icon(Icons.fast_forward),
                              label: const Text('Advance demo'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class InfoTile extends StatelessWidget {
  const InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(child: Icon(icon)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  const SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    super.key,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)
        : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
