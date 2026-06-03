# Sprint 6 Build Notes

Sprint 6 focuses on customer retention and trust by giving shoppers visibility into loyalty, monthly grocery spend, and store credit.

## Delivered in this sprint

- Customer wallet model with base loyalty points, store credit limit, used credit, and available credit calculation.
- Account screen now includes a Grocery wallet card with monthly app spend, available loyalty points, store credit balance, and digital-payment order count.
- Loyalty points are estimated from completed app order value so UAT users can see how repeat ordering will be rewarded.
- Wallet messaging guides customers to redeem loyalty points with the LOYAL50 checkout offer.
- Empty-state wallet copy explains how first app orders unlock loyalty and monthly spend insights.

## Backend handoff expected next

1. Replace local wallet constants with customer wallet API responses.
2. Reconcile loyalty earn/burn entries with invoices and returns.
3. Connect khata/store-credit balances to owner-approved account limits.
4. Add monthly statement downloads and WhatsApp statement sharing.
5. Enforce loyalty redemption server-side during payment/order creation.
