defmodule TelephonyTest do
  use ExUnit.Case

  setup do
    case Telephony.Server.start_link(:telephony) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> :ok
    end

    on_exit(:h, fn ->
      if GenServer.whereis(:telephony) do
        GenServer.stop(:telephony)
      end
    end)

    %{hello: "oi"}
  end

  test "create_subscriber" do
    payload = %{full_name: "Aislan", phone_number: "123", type: :prepaid}

    assert Telephony.create_subscriber(payload) == [
             %Telephony.Core.Subscriber{
               full_name: "Aislan",
               phone_number: "123",
               type: %Telephony.Core.Prepaid{credits: 0, recharges: []},
               calls: []
             }
           ]
  end

  test "search_subscriber" do
    # Cria um assinante
    payload = %{full_name: "Aislan", phone_number: "123", type: :prepaid}
    Telephony.create_subscriber(payload)

    # Busca o assinante
    subscriber = Telephony.search_subscriber("123")
    assert subscriber.full_name == "Aislan"
  end

  test "make_recharge" do
    # Cria um assinante
    payload = %{full_name: "Aislan", phone_number: "123", type: :prepaid}
    Telephony.create_subscriber(payload)

    # Realiza uma recarga
    Telephony.make_recharge("123", 100, Date.utc_today())

    # Busca o assinante novamente
    subscriber = Telephony.search_subscriber("123")
    assert subscriber.type.credits == 100
  end

  test "make_call" do
    # Cria um assinante
    payload = %{full_name: "Aislan", phone_number: "123", type: :prepaid}
    date = Date.utc_today()
    Telephony.create_subscriber(payload)

    # assert result == {:error, "Subscriber doest not have credits"}

    # Realiza uma recarga de créditos
    Telephony.make_recharge("123", 100, date)

    # Realiza uma chamada
    result = Telephony.make_call("123", 60, date)

    assert result == %Telephony.Core.Subscriber{
             full_name: "Aislan",
             phone_number: "123",
             type: %Telephony.Core.Prepaid{
               credits: 13.0,
               recharges: [%Telephony.Core.Recharge{value: 100, date: date}]
             },
             calls: [%Telephony.Core.Call{time_spent: 60, date: date}]
           }

    result = Telephony.make_call("123", 60, date)
    assert result == {:error, "Subscriber doest not have credits"}
  end

  test "print_invoice" do
    # Cria um assinante
    payload = %{full_name: "Aislan", phone_number: "123", type: :prepaid}
    Telephony.create_subscriber(payload)

    # Realiza uma recarga
    Telephony.make_recharge("123", 100, Date.utc_today())

    # Realiza uma chamada
    Telephony.make_call("123", 60, Date.utc_today())

    # Imprime a fatura
    invoice = Telephony.print_invoice("123", 2023, 1)
    assert invoice != nil
  end

  test "print_all_invoices" do
    # Cria um assinante
    payload = %{full_name: "Aislan", phone_number: "123", type: :prepaid}
    Telephony.create_subscriber(payload)

    # Realiza uma recarga
    Telephony.make_recharge("123", 100, Date.utc_today())

    # Realiza uma chamada
    Telephony.make_call("123", 60, Date.utc_today())

    # Imprime a fatura
    invoices = Telephony.print_all_invoices(2023, 1)
    assert length(invoices) > 0
  end
end
