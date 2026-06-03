# Sprint 25 Build Notes

## Focus

Delivery reschedule requests for customers who need to change the slot after placing an order but before delivery is complete.

## Delivered in the Flutter app

- Added a delivery change request model with order ID, requested slot, reason, optional note, and created timestamp.
- Added per-order reschedule request state and visible reschedule chips on recent order cards.
- Added a reschedule bottom sheet where customers can choose a new slot, reason, and note for the store.
- Added WhatsApp reschedule handoff so the store can manually confirm slot availability during UAT.
- Added reschedule/edit-slot actions for non-terminal orders beside payment proof, invoice, support, cancellation, and tracking controls.

## Backend handoff expected next

1. Persist reschedule requests against orders and fulfilment tasks.
2. Validate requested slots against store capacity, delivery routes, and cutoff times.
3. Notify customers when a reschedule request is accepted, rejected, or needs alternatives.
4. Recalculate delivery fees and route assignments after confirmed slot changes.
5. Add audit logs for customer-initiated and store-initiated delivery changes.
