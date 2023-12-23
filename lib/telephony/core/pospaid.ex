defmodule Telephony.Core.Pospaid do
  alias Telephony.Core.Call
  defstruct spent: 0
  @price_per_minute 1.04

  def make_call(subscriber, time_spent, date) do
    subscriber
    |> update_credit_spent(time_spent)
    |> add_new_call(time_spent, date)
  end

  defp update_credit_spent(%{subscriber_type: subscriber_type} = subscriber, time_spent) do
    subscriber_type = %{subscriber_type | spent: subscriber_type.spent + credit_spent(time_spent)}
    %{subscriber | subscriber_type: subscriber_type}
  end

  defp credit_spent(time_spent) do
    @price_per_minute * time_spent
  end

  def add_new_call(subscriber, time_spent, date) do
    call = Call.new(time_spent, date)
    %{subscriber | calls: subscriber.calls ++ [call]}
  end
end
