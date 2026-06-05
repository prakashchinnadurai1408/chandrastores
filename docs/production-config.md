# Production Configuration

Smart Kirana now exposes admin-editable configuration through the app Admin tab and backend routes:

- `GET /admin/config`
- `PUT /admin/config`
- `GET /admin/config/history`
- `POST /admin/catalogue/products`
- `GET /admin/state/export`
- `POST /admin/state/import`

Use `x-role: admin` or `x-role: owner` for admin routes.

## Provider Parameters

Configure these values before launch:

- WhatsApp Business provider, phone number ID, template namespace, and approved templates.
- Razorpay key ID or Cashfree client ID.
- Payment webhook secret confirmation.
- Store UPI VPA.
- Settlement schedule, default `0 22 * * *`.

Secrets should be stored in the deployment secret manager. Admin responses redact key-like values and only expose configured flags for webhook, database, and JWT secrets.

## Storage And Auth

The backend now supports production state export/import snapshots and readiness flags for persistent storage. A production deployment should connect these maps to Postgres, Firestore, or another managed store before live orders.

JWT-shaped tokens now include issuer, audience, subject, role, issued-at, and expiry claims. Production readiness requires a configured JWT signing secret.

## App Distribution

Android package ID:

```text
com.chandrastores.smartkirana
```

iOS bundle ID:

```text
in.chandrastores.smartkirana
```

Release signing environment variables:

```text
SMART_KIRANA_KEYSTORE
SMART_KIRANA_KEYSTORE_PASSWORD
SMART_KIRANA_KEY_ALIAS
SMART_KIRANA_KEY_PASSWORD
```

The QR landing page is available at `web/app.html` and should be hosted at:

```text
https://chandrastores.in/app
```

Append a channel query parameter for QR source tracking, such as `?channel=counter`, `?channel=bag`, or `?channel=invoice`.
