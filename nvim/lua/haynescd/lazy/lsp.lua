return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            {
                "folke/lazydev.nvim",
                ft = "lua", -- only load on lua files
                opts = {
                    library = {
                        -- See the configuration section for more details
                        -- Load luvit types when the `vim.uv` word is found
                        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                    },
                },
            },
        },
        config = function()
            local capabilities = require('blink.cmp').get_lsp_capabilities()

            vim.lsp.config('*', {
                capabilities = capabilities,
                root_markers = { '.git' },
            })

            vim.lsp.config('ruff', {
                init_options = {
                    settings = {
                        --Ruff language server settings go here
                        fixAll = true,
                        organizeImports = true,
                        lineLength = 80,
                        lint = {
                            enable = false,
                        },
                    }
                }
            })

            vim.lsp.config('basedpyright', {
                settings = {
                    basedpyright = {
                        anaylsis = {
                            inlayHints = {
                                callArgumentNames = true
                            }
                        }
                    }
                }
            })

            vim.lsp.enable('lua_ls')
            vim.lsp.enable('basedpyright')
            vim.lsp.enable('ruff')

            --vim.lsp.set_log_level('debug')

            vim.diagnostic.config({ virtual_text = true })

            -- Set for virtual lines
            --vim.diagnostic.config({
            --    virtual_lines = {
            --        current_line = true,
            --    },
            --})

            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('my.lsp', {}),
                callback = function(args)
                    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
                    if not client then return end

                    client.offset_encoding = "utf-16"

                    -- Auto-format ("lint") on save.
                    -- Usually not needed if server supports "textDocument/willSaveWaitUntil".
                    if not client:supports_method('textDocument/willSaveWaitUntil')
                        and client:supports_method('textDocument/formatting') then
                        vim.api.nvim_create_autocmd('BufWritePre', {
                            group = vim.api.nvim_create_augroup('my.lsp', { clear = false }),
                            buffer = args.buf,
                            callback = function()
                                print(client.name)
                                vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
                            end,
                        })
                    end
                end,
            })
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup('lsp_attach_disable_ruff_hover', { clear = true }),
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client == nil then
                        return
                    end
                    if client.name == 'ruff' then
                        -- Disable hover in favor of Pyright
                        client.server_capabilities.hoverProvider = false
                    end
                end,
                desc = 'LSP: Disable hover capability from Ruff',
            })
        end,
    }
}
