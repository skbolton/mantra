defmodule MantraWeb.PageController do
  use MantraWeb, :controller
  alias Mantra.Contents

  def index(conn, _params) do
    json(conn, %{pages: Contents.list_pages()})
  end
end
