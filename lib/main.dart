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
        cardTheme: const CardTheme(margin: EdgeInsets.zero),
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
  const CustomerAddress({required this.label, required this.line1, required this.landmark});

  final String label;
  final String line1;
  final String landmark;
}

class CustomerWallet {
  const CustomerWallet({required this.baseLoyaltyPoints, required this.storeCreditLimit, required this.storeCreditUsed});

  final int baseLoyaltyPoints;
  final int storeCreditLimit;
  final int storeCreditUsed;

  int get availableStoreCredit => storeCreditLimit - storeCreditUsed;
}

class CustomerPreferences {
  const CustomerPreferences({required this.languageCode, required this.easyMode, required this.voiceOrdering});

  final String languageCode;
  final bool easyMode;
  final bool voiceOrdering;

  CustomerPreferences copyWith({String? languageCode, bool? easyMode, bool? voiceOrdering}) => CustomerPreferences(
        languageCode: languageCode ?? this.languageCode,
        easyMode: easyMode ?? this.easyMode,
        voiceOrdering: voiceOrdering ?? this.voiceOrdering,
      );
}

class StoreInvite {
  const StoreInvite({required this.landingUrl, required this.referralCode, required this.rewardText});

  final String landingUrl;
  final String referralCode;
  final String rewardText;
}

class KiranaOrder {
  const KiranaOrder({
    required this.id,
    required this.items,
    required this.total,
    required this.discount,
    required this.payable,
    required this.slot,
    required this.paymentMethod,
    required this.deliveryInstruction,
    required this.substitutionPreference,
    required this.createdAt,
    this.status = 'Received',
  });

  final String id;
  final List<CartLine> items;
  final int total;
  final int discount;
  final int payable;
  final String slot;
  final String paymentMethod;
  final String deliveryInstruction;
  final String substitutionPreference;
  final DateTime createdAt;
  final String status;

  KiranaOrder copyWith({String? status}) => KiranaOrder(
        id: id,
        items: items,
        total: total,
        discount: discount,
        payable: payable,
        slot: slot,
        paymentMethod: paymentMethod,
        deliveryInstruction: deliveryInstruction,
        substitutionPreference: substitutionPreference,
        createdAt: createdAt,
        status: status ?? this.status,
      );

  int get itemCount => items.fold(0, (sum, line) => sum + line.quantity);
  int get statusIndex => orderStatusSteps.indexOf(status).clamp(0, orderStatusSteps.length - 1).toInt();
}

class OrderFeedback {
  const OrderFeedback({required this.orderId, required this.rating, required this.issueTag, required this.note, required this.createdAt});

  final String orderId;
  final int rating;
  final String issueTag;
  final String note;
  final DateTime createdAt;
}

class SmartOffer {
  const SmartOffer({required this.code, required this.title, required this.description, required this.minimumOrderValue, required this.discount});

  final String code;
  final String title;
  final String description;
  final int minimumOrderValue;
  final int discount;

  bool isEligible(int subtotal) => subtotal >= minimumOrderValue;
}

const storeWhatsAppNumber = '919876543210';
const storeUpiId = 'chandrastores@upi';
const appInvite = StoreInvite(landingUrl: 'https://chandrastores.example/app', referralCode: 'CHANDRA50', rewardText: 'Get ₹50 grocery savings after your first app order');
const customerAddress = CustomerAddress(label: 'Home', line1: '12, Market Street, Near Temple Road', landmark: 'Green gate, 2nd floor');
const customerWallet = CustomerWallet(baseLoyaltyPoints: 420, storeCreditLimit: 5000, storeCreditUsed: 1250);
final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

const orderStatusSteps = ['Received', 'Packing', 'Ready for dispatch', 'Out for delivery', 'Delivered'];
const supportedLanguages = {'en': 'English', 'ta': 'தமிழ்', 'hi': 'हिन्दी', 'kn': 'ಕನ್ನಡ'};

const smartOffers = <SmartOffer>[
  SmartOffer(code: 'WEEKLY100', title: 'Weekly basket reward', description: 'Save ₹100 on planned grocery baskets above ₹1,999.', minimumOrderValue: 1999, discount: 100),
  SmartOffer(code: 'MONTHLY250', title: 'Monthly stock-up bonus', description: 'Save ₹250 when your monthly staples cart crosses ₹4,999.', minimumOrderValue: 4999, discount: 250),
  SmartOffer(code: 'LOYAL50', title: 'Loyal customer thank-you', description: 'Use 50 loyalty points as instant grocery savings.', minimumOrderValue: 799, discount: 50),
];

