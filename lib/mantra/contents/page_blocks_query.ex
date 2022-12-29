defmodule Mantra.Contents.PageBlocksQuery do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          page_id: String.t(),
          limit: non_neg_integer(),
          skip: non_neg_integer() | nil
        }

  @primary_key false
  embedded_schema do
    field :page_id, :string
    field :limit, :integer
    field :skip, :integer
  end

  def changeset(query, params \\ %{}) do
    query
    |> cast(params, [:page_id, :limit, :skip])
    |> validate_required([:page_id])
    |> validate_number(:limit, less_than_or_equal_to: 100, greater_than_or_equal_to: 0)
    |> validate_number(:skip, greater_than_or_equal_to: 0)
    |> set_default_limit()
    |> set_default_skip()
  end

  def set_default_limit(changeset) do
    case get_field(changeset, :limit) do
      nil ->
        put_change(changeset, :limit, 100)

      _value ->
        changeset
    end
  end

  def set_default_skip(changeset) do
    case get_field(changeset, :skip) do
      nil ->
        put_change(changeset, :skip, 0)

      _value ->
        changeset
    end
  end
end
