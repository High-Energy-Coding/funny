defmodule Funny.AWS.Default do
  alias ExAws.SES

  def get_object(object) do
    bucket()
    |> ExAws.S3.get_object(object)
    |> ExAws.request()
    |> TT.map(&Map.get(&1, :body))
  end

  def put_object(object, body, options \\ []) do
    bucket()
    |> ExAws.S3.put_object(object, body, options)
    |> ExAws.request()
  end

  def delete_object(object) do
    bucket()
    |> ExAws.S3.delete_object(object)
    |> ExAws.request()
  end

  def send_email(destination, message, from) do
    SES.send_email(destination, message, from)
    |> ExAws.request()
  end

  defp bucket, do: Application.fetch_env!(:funny, :s3_bucket)
end