const products = <Product>[
  Product(id: 'rice-sona-25', name: 'Sona Masoori Rice', brand: 'Store Select', category: 'Staples', packSize: '25 kg', price: 1399, mrp: 1499, inStock: true, stockQty: 9, reorderLevel: 6, icon: Icons.rice_bowl),
  Product(id: 'atta-10', name: 'Whole Wheat Atta', brand: 'Aashirvaad', category: 'Staples', packSize: '10 kg', price: 469, mrp: 520, inStock: true, stockQty: 18, reorderLevel: 8, icon: Icons.bakery_dining),
  Product(id: 'toor-2', name: 'Toor Dal', brand: 'Tata Sampann', category: 'Pulses', packSize: '2 kg', price: 339, mrp: 380, inStock: true, stockQty: 5, reorderLevel: 6, icon: Icons.grain),
  Product(id: 'oil-5', name: 'Sunflower Oil', brand: 'Fortune', category: 'Oil & Ghee', packSize: '5 L', price: 745, mrp: 820, inStock: true, stockQty: 4, reorderLevel: 5, icon: Icons.water_drop),
  Product(id: 'milk-1', name: 'Toned Milk', brand: 'Daily Fresh', category: 'Dairy', packSize: '1 L', price: 58, mrp: 60, inStock: true, stockQty: 24, reorderLevel: 10, icon: Icons.local_drink),
  Product(id: 'curd-500', name: 'Fresh Curd', brand: 'Nandini', category: 'Dairy', packSize: '500 g', price: 34, mrp: 36, inStock: true, stockQty: 7, reorderLevel: 8, icon: Icons.icecream),
  Product(id: 'tea-1', name: 'Premium Tea', brand: 'Tata Tea', category: 'Beverages', packSize: '1 kg', price: 489, mrp: 540, inStock: true, stockQty: 12, reorderLevel: 5, icon: Icons.coffee),
  Product(id: 'sugar-5', name: 'Sugar', brand: 'Store Select', category: 'Staples', packSize: '5 kg', price: 245, mrp: 270, inStock: true, stockQty: 20, reorderLevel: 8, icon: Icons.cake),
  Product(id: 'detergent-4', name: 'Detergent Powder', brand: 'Surf Excel', category: 'Home Care', packSize: '4 kg', price: 699, mrp: 760, inStock: true, stockQty: 6, reorderLevel: 4, icon: Icons.local_laundry_service),
  Product(id: 'soap-4', name: 'Bath Soap Combo', brand: 'Pears', category: 'Personal Care', packSize: '4 x 125 g', price: 219, mrp: 248, inStock: false, stockQty: 0, reorderLevel: 5, icon: Icons.soap),
];

const plannerPresets = <PlannerItem>[
  PlannerItem(label: 'Weekly Fresh Basket', frequency: 'Every Monday', budget: 1200, products: ['Toned Milk', 'Fresh Curd', 'Whole Wheat Atta', 'Sugar']),
  PlannerItem(label: 'Biweekly Staples Refill', frequency: '1st and 15th', budget: 2400, products: ['Sona Masoori Rice', 'Toor Dal', 'Sunflower Oil', 'Premium Tea']),
  PlannerItem(label: 'Monthly Home Care', frequency: 'Monthly', budget: 1400, products: ['Detergent Powder', 'Bath Soap Combo']),
];

