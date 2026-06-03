# Sprint 17 Build Notes

## Focus

Order cancellation and refund preference capture for customer self-service before the backend workflow is connected.

## Delivered in the Flutter app

- Added an order cancellation model with order ID, cancellation reason, refund mode, and created timestamp.
- Added a cancellation bottom sheet from recent orders so customers can choose why they are cancelling and how they prefer the refund handled.
- Saved cancellation requests locally and moved the order status to `Cancelled` for UAT visibility.
- Added a WhatsApp cancellation handoff containing the order ID, reason, and refund preference for store follow-up.
- Hid cancellation and demo advancement actions once an order is delivered or cancelled, while surfacing the refund preference chip on the order card.

## Backend handoff expected next

1. Persist cancellation requests against the order record and release reserved stock when cancellation is accepted.
2. Enforce cancellation windows by fulfilment state, e.g. allow before packing and require store approval after packing begins.
3. Connect refund routing to payment gateway APIs, UPI refund flows, store credit/khata ledgers, and customer notifications.
4. Notify the store owner/admin dashboard and customer WhatsApp/app channels whenever cancellation status changes.
5. Add analytics for cancellation reasons, refund modes, and prevented fulfilment waste.
