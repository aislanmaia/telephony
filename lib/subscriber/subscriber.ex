defmodule Subscriber.Subscriber do
  defstruct full_name: nil, id: nil, phone_number: nil, type: :prepaid

  def new(payload) do
    struct(__MODULE__, payload)
  end
end
