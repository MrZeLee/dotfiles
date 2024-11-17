return {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, -- set this if you want to always pull the latest change
    opts = {
        provider = "claude-haiku",
        auto_suggestions_provider = "ollama",
        behaviour = {
            auto_suggestions = false, -- Experimental stage
            auto_set_highlight_group = true,
            auto_set_keymaps = true,
            auto_apply_diff_after_generation = false,
            support_paste_from_clipboard = false,
        },
        claude = {
            endpoint = "https://api.anthropic.com",
            model = "claude-3-5-sonnet-20241022",
            timeout = 30000, -- Timeout in milliseconds
            temperature = 0,
            max_tokens = 8192,
        },
        openai = {
            endpoint = "https://api.openai.com/v1",
            model = "gpt-4o-mini",
            timeout = 30000, -- Timeout in milliseconds
            temperature = 0,
            max_tokens = 4096,
        },
        ---@type {[string]: AvanteProvider}
        vendors = {
            ---@type AvanteSupportedProvider
            ["claude-haiku"] = {
                api_key_name = "cmd:printenv ANTHROPIC_API_KEY",
                endpoint = "https://api.anthropic.com",
                model = "claude-3-5-haiku-20241022",
                timeout = 30000, -- Timeout in milliseconds
                temperature = 0,
                max_tokens = 8192,
                parse_curl_args = function(opts, prompt_opts)
                    local base, body_opts = require("avante.providers").parse_config(opts)

                    local headers = {
                        ["Content-Type"] = "application/json",
                        ["anthropic-version"] = "2023-06-01",
                        ["anthropic-beta"] = "prompt-caching-2024-07-31",
                    }

                    headers["x-api-key"] = opts.parse_api_key()

                    local messages = require("avante.providers").claude.parse_messages(prompt_opts)

                    return {
                        url = opts.endpoint .. "/v1/messages",
                        proxy = base.proxy,
                        insecure = base.allow_insecure,
                        headers = headers,
                        body = vim.tbl_deep_extend("force", {
                            model = base.model,
                            system = {
                                {
                                    type = "text",
                                    text = prompt_opts.system_prompt,
                                    cache_control = { type = "ephemeral" },
                                },
                            },
                            messages = messages,
                            stream = true,
                        }, body_opts),
                    }
                end,
                parse_response_data = function(data_stream, event_state, opts)
                    require("avante.providers").claude.parse_response(data_stream, event_state, opts)
                end,
            },
            ---@type AvanteProvider
            ["ollama"] = {
                endpoint = "http://localhost:11434/v1",
                model = "codellama:7b",
                parse_curl_args = function(opts, code_opts)
                    return {
                        url = opts.endpoint .. "/chat/completions",
                        headers = {
                            ["Accept"] = "application/json",
                            ["Content-Type"] = "application/json",
                        },
                        body = {
                            model = opts.model,
                            messages = require("avante.providers").copilot.parse_messages(code_opts),
                            max_tokens = 8192,
                            stream = true,
                        },
                    }
                end,
                parse_response_data = function(data_stream, event_state, opts)
                    require("avante.providers").openai.parse_response(data_stream, event_state, opts)
                end,
            },
        },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "stevearc/dressing.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        --- The below dependencies are optional,
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
}
