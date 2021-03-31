defmodule Funny.Repo.Migrations.AddTitleToJoke do
  use Ecto.Migration

  def change do
    alter table(:jokes) do
      add :title, :string
    end
  end
end
