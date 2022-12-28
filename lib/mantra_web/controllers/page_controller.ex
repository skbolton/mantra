defmodule MantraWeb.PageController do
  use MantraWeb, :controller
  alias Mantra.Contents
  alias Mantra.Contents.PageBlocksQuery

  def index(conn, _params) do
    json(conn, %{pages: Contents.list_pages()})
  end

  def blocks(conn, params) do
    case PageBlocksQuery.changeset(%PageBlocksQuery{}, params) do
      %Ecto.Changeset{valid?: true} = changeset ->
        json(conn, Contents.page_blocks(Ecto.Changeset.apply_changes(changeset)))

      invalid_changeset ->
        conn
        |> put_status(400)
        |> json(%{errors: invalid_changeset.errors})
    end
  end
end
