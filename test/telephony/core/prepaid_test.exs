defmodule Telephony.Core.PrepaidTest do
  use ExUnit.Case
  alias Telephony.Core.{Call, Prepaid, Recharge}

  setup do
    prepaid = %Prepaid{credits: 10, recharges: []}

    prepaid_without_credits = %Prepaid{credits: 0, recharges: []}

    %{prepaid: prepaid, prepaid_without_credits: prepaid_without_credits}
  end

  test "make a call", %{prepaid: prepaid} do
    time_spent = 2
    date = NaiveDateTime.utc_now()
    result = Subscriber.make_call(prepaid, time_spent, date)

    prepaid_expect = %Prepaid{credits: 7.1, recharges: []}
    call_expect = %Call{time_spent: 2, date: date}
    expect = {prepaid_expect, call_expect}

    assert expect == result
  end

  test "try to make a call", %{prepaid_without_credits: prepaid_without_credits} do
    time_spent = 2
    date = NaiveDateTime.utc_now()
    result = Subscriber.make_call(prepaid_without_credits, time_spent, date)

    expect = {:error, "Subscriber doest not have credits"}

    assert expect == result
  end

  test "make a recharge", %{prepaid: prepaid} do
    value = 100
    date = NaiveDateTime.utc_now()

    result = Subscriber.make_recharge(prepaid, value, date)

    prepaid_expect = %Prepaid{
      credits: 110,
      recharges: [
        %Recharge{value: 100, date: date}
      ]
    }

    assert prepaid_expect == result
  end

  test "print invoice" do
    date = ~D[2023-12-23]
    last_month = ~D[2023-11-23]

    subscriber = %Telephony.Core.Subscriber{
      full_name: "Aislan",
      phone_number: "123",
      subscriber_type: %Prepaid{
        credits: 253.6,
        recharges: [
          %Recharge{value: 100, date: date},
          %Recharge{value: 100, date: last_month},
          %Recharge{value: 100, date: last_month}
        ]
      },
      calls: [
        %Call{
          date: date,
          time_spent: 2
        },
        %Call{
          date: last_month,
          time_spent: 10
        },
        %Call{
          date: last_month,
          time_spent: 20
        }
      ]
    }

    subscriber_type = subscriber.subscriber_type
    calls = subscriber.calls

    assert Subscriber.print_invoice(subscriber_type, calls, 2023, 11) == %{
             calls: [
               %{
                 date: last_month,
                 time_spent: 10,
                 value_spent: 14.5
               },
               %{
                 date: last_month,
                 time_spent: 20,
                 value_spent: 29.0
               }
             ],
             recharges: [
               %Recharge{value: 100, date: last_month},
               %Recharge{value: 100, date: last_month}
             ],
             credits: 253.6
           }
  end
end
