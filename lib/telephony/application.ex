defmodule Telephony.Application do
  use Application

  def start(_, _) do
    children = [
      {Telephony.Server, :telephony}
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]

    Supervisor.start_link(children, opts)
  end
end
