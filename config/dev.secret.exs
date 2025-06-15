import Config

# Secret config for th twilio API
config :phone_app, :twilio,
  key_sid: "mock-key-sid",
  key_secret: "mock-key",
  account_sid: "mock-account",
  number: "+19998887777",
  base_url: "http://localhost:4005/2010-04-01"
