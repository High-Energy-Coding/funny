defmodule TT do
  @moduledoc """
  Utility functions for working with tagged tuples
  """
  @type a :: any()

  @type b :: any()

  @type e :: any()

  @type t(a, e) :: {:ok, a} | {:error, e}

  def sequence([]), do: {:ok, []}
  def sequence([h | t]), do: sequence(h, sequence(t))
  defp sequence(:ok, {:ok, values}), do: {:ok, values}
  defp sequence({:ok, value}, {:ok, values}), do: {:ok, [value | values]}
  defp sequence({:ok, _value}, {:error, values}), do: {:error, values}
  defp sequence({:error, value}, {:ok, _values}), do: {:error, [value]}
  defp sequence({:error, value}, {:error, values}), do: {:error, [value | values]}

  def wrap(value, error_message \\ nil)
  def wrap(nil, error_message), do: {:error, error_message}
  def wrap(value, _), do: {:ok, value}

  @doc """
  Transform a TaggedTuple structure with a given function.

  ## Examples

    iex> TaggedTuple.map({:ok, 9}, &:math.sqrt/1)
    {:ok, 3.0}

    iex> TaggedTuple.map({:error, :shrug}, &:math.sqrt/1)
    {:error, :shrug}

  """
  @spec map(t(a, e), (a -> b)) :: t(b, e)
  def map({:ok, value} = _tagged_tuple, fun), do: {:ok, fun.(value)}
  def map({:error, value}, _), do: {:error, value}

  @doc """
  Chain together computations that may fail.

  We only continue with the callback if things are going well, and then
  flatten the tagged_tuple structure.

  The significance of `and_then` lies in the TaggedTuple structure the
  callback function returns.
  """
  @spec and_then(t(a, e), (a -> t(b, e))) :: t(b, e)
  def and_then({:ok, value} = _tagged_tuple, fun), do: fun.(value)
  def and_then({:error, _} = reason, _), do: reason

  @doc """
  Shed the tagged tuple structure

  If the optional value is present, return the optional value

  Otherwise return the provided default value

  ## Examples

    iex> TaggedTuple.with_default({:ok, 9}, 12)
    9

    iex> TaggedTuple.with_default({:error, :shrug}, :high_five)
    :high_five

  """
  @spec with_default(t(a, e), a) :: a
  def with_default({:ok, val}, _), do: val
  def with_default({:error, _}, default), do: default
end
