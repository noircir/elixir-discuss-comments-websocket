defmodule Discuss.Comment do
    use Discuss.Web, :model

    # Poison.Encoder library turns models to JSON data.
    # Whenever someone tries to turn a comment into JSON, 
    # only allow the 'content' property to pass through.

    @derive {Poison.Encoder, only: [:content, :user]}

    schema "comments" do
        field :content, :string
        belongs_to :user, Discuss.User
        belongs_to :topic, Discuss.Topic

        timestamps()
    end

    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:content])
        |> validate_required([:content])
    end
end