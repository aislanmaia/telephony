defmodule Telephony.Core.SubscriberTest do
  use ExUnit.Case
  alias Telephony.Core.Subscriber

  test "create a subscriber" do
    # Given
    payload = %{
      full_name: "Aislan",
      phone_number: "123"
    }

    # When
    result = Subscriber.new(payload)
    # Then
    expect = %Subscriber{
      full_name: "Aislan",
      phone_number: "123",
      subscriber_type: :prepaid
    }

    assert expect == result
  end
end
