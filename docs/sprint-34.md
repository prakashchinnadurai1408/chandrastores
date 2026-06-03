# Sprint 34 - Recurring grocery plan execution

## Goal

Move recurring grocery plans from saved schedules to executable backend jobs that can create real orders and notify customers.

## Delivered

- Added `/recurring-plans/run-due` to process active plans and create orders using the existing pricing and inventory reservation pipeline.
- Added customer filtering so a single household plan can be executed during UAT without running every active plan.
- Updated plan state with `lastOrderId`, `lastRunAt`, `nextRunAt`, and `runCount` after a successful run.
- Queued a customer notification and WhatsApp transactional message when a recurring plan creates an order.
- Added automated coverage for plan execution, order creation, plan state refresh, notification enqueueing, and WhatsApp template output.

## Backend handoff still pending

1. Replace manual run endpoint with a secure scheduler/cron worker.
2. Persist plan execution attempts and failures in a durable ledger.
3. Add customer approval windows before converting high-value recurring baskets into orders.
4. Support substitutions, skipped items, wallet deductions, and payment authorization retries.
5. Send localized WhatsApp and push reminders before and after each recurring order run.
