defmodule FunnyWeb.JokeView do
  use FunnyWeb, :view
  alias FunnyWeb.JokeView

  def render("index.json", %{jokes: jokes}) do
    %{data: render_many(jokes, JokeView, "joke.json")}
  end

  def render("show.json", %{joke: joke}) do
    %{data: render_one(joke, JokeView, "joke.json")}
  end

  def render("joke.json", %{joke: joke}) do
    %{id: joke.id,
      content: joke.content}
  end
end
