defmodule BlockScoutWeb.Templates.TemplateController do
  use BlockScoutWeb, :controller

  require Logger

  alias BlockScoutWeb.AccessHelper
  alias Explorer.Chain

  def show(conn, %{"id" => template_id}) do
    redirect(conn, to: AccessHelper.get_path(conn, :template_holder_path, :index, template_id))
  end
end
