defmodule Telephony.Core.Pospaid do
  alias Telephony.Core.Call
  defstruct spent: 0

  defimpl Subscriber, for: Telephony.Core.Pospaid do
    @price_per_minute 1.04

    def make_recharge(_, _, _) do
      {:error, "Pospaid can't make a recharge"}
    end

    def print_invoice(_pospaid, calls, year, month) do
      calls = Enum.reduce(calls, [], &filter_calls(&1, &2, year, month))

      value_spent = Enum.reduce(calls, 0, &(&1.value_spent + &2))

      %{
        value_spent: value_spent,
        calls: calls
      }
    end

    def make_call(type, time_spent, date) do
      type
      |> update_credit_spent(time_spent)
      |> add_new_call(time_spent, date)
    end

    defp filter_calls(call, acc, year, month) do
      if call.date.year == year and call.date.month == month do
        value_spent = call.time_spent * @price_per_minute
        call = %{date: call.date, time_spent: call.time_spent, value_spent: value_spent}

        acc ++ [call]
      else
        acc
      end
    end

    defp update_credit_spent(type, time_spent) do
      %{type | spent: type.spent + credit_spent(time_spent)}
    end

    defp add_new_call(type, time_spent, date) do
      call = Call.new(time_spent, date)
      {type, call}
    end

    defp credit_spent(time_spent) do
      @price_per_minute * time_spent
    end
  end
end