List<Product> substituteProducts(Product product) => products
    .where((candidate) => candidate.id != product.id && candidate.category == product.category && candidate.inStock)
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
                child: Icon(Icons.storefront, size: 56, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 24),
              Text('Smart Kirana', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('Order daily essentials, plan weekly groceries, and pay with UPI, cards, QR, GPay, PhonePe, or Paytm.'),
              const SizedBox(height: 32),
              TextField(
                controller: mobileController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(prefixText: '+91 ', labelText: 'Mobile / WhatsApp number', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              if (otpSent)
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'WhatsApp OTP', helperText: 'Use 123456 for demo login', border: OutlineInputBorder()),
                ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  if (!otpSent) {
                    setState(() => otpSent = true);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demo WhatsApp OTP sent: 123456')));
                    return;
                  }
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ShopShell()));
                },
                icon: Icon(otpSent ? Icons.verified_user : Icons.message),
                label: Text(otpSent ? 'Verify and continue' : 'Send WhatsApp OTP'),
              ),
              const SizedBox(height: 24),
              const InfoTile(icon: Icons.qr_code_2, title: 'Download using store QR', subtitle: 'The same app link can be printed on bills, delivery bags, and shop posters.'),
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
  SmartOffer? appliedOffer;
  CustomerPreferences preferences = const CustomerPreferences(languageCode: 'en', easyMode: false, voiceOrdering: true);
  int tabIndex = 0;
  String query = '';
  String category = 'All';
  String deliverySlot = 'Today 6 PM - 8 PM';
  String paymentMethod = 'UPI';
  String deliveryInstruction = 'Ring bell and hand over';
  String substitutionPreference = 'Call before replacing';

  List<String> get categories => ['All', ...{for (final product in products) product.category}];
  int get cartCount => cart.values.fold(0, (sum, line) => sum + line.quantity);
  int get subtotal => cart.values.fold(0, (sum, line) => sum + line.total);
  int get offerDiscount => (appliedOffer?.isEligible(subtotal) ?? false) ? appliedOffer!.discount : 0;
  int get payable => (subtotal - offerDiscount).clamp(0, subtotal).toInt();
  int get savings => cart.values.fold(0, (sum, line) => sum + line.product.saving * line.quantity) + offerDiscount;

  void addToCart(Product product, [int quantity = 1]) {
    if (!product.inStock) {
      final substitutes = substituteProducts(product).map((candidate) => candidate.name).join(', ');
      final suffix = substitutes.isEmpty ? 'No substitute is available right now.' : 'Try: $substitutes.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${product.name} is currently out of stock. $suffix')));
      return;
    }
    setState(() {
      cart.update(product.id, (line) => line..quantity += quantity, ifAbsent: () => CartLine(product, quantity));
    });
  }

  void changeQuantity(String productId, int delta) {
    setState(() {
      final line = cart[productId];
      if (line == null) return;
      line.quantity += delta;
      if (line.quantity <= 0) cart.remove(productId);
      if (!(appliedOffer?.isEligible(subtotal) ?? true)) appliedOffer = null;
    });
  }

  void addPlanner(PlannerItem item) {
    for (final name in item.products) {
      final product = products.firstWhere((candidate) => candidate.name == name);
      addToCart(product);
    }
    setState(() => tabIndex = 2);
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.label} scheduled with WhatsApp reminders')));
  }

  DateTime nextDeliveryFor(String frequency) {
    final now = DateTime.now();
    if (frequency.contains('15th')) return now.add(const Duration(days: 14));
    if (frequency == 'Monthly') return now.add(const Duration(days: 30));
    return now.add(const Duration(days: 7));
  }

  void addSavedPlanToCart(SavedPlan plan) {
    for (final name in plan.products) {
      final product = products.firstWhere((candidate) => candidate.name == name);
      addToCart(product);
    }
    setState(() => tabIndex = 2);
  }

  void applyOffer(SmartOffer offer) {
    if (!offer.isEligible(subtotal)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Add ${currency.format(offer.minimumOrderValue - subtotal)} more to unlock ${offer.code}')));
      return;
    }
    setState(() => appliedOffer = offer);
  }

  Future<void> placeOrder() async {
    final order = KiranaOrder(
      id: 'SK${DateTime.now().millisecondsSinceEpoch}',
      items: cart.values.map((line) => CartLine(line.product, line.quantity)).toList(growable: false),
      total: subtotal,
      discount: offerDiscount,
      payable: payable,
      slot: deliverySlot,
      paymentMethod: paymentMethod,
      deliveryInstruction: deliveryInstruction,
      substitutionPreference: substitutionPreference,
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
      builder: (context) => OrderConfirmationSheet(order: order, onPay: () => openPayment(order), onShareWhatsApp: () => shareOrderOnWhatsApp(order)),
    );
  }

  Future<void> shareOrderOnWhatsApp(KiranaOrder order) async {
    final summary = order.items.map((line) => '${line.quantity} x ${line.product.name} (${line.product.packSize})').join(', ');
    final message = Uri.encodeComponent(
      'Smart Kirana order ${order.id}: $summary. Total: ${currency.format(order.payable)}. Slot: ${order.slot}. Payment: ${order.paymentMethod}. Delivery: ${order.deliveryInstruction}. Substitution: ${order.substitutionPreference}. Address: ${customerAddress.line1}, ${customerAddress.landmark}.',
    );
    final uri = Uri.parse('https://wa.me/$storeWhatsAppNumber?text=$message');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> openPayment(KiranaOrder order) async {
    final upiUri = Uri.parse('upi://pay?pa=$storeUpiId&pn=Chandra%20Stores&am=${order.payable}&cu=INR&tn=${order.id}');
    await launchUrl(upiUri, mode: LaunchMode.externalApplication);
  }

  Future<void> showOrderTracking(KiranaOrder order) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => OrderTrackingSheet(order: order),
    );
  }

  void advanceOrderStatus(KiranaOrder order) {
    final current = orderStatusSteps.indexOf(order.status);
    if (current < 0 || current >= orderStatusSteps.length - 1) return;
    final next = orderStatusSteps[current + 1];
    setState(() {
      final index = orderHistory.indexWhere((candidate) => candidate.id == order.id);
      if (index != -1) orderHistory[index] = order.copyWith(status: next);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${order.id} moved to $next')));
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Thanks for rating ${order.id}')));
        },
      ),
    );
  }

  void updateLanguage(String languageCode) => setState(() => preferences = preferences.copyWith(languageCode: languageCode));

  void toggleEasyMode(bool value) => setState(() => preferences = preferences.copyWith(easyMode: value));

  void toggleVoiceOrdering(bool value) => setState(() => preferences = preferences.copyWith(voiceOrdering: value));

  Future<void> startVoiceOrder() async {
    final language = supportedLanguages[preferences.languageCode] ?? 'English';
    final message = Uri.encodeComponent('Smart Kirana voice order request. Please call/WhatsApp me in $language and help build my grocery basket.');
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
      PlannerPage(activePlans: savedPlans, onAddPlan: addPlanner, onSchedulePlan: schedulePlan, onAddSavedPlan: addSavedPlanToCart),
      CartPage(
        lines: cart.values.toList(),
        subtotal: subtotal,
        offerDiscount: offerDiscount,
        savings: savings,
        appliedOffer: appliedOffer,
        deliverySlot: deliverySlot,
        paymentMethod: paymentMethod,
        deliveryInstruction: deliveryInstruction,
        substitutionPreference: substitutionPreference,
        onQuantity: changeQuantity,
        onSlotChanged: (value) => setState(() => deliverySlot = value),
        onPaymentChanged: (value) => setState(() => paymentMethod = value),
        onDeliveryInstructionChanged: (value) => setState(() => deliveryInstruction = value),
        onSubstitutionPreferenceChanged: (value) => setState(() => substitutionPreference = value),
        onApplyOffer: applyOffer,
        onCheckout: cart.isEmpty ? null : placeOrder,
      ),
      AccountPage(
        orders: orderHistory,
        plans: savedPlans,
        onShareOrder: shareOrderOnWhatsApp,
        onTrackOrder: showOrderTracking,
        onAdvanceOrder: advanceOrderStatus,
        onFeedbackOrder: showFeedbackSheet,
        feedbackByOrderId: feedbackByOrderId,
        onAddSavedPlan: addSavedPlanToCart,
        preferences: preferences,
        onLanguageChanged: updateLanguage,
        onEasyModeChanged: toggleEasyMode,
        onVoiceOrderingChanged: toggleVoiceOrdering,
        onStartVoiceOrder: startVoiceOrder,
        onShareInvite: shareAppInvite,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Kirana'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Badge(label: Text('$cartCount'), child: const Icon(Icons.shopping_cart_outlined)),
          ),
        ],
      ),
      body: pages[tabIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tabIndex,
        onDestinationSelected: (index) => setState(() => tabIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'Shop'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Planner'),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Account'),
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
      final text = '${product.name} ${product.brand} ${product.category}'.toLowerCase();
      return matchesCategory && text.contains(query.toLowerCase());
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          onChanged: onQueryChanged,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Search rice, oil, milk...', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final item = categories[index];
              return ChoiceChip(label: Text(item), selected: item == category, onSelected: (_) => onCategoryChanged(item));
            },
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: categories.length,
          ),
        ),
        const SizedBox(height: 16),
        const InfoTile(icon: Icons.auto_awesome, title: 'Smart reorder suggestions', subtitle: 'Weekly staples and frequently bought products are highlighted first for faster ordering.'),
        const SizedBox(height: 12),
        InfoTile(icon: Icons.inventory_2_outlined, title: 'Live stock confidence', subtitle: '${products.where((product) => product.lowStock).length} low-stock essentials and ${products.where((product) => !product.inStock).length} unavailable items are highlighted before checkout.'),
        const SizedBox(height: 16),
        ...filtered.map((product) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ProductCard(product: product, onAdd: () => onAdd(product)),
            )),
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
                  Text(product.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  Text('${product.brand} • ${product.packSize} • ${product.category}'),
                  const SizedBox(height: 6),
                  Row(children: [
                    Text(currency.format(product.price), style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(width: 8),
                    Text(currency.format(product.mrp), style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)),
                    if (product.saving > 0) Text('  Save ${currency.format(product.saving)}', style: const TextStyle(color: Colors.green)),
                  ]),
                  const SizedBox(height: 6),
                  Wrap(spacing: 6, children: [
                    Chip(label: Text(product.stockLabel), visualDensity: VisualDensity.compact),
                    if (!product.inStock && substituteProducts(product).isNotEmpty) const Chip(label: Text('Substitute available'), visualDensity: VisualDensity.compact),
                  ]),
                ],
              ),
            ),
            FilledButton.tonalIcon(onPressed: onAdd, icon: Icon(product.inStock ? Icons.add : Icons.swap_horiz), label: Text(product.inStock ? 'Add' : 'Swap')),
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
        Text('Plan groceries ahead', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('Create weekly, biweekly, or monthly baskets so the family never misses essentials.'),
        const SizedBox(height: 16),
        const InfoTile(icon: Icons.savings_outlined, title: 'Budget guardrails', subtitle: 'Each plan shows an estimated spend before you add it to cart.'),
        const SizedBox(height: 16),
        Text('Recurring plans', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        if (activePlans.isEmpty)
          const InfoTile(icon: Icons.event_repeat, title: 'No recurring grocery plan yet', subtitle: 'Schedule a basket below to receive WhatsApp reminders before each delivery.'),
        ...activePlans.map((plan) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SavedPlanCard(plan: plan, onAddToCart: () => onAddSavedPlan(plan)),
            )),
        const SizedBox(height: 16),
        Text('Suggested baskets', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        ...plannerPresets.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(child: Text(item.label, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
                        Chip(label: Text(item.frequency)),
                      ]),
                      const SizedBox(height: 8),
                      Text(item.products.join(' • ')),
                      const SizedBox(height: 8),
                      Text('Estimated budget ${currency.format(item.budget)}'),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: OutlinedButton.icon(onPressed: () => onSchedulePlan(item), icon: const Icon(Icons.event_repeat), label: const Text('Schedule'))),
                        const SizedBox(width: 12),
                        Expanded(child: FilledButton.icon(onPressed: () => onAddPlan(item), icon: const Icon(Icons.playlist_add_check), label: const Text('Add now'))),
                      ]),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

