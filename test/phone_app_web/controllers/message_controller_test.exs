defmodule PhoneAppWeb.MessageControllerTest do
  # sets dependencies for a connection case and data case
  use PhoneAppWeb.ConnCase, async: true

  alias PhoneApp.Conversations
  alias Test.Factory.SmsMessageFactory

  describe "Get /messages" do
    test "empty messages redirects to new messages", %{conn: conn} do
      conn = get(conn, ~p"/messages")
      assert redirected_to(conn, 302) == "/messages/new"
    end

    test "redirects to latest messages", %{conn: conn} do
      _m1 = SmsMessageFactory.create(%{to: "111-222-3333", body: "Test 1"})
      m2 = SmsMessageFactory.create(%{to: "211-222-3333", body: "Test 2"})

      conn = get(conn, ~p"/messages")
      assert redirected_to(conn, 302) == "/messages/#{m2.contact_id}"
    end
  end

  describe "GET /messages/new" do
    test "a message form is rendered", %{conn: conn} do
      conn = get(conn, ~p"/messages/new")

      # uses regex pattern matching
      assert html = html_response(conn, 200)
      assert html =~ ~S(<form action="/messages/new" method="post")
      assert html =~ "Send a message..."
      assert html =~ "To (Phone Number)"
    end
  end

  alias PhoneApp.Conversations.Schema.SmsMessage

  describe "POST /messages/new" do
    test "invalid params is rejected", %{conn: conn} do
      conn = post(conn, ~p"/messages/new", %{})

      assert html_response(conn, 200) =~
               Plug.HTML.html_escape("can't be blank")
    end

    test "valid params creates a message", %{conn: conn} do
      bypass = Bypass.open()
      Process.put(:twilio_base_url, "http://localhost:#{bypass.port}")

      Bypass.expect_once(
        bypass,
        "POST",
        "/Accounts/mock-account/Messages.json",
        fn conn ->
          conn
          |> put_resp_header("Content-Type", "application/json")
          |> resp(201, File.read!("test/support/fixtures/success.json"))
        end
      )

      params = %{message: %{to: "+1111-222-3333", body: "Test"}}
      conn = post(conn, ~p"/messages/new", params)
      assert redirected_to(conn, 302) == "/messages"
      assert PhoneApp.Repo.aggregate(SmsMessage, :count) == 1
    end
  end

  use Oban.Testing, repo: Repo

  alias PhoneApp.Conversations.Worker.StatusWorker

  describe "create_sms_message/1" do
    test "a valid SMS message is created" do
      params = Test.Factory.SmsMessageFactory.params()
      assert {:ok, msg} = Conversations.create_sms_message(params)
      assert_enqueued(worker: StatusWorker, args: %{"id" => msg.id})
    end

    test "incoming SMS message doesn't enqueue a worker" do
      params = Test.Factory.SmsMessageFactory.params(%{direction: :incoming})
      assert {:ok, _msg} = Conversations.create_sms_message(params)
      refute_enqueued(worker: StatusWorker)
    end

    test "an invalid message returns an error" do
      params = Test.Factory.SmsMessageFactory.params(%{direction: :incoming})
      assert {:error, _} = Conversations.create_sms_message(params)
      refute_enqueued(worker: StatusWorker)
    end
  end
end
