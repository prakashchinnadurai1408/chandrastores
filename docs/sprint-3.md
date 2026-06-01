# Sprint 3 Build Notes

Sprint 3 focuses on conversion and retention features that make planned grocery baskets feel rewarding before backend promotion services are connected.

## Delivered in this sprint

- Smart offer model with minimum cart value, coupon code, description, and fixed discount.
- Checkout offer cards that show eligibility, remaining amount to unlock, and applied state.
- Cart summary now separates subtotal, offer discount, total savings, and payable amount.
- Order records now preserve original cart total, discount, and final payable amount.
- WhatsApp order handoff and UPI intent use the discounted payable amount.

## Backend handoff expected next

1. Move offer eligibility to the backend so discounts cannot be manipulated on-device.
2. Add customer-specific loyalty point redemption rules and coupon usage limits.
3. Return promotion messages with inventory-aware recommendations.
4. Persist discount breakdowns on orders and invoices for store reconciliation.
5. Add automated tests once Flutter SDK is available in CI.