class SavedPlanCard extends StatelessWidget {
  const SavedPlanCard({required this.plan, required this.onAddToCart, super.key});

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
            Row(children: [
              const CircleAvatar(child: Icon(Icons.event_repeat)),
              const SizedBox(width: 12),
              Expanded(child: Text(plan.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
              Chip(label: Text(plan.frequency)),
            ]),
            const SizedBox(height: 8),
            Text('Next delivery ${DateFormat('EEE, d MMM').format(plan.nextDelivery)} • Budget ${currency.format(plan.budget)}'),
            const SizedBox(height: 6),
            Text(plan.products.join(' • ')),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(onPressed: onAddToCart, icon: const Icon(Icons.add_shopping_cart), label: const Text('Add plan to cart')),
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
    required this.savings,
    required this.appliedOffer,
    required this.deliverySlot,
    required this.paymentMethod,
    required this.deliveryInstruction,
    required this.substitutionPreference,
    required this.onQuantity,
    required this.onSlotChanged,
    required this.onPaymentChanged,
    required this.onDeliveryInstructionChanged,
    required this.onSubstitutionPreferenceChanged,
    required this.onApplyOffer,
    required this.onCheckout,
    super.key,
  });

  final List<CartLine> lines;
  final int subtotal;
  final int offerDiscount;
  final int savings;
  final SmartOffer? appliedOffer;
  final String deliverySlot;
  final String paymentMethod;
  final String deliveryInstruction;
  final String substitutionPreference;
  final void Function(String productId, int delta) onQuantity;
  final ValueChanged<String> onSlotChanged;
  final ValueChanged<String> onPaymentChanged;
  final ValueChanged<String> onDeliveryInstructionChanged;
  final ValueChanged<String> onSubstitutionPreferenceChanged;
  final ValueChanged<SmartOffer> onApplyOffer;
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context) {
    const slots = ['Today 6 PM - 8 PM', 'Tomorrow 8 AM - 10 AM', 'Sunday weekly delivery'];
    const payments = ['UPI', 'GPay', 'PhonePe', 'Paytm', 'Credit card', 'Debit card', 'QR pay', 'Cash'];
    const deliveryInstructions = ['Ring bell and hand over', 'Leave at doorstep', 'Call on arrival', 'Deliver to security'];
    const substitutionPreferences = ['Call before replacing', 'WhatsApp photo before replacing', 'Use same brand only', 'No substitutions'];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Your cart', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        if (lines.isEmpty) const InfoTile(icon: Icons.shopping_basket_outlined, title: 'Cart is empty', subtitle: 'Add products from the shop or weekly planner.'),
        ...lines.map((line) => Card(
              child: ListTile(
                leading: CircleAvatar(child: Icon(line.product.icon)),
                title: Text(line.product.name),
                subtitle: Text('${line.product.packSize} • ${currency.format(line.product.price)} each'),
                trailing: QuantityStepper(quantity: line.quantity, onMinus: () => onQuantity(line.product.id, -1), onPlus: () => onQuantity(line.product.id, 1)),
              ),
            )),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: deliverySlot,
          items: slots.map((slot) => DropdownMenuItem(value: slot, child: Text(slot))).toList(),
          onChanged: (value) => value == null ? null : onSlotChanged(value),
          decoration: const InputDecoration(labelText: 'Delivery slot', border: OutlineInputBorder(), prefixIcon: Icon(Icons.schedule)),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: deliveryInstruction,
          items: deliveryInstructions.map((instruction) => DropdownMenuItem(value: instruction, child: Text(instruction))).toList(),
          onChanged: (value) => value == null ? null : onDeliveryInstructionChanged(value),
          decoration: const InputDecoration(labelText: 'Delivery instruction', border: OutlineInputBorder(), prefixIcon: Icon(Icons.delivery_dining)),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: substitutionPreference,
          items: substitutionPreferences.map((preference) => DropdownMenuItem(value: preference, child: Text(preference))).toList(),
          onChanged: (value) => value == null ? null : onSubstitutionPreferenceChanged(value),
          decoration: const InputDecoration(labelText: 'Substitution preference', border: OutlineInputBorder(), prefixIcon: Icon(Icons.swap_horiz)),
        ),
        const SizedBox(height: 16),
        Text('Payment method', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: payments.map((payment) => ChoiceChip(label: Text(payment), selected: payment == paymentMethod, onSelected: (_) => onPaymentChanged(payment))).toList(),
        ),
        const SizedBox(height: 20),
        Text('Smart offers', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        ...smartOffers.map((offer) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OfferTile(offer: offer, subtotal: subtotal, selected: appliedOffer?.code == offer.code, onApply: () => onApplyOffer(offer)),
            )),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              SummaryRow(label: 'Subtotal', value: currency.format(subtotal)),
              if (offerDiscount > 0) SummaryRow(label: 'Offer discount', value: '-${currency.format(offerDiscount)}'),
              SummaryRow(label: 'You save', value: currency.format(savings)),
              const Divider(),
              SummaryRow(label: 'Payable', value: currency.format(subtotal - offerDiscount), bold: true),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: onCheckout, icon: const Icon(Icons.chat), label: const Text('Review and place order')),
      ],
    );
  }
}

