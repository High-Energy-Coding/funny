defmodule Funny.Notifications do
  alias Funny.Catalog.Joke

  def notify_subs(joke_id, except_person_id) do
    %{person: %{name: first_name}} = Joke.get_by(%{with_person: true, id: joke_id})

    body =
      %{name: first_name, link: "localhost:4000/jokes/#{joke_id}"}
      |> Jason.encode!()

    Joke.list(%{subs_for_joke: {joke_id, except_person_id}})
    |> Enum.each(fn subscription ->
      sub = Map.take(subscription, [:endpoint, :keys])

      WebPushEncryption.send_web_push(body, sub, _not_needed_gcm_api_key = nil)
    end)
  end
end
