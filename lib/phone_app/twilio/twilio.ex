defmodule PhoneApp.Twilio do
  defdelegate send_sms_message!(msg), to: PhoneApp.Twilio.Api
  defdelegate get_sms_message!(msg), to: PhoneApp.Twilio.Api
end
