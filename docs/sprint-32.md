# Sprint 32 - Staff fulfilment queue and packing handoff

## Goal

Move the backend scaffold beyond single status updates by modelling the staff app queue that pickers and packers need during daily kirana fulfilment.

## Delivered

- Added `/staff/orders/queue` to return open, non-terminal orders with customer, slot, fulfilment mode, payable amount, item count, and assignment state.
- Added `/staff/orders/{orderId}/assign` so a staff member can claim an order as picker or packer while preserving role-guard protection.
- Added `/staff/orders/{orderId}/pack` so picked orders can be marked packed with bag count, packed-by metadata, and pickup/home-delivery status transitions.
- Stored assignment metadata in the in-memory staff fulfilment service for UAT and API contract testing.
- Added automated backend coverage for denied anonymous staff queue access, queue visibility, assignment, packing, and assignment status replay.

## Backend handoff still pending

1. Persist assignment state in a database with staff workload indexes.
2. Add per-item barcode/QR scan verification for substitutions and missing stock.
3. Add route batching and rider handoff for home-delivery orders.
4. Connect staff app screens to these queue, assign, and pack endpoints.
5. Emit real-time notifications when orders move from received to assigned, packed, ready, and delivered.
