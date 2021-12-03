defmodule Funny.Email do
  alias ExAws.SES

  def send(email) do
    IO.inspect("pretend i sent something to #{email}")

    destination = %{
      to: [email]
    }

    message = %{
      body: %{
        text: %{data: "hey you. welcome to funny app. we're glad to have you. "}
      },
      subject: %{data: "Welcome to Funny App"}
    }

    SES.send_email(destination, message, _source = "hello@highenergycoding.com")
    |> ExAws.request()
    |> IO.inspect()
  end
end
