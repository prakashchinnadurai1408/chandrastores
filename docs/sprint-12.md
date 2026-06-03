# Sprint 12 Build Notes

Sprint 12 focuses on monthly grocery visibility so families can understand spend patterns and share statements over WhatsApp.

## Delivered in this sprint

- Grocery statement model that captures statement month, order count, total spend, digital-payment count, and top category spend.
- Account screen now includes a monthly grocery statement card below the wallet summary.
- Statement card shows order count, total spend, digital-payment share, and top spending categories.
- Empty-state statement copy explains that category insights appear after app orders.
- WhatsApp statement sharing sends a compact monthly summary for family budgeting or store reconciliation.

## Backend handoff expected next

1. Generate monthly statements from backend order history instead of local in-memory orders.
2. Add invoice/PDF downloads and secure customer statement links.
3. Support category mappings from the production catalogue taxonomy.
4. Include refunds, cancelled orders, loyalty redemptions, and store-credit settlement entries.
5. Schedule automated monthly WhatsApp statement delivery for opted-in customers.
