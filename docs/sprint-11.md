# Sprint 11 Build Notes

Sprint 11 focuses on customer acquisition and app distribution so the store can convert family members and walk-in shoppers into app users.

## Delivered in this sprint

- Store invite model with app landing URL, referral code, and reward text.
- Account screen now includes an invite card with app link, referral code, and reward copy.
- WhatsApp share handoff creates a prefilled invite message that customers can forward to family or neighbours.
- Invite card reinforces QR/app-link rollout from the launch plan without requiring backend referral APIs yet.
- Referral code copy prepares UAT for future install attribution and first-order reward campaigns.

## Backend handoff expected next

1. Replace the placeholder landing URL with the production app deep link or store landing page.
2. Generate customer-specific referral codes after OTP login.
3. Track invite shares, QR scans, installs, OTP completion, and first order attribution.
4. Enforce referral reward eligibility server-side after successful first order.
5. Add admin reporting for referral campaigns and customer acquisition cost.
