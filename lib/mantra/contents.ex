defmodule Mantra.Contents do
  alias Mantra.Contents.{Block, Page, PageBlocksQuery}
  defp contents_repo(), do: Application.get_env(:mantra, Mantra.Contents.ContentRepo)

  @doc """
  Returns a list of pages
  """
  def list_pages() do
    contents_repo().list_pages()
  end

  @spec page_blocks(PageBlocksQuery.t()) :: [Block.t()]
  def page_blocks(params) do
    contents_repo().page_blocks(params)
  end

  @doc """
  Creates a new Page.

  Page will fail to create if the title is not unique.
  """
  def create_page(params) do
    Page.create_changeset(%Page{}, params)
    |> contents_repo().create_page()
  end

  @doc """
  Add's block to a page.
  """
  def add_block_to_page(page_id, block_params) do
    case contents_repo().get_page_by(:id, page_id) do
      %Page{} = page ->
        block_changeset =
          Block.create_changeset(
            %Block{},
            Map.merge(block_params, %{
              ancestors: [page.id],
              positions: [block_params[:position] | [page.id]]
            })
          )

        contents_repo().add_block_to_page(page, block_changeset)

      nil ->
        {:error, :page_not_found}
    end
  end

  def add_block_to_block(parent_block_id, block_params) do
    case contents_repo().get_block_by(:id, parent_block_id) do
      %Block{} = parent_block ->
        block_changeset =
          Block.create_changeset(
            %Block{},
            Map.merge(block_params, %{
              ancestors: [parent_block.id | parent_block.ancestors],
              positions: [block_params[:position] | parent_block.positions]
            })
          )

        contents_repo().add_block_to_block(parent_block, block_changeset)

      nil ->
        {:error, :page_not_found}
    end
  end
end
