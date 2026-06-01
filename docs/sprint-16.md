# Sprint 16 Build Notes

Sprint 16 focuses on delivery-fee transparency so customers can choose slots with clear costs before checkout.

## Delivered in this sprint

- Delivery fee rules by slot with a free-delivery threshold for larger baskets.
- Order records now store delivery fee separately from subtotal, discounts, and payable amount.
- Cart delivery slot selector shows whether each slot is free or has a fee.
- Cart summary now separates delivery fee and free-delivery unlock amount.
- WhatsApp handoff, order confirmation, and tracking display delivery fee details.

## Backend handoff expected next

1. Replace local delivery fee rules with store-configurable backend delivery pricing.
2. Support distance, pincode, basket weight, and membership/loyalty based delivery fee rules.
3. Lock delivery fee during order creation and payment gateway checkout.
4. Reconcile delivery fees in invoices, monthly statements, and settlement reports.
5. A/B test free-delivery thresholds against weekly basket adoption and profitability.
