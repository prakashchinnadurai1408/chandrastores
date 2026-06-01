# Sprint 5 Build Notes

Sprint 5 focuses on post-checkout confidence: customers should know what is happening after an order is placed and how substitutions will be handled.

## Delivered in this sprint

- Order status progression model covering Received, Packing, Ready for dispatch, Out for delivery, and Delivered.
- Order records can now copy themselves into the next fulfillment state for local demo and UAT flows.
- Account order cards now include Track, WhatsApp, and Advance demo actions.
- Order tracking bottom sheet shows a visual delivery timeline for each order.
- Tracking view includes substitution-approval guidance so unavailable items are handled through WhatsApp confirmation before dispatch.

## Backend handoff expected next

1. Replace the local Advance demo action with store/admin order status updates.
2. Send order status changes to customers through push notifications and WhatsApp templates.
3. Persist fulfillment events with timestamps and delivery executive assignment.
4. Add substitution recommendation, approval, and rejection APIs.
5. Connect delivery proof-of-delivery OTP and final invoice generation.
