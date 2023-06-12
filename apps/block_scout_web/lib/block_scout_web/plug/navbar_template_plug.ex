defmodule BlockScoutWeb.NavbarTemplatePlug do
  import Plug.Conn

  alias Explorer.{Chain, PagingOptions}

  def init(default), do: default

  def call(conn, _default) do
    paging_params = %PagingOptions{page_size: 5}
    case Chain.list_top_templates(nil, [
      paging_options: paging_params
    ]) do
      templates when is_list(templates) ->
        assign(conn, :navbar_top_templates, templates)
      _ -> assign(conn, :navbar_top_templates, [])
    end
  end
end
