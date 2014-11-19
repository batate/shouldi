defmodule ShouldI.CLIFormatter do
  @moduledoc false

  alias ExUnit.CLIFormatter, as: CF
  import ExUnit.Formatter, only: [format_test_failure: 5]
  use GenEvent

  ## Callbacks

  def init(opts) do
    CF.init(opts)
  end

  def handle_event({:test_finished, %ExUnit.Test{state: {:failed, {:error, %ShouldI.MultiError{errors: errors}, _stack}}} = test}, config) do
    if config.trace do
      IO.puts failure(trace_test_result(test), config)
    end

    Enum.each(errors, fn {_, error} ->
      formatted = format_test_failure(test, error, config.failures_counter + 1,
                                      config.width, &formatter(&1, &2, config))
      print_failure(formatted, config)
    end)

    {:ok, %{config | tests_counter: config.tests_counter + 1,
                     failures_counter: config.failures_counter + 1}}
  end

  def handle_event(event, config) do
    CF.handle_event(event, config)
  end

  defp print_failure(formatted, config) do
    cond do
      config.trace -> IO.puts ""
      true -> IO.puts "\n"
    end
    IO.puts formatted
  end

  ## Tracing

  defp trace_test_name(%ExUnit.Test{name: name}) do
    case Atom.to_string(name) do
      "test " <> rest -> rest
      rest -> rest
    end
  end

  defp trace_test_time(%ExUnit.Test{time: time}) do
    "#{format_us(time)}ms"
  end

  defp trace_test_result(test) do
    "\r  * #{trace_test_name test} (#{trace_test_time(test)})"
  end

  defp format_us(us) do
    us = div(us, 10)
    if us < 10 do
      "0.0#{us}"
    else
      us = div us, 10
      "#{div(us, 10)}.#{rem(us, 10)}"
    end
  end

  # Color styles

  defp colorize(escape, string, %{colors: colors}) do
    enabled = colors[:enabled]
    [IO.ANSI.format_fragment(escape, enabled),
     string,
     IO.ANSI.format_fragment(:reset, enabled)] |> IO.iodata_to_binary
  end

  defp failure(msg, config) do
    colorize([:red], msg, config)
  end

  defp formatter(:error_info, msg, config),    do: colorize([:red], msg, config)
  defp formatter(:extra_info, msg, config),    do: colorize([:cyan], msg, config)
  defp formatter(:location_info, msg, config), do: colorize([:bright, :black], msg, config)
  defp formatter(_,  msg, _config),            do: msg
end
