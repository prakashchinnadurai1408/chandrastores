# Sprint 9 Build Notes

Sprint 9 focuses on reducing delivery ambiguity and substitution friction during checkout.

## Delivered in this sprint

- Orders now persist delivery instruction and substitution preference alongside slot and payment details.
- Cart checkout includes a delivery-instruction selector for handover, doorstep, call-on-arrival, and security delivery flows.
- Cart checkout includes a substitution-preference selector for call, WhatsApp-photo approval, same-brand-only, and no-substitution flows.
- WhatsApp order handoff now includes delivery and substitution preferences for clearer store fulfilment.
- Order confirmation and tracking surfaces now display the selected delivery and substitution instructions.

## Backend handoff expected next

1. Persist delivery instructions and substitution preferences on order records.
2. Expose store-configurable instruction and substitution options from the backend.
3. Route substitution approvals through WhatsApp templates with customer accept/reject actions.
4. Show delivery instructions in the packing and delivery executive apps.
5. Track substitution preference compliance in post-delivery feedback.
