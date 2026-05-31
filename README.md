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
docs/launch-plan.md        Play Store/App Store/QR rollout checklist
pubspec.yaml               Flutter dependencies and app metadata
```

## Run locally

Install Flutter 3.22+ and then run:

```bash
flutter pub get
flutter run
```

## Production integration notes

The current repository now contains the customer-facing mobile app shell and UX flow. Production rollout should connect the placeholders to the backend described in the technical document:

1. WhatsApp Business Platform OTP and transactional templates.
2. Razorpay or Cashfree payment gateway for UPI, QR, cards, GPay, PhonePe, and Paytm.
3. Store catalogue, live inventory, pricing, offers, and customer-specific saved baskets.
4. Order webhooks, delivery-slot assignment, invoice generation, and notifications.
5. Play Store and App Store release builds, with a QR code pointing to the store landing page or Firebase Dynamic Link.

## Sprint 2 additions

- Checkout now creates a local Smart Kirana order record before WhatsApp/payment handoff.
- Account includes recent order history with order status and WhatsApp resend support.
- Customer address details are surfaced in the profile and included in the structured WhatsApp order message.
- Digital payment selections can hand off to a UPI intent stub while the gateway integration is pending.

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
- Account order cards include Track, WhatsApp, and demo status progression actions for UAT.
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
