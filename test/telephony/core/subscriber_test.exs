defmodule Telephony.Core.SubscriberTest do
  use ExUnit.Case
  alias Telephony.Core.{Subscriber, Prepaid, Pospaid}

  test "create a prepaid subscriber" do
    # Given
    payload = %{
      full_name: "Aislan",
      phone_number: "123",
      subscriber_type: :prepaid
    }

    # When
    result = Subscriber.new(payload)
    # Then
    expect = %Subscriber{
      full_name: "Aislan",
      phone_number: "123",
      subscriber_type: %Prepaid{credits: 0, recharges: []}
    }

    assert expect == result
  end

  test "create a pospaid subscriber" do
    payload = %{
      full_name: "Aislan",
      phone_number: "123",
      subscriber_type: :pospaid
    }

    result = Subscriber.new(payload)

    expect = %Subscriber{
      full_name: "Aislan",
      phone_number: "123",
      subscriber_type: %Pospaid{spent: 0}
    }

    assert expect == result
  end
end
