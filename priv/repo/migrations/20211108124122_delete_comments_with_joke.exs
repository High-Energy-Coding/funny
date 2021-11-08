defmodule Funny.Repo.Migrations.DeleteCommentsWithJoke do
  use Ecto.Migration

  def change do
    drop_if_exists(constraint("comments", [:joke_id], name: :comments_joke_id_fkey))

    alter table("comments") do
      modify(:joke_id, references(:jokes, on_delete: :delete_all, type: :binary_id))
    end
  end
end
