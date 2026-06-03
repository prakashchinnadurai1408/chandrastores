# Sprint 33 - Delivery route planning and rider dispatch

## Goal

Connect packed home-delivery orders to a route manifest so the backend scaffold can model the handoff from packing counter to delivery rider.

## Delivered

- Added `/delivery/routes/plan` to collect packed home-delivery orders into a rider route.
- Added `/delivery/routes/{routeId}/dispatch` to move every stop in the route to `out_for_delivery` and update order status.
- Added `/delivery/routes` to list current route manifests for admin/store dashboard UAT.
- Linked dispatch to the tracking service so each dispatched order receives an `Out for delivery` timeline event.
- Added automated coverage for no-ready-order validation, route creation, rider assignment, dispatch, order status updates, tracking events, and route listing.

## Backend handoff still pending

1. Persist routes and stop sequence in a database with rider indexes.
2. Add geocoding, distance estimates, and route optimization.
3. Support partial dispatch when a stop fails quality or payment checks.
4. Wire rider mobile app views for route accept, proof-of-delivery, and cash/UPI collection.
5. Emit WhatsApp and push notifications for rider assigned, out for delivery, delayed, and delivered events.
