# Sprint 26 Build Notes

## Focus

Store pickup and home delivery fulfilment mode selection for customers who want to avoid delivery fees or collect baskets directly.

## Delivered in the Flutter app

- Added fulfilment mode state for Home delivery and Store pickup.
- Added checkout fulfilment mode chips before delivery slot selection.
- Updated delivery fee calculation so Store pickup is free regardless of basket size.
- Stored fulfilment mode on each order and restored it when repeating a previous order.
- Added WhatsApp order handoff copy that includes fulfilment mode for store operations.

## Backend handoff expected next

1. Persist fulfilment mode on orders and expose it to store/admin fulfilment queues.
2. Validate pickup slot capacity and pickup-ready status separately from home delivery routes.
3. Recalculate taxes, fees, packaging, and route assignments by fulfilment mode.
4. Send pickup-ready WhatsApp/app notifications with store pickup instructions and QR/order code.
5. Track pickup versus home-delivery conversion, wait times, and delivery-cost savings.
