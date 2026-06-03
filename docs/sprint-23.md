# Sprint 23 Build Notes

## Focus

Payment proof capture and reconciliation for UPI, card, QR, wallet, and cash payments before production gateway webhooks are connected.

## Delivered in the Flutter app

- Added a payment proof model with order ID, method, reference number, amount, and created timestamp.
- Added per-order payment proof state and visible paid/reference chips on recent order cards.
- Added a payment proof bottom sheet for customers to capture method, reference number, and amount paid.
- Added WhatsApp payment-proof handoff so the store can manually reconcile payment references during UAT.
- Added payment proof actions beside repeat, feedback, support, invoice, cancellation, and tracking controls.

## Backend handoff expected next

1. Persist payment proofs against orders and customer payment attempts.
2. Reconcile proof references with Razorpay/Cashfree/UPI gateway webhooks and bank settlement files.
3. Add duplicate-reference, amount-mismatch, and expired-payment validation.
4. Notify customers when payment is verified, rejected, refunded, or needs a new attempt.
5. Feed verified payment status into invoices, order fulfilment, cancellations, and store accounting.
