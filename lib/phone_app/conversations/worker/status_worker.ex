defmodule PhoneApp.Conversations.Worker.StatusWorker do
  use Oban.Worker
  alias PhoneApp.Conversations.Schema.SmsMessage

  def enqueue(%SmsMessage{} = message) do
    %{"id" => message.id}
    |> new()
    |> Oban.insert()
  end

  alias PhoneApp.Conversations.Query.SmsMessageStore

  # Loads the data form the arguments, qu
  def perform(%Oban.Job{args: %{"id" => message_id}}) do
    message = SmsMessageStore.get_sms_message!(message_id)
    %{body: resp} = PhoneApp.Twilio.get_sms_message!(message)

    case resp["status"] do
      "queued" ->
        {:error, "Message not ready"}

      status ->
        PhoneApp.Conversations.update_sms_message(
          message.message_sid,
          %{status: status}
        )
    end
  end
end
