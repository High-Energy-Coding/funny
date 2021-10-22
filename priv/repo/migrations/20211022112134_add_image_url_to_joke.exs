defmodule Funny.Repo.Migrations.AddImageUrlToJoke do
  use Ecto.Migration

  def change do
    alter table(:jokes) do
      add :image_url, :string
    end
  end
end
