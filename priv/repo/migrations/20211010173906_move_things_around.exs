defmodule Funny.Repo.Migrations.MoveThingsAround do
  use Ecto.Migration

  def change do
    drop_if_exists index("persons", :persons_username_index)

    alter table("persons") do
      remove :username
    end
  end
end
