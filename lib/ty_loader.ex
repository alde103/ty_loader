defmodule TyLoader do
  @moduledoc """
  Command line Teensy Loader in Elixir.
  """
  use GenServer
  require Logger

  @device_map %{
    "Teensy 4.0" => "--mcu=imxrt1062",
    "Teensy 3.6" => "--mcu=mk66fx1m0",
    "Teensy 3.5" => "--mcu=mk64fx512",
    "Teensy 3.2" => "--mcu=mk20dx256",
    "Teensy 3.1" => "--mcu=mk20dx256",
    "Teensy 3.0" => "--mcu=mk20dx128",
    "Teensy LC" => "--mcu=mkl26z64",
    "Teensy++ 2.0" => "--mcu=at90usb1286",
    "Teensy 2.0" => "--mcu=atmega32u4",
    "Teensy++ 1.0" => "--mcu=at90usb646",
    "Teensy 1.0" => "--mcu=at90usb162"
  }

  defstruct cmd_path: nil

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_args) do
    cmd_path =
    :code.priv_dir(:tycmdex)
    |> to_string()
    |> Path.join("/teensy_loader_cli")

    state = %__MODULE__{
      cmd_path: cmd_path
    }
    {:ok, state}
  end

  def upload(pid, args) do
    file = Keyword.fetch!(args, :file)
    device = Keyword.fetch!(args, :device)
    GenServer.call(pid, {:upload, file, device}, 15000)
  end

  def handle_call({:upload, file, device}, _from, %{cmd_path: cmd_path} = state) do
    processor = Map.fetch!(@device_map, device)
    response =
      MuonTrap.cmd(cmd_path, [processor, "-w", file], stderr_to_stdout: true)
      |> cmd_response()
    {:reply, response, state}
  end

  def handle_call(_unkwon_call, _from, state) do
    {:reply, {:error, :einval}, state}
  end

  def terminate(reason, state) do
    Logger.error("(#{__MODULE__}) Error: #{inspect({reason, state})}.")
  end

  defp cmd_response({_response, 0}), do: :ok
  defp cmd_response({response, 1}) do
    cond do
      String.match?(response, ~r/Device or resource busy/) ->
        {:error, :eagain}
      true ->
        {:error, :einval}
    end
  end
end
