defmodule Funny.AWS.Local do
  def get_object(object) do
    local_file_path(object)
    |> File.read()
    |> case do
      {:ok, contents} -> {:ok, contents}
      {:error, _reason} -> {:error, {:http_error, 404, "something"}}
    end
  end

  def put_object(object, body, _IGNORED_options) do
    path = local_file_path(object)

    Path.dirname(path)
    |> File.mkdir_p()
    |> TT.wrap()
    |> TT.map(fn _ -> File.write(path, body) end)
  end

  def delete_object(object) do
    local_file_path(object)
    |> rm_object()
    |> case do
      :ok -> :ok
      {:error, :enoent} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  def send_email(destination, message, from) do
    IO.puts("""
    TOTES SENDING THIS EMAIL
    #{destination}
    #{from}
    #{message}
    """)
  end

  defp rm_object(path) do
    if File.dir?(path) do
      File.rmdir(path)
    else
      File.rm(path)
    end
  end

  @local_s3_bucket "local_s3_dev_bucket"
  defp local_file_path(object) do
    Path.join([:code.priv_dir(:funny), @local_s3_bucket, object])
  end
end
