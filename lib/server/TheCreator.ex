defmodule Server.TheCreator do

  @doc false
  defmacro __using__(_) do
    quote do
      import Plug.Conn
      import Server.TheCreator

      # Init an empty map of URLS and their associated functions, also an error tuple with default values
      @urls %{}
      @error {404, "Go away, you are not welcome here"}

      # Invoque the before compile before the module is compiled
      @before_compile Server.TheCreator
    end
  end

  defmacro my_get(url, do: {code, message}) do
    function_name = String.to_atom("url " <> url)

    quote do
      # Add the new function name into the attributes
      @urls Map.put(@urls, unquote(url), unquote(function_name))

      # define the new function
      def unquote(function_name)(conn), do: send_resp(conn, unquote(code), unquote(message))
    end
    # IO.inspect(@urls)
  end

  defmacro my_error(code: code, content: content) do
    quote do
      # replace default error by the new one
      @error {unquote(code), unquote(content)}
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def init(opts) do
        opts
      end

      def call(conn, _opts) do
        # call the function associated with URL if exist
        if @urls[conn.request_path] != nil do
          apply(__MODULE__, @urls[conn.request_path], [conn])

        # error message otherwise
        else
          send_resp(conn, elem(@error, 0), elem(@error, 1))
        end
      end

    end
  end
end
