defmodule Infra.CouchDB.ContentRepo do
  @behaviour Mantra.Contents.ContentRepo
  alias Ecto.Changeset
  alias Infra.CouchDB
  alias Infra.CouchDB.Client
  alias Infra.CouchDB.Document
  alias Mantra.Contents.{Block, Page}

  @impl Mantra.Contents.ContentRepo
  def get_page_by(:id, page_id) do
    with {:ok, doc} <- Client.get("/blocks/#{page_id}") do
      Document.from_doc(Page, doc)
    end
  end

  @impl Mantra.Contents.ContentRepo
  def create_page(page_changeset) do
    with {:ok, page} <- Changeset.apply_action(page_changeset, :insert) do
      page_id = Slug.slugify(page.title, lowercase: false, separator: "__")

      case Client.put("/blocks/#{page_id}", Document.to_doc(page)) do
        {:ok, doc} ->
          {:ok, Document.merge_identifiers(page, doc)}

        {:error, %CouchDB.DocumentConflict{}} ->
          {:error, Changeset.add_error(page_changeset, :title, "is already taken")}
      end
    end
  end

  @impl Mantra.Contents.ContentRepo
  def get_block_by(:id, block_id) do
    case Client.get("/blocks/#{block_id}") do
      {:error, %CouchDB.NotFound{}} ->
        nil

      {:ok, doc} ->
        Document.from_doc(Block, doc)
    end
  end

  @impl Mantra.Contents.ContentRepo
  def add_block_to_page(page, block_changeset) do
    with {:ok, block} <- Changeset.apply_action(block_changeset, :insert) do
      block_id = "#{page.id}-#{Nanoid.generate()}"

      case Client.put("/blocks/#{block_id}", Document.to_doc(block)) do
        {:ok, doc} ->
          {:ok, Document.merge_identifiers(block, doc)}

        # TODO: Error handling
        error ->
          IO.inspect(error)
          {:error, Changeset.add_error(block_changeset, :id, "cannot be created")}
      end
    end
  end

  @impl Mantra.Contents.ContentRepo
  def add_block_to_block(parent_block, block_changeset) do
    with {:ok, new_block} <- Changeset.apply_action(block_changeset, :insert) do
      page_id = List.last(parent_block.ancestors)
      block_id = "#{page_id}-#{Nanoid.generate()}"

      case Client.put("/blocks/#{block_id}", Document.to_doc(new_block)) do
        {:ok, doc} ->
          {:ok, Document.merge_identifiers(new_block, doc)}

        # TODO: Error handling
        error ->
          IO.inspect(error)
          {:error, Changeset.add_error(block_changeset, :id, "cannot be created")}
      end
    end
  end
end
