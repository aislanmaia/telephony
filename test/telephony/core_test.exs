defmodule Telephony.CoreTest do
  use ExUnit.Case
  alias Telephony.Core
  alias Telephony.Core.{Pospaid, Prepaid, Recharge, Subscriber}

  setup do
    subscribers = [
      %Subscriber{
        full_name: "Aislan",
        phone_number: "123",
        type: %Prepaid{credits: 0, recharges: []}
      },
      %Subscriber{
        full_name: "Aislan",
        phone_number: "456",
        type: %Pospaid{spent: 0}
      }
    ]

    payload = %{
      full_name: "Aislan",
      phone_number: "123",
      type: :prepaid
    }

    %{subscribers: subscribers, payload: payload}
  end

  test "create new subscriber", %{payload: payload} do
    subscribers = []

    result = Core.create_subscriber(subscribers, payload)

    expect = [
      %Subscriber{
        full_name: "Aislan",
        phone_number: "123",
        type: %Prepaid{credits: 0, recharges: []}
      }
    ]

    assert expect == result
  end

  test "create a new subscriber", %{subscribers: subscribers} do
    payload = %{
      full_name: "Joe",
      phone_number: "1234",
      type: :prepaid
    }

    result = Core.create_subscriber(subscribers, payload)

    expect = [
      %Subscriber{
        full_name: "Aislan",
        phone_number: "123",
        type: %Prepaid{credits: 0, recharges: []}
      },
      %Subscriber{
        full_name: "Aislan",
        phone_number: "456",
        type: %Pospaid{spent: 0},
        calls: []
      },
      %Subscriber{
        full_name: "Joe",
        phone_number: "1234",
        type: %Prepaid{credits: 0, recharges: []}
      }
    ]

    assert expect == result
  end

  test "display error when subscriber already exists", %{
    subscribers: subscribers,
    payload: payload
  } do
    result = Core.create_subscriber(subscribers, payload)
    assert {:error, "Subscriber `123` already exists"} == result
  end

  test "display error when subscriber type does not exists", %{payload: payload} do
    payload = Map.put(payload, :type, :type_not_existing)
    result = Core.create_subscriber([], payload)
    assert {:error, "Only 'prepaid' or 'pospaid' are accepted"} == result
  end

  test "search a subscriber", %{subscribers: subscribers} do
    expect = %Subscriber{
      full_name: "Aislan",
      phone_number: "123",
      type: %Prepaid{credits: 0, recharges: []}
    }

    result = Core.search_subscriber(subscribers, "123")
    assert expect == result
  end

  test "return nil when subscriber does not exist", %{subscribers: subscribers} do
    result = Core.search_subscriber(subscribers, "12323123")
    assert nil == result
  end

  test "make a recharge", %{subscribers: subscribers} do
    date = Date.utc_today()
    result = Core.make_recharge(subscribers, "123", 2, date)

    assert result ==
             {[
                %Subscriber{
                  full_name: "Aislan",
                  phone_number: "456",
                  type: %Pospaid{spent: 0},
                  calls: []
                },
                %Subscriber{
                  full_name: "Aislan",
                  phone_number: "123",
                  type: %Prepaid{
                    credits: 2,
                    recharges: [%Recharge{value: 2, date: date}]
                  },
                  calls: []
                }
              ],
              %Subscriber{
                full_name: "Aislan",
                phone_number: "123",
                type: %Prepaid{
                  credits: 2,
                  recharges: [%Recharge{value: 2, date: date}]
                },
                calls: []
              }}
  end

  test "make a recharge pospaid", %{subscribers: subscribers} do
    date = Date.utc_today()
    result = Core.make_recharge(subscribers, "123", 2, date)

    assert result ==
             {[
                %Subscriber{
                  full_name: "Aislan",
                  phone_number: "456",
                  type: %Pospaid{spent: 0},
                  calls: []
                },
                %Subscriber{
                  full_name: "Aislan",
                  phone_number: "123",
                  type: %Prepaid{
                    credits: 2,
                    recharges: [%Recharge{value: 2, date: date}]
                  },
                  calls: []
                }
              ],
              %Subscriber{
                full_name: "Aislan",
                phone_number: "123",
                type: %Prepaid{
                  credits: 2,
                  recharges: [%Recharge{value: 2, date: date}]
                },
                calls: []
              }}
  end

  test "make a call", %{subscribers: subscribers} do
    expected = {:error, "Subscriber doest not have credits"}

    date = Date.utc_today()
    result = Core.make_call(subscribers, "123", 1, date)
    assert expected == result
  end

  test "print invoice", %{subscribers: subscribers} do
    expected = %{
      subscriber: %Subscriber{
        full_name: "Aislan",
        phone_number: "123",
        type: %Prepaid{credits: 0, recharges: []},
        calls: []
      },
      invoice: %{credits: 0, recharges: [], calls: []}
    }

    date = Date.utc_today()
    result = Core.print_invoice(subscribers, "123", date.year, date.month)
    assert expected == result
  end

  test "print all invoices", %{subscribers: subscribers} do
    date = Date.utc_today()
    result = Core.print_all_invoices(subscribers, date.year, date.month)

    expected = [
      %{
        subscriber: %Telephony.Core.Subscriber{
          full_name: "Aislan",
          phone_number: "123",
          type: %Telephony.Core.Prepaid{credits: 0, recharges: []},
          calls: []
        },
        invoice: %{credits: 0, recharges: [], calls: []}
      },
      %{
        subscriber: %Telephony.Core.Subscriber{
          full_name: "Aislan",
          phone_number: "456",
          type: %Telephony.Core.Pospaid{spent: 0},
          calls: []
        },
        invoice: %{calls: [], value_spent: 0}
      }
    ]

    assert expected == result
  end
end
