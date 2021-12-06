defmodule Funny.Email do
  import Funny.AWS, only: [send_email: 3]

  def send(email) do
    destination = %{
      to: [email]
    }

    message = %{
      body: %{
        text: %{data: "hey you. welcome to funny app. we're glad to have you. "}
      },
      subject: %{data: "Welcome to Funny App"}
    }

    send_email(destination, message, "hello@highenergycoding.com")
  end
end
