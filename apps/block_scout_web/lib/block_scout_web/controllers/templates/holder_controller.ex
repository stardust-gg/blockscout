defmodule BlockScoutWeb.Templates.HolderController do
  use BlockScoutWeb, :controller

  import BlockScoutWeb.Account.AuthController, only: [current_user: 1]
  import BlockScoutWeb.Models.GetAddressTags, only: [get_address_tags: 2]

  alias BlockScoutWeb.{AccessHelper, Controller}
  alias BlockScoutWeb.Templates.HolderView
  alias Explorer.Chain
  alias Explorer.Chain.Address
  alias Indexer.Fetcher.TokenTotalSupplyOnDemand
  alias Phoenix.View

  import BlockScoutWeb.Chain,
    only: [
      split_list_by_page: 1,
      paging_options: 1,
      next_page_params: 3
    ]

  def index(conn, %{"template_id" => template_id, "type" => "JSON"} = params) do
    with {:ok, template} <- Chain.template_from_id(template_id),
         template_balances <- Chain.fetch_template_holders_from_template_id(template_id, paging_options(params)) do
      {template_balances_paginated, next_page} = split_list_by_page(template_balances)

      next_page_path =
        case next_page_params(next_page, template_balances_paginated, params) do
          nil ->
            nil

          next_page_params ->
            template_holder_path(conn, :index, template_id, Map.delete(next_page_params, "type"))
        end

      template_balances_json =
        Enum.map(template_balances_paginated, fn template_balance ->
          View.render_to_string(HolderView, "_template_balances.html",
            template_id: template_id,
            template_balance: template_balance,
            template: template,
            conn: conn
          )
        end)

      json(conn, %{items: template_balances_json, next_page_path: next_page_path})
    else
      {:restricted_access, _} ->
        not_found(conn)

      :error ->
        not_found(conn)

      {:error, :not_found} ->
        not_found(conn)
    end
  end

  def index(conn, %{"template_id" => template_id} = params) do
    with {:ok, template} <- Chain.template_from_id(template_id) do
      render(
        conn,
        "index.html",
        current_path: Controller.current_full_path(conn),
        template: template
      )
    else
      {:restricted_access, _} ->
        not_found(conn)

      :error ->
        not_found(conn)

      {:error, :not_found} ->
        not_found(conn)
    end
  end
end
