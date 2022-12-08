defmodule Mantra.Accounts.AccountRepo do
  alias Ecto.Changeset
  alias Mantra.Accounts.Account

  @callback create_account(Changeset.t(Account.t())) ::
              {:ok, Account.t()} | {:error, Changeset.t(Account.t())}
end
