defmodule Server.EwebRouter do
  use Ewebmachine.Builder.Resources
  if Mix.env == :dev, do: plug Ewebmachine.Plug.Debug

  resource "/hello/:name" do %{name: name} after
    content_types_provided do: ['text/html': :to_html]
    defh to_html, do: "<html><h1>Hello #{state.name}</h1></html>"
  end

  resources_plugs error_forwarding: "/error/:status", nomatch_404: true
end
