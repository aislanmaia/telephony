defmodule Telephony.Core.SubscriberTest do
  use ExUnit.Case
  alias Telephony.Core.{Pospaid, Prepaid, Subscriber}

  setup do
    pospaid = %Subscriber{
      full_name: "Aislan",
      phone_number: "123",
      subscriber_type: %Pospaid{spent: 0}
    }

    prepaid = %Subscriber{
      full_name: "Aislan",
      phone_number: "123",
      subscriber_type: %Prepaid{credits: 10, recharges: []}
    }

    %{pospaid: pospaid, prepaid: prepaid}
  end

  test "create a prepaid subscriber" do
    # Given
    payload = %{
      full_name: "Aislan",
      phone_number: "123",
      subscriber_type: :prepaid
    }

    # When
    result = Subscriber.new(payload)

    # then
    expected = %Subscriber{
      full_name: "Aislan",
      phone_number: "123",
      subscriber_type: %Prepaid{credits: 0, recharges: []}
    }

    assert expected == result
  end

  test "create a pospaid subscriber" do
    payload = %{
      full_name: "Aislan",
      phone_number: "123",
      subscriber_type: :pospaid
    }

    result = Subscriber.new(payload)

    expected = %Subscriber{
      full_name: "Aislan",
      phone_number: "123",
      subscriber_type: %Pospaid{spent: 0}
    }

    assert expected == result
  end
end
