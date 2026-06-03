# Sprint 22 Build Notes

## Focus

Repeat-order workflow for customers who frequently buy the same weekly, biweekly, or monthly grocery baskets.

## Delivered in the Flutter app

- Added repeat-order logic that rebuilds cart lines from a previous order while respecting current stock availability.
- Restored delivery slot, selected address, delivery instruction, and substitution preference from the repeated order.
- Added a Repeat action to each recent order card alongside tracking, WhatsApp sharing, feedback, support, invoice, and cancellation controls.
- Moved customers directly to the cart after repeating an order so they can review quantities, offers, rewards, approvals, and payment options.
- Added snackbar feedback for repeated orders and no-stock repeat attempts.

## Backend handoff expected next

1. Store repeat-order templates and item substitutions per customer profile.
2. Reprice repeated baskets against live catalogue, offers, taxes, delivery fees, and inventory.
3. Suggest smart replacements for skipped unavailable lines before checkout.
4. Track repeat-order conversion and churn signals for frequently purchased staples.
5. Add one-tap reorder notifications from WhatsApp/app reminders for weekly and monthly baskets.
