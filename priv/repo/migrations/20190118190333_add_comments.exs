defmodule Discuss.Repo.Migrations.AddComments do
  use Ecto.Migration

  def change do

    # a comment has 1 user and 1 topic
    # a user has many comments and many topics
    # a topic has many comments and one user (creator of the topic)

    create table(:comments) do
      add :content, :string
      add :user_id, references(:users)
      add :topic_id, references(:topics)

      timestamps()
    end
  end
end
