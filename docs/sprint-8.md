# Sprint 8 Build Notes

Sprint 8 focuses on accessibility and assisted ordering so senior customers and multilingual households can place planned grocery orders with less friction.

## Delivered in this sprint

- Customer preference model for preferred language, senior-friendly easy mode, and voice-ordering support.
- Account screen now includes an Accessibility & language card with language selection for English, Tamil, Hindi, and Kannada.
- Easy mode and voice-ordering preferences can be toggled locally for UAT.
- Voice-ordering action opens WhatsApp with a structured request asking the store to help build the basket in the selected language.
- Existing static senior-friendly copy has been replaced with an interactive preference flow.

## Backend handoff expected next

1. Persist customer preferences by mobile number after OTP login.
2. Localise catalogue, cart, offers, and notification templates using the preferred language.
3. Connect voice-order requests to WhatsApp Business support queues or call-back workflows.
4. Apply easy-mode settings globally for larger controls and simplified checkout paths.
5. Measure assisted-order conversions separately from self-serve cart orders.
