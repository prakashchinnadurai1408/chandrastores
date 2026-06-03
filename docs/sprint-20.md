# Sprint 20 Build Notes

## Focus

Invoice and bill request workflow for customers who need retail bills, GST invoices, monthly grocery statements, or khata ledger copies from Chandra Stores.

## Delivered in the Flutter app

- Added an invoice request model with order ID, invoice type, billing name, optional GSTIN, optional email, and created timestamp.
- Added invoice request state per order and surfaced saved invoice request chips on recent order cards.
- Added an invoice request bottom sheet where customers can choose invoice type and provide billing details.
- Added WhatsApp invoice handoff so the store receives structured billing details for manual follow-up.
- Added invoice actions to recent orders alongside tracking, WhatsApp, feedback, support, cancellation, and status controls.

## Backend handoff expected next

1. Persist invoice requests against orders and customer billing profiles.
2. Validate GSTIN and business billing details before invoice generation.
3. Generate downloadable PDF invoices, retail bills, monthly statements, and khata ledger exports.
4. Attach invoice documents to WhatsApp/app notifications and customer account history.
5. Reconcile invoice status with payment capture, refunds, cancellations, and store accounting.
