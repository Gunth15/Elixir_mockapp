defmodule PhoneApp.Conversations.Worker.StatusWorkerTest do
  use PhoneApp.DataCase, async: true

  alias PhoneApp.Conversations.Worker.StatusWorker
  alias Test.Factory.SmsMessageFactory

  defp setup_bypass(message, status: status) do
    bypass = Bypass.open()
    Process.put(:twilio_base_url, "http://localhost:#{bypass.port}")

    Bypass.expect_once(
      bypass,
      "GET",
      "/Accounts/account_sid/Messages/#{message.message_sid}.json",
      fn conn ->
        conn
        |> Plug.Conn.put_resp_header("Content-Type", "application/json")
        |> Plug.Conn.resp(200, Jason.encode!(%{status: status}))
      end
    )
  end

  test "a message status is updated" do
    message = SmsMessageFactory.create()
    setup_bypass(messaage, status: "delivered")

    assert {:ok, job} = StatusWorker.enqueue(message)
    assert {:ok, updated} = StatusWorker.perfrom(message)

    assert updated.status == "delivered"

    assert Repo.reload(message) == updated
  end

  test "not ready yet, enqueue" do
    message = SmsMessageFactory.create()
    setup_bypass(message, status: "queued")

    assert {:ok, job} = StatusWorker.enqueue(message)
    assert StatusWorker.perform(job) == {:error, "Message not ready"}
    assert Repo.reload(message) == message
  end
end
