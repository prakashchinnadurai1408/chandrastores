# Sprint 13 Build Notes

Sprint 13 focuses on customer support and issue escalation after an order is placed.

## Delivered in this sprint

- Support ticket model with ticket ID, order ID, issue type, priority, description, status, and timestamp.
- Account order cards now include Support / View ticket actions alongside tracking, WhatsApp, and feedback.
- Support ticket bottom sheet captures issue type, priority, and customer description.
- Support tickets can be saved locally for UAT and also shared to the store over WhatsApp.
- Recent order cards show a support-ticket chip once an issue has been raised.

## Backend handoff expected next

1. Persist support tickets against customer and order records.
2. Route urgent/refund-needed tickets to owner/admin queues with SLA timers.
3. Link ticket status updates to WhatsApp templates and push notifications.
4. Attach photos, invoices, and replacement/refund decisions to each ticket.
5. Report recurring support issues by SKU, picker, delivery slot, and delivery executive.
