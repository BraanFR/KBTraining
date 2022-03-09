defmodule Riak do
  require Logger

  def url, do: "https://kbrw-sb-tutoex-riak-gateway.kbrw.fr"
  def bucket, do: "vlu_orders"
  def schema_path, do: "/home/vincent/Documents/Projects/KBRW/training/kbrw_training/project/schemas/vlu_schema.xml"
  def index, do: "vlu_orders_index"


  def auth_header do
    username = "sophomore"
    password = "jlessthan3tutoex"

    auth = :base64.encode_to_string("#{username}:#{password}")
    [{'authorization', 'Basic #{auth}'}]
  end


  def put(key, object) do
    {:ok, {{_, code, _message}, _headers, body}} = :httpc.request(:put, {'#{Riak.url}/buckets/#{Riak.bucket}/keys/#{key}', Riak.auth_header(), 'application/json', object}, [], [])

    # Logger.info(body)

    if code in [200, 201, 204, 300] do
      {:ok, {code, body}}
    else
      {:ko, {code, body}}
    end
  end


  def list_buckets do
    {:ok, {{_, 200, _message}, _headers, body}} = :httpc.request(:get, {'#{Riak.url}/buckets?buckets=true', Riak.auth_header()}, [], [])

    # Logger.info(body)

    {:ok, body}
  end


  def list_keys do
    {:ok, {{_, 200, _message}, _headers, body}} = :httpc.request(:get, {'#{Riak.url}/buckets/#{Riak.bucket}/keys?keys=true', Riak.auth_header()}, [], [])

    # Logger.info(body)

    {:ok, body}
  end


  def get(key) do
    {:ok, {{_, code, _message}, _headers, body}} = :httpc.request(:get, {'#{Riak.url}/buckets/#{Riak.bucket}/keys/#{key}', Riak.auth_header()}, [], [])

    # Logger.info(body)

    if code in [200, 300] do
      {:ok, {code, Poison.decode!(body)}}
    else
      {:ko, {code, body}}
    end
  end


  def delete(key) do
    {:ok, {{_, code, _message}, _headers, body}} = :httpc.request(:delete, {'#{Riak.url}/buckets/#{Riak.bucket}/keys/#{key}', Riak.auth_header()}, [], [])

    # Logger.info(body)

    if code in [204, 404] do
      {:ok, {code, body}}
    else
      {:ko, {code, body}}
    end
  end


  def upload_schema() do
    schema_file = File.read!(Riak.schema_path)
    {:ok, {{_, code, _message}, _headers, body}} = :httpc.request(:put, {'#{Riak.url}/search/schema/vlu_orders_schema', Riak.auth_header(), 'application/xml', schema_file}, [], [])

    # Logger.info(body)

    if code == 204 do
      {:ok, {code, body}}
    else
      {:ko, {code, body}}
    end
  end


  def get_schema(schema_name) do
    {:ok, {{_, code, _message}, _headers, body}} = :httpc.request(:get, {'#{Riak.url}/search/schema/#{schema_name}', Riak.auth_header()}, [], [])

    if code == 200 do
      {:ok, {code, body}}
    else
      {:ko, {code, body}}
    end
  end


  def create_index do
    object = '{"schema": "vlu_orders_schema"}'
    {:ok, {{_, code, _message}, _headers, body}} = :httpc.request(:put, {'#{Riak.url}/search/index/vlu_orders_index', Riak.auth_header(), 'application/json', object}, [], [])

    if code == 204 do
      {:ok, {code, body}}
    else
      {:ko, {code, body}}
    end
  end


  def assign_index do
    object = '{"props": {"search_index": "vlu_orders_index"}}'
    {:ok, {{_, code, _message}, _headers, body}} = :httpc.request(:put, {'#{Riak.url}/buckets/#{Riak.bucket}/props', Riak.auth_header(), 'application/json', object}, [], [])

    if code == 204 do
      {:ok, {code, body}}
    else
      {:ko, {code, body}}
    end
  end


  def list_indexes do
    {:ok, {{_, code, _message}, _headers, body}} = :httpc.request(:get, {'#{Riak.url}/search/index', Riak.auth_header()}, [], [])

    if code == 200 do
      {:ok, {code, body}}
    else
      {:ko, {code, body}}
    end
  end


  def list_bucket_props do
    {:ok, {{_, code, _message}, _headers, body}} = :httpc.request(:get, {'#{Riak.url}/buckets/#{Riak.bucket}/props', Riak.auth_header()}, [], [])

    if code == 200 do
      {:ok, {code, body}}
    else
      {:ko, {code, body}}
    end
  end


  def empty_bucket() do
    keys = Poison.decode!(elem(Riak.list_keys(), 1))["keys"]

    task = Task.async_stream(keys, fn item -> Riak.delete(item) end, max_concurrency: 5)
    Stream.run(task)

    {:ok}
  end


  def delete_bucket(_bucket) do
    {:ko}
  end


  def delete_bucket_props() do
    {:ok, {{_, code, _message}, _headers, body}} = :httpc.request(:delete, {'#{Riak.url}/buckets/#{Riak.bucket}/props', Riak.auth_header()}, [], [])

    if code == 204 do
      {:ok, {code, body}}
    else
      {:ko, {code, body}}
    end
  end


  def delete_index() do
    {:ok, {{_, code, _message}, _headers, body}} = :httpc.request(:delete, {'#{Riak.url}/search/index/#{Riak.index}', Riak.auth_header()}, [], [])

    if code == 204 do
      {:ok, {code, body}}
    else
      {:ko, {code, body}}
    end
  end


  def search(index, query, page \\ 0, rows \\ 30, sort \\ "creation_date_index") do
    # {:ok, {{_, code, _message}, _headers, body}} = :httpc.request(:get, {'#{Riak.url}/search/query/#{Riak.index}/?wt=json&q=type:nat_order', Riak.auth_header()}, [], [])

    # query = Riak.escape(query)

    {:ok, {{_, code, _message}, _headers, body}} = :httpc.request(:get, {'#{Riak.url}/search/query/#{index}/?wt=json&q=#{query}&start=#{page}&rows=#{rows}&sort=#{sort}%20DESC', Riak.auth_header()}, [], [])

    {:ok, Poison.decode!(body)["response"]}
  end


  def escape(string) do
    string = String.replace(string, "+", "\\+")
    string = String.replace(string, "-", "\\-")
    string = String.replace(string, "&&", "\\&\\&")
    string = String.replace(string, "||", "\\|\\|")
    string = String.replace(string, "!", "\\!")
    string = String.replace(string, "(", "\\(")
    string = String.replace(string, ")", "\\)")
    string = String.replace(string, "{", "\\{")
    string = String.replace(string, "}", "\\}")
    string = String.replace(string, "[", "\\[")
    string = String.replace(string, "]", "\\]")
    string = String.replace(string, "^", "\\^")
    string = String.replace(string, "\"", "\\\"")
    string = String.replace(string, "~", "\\~")
    string = String.replace(string, "*", "\\*")
    string = String.replace(string, "?", "\\?")
    string = String.replace(string, ":", "\\:")
    string = String.replace(string, "/", "\\/")

    string = String.replace(string, "\\", "%5C")

    string
  end

end
