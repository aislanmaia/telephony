defmodule Subscriber.SubscriberTest do
  use ExUnit.Case
  alias Subscriber.Subscriber

  test "create a subscriber" do
    # Given
    payload = %{
      full_name: "Aislan",
      id: "123",
      phone_number: "123"
    }
    # When
    result = Subscriber.new(payload)
    # Then
    expect = %Subscriber{
      full_name: "Aislan",
      id: "123",
      phone_number: "123",
      subscriber_type: :prepaid
    }
    assert expect == result
  end
end
