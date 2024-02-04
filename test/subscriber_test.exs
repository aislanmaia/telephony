defmodule Subscriber.SubscriberTest do
  use ExUnit.Case

  alias Subscriber.Subscriber

  test "creates a new subscriber with the given payload" do
    payload = %{full_name: "Aislan", phone_number: "123", type: :pospaid}
    subscriber = Subscriber.new(payload)

    assert %Subscriber{
             full_name: "Aislan",
             id: nil,
             phone_number: "123",
             type: :pospaid
           } = subscriber
  end
end
