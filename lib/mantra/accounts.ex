defmodule Mantra.Accounts do
  alias Mantra.Accounts.Account

  defp account_repo(), do: Application.get_env(:mantra, Mantra.Accounts.AccountRepo)

  def create_account(params) do
    %Account{}
    |> Account.create_changeset(params)
    |> account_repo().create_account()
  end
end
