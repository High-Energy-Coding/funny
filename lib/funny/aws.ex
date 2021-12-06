defmodule Funny.AWS do
  def get_object(path), do: adapter().get_object(path)
  def put_object(object, body, options \\ []), do: adapter().put_object(object, body, options)
  def delete_object(object), do: adapter().delete_object(object)
  def send_email(destination, message, from), do: adapter().send_email(destination, message, from)

  defp adapter, do: Application.get_env(:funny, :aws_adapter, Funny.AWS.Local)
end
