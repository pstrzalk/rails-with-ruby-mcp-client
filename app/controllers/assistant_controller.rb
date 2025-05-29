# require "mcp_client"

class AssistantController < ApplicationController
  def show; end

  def chat
    system_message = {
      "role" => "system",
      "content" => "You are a helpful assistant."
    }
    user_message = {
      "role" => "user",
      "content" => params[:prompt]
    }

    openai_client = OpenAI::Client.new
    response = openai_client.chat(
      parameters: {
        model: "gpt-4.1-mini",
        messages: [ system_message, user_message ],
        temperature: 0.7
      }
    )

    assistant_message = response.dig("choices", 0, "message")

    respond_to do |format|
      format.turbo_stream do
        render(
          turbo_stream: turbo_stream.append(
                          "messages",
                          partial: "assistant/message",
                          locals: { message: user_message }
                        ) +
                        turbo_stream.append(
                          "messages",
                          partial: "assistant/message",
                          locals: { message: assistant_message }
                        ) +
                        turbo_stream.update(
                          "chat_input",
                          partial: "assistant/chat_form"
                        )
        )
      end
    end
  end
end


# require "mcp_client"
# require "openai"

# class AssistantController < ApplicationController
#   def show
#     # Render chat interface
#   end

#   def chat
#     mcp_client = MCPClient::Client.new(
#       mcp_server_configs: [
#         MCPClient.sse_config(
#           base_url: "http://localhost:3000/mcp/sse",
#           read_timeout: 30,
#           retries: 3,
#           retry_backoff: 1
#         )
#       ]
#     )

#     # Get tools in OpenAI format
#     tools = mcp_client.to_openai_tools

#     openai = OpenAI::Client.new

#     system_prompt = "You are a helpful assistant."
#     messages = []
#     messages << { role: "user", content: params[:content] }
#     openai_messages = [ { role: "system", content: system_prompt } ] + messages

#     # Send chat request with tools
#     response = openai.chat(
#       parameters: {
#         model: "gpt-4.1-mini",
#         messages: openai_messages,
#         tools: tools,
#         tool_choice: "auto",
#         temperature: 0.7
#       }
#     )

#     assistant_message = response.dig("choices", 0, "message")

#     # Check for tool calls in assistant message
#     tool_calls = assistant_message["tool_calls"] || []

#     while tool_calls.any?
#       tool_call = tool_calls.first
#       function_details = tool_call["function"]
#       name = function_details["name"]
#       args = JSON.parse(function_details["arguments"])

#       # Call the tool using MCP client
#       result = mcp_client.call_tool(name, args)

#       # Append assistant message with tool call and tool message with result
#       openai_messages << { role: "assistant", tool_calls: [ tool_call ] }
#       openai_messages << { role: "tool", tool_call_id: tool_call["id"], name: name, content: result.to_json }

#       # Send chat request again with updated messages
#       response = openai.chat(
#         parameters: {
#           model: "gpt-4.1-mini",
#           messages: openai_messages,
#           tools: tools,
#           tool_choice: "auto",
#           temperature: 0.7
#         }
#       )

#       assistant_message = response.dig("choices", 0, "message")
#       tool_calls = assistant_message["tool_calls"] || []
#     end

#     # Append the final assistant message to messages
#     messages << assistant_message

#     respond_to do |format|
#       format.turbo_stream do
#         render turbo_stream: turbo_stream.append("messages", partial: "assistant/message", locals: { message: assistant_message }) +
#                              turbo_stream.update("chat_input", partial: "assistant/chat_form", locals: { messages: messages })
#       end
#       format.html do
#         redirect_to assistant_path
#       end
#     end
#   end
# end
