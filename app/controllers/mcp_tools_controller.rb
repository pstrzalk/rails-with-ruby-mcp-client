require "mcp_client"

class McpToolsController < ApplicationController
  def index
    client = MCPClient.create_client(
      mcp_server_configs: [
        MCPClient.http_config(
          base_url: "http://localhost:3000/mcp",
          headers: {},
        )
      ]
    )

    @tools = client.list_tools
  end
end