class OfferTile extends StatelessWidget {
  const OfferTile({required this.offer, required this.subtotal, required this.selected, required this.onApply, super.key});

  final SmartOffer offer;
  final int subtotal;
  final bool selected;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final eligible = offer.isEligible(subtotal);
    final unlockAmount = (offer.minimumOrderValue - subtotal).clamp(0, offer.minimumOrderValue).toInt();
    return Card(
      color: selected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        leading: CircleAvatar(child: Icon(selected ? Icons.check : Icons.local_offer_outlined)),
        title: Text('${offer.title} • ${currency.format(offer.discount)} off'),
        subtitle: Text(eligible ? '${offer.code}: ${offer.description}' : 'Add ${currency.format(unlockAmount)} more to unlock ${offer.code}.'),
        trailing: TextButton(onPressed: eligible ? onApply : null, child: Text(selected ? 'Applied' : 'Apply')),
      ),
    );
  }
}

class OrderConfirmationSheet extends StatelessWidget {
  const OrderConfirmationSheet({required this.order, required this.onPay, required this.onShareWhatsApp, super.key});

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
          Row(children: [
            CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: const Icon(Icons.check)),
            const SizedBox(width: 12),
            Expanded(child: Text('Order received', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800))),
          ]),
          const SizedBox(height: 16),
          SummaryRow(label: 'Order ID', value: order.id),
          SummaryRow(label: 'Items', value: '${order.itemCount}'),
          SummaryRow(label: 'Delivery slot', value: order.slot),
          SummaryRow(label: 'Instruction', value: order.deliveryInstruction),
          SummaryRow(label: 'Substitution', value: order.substitutionPreference),
          SummaryRow(label: 'Payment', value: order.paymentMethod),
          const Divider(height: 24),
          if (order.discount > 0) SummaryRow(label: 'Offer discount', value: '-${currency.format(order.discount)}'),
          SummaryRow(label: 'Total payable', value: currency.format(order.payable), bold: true),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(onPressed: onShareWhatsApp, icon: const Icon(Icons.chat), label: const Text('Send WhatsApp')),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(onPressed: isDigitalPayment ? onPay : null, icon: const Icon(Icons.payments), label: Text(isDigitalPayment ? 'Pay now' : 'Cash order')),
            ),
          ]),
          const SizedBox(height: 8),
          const Text('Production builds will replace this with Razorpay/Cashfree payment confirmation webhooks and automated WhatsApp templates.'),
        ],
      ),
    );
  }
}

