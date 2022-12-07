defmodule Infra.CouchDB.Document do
  @moduledoc """
  Utilities for working with CouchDB documents.
  """
  alias Mantra.Contents.{Block, Page}

  @doc """
  Merges id and rev from `doc` into `struct`.

  When a new doc is created in couch the id and the rev come back in the response
  as `id` and `rev`. This function can be used to extract these values and merge
  into a model.
  """
  def merge_identifiers(struct, %{"id" => id, "rev" => rev}) do
    Map.merge(struct, %{id: id, rev: rev})
  end

  @doc """
  Convert `model` into format better persisted in couchdb.

  * Adds a `document_type` for the given model
  * Drops `id` and `rev` (stored in couch as `_rev`, `_id`)

  # TODO: on updates the `_rev` field needs to be present
  # add `action` flag on update to have rev -> _rev
  """
  def to_doc(model) do
    model
    |> Ecto.embedded_dump(:json)
    |> Map.put(:document_type, document_type_for(model))
    |> Map.drop([:id, :rev])
  end

  @doc """
  Loads `model` from `doc`.
  """
  def from_doc(model, doc) do
    # move _rev and _id to rev and id
    {id, doc} = Map.pop(doc, "_id")
    {rev, doc} = Map.pop(doc, "_rev")
    doc = Map.merge(doc, %{"id" => id, "rev" => rev})

    Ecto.embedded_load(model, doc, :atoms)
  end

  defp document_type_for(%Page{}), do: "page"
  defp document_type_for(%Block{}), do: "block"
end
