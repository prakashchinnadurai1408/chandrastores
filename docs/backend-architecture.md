# Smart Kirana Production Backend Architecture

This repository now includes a Dart backend service scaffold in `lib/backend.dart` that models the production services required to move the Flutter customer app beyond local/UAT state.

## Services included

1. **Customer API** - mobile login start/verify endpoints with WhatsApp OTP-shaped responses.
2. **Product/catalogue API** - list and product-detail endpoints over active catalogue records.
3. **Inventory service** - stock validation, reservation, and release logic.
4. **Pricing/offer engine** - quote calculation with subtotal, discounts, delivery fee, and payable amount.
5. **Order creation API** - creates orders from quote + inventory reservation.
6. **Payment gateway backend** - payment attempt creation and webhook status update shape for Razorpay/Cashfree-style integrations.
7. **WhatsApp Business backend** - template-message outbox queue shape.
8. **Delivery-slot service** - home-delivery and pickup-capacity slot responses.
9. **Invoice service** - invoice generation response with downloadable URL shape.
10. **Notification service** - push/WhatsApp/SMS notification queue shape.
11. **Admin/store dashboard** - order count, revenue, low-stock, and open-order summary.
12. **Staff fulfilment app API** - staff order-status transition endpoint.
13. **QR scan/verify API** - pickup/delivery code verification against created orders.

## Route map

- `POST /customers/login/start`
- `POST /customers/login/verify`
- `GET /catalogue/products`
- `GET /catalogue/products/{productId}`
- `POST /inventory/reserve`
- `POST /pricing/quote`
- `POST /orders`
- `POST /payments/create`
- `POST /payments/webhook`
- `POST /whatsapp/send`
- `GET /delivery-slots`
- `POST /invoices`
- `POST /notifications`
- `GET /admin/dashboard`
- `POST /staff/orders/{orderId}/status`
- `POST /qr/verify`

## Completed partly-built production loops

- WhatsApp OTP now has backend request/verify shapes and transactional WhatsApp template routing.
- Payment backend now supports payment attempts, webhook updates, and refund initiation.
- QR download and pickup/delivery scan verification now expose app-download payloads, scan audit entries, and completion updates.
- Rewards/wallet, support tickets, delivery tracking, recurring plans, invoices, and notifications now have service APIs and tests.

## Production hardening still required

- Replace in-memory maps with Postgres/Firestore tables and migrations.
- Add authentication/authorization middleware for customers, staff, and admins.
- Add idempotency keys for order, payment, webhook, invoice, and WhatsApp operations.
- Connect real WhatsApp Business, Razorpay/Cashfree, notification, invoice/PDF, and analytics providers.
- Add observability: structured logs, metrics, tracing, audit events, and dead-letter queues.
- Deploy as a containerized API with CI/CD, secrets management, environment configs, and staging/prod separation.
