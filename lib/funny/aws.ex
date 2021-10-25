defmodule Funny.AWS do
  def get_object(path), do: adapter().get_object(path)
  def put_object(object, body, options \\ []), do: adapter().put_object(object, body, options)
  def delete_object(object), do: adapter().delete_object(object)

  defmodule Local do
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

  defmodule Default do
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

    defp bucket, do: Application.fetch_env!(:funny, :s3_bucket)
  end

  defp adapter, do: Application.get_env(:funny, :aws_adapter, Local)
end
