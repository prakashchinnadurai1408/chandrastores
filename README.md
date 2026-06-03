# Smart Kirana Mobile App

Smart Kirana is a Flutter mobile application for a neighbourhood kirana store serving 2,000+ customers. It is designed from the BRD and technical document in this repository to support mobile-number login, WhatsApp OTP confirmation, structured cart ordering, weekly/biweekly/monthly grocery planning, and India-ready payment choices.

## Customer capabilities

- Mobile-number onboarding with a WhatsApp OTP flow.
- Product discovery by category with search, price, pack size, savings, and stock status.
- Amazon-style cart with quantity controls, totals, delivery slots, and payment selection.
- Weekly, biweekly, and monthly grocery planning with one-tap add-to-cart.
- Supported payment modes shown in the checkout: UPI, GPay, PhonePe, Paytm, credit card, debit card, QR pay, and cash-on-delivery fallback.
- WhatsApp order handoff that opens a structured order message to the kirana store.
- Senior-friendly settings, loyalty points, delivery address, and store QR-code download guidance.

## Project structure

```text
lib/main.dart              Flutter customer app implementation
lib/backend.dart           Production-shaped backend service scaffold
test/                      Widget and backend contract tests
docs/launch-plan.md        Play Store/App Store/QR rollout checklist
pubspec.yaml               Flutter dependencies and app metadata
```

## Run locally

Install Flutter 3.22+ and then run:

```bash
flutter pub get
flutter run
```

## Production readiness

The current repository contains the customer-facing Flutter app, backend route scaffold, role guards, idempotency/audit handling, provider-aware payment and WhatsApp handoff services, QR/app-download payloads, fulfilment APIs, recurring plan execution, reconciliation, and automated tests.

Before a live launch, configure the deployment with real provider values:

1. WhatsApp Business Platform credentials and approved OTP/transactional templates.
2. Razorpay or Cashfree keys, webhook signature verification, and settlement reporting.
3. Production catalogue, live inventory, pricing, offers, and customer saved baskets.
4. Invoice storage domain, notification delivery provider, and app download landing URL.
5. Play Store and App Store signing, release builds, and QR code pointing to the production landing page.

Backend code should be started with `SmartKiranaBackend.production(...)` and a `SmartKiranaBackendConfig.production(...)` value. Local tests continue to use `SmartKiranaBackend.seeded()`, which enables deterministic demo OTP behavior.


## Production backend scaffold

The repository now includes a Dart backend service scaffold at `lib/backend.dart` with Customer API, catalogue API, inventory reservation, pricing/offers, order creation, payment attempts/webhooks, WhatsApp template queue, delivery slots, invoices, notifications, admin dashboard summaries, staff fulfilment status updates, and QR scan verification. See `docs/backend-architecture.md` for the route map and production hardening checklist.

## Sprint 2 additions

- Checkout now creates a local Smart Kirana order record before WhatsApp/payment handoff.
- Account includes recent order history with order status and WhatsApp resend support.
- Customer address details are surfaced in the profile and included in the structured WhatsApp order message.
- Digital payment selections create provider-shaped payment attempts and UPI intent payloads using configured store payment settings.

## Sprint 3 additions

- Checkout includes smart offer cards for weekly, monthly, and loyalty-based discounts.
- Cart totals now show subtotal, applied offer discount, savings, and final payable amount.
- Order records, WhatsApp handoff, and UPI intent use the discounted payable amount for consistency.

## Sprint 4 additions

- Planner supports active recurring grocery plans for weekly, biweekly, and monthly baskets.
- Customers can schedule a suggested basket, receive reminder-ready plan state, and add saved plans back to the cart.
- Account now surfaces active grocery plans next to recent orders for repeat ordering.

## Sprint 5 additions

- Recent orders now support a tracking timeline from received through delivered.
- Account order cards include Track, WhatsApp, and status progression actions for UAT.
- Tracking includes substitution-approval guidance for unavailable products before dispatch.

## Sprint 6 additions

- Account includes a Grocery wallet summary for monthly spend, loyalty points, store credit, and digital-payment order count.
- Loyalty points are estimated from app order value and linked to the existing LOYAL50 checkout offer.
- Store credit display prepares the app for future khata/account integrations.

## Sprint 7 additions

- Catalogue products now show stock quantity confidence through in-stock, low-stock, and out-of-stock labels.
- Customers see substitute guidance when attempting to add unavailable products.
- Catalogue summary highlights low-stock and unavailable items before checkout.

## Sprint 8 additions

- Account includes accessibility and language preferences for English, Tamil, Hindi, and Kannada.
- Customers can toggle senior-friendly easy mode and voice-ordering support locally for UAT.
- Voice-ordering handoff opens WhatsApp with the selected language so the store can help build the basket.

