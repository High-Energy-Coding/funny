defmodule Funny.Accounts.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :funny,
    error_handler: Funny.Accounts.ErrorHandler,
    module: Funny.Accounts.Guardian

  # If there is a session token, restrict it to an access token and validate it
  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}

  # If there is an authorization header, restrict it to an access token and validate it
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}

  plug Guardian.Plug.VerifyCookie

  # Load the user if either of the verifications worked
  plug Guardian.Plug.LoadResource, allow_blank: true
end
