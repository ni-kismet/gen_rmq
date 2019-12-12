defmodule GenRMQ.Connection do
  alias AMQP.Connection

  def open(config) when is_list(config) do
    case Keyword.get(config, :uri) do
      nil ->
        open_connection(Enum.into(config, %{}))

      uri ->
        Connection.open(uri)
    end
  end

  defp open_connection(config) when is_map(config) do
    case validate_open_params(config) do
      :ok_non_ssl ->
        Connection.open(
          host: config[:host],
          port: config[:port],
          username: config[:username],
          password: config[:password]
        )

      :ok_ssl ->
        Connection.open(
          host: config[:host],
          port: config[:port],
          username: config[:username],
          password: config[:password],
          ssl_options: config[:ssl_options]
        )
    end
  end

  defp validate_open_params(%{host: nil}) do
    {:error, :host_cannot_be_nil}
  end

  defp validate_open_params(%{port: nil}) do
    {:error, :port_cannot_be_nil}
  end

  defp validate_open_params(%{username: nil}) do
    {:error, :username_cannot_be_nil}
  end

  defp validate_open_params(%{password: nil}) do
    {:error, :password_cannot_be_nil}
  end

  defp validate_open_params(%{ssl_options: nil}) do
    :ok_non_ssl
  end

  defp validate_open_params(_config) do
    :ok_ssl
  end
end
