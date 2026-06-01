# Sprint 2 Build Notes

Sprint 2 turns the first customer-app shell into a more production-shaped MVP flow while still keeping integrations mockable inside the app.

## Delivered in this sprint

- Order confirmation flow after checkout with a generated Smart Kirana order ID.
- Recent order history in the Account tab with status, amount, delivery slot, and WhatsApp resend action.
- Customer address data shown in the Account tab and included in the WhatsApp order handoff.
- Payment handoff stub for UPI-compatible apps using the configured store UPI ID.
- Checkout confirmation sheet that separates order creation, WhatsApp sharing, and digital payment action.

## Backend handoff expected next

1. Replace in-memory product, cart, and order state with API calls.
2. Persist customer addresses and preferred delivery slots.
3. Replace the demo OTP with WhatsApp Business Platform OTP verification.
4. Replace the UPI stub with Razorpay or Cashfree order creation and webhook confirmation.
5. Emit order-created and payment-success events for packing, delivery assignment, and customer notifications.
