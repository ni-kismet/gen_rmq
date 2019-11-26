defmodule GenRMQ.Connection do
  @moduledoc "Responsible for connection setup"

  require Logger

  defmodule Params do
    @moduledoc "Connection setup params"

    defstruct reconnect_attempt: 0,
              retry_delay_function: &Params.linear_delay/1,
              # By default, we retry forever
              max_attempts: -1

    defp linear_delay(attempt), do: :timer.sleep(attempt * 1_000)
  end

  def get_connection(_, %Params{reconnect_attempt: attempt, max_attempts: attempt}) do
    {:error, {:max_attempts_reached, attempt}}
  end

  def get_connection(uri, %Params{reconnect_attempt: attempt, retry_delay_function: retry_delay_fn} = params) do
    case AMQP.Connection.open(uri) do
      {:ok, conn} ->
        {:ok, conn}

      {:error, e} ->
        Logger.error("Failed to connect to RabbitMQ with settings: #{inspect(params)}, reason #{inspect(e)}")
        next_attempt = attempt + 1
        retry_delay_fn.(next_attempt)
        get_connection(uri, %Params{params | reconnect_attempt: next_attempt})
    end
  end
end
