defmodule Telephony.ServerTest do
  use ExUnit.Case
  alias Telephony.Server

  setup do
    {:ok, pid} = Server.start_link(:test)

    payload = %{
      full_name: "Aislan",
      type: :prepaid,
      phone_number: "123"
    }

    %{pid: pid, process_name: :test, payload: payload}
  end

  test "start_link", %{pid: pid} do
    # Inicia o GenServer
    result = Telephony.Server.start_link(:telephony)

    assert {:error, {:already_started, _pid}} = result

    # Verifica se o GenServer foi iniciado
    assert GenServer.whereis(:test) == pid
  end

  test "check telephony subscribers state", %{pid: pid} do
    assert [] = :sys.get_state(pid)
  end

  test "create a subscriber", %{pid: pid, process_name: process_name, payload: payload} do
    old_state = :sys.get_state(pid)
    assert [] == old_state

    result = GenServer.call(process_name, {:create_subscriber, payload})

    refute old_state == result

    assert [
             %Telephony.Core.Subscriber{
               full_name: "Aislan",
               phone_number: "123",
               type: %Telephony.Core.Prepaid{credits: 0, recharges: []},
               calls: []
             }
           ] == result
  end

  test "error message when try to create a subscriber", %{
    pid: pid,
    process_name: process_name,
    payload: payload
  } do
    old_state = :sys.get_state(pid)
    assert [] == old_state

    GenServer.call(process_name, {:create_subscriber, payload})
    result = GenServer.call(process_name, {:create_subscriber, payload})

    assert {:error, "Subscriber `123` already exists"} == result
  end

  test "search subscriber", %{process_name: process_name, payload: payload} do
    result = GenServer.call(process_name, {:search_subscriber, payload.phone_number})
    assert result == nil

    GenServer.call(process_name, {:create_subscriber, payload})
    result = GenServer.call(process_name, {:search_subscriber, payload.phone_number})
    assert result.full_name == payload.full_name
  end

  test "make a recharge", %{pid: pid, process_name: process_name, payload: payload} do
    GenServer.call(process_name, {:create_subscriber, payload})

    date = Date.utc_today()
    state = :sys.get_state(pid)
    subscriber_state = hd(state)
    assert subscriber_state.type.recharges == []
    :ok = GenServer.cast(process_name, {:make_recharge, payload.phone_number, 100, date})

    state = :sys.get_state(pid)
    subscriber_state = hd(state)
    refute subscriber_state.type.recharges == []

    :ok = GenServer.cast(process_name, {:make_recharge, "999", 50, date})

    state = :sys.get_state(pid)
    subscriber_state = hd(state)

    assert length(subscriber_state.type.recharges) == 1
  end

  test "make a success call", %{pid: pid, process_name: process_name, payload: payload} do
    date = Date.utc_today()
    phone_number = payload.phone_number
    time_spent = 10

    GenServer.call(process_name, {:create_subscriber, payload})
    GenServer.cast(process_name, {:make_recharge, payload.phone_number, 100, date})

    state = :sys.get_state(pid)
    subscriber_state = hd(state)
    assert subscriber_state.calls == []

    result = GenServer.call(process_name, {:make_call, phone_number, time_spent, date})

    refute result.calls == []
  end

  test "make a failed call", %{process_name: process_name, payload: payload} do
    date = Date.utc_today()
    phone_number = payload.phone_number
    time_spent = 10

    GenServer.call(process_name, {:create_subscriber, payload})

    result = GenServer.call(process_name, {:make_call, phone_number, time_spent, date})

    assert {:error, "Subscriber doest not have credits"} == result
  end

  test "print invoice", %{process_name: process_name, payload: payload} do
    GenServer.call(process_name, {:create_subscriber, payload})
    date = Date.utc_today()
    phone_number = payload.phone_number

    result = GenServer.call(process_name, {:print_invoice, phone_number, date.year, date.month})

    assert result.invoice.calls == []
  end

  test "print all invoices", %{process_name: process_name, payload: payload} do
    GenServer.call(process_name, {:create_subscriber, payload})
    date = Date.utc_today()

    result = GenServer.call(process_name, {:print_all_invoices, date.year, date.month})

    assert result |> hd() |> then(& &1.invoice) == %{credits: 0, recharges: [], calls: []}
  end
end
