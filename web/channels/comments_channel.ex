defmodule Discuss.CommentsChannel do
    use Discuss.Web, :channel

    alias Discuss.{Topic, Comment}

    def join("comments:" <> topic_id, _params, socket) do 

        topic_id = String.to_integer(topic_id)
        # Repo.preload fetches all comments on that topic, from db
        #  Nested associasion comments: [:user]
        topic = Topic
            |> Repo.get(topic_id)
            |> Repo.preload(comments: [:user])

        # a 'topic' is transferred from one function to another through 'assigns'
        # "Poison" library tries to encode db comment into JSON.
        # => specify in the Comment model that only 'content' field needs to be encoded.
        {:ok, %{comments: topic.comments}, assign(socket, :topic, topic)}
    end

    def handle_in(name, %{"content" => content}, socket) do 
        topic = socket.assigns.topic
        user_id = socket.assigns.user_id

        # insert the comment into db; create a changeset first
        # (create a struct for Comment.changeset function)

        #  'build_assoc' function can only associate with one relation...
        #  so adding a user_id as a workaround
        changeset = topic
        |> build_assoc(:comments, user_id: user_id)
        |> Comment.changeset(%{content: content})
        
        case Repo.insert(changeset) do
            {:ok, comment} ->
                broadcast!(socket, "comments:#{socket.assigns.topic.id}:new", %{comment: comment})
                {:reply, :ok, socket}
            {:error, _reason} ->
                {:reply, {:error, %{errors: changeset}}, socket}
        end
    end
end