class FeedbackSheet extends StatefulWidget {
  const FeedbackSheet({required this.order, required this.initialFeedback, required this.onSubmit, super.key});

  final KiranaOrder order;
  final OrderFeedback? initialFeedback;
  final ValueChanged<OrderFeedback> onSubmit;

  @override
  State<FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<FeedbackSheet> {
  late int rating = widget.initialFeedback?.rating ?? 5;
  late String issueTag = widget.initialFeedback?.issueTag ?? 'Everything was good';
  late final TextEditingController noteController = TextEditingController(text: widget.initialFeedback?.note ?? '');

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const issueTags = ['Everything was good', 'Late delivery', 'Missing item', 'Wrong item', 'Quality issue', 'Substitution issue'];
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: const Icon(Icons.rate_review)),
            const SizedBox(width: 12),
            Expanded(child: Text('Rate ${widget.order.id}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800))),
          ]),
          const SizedBox(height: 8),
          Text('${widget.order.itemCount} items • ${currency.format(widget.order.payable)}'),
          const SizedBox(height: 16),
          Text('Delivery rating', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(5, (index) {
              final value = index + 1;
              return ChoiceChip(label: Text('$value ★'), selected: rating == value, onSelected: (_) => setState(() => rating = value));
            }),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: issueTag,
            items: issueTags.map((tag) => DropdownMenuItem(value: tag, child: Text(tag))).toList(),
            onChanged: (value) => value == null ? null : setState(() => issueTag = value),
            decoration: const InputDecoration(labelText: 'Feedback reason', border: OutlineInputBorder(), prefixIcon: Icon(Icons.feedback_outlined)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Optional note for store owner', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => widget.onSubmit(OrderFeedback(orderId: widget.order.id, rating: rating, issueTag: issueTag, note: noteController.text.trim(), createdAt: DateTime.now())),
            icon: const Icon(Icons.send),
            label: const Text('Submit feedback'),
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
          Row(children: [
            CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: const Icon(Icons.delivery_dining)),
            const SizedBox(width: 12),
            Expanded(child: Text('Track ${order.id}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800))),
          ]),
          const SizedBox(height: 8),
          Text('${order.itemCount} items • ${order.slot} • ${currency.format(order.payable)}'),
          const SizedBox(height: 4),
          Text('Delivery: ${order.deliveryInstruction} • Substitution: ${order.substitutionPreference}'),
          const SizedBox(height: 16),
          ...orderStatusSteps.asMap().entries.map((entry) => OrderTimelineStep(
                label: entry.value,
                completed: entry.key <= order.statusIndex,
                isCurrent: entry.key == order.statusIndex,
              )),
          const SizedBox(height: 12),
          const InfoTile(icon: Icons.swap_horiz, title: 'Substitution approval', subtitle: 'If an item is unavailable, the store will confirm replacements on WhatsApp before dispatch.'),
        ],
      ),
    );
  }
}

