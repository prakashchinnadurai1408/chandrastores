# Sprint 7 Build Notes

Sprint 7 focuses on inventory confidence before checkout so customers understand availability and substitutions while building a basket.

## Delivered in this sprint

- Product inventory metadata now includes stock quantity and reorder level in addition to availability.
- Catalogue cards show in-stock, low-stock, and out-of-stock labels before customers add items.
- Catalogue summary highlights how many essentials are low-stock or unavailable.
- Out-of-stock add attempts now suggest in-category substitutes where available.
- Product cards surface a substitute-available chip and use a Swap call-to-action for unavailable items.

## Backend handoff expected next

1. Replace local stock counts with inventory API responses and cache invalidation.
2. Reserve stock during checkout to prevent over-selling high-demand staples.
3. Connect substitution suggestions to owner-approved equivalent SKUs and price rules.
4. Trigger low-stock alerts for the admin portal when quantities reach reorder levels.
5. Track out-of-stock events to improve purchase planning and customer messaging.
