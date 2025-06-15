defmodule PhoneApp.ConversationsTest do
  use PhoneApp.DataCase, async: true

  alias PhoneApp.Conversations
  alias PhoneApp.COnversations.Schema.NewMessage

  describe "sens_sms_message/1" do
    test "successful request creates an SMS message" do
      bypass = Bypass.open()

      Process.put(:twilio_base_url, "http://localhost:#{bypass.port}")

      resp = Jason.decode!(File.read!("test/support/fixtures/success.json"))

      Bypass.expect_once(
        bypass,
        "POST",
        "Accounts/mock-account/Messages.json",
        fn conn ->
          conn
          |> Plug.Conn.put_resp_handler("Content-Type", "application/json")
          |> Plug.Conn.resp(201, Jason.encode!(resp))
        end
      )

      assert {:ok, message} = Conversations.sens_sms_message(%NewMessage{})
      assert message.from == resp["from"]
      assert message.to == resp["to"]
      assert message.body == resp["body"]
      assert message.message_sid == resp["message_sid"]
      assert message.account_sid == resp["account_sid"]

      assert message.status == resp["status"]
      assert message.direction == :outgoing
    end

    test "a failed request returns an error" do
      bypass = Bypass.open()
      Process.put(:twilio_base_url, "http://localhost:#{bypass.port}")

      Bypass.expect_once(
        bypass,
        "POST",
        "Accounts/mock-account/Messages.json",
        fn conn ->
          Plug.Conn.resp(conn, 500, "")
        end
      )

      assert Conversations.sens_sms_message(%NewMessage{}) == {:error, "Failed to send message"}
    end
  end
end