## Sprint 9 additions

- Checkout captures delivery instructions such as doorstep, call-on-arrival, and security delivery.
- Checkout captures substitution preferences including WhatsApp-photo approval and no-substitution options.
- WhatsApp order handoff, confirmation, and tracking include delivery and substitution instructions.

## Sprint 10 additions

- Recent orders include feedback actions for rating the order experience.
- Feedback captures star rating, issue reason, and optional notes for the store owner.
- Submitted feedback appears on the matching order card and can be edited during UAT.

## Sprint 11 additions

- Account includes an app invite card with landing link, referral code, and reward copy.
- Customers can share a prefilled Smart Kirana download invite through WhatsApp.
- Referral copy prepares the app for QR/app-link acquisition and future first-order reward tracking.

## Sprint 12 additions

- Account includes a monthly grocery statement with order count, spend, digital-payment share, and category breakdown.
- Customers can share a compact monthly statement over WhatsApp for family budgeting or reconciliation.
- Statement logic prepares the app for future invoice/PDF downloads and automated monthly summaries.

## Sprint 13 additions

- Recent orders include support ticket actions for missing, wrong, damaged, late, payment, and refund issues.
- Support tickets capture issue type, priority, and description, then can be saved locally or shared on WhatsApp.
- Submitted support tickets appear on order cards for UAT visibility before backend ticket persistence is connected.

## Sprint 14 additions

- Cart quantity controls now prevent customers from exceeding available stock for each product.
- Checkout communicates a 15-minute stock reservation window while payment/WhatsApp confirmation completes.
- Order confirmation, WhatsApp handoff, and tracking include reservation expiry details for fulfilment confidence.

## Sprint 15 additions

- Account includes a notification center for order updates, recurring plan reminders, and support ticket status.
- Notification digest sharing creates a compact WhatsApp summary of recent customer updates.
- Local notification generation prepares the app for Firebase/WhatsApp notification APIs and read-state tracking.

## Sprint 16 additions

- Checkout now calculates delivery fees by selected slot and shows free-delivery eligibility for larger baskets.
- Order totals store delivery fee separately from subtotal, discounts, and payable amount.
- WhatsApp handoff, confirmation, and tracking include delivery fee details for clearer reconciliation.

## Sprint 17 additions

- Recent orders can now be cancelled before terminal statuses, with reason and refund preference capture.
- Cancellation requests can be saved locally for UAT and shared to the store through WhatsApp with the order ID, reason, and refund mode.
- Cancelled orders show a refund preference chip and no longer expose status advancement or repeat cancellation actions.

## Sprint 18 additions

- Cart now supports household approval requests before checkout for high-value weekly or monthly baskets.
- Customers can pick a family approver, add a note, save the approval locally, or send a WhatsApp approval request.
- Account includes a household approvals card with recent approval requests and WhatsApp resend actions.

## Sprint 19 additions

- Account now includes a reward center showing available loyalty points and redeemable grocery vouchers.
- Customers can redeem eligible vouchers locally or share reward details through WhatsApp for family/store coordination.
- Reward state tracks redeemed voucher codes so UAT can validate loyalty burn before gateway-backed coupon redemption is connected.

## Sprint 20 additions

- Recent orders now include invoice request actions for retail bills, GST invoices, monthly statements, and khata ledger copies.
- Customers can capture billing name, optional GSTIN, and optional email, then save the invoice request locally or send it to the store on WhatsApp.
- Order cards show invoice request chips so UAT can confirm bill-request status before backend invoice generation is connected.

## Sprint 21 additions

- Checkout now includes an address selector so customers can choose saved Home, Parents, or Office delivery locations before placing an order.
- WhatsApp order handoff includes the selected address label, address line, and landmark for clearer delivery planning.
- Account now includes an address book card so customers can switch the active delivery address during UAT.

## Sprint 22 additions

- Recent orders now include a Repeat action so customers can rebuild a previous basket into the cart quickly.
- Repeat order logic restores repeatable in-stock quantities, delivery slot, selected address, delivery instruction, and substitution preference.
- Stock-aware repeat handling skips unavailable lines and moves customers directly to the cart for final review before checkout.

## Sprint 23 additions

- Recent orders now include payment proof capture for UPI, cards, QR, wallet, and cash reconciliation.
- Customers can save payment method, reference number, and paid amount locally or send the proof to the store over WhatsApp.
- Order cards show paid/reference chips so UAT can validate payment reconciliation before gateway webhooks are connected.

## Sprint 24 additions

