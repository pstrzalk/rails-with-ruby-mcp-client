# Assistant with MCP Capabilities

Example usage of `ruby-mcp-client` gem in a Ruby on Rails application. Parts of the code will be shared in an article describing the gem.

## Before you use

Launch an MCP server at `http://localhost:3000/mcp`. Yes, it's hardcoded - it's just a demo for an article. Adjust to your needs.

## How to use

- clone the repository
- run `bundle install`
- provide OpenAI API key in OPENAI_API_KEY environment variable
- run the application with `bin/dev` - the app launches on port 3030
- open `http://localhost:3030/assistant` in your browser
- submit a prompt (possibly, related to the MCP capabilities)

### Available Tools

When you open the root URL `http://localhost:3030`, you will see a list of all the available tools.
