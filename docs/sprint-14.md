# Sprint 14 Build Notes

Sprint 14 focuses on checkout stock reservation so customers do not order more units than the store can fulfil.

## Delivered in this sprint

- Orders now store a stock reservation expiry timestamp.
- Add-to-cart and quantity increment actions block quantities above available stock and show customer-friendly availability messages.
- Cart line items display available stock and show when the cart has reached the maximum quantity for that SKU.
- Checkout displays a stock reservation notice explaining that stock is reserved for 15 minutes.
- Order confirmation, WhatsApp handoff, and tracking display reservation expiry details.

## Backend handoff expected next

1. Replace local stock checks with backend stock reservation APIs.
2. Expire unpaid/unconfirmed reservations automatically after the reservation window.
3. Deduct inventory only after payment/order confirmation and release on cancellation.
4. Handle concurrent reservations across app, walk-in billing, and WhatsApp/manual orders.
5. Show reservation expiry timers in customer and admin order views.
