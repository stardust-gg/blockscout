defmodule Explorer.ThirdPartyIntegrations.Stardust do
  require HTTPoison
  import Jason

  defp make_request(endpoint, method, params \\ []) do
    base_url = Application.get_env(:block_scout_web, :api_config)[:base_url]
    url = "#{base_url}/#{endpoint}"
    api_key = Application.get_env(:block_scout_web, :api_config)[:api_key]
    headers = [{"x-api-key", api_key}]
    options = [
      params: params,
      timeout: 50_000
    ]

    case method do
      :get -> HTTPoison.get(url, headers, options)
    end
    |> handle_response()
  end

  def get_all_templates(gameId, start, limit) do
    make_request("template/get-all", :get, [{"gameId", gameId}, {"start", start}, {"limit", limit}])
  end

  def get_token(tokenId) do
    tokenIds = Enum.map([tokenId], &Integer.to_string/1) |> Jason.encode!()
    make_request("token/get", :get, [{"tokenIds", tokenIds}])
  end

  def get_template(gameId, templateId) do
    make_request("template/get", :get, [{"gameId", gameId}, {"templateId", templateId}])
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    {:ok, Jason.decode!(body)}
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: status, body: body}}) do
    {:error, "Error: #{status} - #{body}"}
  end

  defp handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, "HTTPoison Error: #{reason}"}
  end
end
