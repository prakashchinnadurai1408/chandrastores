# Sprint 27 Build Notes

## Focus

Pickup and delivery handoff pass so store staff, riders, and customers can reconcile the right basket without a backend QR service yet.

## Delivered in the Flutter app

- Added deterministic handoff codes for every order, with pickup codes for Store pickup and delivery codes for Home delivery.
- Added a QR-style handoff pass sheet showing the code, fulfilment mode, slot, address, and payment method.
- Added handoff code visibility in order confirmation, tracking, recent-order chips, and WhatsApp order copy.
- Added an Account order action for Pickup pass or Delivery pass depending on fulfilment mode.
- Added widget coverage for the pickup pass display and code generation.

## Backend handoff expected next

1. Replace deterministic demo codes with server-issued unique QR tokens.
2. Add staff-side scan/verify API for pickup counter and delivery rider handoff.
3. Expire handoff codes after pickup/delivery confirmation and regenerate for rescheduled orders.
4. Audit code scans with customer, order, staff member, timestamp, and device metadata.
5. Send pickup-ready notifications that include the generated pass or app deep link.
