# Sprint 31 Build Notes

## Focus

Role-based access control for operational backend routes so admin, audit, and staff fulfilment actions are no longer public in the UAT scaffold.

## Delivered in the backend scaffold

- Added `RoleAccessService` with `x-role` based guards for admin, audit, and staff routes.
- Protected `/admin/*` and `/audit/events` so only `admin` or `owner` roles can read or mutate operational data.
- Protected `/staff/*` fulfilment routes so `staff`, `admin`, or `owner` roles can update store operations.
- Returned structured `403 FORBIDDEN` responses with required and actual role metadata.
- Added tests for denied anonymous access and allowed admin access.

## Backend handoff expected next

1. Replace header-based roles with signed JWT/session claims from the Customer API and staff/admin identity provider.
2. Add route-level scopes such as `orders.write`, `alerts.resolve`, `audit.read`, and `staff.fulfilment`.
3. Persist role assignments for owners, cashiers, pickers, riders, support agents, and auditors.
4. Add audit events for authorization failures and privilege changes.
5. Add UI states for forbidden admin/staff actions in the dashboard and staff app.
