# Sprint 18 Build Notes

## Focus

Household approval workflow for families that want a spouse, parent, or khata reviewer to approve larger Smart Kirana baskets before checkout.

## Delivered in the Flutter app

- Added household member and approval request models with approver role, mobile number, monthly comfort limit, request note, cart total, timestamp, and pending status.
- Added a family approval card in the cart so customers can request review before placing weekly or monthly grocery orders.
- Added an approval request bottom sheet that lets customers choose the approver and customize the WhatsApp approval note.
- Saved approval requests locally and surfaced the recent requests in the Account page for UAT visibility.
- Added WhatsApp handoff for approval requests using the selected household member mobile number.

## Backend handoff expected next

1. Persist household members, approval limits, consent, and notification preferences against the customer account.
2. Store approval requests with cart snapshots so the approver can see items, substitutions, delivery slot, and payable amount.
3. Add approval status transitions such as pending, approved, rejected, expired, and checkout-linked.
4. Connect WhatsApp Business templates and deep links so approvers can approve directly from WhatsApp or the app.
5. Add audit logs for khata/store-credit approvals and monthly family budget reporting.
