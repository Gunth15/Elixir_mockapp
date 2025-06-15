defmodule PhoneApp.Twilio.Api do
  defp twilio_config do
    # Fetches config 
    Application.fetch_env!(:phone_app, :twilio)
  end

  # Take keywords and checks if they exist, if not use defaults in the config
  # The creates client
  def req_client(opts \\ []) do
    config = twilio_config()
    default_base_url = Keyword.fetch!(config, :base_url)
    base_url = Keyword.get(opts, :base_url, default_base_url)
    key_sid = Keyword.fetch!(config, :key_sid)

    key_secret = Keyword.fetch!(config, :key_secret)
    # testsing url
    force_base_url = Process.get(:twilio_base_url)

    Req.new(
      base_url: force_base_url || base_url,
      auth: {:basic, "#{key_sid}:#{key_secret}"}
    )
  end

  # The function gets  the default client whilst still excepting alternatives, CRAZY
  def get_sms_message!(params, client \\ req_client()) do
    %{account_sid: account, message_sid: id} = params

    Req.get!(client, url: "/Accounts/#{account}/Messages/#{id}.json")
  end

  def send_sms_message!(params, client \\ req_client()) do
    account_sid = Keyword.fetch!(twilio_config(), :account_sid)
    %{from: from, to: to, body: body} = params
    body = %{From: from, To: to, Body: body}

    url = "/Accounts/#{account_sid}/Messages.json"
    Req.post!(client, url: url, form: body)
  end
end
