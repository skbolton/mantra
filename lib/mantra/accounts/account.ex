defmodule Mantra.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: String.t(),
          rev: String.t(),
          name: String.t()
        }

  @primary_key {:id, :string, autogenerate: false}
  embedded_schema do
    field :rev, :string
    field :name, :string
  end

  def create_changeset(account, params \\ %{}) do
    account
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end
