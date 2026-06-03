# Sprint 19 Build Notes

## Focus

Loyalty reward redemption for repeat Smart Kirana customers before production coupon and wallet services are connected.

## Delivered in the Flutter app

- Added reward voucher models with code, title, description, point cost, discount value, and validity date.
- Added sample loyalty vouchers for cashback, household-approved family baskets, and monthly stock-up orders.
- Added reward point accounting from base wallet points plus app-order earnings minus locally redeemed voucher points.
- Added an Account reward center that shows available points, voucher eligibility, redeemed vouchers, and WhatsApp share actions.
- Added local redemption handling with insufficient-points and already-redeemed guardrails for UAT.

## Backend handoff expected next

1. Persist reward balances, voucher catalogs, expiry, redemption status, and campaign eligibility in the customer backend.
2. Connect redeemed voucher codes to checkout pricing, refund reversals, and order invoices.
3. Add fraud controls for one-time redemption, device/account limits, and cancelled-order point reversals.
4. Trigger WhatsApp/app notifications for expiring rewards and post-order point credits.
5. Expose reward analytics for repeat purchase rate, redemption conversion, and campaign ROI.
