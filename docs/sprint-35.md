# Sprint 35 - Admin payment reconciliation phase

## Goal

Add a store-owner reconciliation view that compares orders, payment captures, refunds, and invoice generation before daily closing.

## Delivered

- Added `/admin/reconciliation` behind the existing admin role guard.
- Summarised order count, payment attempts, invoice count, captured amount, refund amount, net collected amount, pending count, and unmatched payment count.
- Added per-order reconciliation rows with payable, paid, balance, payment status, invoice status, and invoice IDs.
- Treated captured and refund-initiated attempts as collected before subtracting refund ledger totals from net collection.
- Added automated backend coverage for protected access, captured payment, refund, invoice generation, settled row status, and net collected math.

## Backend handoff still pending

1. Persist reconciliation snapshots for each store closing day.
2. Integrate payment gateway settlement files and UTR/reference matching.
3. Export CSV/PDF reports for owner and accountant review.
4. Add cash-on-delivery and wallet ledger reconciliation.
5. Surface mismatch alerts when captured payments, invoices, refunds, or order totals do not agree.
