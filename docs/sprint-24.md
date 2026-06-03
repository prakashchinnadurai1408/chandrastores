# Sprint 24 Build Notes

## Focus

Monthly grocery budget guardrails so customers can plan weekly, biweekly, and monthly baskets without overspending.

## Delivered in the Flutter app

- Added a default monthly grocery budget limit for UAT.
- Added monthly spend calculation from local order history.
- Added a cart budget guard card showing current spend, cart projection, remaining budget, and progress percentage.
- Added over-budget messaging that nudges customers to move non-urgent items to later baskets.
- Added documentation for backend budget and spend-alert handoff.

## Backend handoff expected next

1. Persist customer and household budget limits by month, category, and family member.
2. Recalculate budgets against paid, cancelled, refunded, and khata orders.
3. Add budget alerts via WhatsApp, push notifications, and in-app banners.
4. Connect planner recommendations to move optional items into future weekly or monthly baskets.
5. Expose budget analytics for customer retention, affordability, and campaign targeting.
