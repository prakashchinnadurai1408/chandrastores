# Sprint 21 Build Notes

## Focus

Saved address selection for multi-location grocery delivery across home, family, and office addresses.

## Delivered in the Flutter app

- Added a saved customer address book with Home, Parents, and Office delivery locations.
- Added selected-address state in the app shell and stored the chosen delivery address on each created order.
- Added a checkout delivery-address selector before delivery instructions and substitution preferences.
- Updated WhatsApp order handoff to include the selected address label, address line, and landmark.
- Added an Account address book card with quick address switching for UAT.

## Backend handoff expected next

1. Persist multiple customer addresses with geolocation, serviceability, and delivery fee zones.
2. Validate address edits with OTP/customer confirmation before fulfilment.
3. Attach the chosen address snapshot to each order so later address changes do not alter past invoices or delivery records.
4. Integrate delivery partner/store route planning by selected address and delivery slot.
5. Add address-level delivery instructions, access notes, and WhatsApp confirmation templates.