class OrderTimelineStep extends StatelessWidget {
  const OrderTimelineStep({required this.label, required this.completed, required this.isCurrent, super.key});

  final String label;
  final bool completed;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final color = completed ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Icon(completed ? Icons.check_circle : Icons.radio_button_unchecked, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500, color: isCurrent ? Theme.of(context).colorScheme.primary : null),
          ),
        ),
      ]),
    );
  }
}

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({required this.quantity, required this.onMinus, required this.onPlus, super.key});

  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(onPressed: onMinus, icon: const Icon(Icons.remove_circle_outline)),
        Text('$quantity', style: const TextStyle(fontWeight: FontWeight.w800)),
        IconButton(onPressed: onPlus, icon: const Icon(Icons.add_circle_outline)),
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
            Row(children: [
              CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: const Icon(Icons.translate)),
              const SizedBox(width: 12),
              Expanded(child: Text('Accessibility & language', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
            ]),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: preferences.languageCode,
              items: supportedLanguages.entries.map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value))).toList(),
              onChanged: (value) => value == null ? null : onLanguageChanged(value),
              decoration: const InputDecoration(labelText: 'Preferred language', border: OutlineInputBorder(), prefixIcon: Icon(Icons.language)),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: preferences.easyMode,
              onChanged: onEasyModeChanged,
              title: const Text('Senior-friendly easy mode'),
              subtitle: const Text('Prioritise larger controls, repeat baskets, and simplified checkout copy.'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: preferences.voiceOrdering,
              onChanged: onVoiceOrderingChanged,
              title: const Text('Voice ordering support'),
              subtitle: const Text('Ask the store to help create a basket from a WhatsApp voice note or call.'),
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
            Row(children: [
              CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: const Icon(Icons.qr_code_2)),
              const SizedBox(width: 12),
              Expanded(child: Text('Invite family to Smart Kirana', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
            ]),
            const SizedBox(height: 12),
            Text('App link: ${appInvite.landingUrl}'),
            const SizedBox(height: 6),
            Text('Referral code ${appInvite.referralCode} • ${appInvite.rewardText}'),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(onPressed: onShareInvite, icon: const Icon(Icons.ios_share), label: const Text('Share app link on WhatsApp')),
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
  int get digitalOrders => orders.where((order) => order.paymentMethod != 'Cash').length;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primaryContainer, child: const Icon(Icons.account_balance_wallet)),
              const SizedBox(width: 12),
              Expanded(child: Text('Grocery wallet', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
            ]),
            const SizedBox(height: 16),
            SummaryRow(label: 'Monthly app spend', value: currency.format(monthlySpend)),
            SummaryRow(label: 'Loyalty points', value: '$availablePoints pts'),
            SummaryRow(label: 'Store credit available', value: currency.format(customerWallet.availableStoreCredit)),
            SummaryRow(label: 'Digital payment orders', value: '$digitalOrders/${orders.length}'),
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
    required this.onTrackOrder,
    required this.onAdvanceOrder,
    required this.onFeedbackOrder,
    required this.feedbackByOrderId,
    required this.onAddSavedPlan,
    required this.preferences,
    required this.onLanguageChanged,
    required this.onEasyModeChanged,
    required this.onVoiceOrderingChanged,
    required this.onStartVoiceOrder,
    required this.onShareInvite,
    super.key,
  });

  final List<KiranaOrder> orders;
  final List<SavedPlan> plans;
  final ValueChanged<KiranaOrder> onShareOrder;
  final ValueChanged<KiranaOrder> onTrackOrder;
  final ValueChanged<KiranaOrder> onAdvanceOrder;
  final ValueChanged<KiranaOrder> onFeedbackOrder;
  final Map<String, OrderFeedback> feedbackByOrderId;
  final ValueChanged<SavedPlan> onAddSavedPlan;
  final CustomerPreferences preferences;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<bool> onEasyModeChanged;
  final ValueChanged<bool> onVoiceOrderingChanged;
  final VoidCallback onStartVoiceOrder;
  final VoidCallback onShareInvite;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const InfoTile(icon: Icons.person, title: 'Chandra Stores customer', subtitle: '+91 98765 43210 • 420 loyalty points'),
        const SizedBox(height: 12),
        InfoTile(icon: Icons.location_on_outlined, title: customerAddress.label, subtitle: '${customerAddress.line1} • ${customerAddress.landmark}'),
        const SizedBox(height: 12),
        InviteCard(onShareInvite: onShareInvite),
        const SizedBox(height: 12),
        WalletSummaryCard(orders: orders),
        const SizedBox(height: 12),
        PreferenceCard(
          preferences: preferences,
          onLanguageChanged: onLanguageChanged,
          onEasyModeChanged: onEasyModeChanged,
          onVoiceOrderingChanged: onVoiceOrderingChanged,
          onStartVoiceOrder: onStartVoiceOrder,
        ),
        const SizedBox(height: 12),
        const InfoTile(icon: Icons.support_agent, title: 'WhatsApp support', subtitle: 'Ask for substitutions, credit account support, and delivery updates from the store.'),
        const SizedBox(height: 24),
        Text('Active grocery plans', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        if (plans.isEmpty)
          const InfoTile(icon: Icons.event_repeat, title: 'No active recurring plan', subtitle: 'Recurring weekly, biweekly, and monthly plans will appear here.'),
        ...plans.map((plan) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.event_repeat)),
                  title: Text(plan.name),
                  subtitle: Text('${plan.frequency} • Next ${DateFormat('d MMM').format(plan.nextDelivery)} • ${currency.format(plan.budget)}'),
                  trailing: TextButton(onPressed: () => onAddSavedPlan(plan), child: const Text('Add')),
                ),
              ),
            )),
        const SizedBox(height: 24),
        Text('Recent orders', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        if (orders.isEmpty)
          const InfoTile(icon: Icons.receipt_long_outlined, title: 'No app orders yet', subtitle: 'Completed checkout orders will appear here with status and repeat actions.'),
        ...orders.map((order) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(children: [
                    ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.receipt_long)),
                      title: Text('${order.id} • ${currency.format(order.payable)}'),
                      subtitle: Text('${order.itemCount} items • ${order.slot} • ${order.status}'),
                    ),
                    if (feedbackByOrderId[order.id] != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Chip(label: Text('${feedbackByOrderId[order.id]!.rating}★ • ${feedbackByOrderId[order.id]!.issueTag}')),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton.icon(onPressed: () => onTrackOrder(order), icon: const Icon(Icons.delivery_dining), label: const Text('Track')),
                          OutlinedButton.icon(onPressed: () => onShareOrder(order), icon: const Icon(Icons.chat), label: const Text('WhatsApp')),
                          OutlinedButton.icon(onPressed: () => onFeedbackOrder(order), icon: const Icon(Icons.rate_review), label: Text(feedbackByOrderId[order.id] == null ? 'Feedback' : 'Edit feedback')),
                          if (order.status != orderStatusSteps.last)
                            FilledButton.tonalIcon(onPressed: () => onAdvanceOrder(order), icon: const Icon(Icons.fast_forward), label: const Text('Advance demo')),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            )),
      ],
    );
  }
}

class InfoTile extends StatelessWidget {
  const InfoTile({required this.icon, required this.title, required this.subtitle, super.key});

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
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(subtitle),
            ])),
          ],
        ),
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  const SummaryRow({required this.label, required this.value, this.bold = false, super.key});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: style), Text(value, style: style)]),
    );
  }
}