- Cart now includes a monthly budget guard that compares current monthly spend, this cart projection, and the customer budget limit.
- Customers see progress, remaining budget, or over-budget guidance before checkout.
- Budget guardrails prepare the app for backend household budgets, spend alerts, and planned grocery controls.

## Sprint 25 additions

- Recent orders now include delivery reschedule requests for non-terminal orders.
- Customers can request a new delivery slot, choose a reason, add a store note, save locally, or send the request on WhatsApp.
- Order cards show reschedule chips so UAT can validate slot-change workflows before fulfilment APIs are connected.


## Sprint 26 additions

- Checkout now supports fulfilment mode selection between home delivery and store pickup.
- Store pickup removes delivery fees while keeping slot, payment, address, and substitution review in the cart.
- Repeat order and WhatsApp handoff preserve/show the selected fulfilment mode for clearer store operations.


## Sprint 27 additions

- Orders now generate a pickup or delivery handoff code from the order ID for counter/rider verification.
- Store pickup orders expose a pickup pass with QR-style presentation, slot, address, payment, and guidance for the customer.
- Order confirmation, tracking, recent-order chips, and WhatsApp handoff now include the pickup/delivery code for clearer fulfilment.


## Partly-built feature backend completion

The backend scaffold now includes completion paths for the previously partial production features: WhatsApp OTP plus transactional templates, payment attempts/webhooks/refunds, app-download QR payloads, pickup QR/pass scan verification with audit logs, notification queues, rewards/wallet ledger operations, invoice generation, support tickets, delivery tracking events, and recurring grocery plan APIs.


## Sprint 28 additions

- Backend scaffold now supports idempotent POST retries through `x-idempotency-key` so duplicate order/payment/support submissions can safely replay the first successful response.
- Every backend request is captured in an audit log with actor, path, status code, idempotency key, replay flag, and timestamp.
- Added `/health` and `/audit/events` operational routes to prepare the backend scaffold for deployment probes and admin observability.


## Sprint 29 additions

- Backend scaffold now evaluates store-owner alerts across low stock, payment attention, WhatsApp template failures, high-priority support tickets, and open fulfilment orders.
- Added `/admin/alerts` for operational alert summaries and `/admin/alerts/notify` to queue an admin notification for store-owner review.
- Alert output includes severity counts so the admin/store dashboard can prioritise critical issues first.


## Sprint 30 additions

- Store-owner alerts now have lifecycle state for open, acknowledged, and resolved incidents.
- Added `/admin/alerts/acknowledge` to assign an alert with a note and `/admin/alerts/resolve` to remove resolved incidents from active alert output.
- Alert summaries now include acknowledged counts so the admin dashboard can separate new work from already-owned incidents.


## Sprint 31 additions

- Backend scaffold now protects admin, audit, and staff fulfilment routes using a role access guard based on `x-role` headers.
- Anonymous access to `/admin/*`, `/audit/events`, and `/staff/*` returns structured `403 FORBIDDEN` metadata with required and actual roles.
- Tests now cover denied anonymous access and allowed admin access so RBAC handoff work is visible before JWT/scoped auth integration.

## Sprint 32 additions

- Staff fulfilment now exposes `/staff/orders/queue` for open orders with slot, payable, fulfilment mode, item count, and assignment state.
- Added `/staff/orders/{orderId}/assign` and `/staff/orders/{orderId}/pack` so picker/packer handoffs are testable before the dedicated staff app is wired.
- Backend tests now cover protected queue access, assignment metadata, packing status transitions, and queue replay of packed assignment state.

## Sprint 33 additions

- Delivery operations now expose `/delivery/routes/plan`, `/delivery/routes/{routeId}/dispatch`, and `/delivery/routes` for packed home-delivery order routing.
- Route planning assigns packed orders to a rider manifest and dispatch updates order status to `Out for delivery`.
- Dispatch automatically writes tracking timeline events so the customer app can show rider progress once the route is sent out.

## Sprint 34 additions

- Recurring grocery plans now expose `/recurring-plans/run-due` to create orders from active weekly, biweekly, or monthly baskets.
- Successful runs refresh plan metadata with last order, last run time, next run time, and run count.
- Plan execution now queues customer notifications and WhatsApp transactional messages so recurring order creation is visible to customers.

## Sprint 35 additions

- Admin operations now expose `/admin/reconciliation` to compare orders, captured payments, refunds, invoices, and pending balances.
- Reconciliation rows include payable amount, paid amount, balance, payment status, invoice status, and invoice IDs for daily closing UAT.
- Backend tests now cover protected admin access, captured payment, refund subtraction, invoice generation, and settled reconciliation rows.
