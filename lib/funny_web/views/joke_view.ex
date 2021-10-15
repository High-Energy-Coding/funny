defmodule FunnyWeb.JokeView do
  use FunnyWeb, :view

  def show_joke_datetime(dt) do
    if dt.year == DateTime.now!("Etc/UTC").year do
      Calendar.strftime(dt, "%B %d")
    else
      Calendar.strftime(dt, "%y-%m-%d")
    end
  end
end
