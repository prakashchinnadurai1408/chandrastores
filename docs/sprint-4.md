# Sprint 4 Build Notes

Sprint 4 focuses on retention by turning one-time grocery planning into recurring household plans with reminder-ready state.

## Delivered in this sprint

- Recurring grocery plan model that stores plan ID, frequency, next delivery date, budget, products, and WhatsApp reminder preference.
- Planner screen now separates active recurring plans from suggested baskets.
- Suggested weekly, biweekly, and monthly baskets can be scheduled for future deliveries or added to the cart immediately.
- Active recurring plans can be added back to the cart from both Planner and Account screens.
- Account screen now includes active grocery plans alongside recent orders.

## Backend handoff expected next

1. Persist recurring plans per customer and device.
2. Drive next delivery dates from store delivery-slot rules rather than simple local date estimates.
3. Send reminder events through WhatsApp Business templates before the planned delivery date.
4. Add pause, skip-next-delivery, edit quantities, and cancel plan APIs.
5. Reconcile recurring-plan orders with inventory availability and substitution approval.
