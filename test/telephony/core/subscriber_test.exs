defmodule Telephony.Core.SubscriberTest do
  use ExUnit.Case
  alias Telephony.Core.{Call, Pospaid, Prepaid, Subscriber}

  setup do
    pospaid = %Subscriber{
      full_name: "Aislan",
      phone_number: "123",
      type: %Pospaid{spent: 0}
    }

    prepaid = %Subscriber{
      full_name: "Aislan",
      phone_number: "123",
      type: %Prepaid{credits: 10, recharges: []}
    }

    %{pospaid: pospaid, prepaid: prepaid}
  end

  test "create a prepaid subscriber" do
    # Given
    payload = %{
      full_name: "Aislan",
      phone_number: "123",
      type: :prepaid
    }

    # When
    result = Subscriber.new(payload)

    # then
    expected = %Subscriber{
      full_name: "Aislan",
      phone_number: "123",
      type: %Prepaid{credits: 0, recharges: []}
    }

    assert expected == result
  end

  test "create a pospaid subscriber" do
    payload = %{
      full_name: "Aislan",
      phone_number: "123",
      type: :pospaid
    }

    result = Subscriber.new(payload)

    expected = %Subscriber{
      full_name: "Aislan",
      phone_number: "123",
      type: %Pospaid{spent: 0}
    }

    assert expected == result
  end

  test "make a prepaid call" do
    subscriber = %Subscriber{
      full_name: "Aislan",
      phone_number: "123",
      type: %Prepaid{credits: 10, recharges: []}
    }

    date = Date.utc_today()

    assert Subscriber.make_call(subscriber, 1, date) ==
             %Subscriber{
               full_name: "Aislan",
               phone_number: "123",
               type: %Prepaid{credits: 8.55, recharges: []},
               calls: %Call{time_spent: 1, date: date}
             }
  end

  test "make a prepaid without credits call" do
    subscriber = %Subscriber{
      full_name: "Aislan",
      phone_number: "123",
      type: %Prepaid{credits: 0, recharges: []}
    }

    date = Date.utc_today()

    assert Subscriber.make_call(subscriber, 1, date) ==
             {:error, "Subscriber doest not have credits"}
  end

  test "make a pospaid call" do
    subscriber = %Subscriber{
      full_name: "Aislan",
      phone_number: "123",
      type: %Pospaid{spent: 0}
    }

    date = Date.utc_today()

    assert Subscriber.make_call(subscriber, 1, date) ==
             %Subscriber{
               calls: %Call{
                 date: date,
                 time_spent: 1
               },
               full_name: "Aislan",
               phone_number: "123",
               type: %Pospaid{spent: 1.04}
             }
  end
end
