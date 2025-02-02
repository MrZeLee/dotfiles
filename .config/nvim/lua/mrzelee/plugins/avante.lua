return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  lazy = false,
  version = false, -- set this if you want to always pull the latest change
  opts = {
    ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
    provider = "claude", -- Recommend using Claude
    -- WARNING: Since auto-suggestions are a high-frequency operation and therefore expensive,
    -- currently designating it as `copilot` provider is dangerous because: https://github.com/yetone/avante.nvim/issues/1048
    -- Of course, you can reduce the request frequency by increasing `suggestion.debounce`.
    auto_suggestions_provider = "claude",
    claude = {
      endpoint = "https://api.anthropic.com",
      model = "claude-3-5-sonnet-20241022",
      temperature = 0,
      max_tokens = 4096,
    },
    openai = {
      endpoint = "https://api.openai.com/v1",
      model = "gpt-4o-mini",
      timeout = 30000, -- Timeout in milliseconds
      temperature = 0,
      max_tokens = 4096,
    },
    ---Specify the special dual_boost mode
    ---1. enabled: Whether to enable dual_boost mode. Default to false.
    ---2. first_provider: The first provider to generate response. Default to "openai".
    ---3. second_provider: The second provider to generate response. Default to "claude".
    ---4. prompt: The prompt to generate response based on the two reference outputs.
    ---5. timeout: Timeout in milliseconds. Default to 60000.
    ---How it works:
    --- When dual_boost is enabled, avante will generate two responses from the first_provider and second_provider respectively. Then use the response from the first_provider as provider1_output and the response from the second_provider as provider2_output. Finally, avante will generate a response based on the prompt and the two reference outputs, with the default Provider as normal.
    ---Note: This is an experimental feature and may not work as expected.
    dual_boost = {
      enabled = false,
      first_provider = "openai",
      second_provider = "claude",
      prompt =
      "Based on the two reference outputs below, generate a response that incorporates elements from both but reflects your own judgment and unique perspective. Do not provide any explanation, just give the response directly. Reference Output 1: [{{provider1_output}}], Reference Output 2: [{{provider2_output}}]",
      timeout = 60000, -- Timeout in milliseconds
    },
    behaviour = {
      auto_focus_sidebar = true,
      auto_suggestions = false, -- Experimental stage
      auto_suggestions_respect_ignore = false,
      auto_set_highlight_group = true,
      auto_set_keymaps = true,
      auto_apply_diff_after_generation = false,
      jump_result_buffer_on_finish = false,
      support_paste_from_clipboard = false,
      minimize_diff = true,
      enable_token_counting = true,
    },
    windows = {
      ---@alias AvantePosition "right" | "left" | "top" | "bottom" | "smart"
      position = "right",
      wrap = true,        -- similar to vim.o.wrap
      width = 30,         -- default % based on available width in vertical layout
      height = 30,        -- default % based on available height in horizontal layout
      sidebar_header = {
        enabled = true,   -- true, false to enable/disable the header
        align = "center", -- left, center, right for title
        rounded = true,
      },
      input = {
        prefix = "> ",
        height = 8, -- Height of the input window in vertical layout
      },
      edit = {
        border = "rounded",
        start_insert = false, -- Start insert mode when opening the edit window
      },
      ask = {
        floating = false,        -- Open the 'AvanteAsk' prompt in a floating window
        border = "rounded",
        start_insert = false,    -- Start insert mode when opening the ask window
        ---@alias AvanteInitialDiff "ours" | "theirs"
        focus_on_apply = "ours", -- which diff to focus after applying
      },
    },
    -- ---@type {[string]: AvanteProvider}
    -- vendors = {
    --   ---@type AvanteSupportedProvider
    --   ["claude-haiku"] = {
    --     __inherited_from = "claude",
    --     api_key_name = "cmd:printenv ANTHROPIC_API_KEY",
    --     endpoint = "https://api.anthropic.com",
    --     model = "claude-3-5-haiku-20241022",
    --     timeout = 30000, -- Timeout in milliseconds
    --     temperature = 0,
    --     max_tokens = 8000,
    --     -- parse_curl_args = function(opts, prompt_opts)
    --     --   local base, body_opts = require("avante.providers").parse_config(opts)
    --     --
    --     --   local headers = {
    --     --     ["Content-Type"] = "application/json",
    --     --     ["anthropic-version"] = "2023-06-01",
    --     --     ["anthropic-beta"] = "prompt-caching-2024-07-31",
    --     --   }
    --     --
    --     --   headers["x-api-key"] = opts.parse_api_key()
    --     --
    --     --   local messages = require("avante.providers").claude.parse_messages(prompt_opts)
    --     --
    --     --   return {
    --     --     url = opts.endpoint .. "/v1/messages",
    --     --     proxy = base.proxy,
    --     --     insecure = base.allow_insecure,
    --     --     headers = headers,
    --     --     body = vim.tbl_deep_extend("force", {
    --     --       model = base.model,
    --     --       system = {
    --     --         {
    --     --           type = "text",
    --     --           text = prompt_opts.system_prompt,
    --     --           cache_control = { type = "ephemeral" },
    --     --         },
    --     --       },
    --     --       messages = messages,
    --     --       stream = true,
    --     --     }, body_opts),
    --     --   }
    --     -- end,
    --     -- parse_response_data = function(ctx, data_stream, event_state, opts)
    --     --   require("avante.providers").claude.parse_response(ctx, data_stream, event_state, opts)
    --     -- end,
    --   },
    --   ---@type AvanteProvider
    --   ["ollama"] = {
    --     endpoint = "http://localhost:11434/v1",
    --     model = "codellama:7b",
    --     parse_curl_args = function(opts, code_opts)
    --       return {
    --         url = opts.endpoint .. "/chat/completions",
    --         headers = {
    --           ["Accept"] = "application/json",
    --           ["Content-Type"] = "application/json",
    --         },
    --         body = {
    --           model = opts.model,
    --           messages = require("avante.providers").copilot.parse_messages(code_opts),
    --           max_tokens = 8192,
    --           stream = true,
    --         },
    --       }
    --     end,
    --     parse_response_data = function(ctx, data_stream, event_state, opts)
    --       require("avante.providers").openai.parse_response(ctx, data_stream, event_state, opts)
    --     end,
    --   },
    -- },
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    -- "nvim-treesitter/nvim-treesitter",
    --- The below dependencies are optional,
    "hrsh7th/nvim-cmp",            -- autocompletion for avante commands and mentions
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "zbirenbaum/copilot.lua",      -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
  --   config = function()
  --     -- prefil edit window with common scenarios to avoid repeating query and submit immediately
  --     local prefill_edit_window = function(request)
  --       require('avante.api').edit()
  --       local code_bufnr = vim.api.nvim_get_current_buf()
  --       local code_winid = vim.api.nvim_get_current_win()
  --       if code_bufnr == nil or code_winid == nil then
  --         return
  --       end
  --       vim.api.nvim_buf_set_lines(code_bufnr, 0, -1, false, { request })
  --       -- Optionally set the cursor position to the end of the input
  --       vim.api.nvim_win_set_cursor(code_winid, { 1, #request + 1 })
  --       -- Simulate Ctrl+S keypress to submit
  --       vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-s>', true, true, true), 'v', true)
  --     end
  --
  --     -- NOTE: most templates are inspired from ChatGPT.nvim -> chatgpt-actions.json
  --     local avante_grammar_correction = 'Correct the text to standard English, but keep any code blocks inside intact.'
  --     local avante_keywords = 'Extract the main keywords from the following text'
  --     local avante_code_readability_analysis = [[
  --   You must identify any readability issues in the code snippet.
  --   Some readability issues to consider:
  --   - Unclear naming
  --   - Unclear purpose
  --   - Redundant or obvious comments
  --   - Lack of comments
  --   - Long or complex one liners
  --   - Too much nesting
  --   - Long variable names
  --   - Inconsistent naming and code style.
  --   - Code repetition
  --   You may identify additional problems. The user submits a small section of code from a larger file.
  --   Only list lines with readability issues, in the format <line_num>|<issue and proposed solution>
  --   If there's no issues with code respond with only: <OK>
  -- ]]
  --     local avante_optimize_code = 'Optimize the following code'
  --     local avante_summarize = 'Summarize the following text'
  --     local avante_translate = 'Translate this into Chinese, but keep any code blocks inside intact'
  --     local avante_explain_code = 'Explain the following code'
  --     local avante_complete_code = 'Complete the following codes written in ' .. vim.bo.filetype
  --     local avante_add_docstring = 'Add docstring to the following codes'
  --     local avante_fix_bugs = 'Fix the bugs inside the following codes if any'
  --     local avante_add_tests = 'Implement tests for the following code'
  --
  --     require('which-key').add {
  --       { '<leader>a', group = 'Avante' }, -- NOTE: add for avante.nvim
  --       {
  --         mode = { 'n', 'v' },
  --         {
  --           '<leader>ag',
  --           function()
  --             require('avante.api').ask { question = avante_grammar_correction }
  --           end,
  --           desc = 'Grammar Correction(ask)',
  --         },
  --         {
  --           '<leader>ak',
  --           function()
  --             require('avante.api').ask { question = avante_keywords }
  --           end,
  --           desc = 'Keywords(ask)',
  --         },
  --         {
  --           '<leader>al',
  --           function()
  --             require('avante.api').ask { question = avante_code_readability_analysis }
  --           end,
  --           desc = 'Code Readability Analysis(ask)',
  --         },
  --         {
  --           '<leader>ao',
  --           function()
  --             require('avante.api').ask { question = avante_optimize_code }
  --           end,
  --           desc = 'Optimize Code(ask)',
  --         },
  --         {
  --           '<leader>am',
  --           function()
  --             require('avante.api').ask { question = avante_summarize }
  --           end,
  --           desc = 'Summarize text(ask)',
  --         },
  --         {
  --           '<leader>an',
  --           function()
  --             require('avante.api').ask { question = avante_translate }
  --           end,
  --           desc = 'Translate text(ask)',
  --         },
  --         {
  --           '<leader>ax',
  --           function()
  --             require('avante.api').ask { question = avante_explain_code }
  --           end,
  --           desc = 'Explain Code(ask)',
  --         },
  --         {
  --           '<leader>ac',
  --           function()
  --             require('avante.api').ask { question = avante_complete_code }
  --           end,
  --           desc = 'Complete Code(ask)',
  --         },
  --         {
  --           '<leader>ad',
  --           function()
  --             require('avante.api').ask { question = avante_add_docstring }
  --           end,
  --           desc = 'Docstring(ask)',
  --         },
  --         {
  --           '<leader>ab',
  --           function()
  --             require('avante.api').ask { question = avante_fix_bugs }
  --           end,
  --           desc = 'Fix Bugs(ask)',
  --         },
  --         {
  --           '<leader>au',
  --           function()
  --             require('avante.api').ask { question = avante_add_tests }
  --           end,
  --           desc = 'Add Tests(ask)',
  --         },
  --       },
  --     }
  --
  --     require('which-key').add {
  --       { '<leader>a', group = 'Avante' }, -- NOTE: add for avante.nvim
  --       {
  --         mode = { 'v' },
  --         {
  --           '<leader>aG',
  --           function()
  --             prefill_edit_window(avante_grammar_correction)
  --           end,
  --           desc = 'Grammar Correction',
  --         },
  --         {
  --           '<leader>aK',
  --           function()
  --             prefill_edit_window(avante_keywords)
  --           end,
  --           desc = 'Keywords',
  --         },
  --         {
  --           '<leader>aO',
  --           function()
  --             prefill_edit_window(avante_optimize_code)
  --           end,
  --           desc = 'Optimize Code(edit)',
  --         },
  --         {
  --           '<leader>aC',
  --           function()
  --             prefill_edit_window(avante_complete_code)
  --           end,
  --           desc = 'Complete Code(edit)',
  --         },
  --         {
  --           '<leader>aD',
  --           function()
  --             prefill_edit_window(avante_add_docstring)
  --           end,
  --           desc = 'Docstring(edit)',
  --         },
  --         {
  --           '<leader>aB',
  --           function()
  --             prefill_edit_window(avante_fix_bugs)
  --           end,
  --           desc = 'Fix Bugs(edit)',
  --         },
  --         {
  --           '<leader>aU',
  --           function()
  --             prefill_edit_window(avante_add_tests)
  --           end,
  --           desc = 'Add Tests(edit)',
  --         },
  --       },
  --     }
  --   end
}
