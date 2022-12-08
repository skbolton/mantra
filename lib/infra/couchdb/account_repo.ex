defmodule Infra.CouchDB.AccountRepo do
  @behaviour Mantra.Accounts.AccountRepo
  alias Ecto.Changeset
  alias Infra.CouchDB.{Client, Document}

  def create_account(account_changeset) do
    with {:ok, account} <- Changeset.apply_action(account_changeset, :insert),
         {:ok, doc} <- Client.put("/blocks/#{Nanoid.generate()}", Document.to_doc(account)) do
      {:ok, Document.merge_identifiers(account, doc)}
    end
  end
end
