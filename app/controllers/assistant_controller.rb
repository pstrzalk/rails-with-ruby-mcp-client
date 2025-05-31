require "mcp_client"

# greet users 3 and 9

class AssistantController < ApplicationController
  def show; end

  def chat
    openai_messages = []
    ui_messages = []

    openai_messages << {
      "role" => "system",
      "content" => "You are a helpful assistant."
    }

    user_message = {
      "role" => "user",
      "content" => params[:prompt]
    }
    openai_messages << user_message
    ui_messages << user_message

    mcp_client = MCPClient::Client.new(
      mcp_server_configs: [
        MCPClient.sse_config(
          base_url: "http://localhost:3000/mcp/sse",
          read_timeout: 30,
          retries: 3,
          retry_backoff: 1
        )
      ]
    )
    tools = mcp_client.to_openai_tools

    openai_client = OpenAI::Client.new
    response = openai_client.chat(
      parameters: {
        model: "gpt-4.1-mini",
        messages: openai_messages,
        temperature: 0.7,
        tools: tools,
        tool_choice: "auto"
      }
    )

    assistant_message = response.dig("choices", 0, "message")
    tool_calls = assistant_message["tool_calls"] || []

    while tool_calls.any?
      tool_call = tool_calls.first
      function_details = tool_call["function"]
      function_name = function_details["name"]
      function_arguments = JSON.parse(
        function_details["arguments"]
      )

      tool_call_result = mcp_client.call_tool(
        function_name, function_arguments
      )

      openai_messages << {
        "role" => "assistant",
        "tool_calls" => [ tool_call ]
      }
      openai_messages << {
        "role" => "tool",
        "tool_call_id" => tool_call["id"],
        "name" => function_name,
        "content" => tool_call_result.to_json
      }
      ui_messages << {
        "role" => "assistant",
        "content" => "Calling tool /#{function_name}/, with #{function_arguments}"
      }

      response = openai_client.chat(
        parameters: {
          model: "gpt-4.1-mini",
          messages: openai_messages,
          tools: tools,
          tool_choice: "auto",
          temperature: 0.7
        }
      )

      assistant_message = response.dig("choices", 0, "message")
      tool_calls = assistant_message["tool_calls"] || []
    end

    ui_messages << assistant_message

    respond_to do |format|
      format.turbo_stream do
        turbo_stream_response = ActiveSupport::SafeBuffer.new

        ui_messages.each do |message|
          turbo_stream_response += turbo_stream.append(
            "messages",
            partial: "assistant/message",
            locals: { message: }
          )
        end

        turbo_stream_response += turbo_stream.update(
          "chat_input",
          partial: "assistant/chat_form"
        )

        render turbo_stream: turbo_stream_response
      end
    end
  end
end
