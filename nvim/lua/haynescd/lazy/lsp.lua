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
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)
            capabilities.textDocument.semanticTokens.multilineTokenSupport = true
            capabilities.textDocument.completion.completionItem.snippetSupport = true

            vim.lsp.config('*', {
                capabilities = capabilities,
                root_markers = { '.git' },
            })

            vim.lsp.config('basedpyright', {
                settings = {
                    basedpyright = {
                        disableOrganizeImports = true,
                        anaylsis = {
                            autoImportCompletions = true,

                            inlayHints = {
                                callArgumentNames = true
                            }
                        }
                    }
                }
            })

            vim.lsp.enable({ 'lua_ls', 'basedpyright' })

            --vim.lsp.set_log_level('debug')

            vim.diagnostic.config({ virtual_text = true })

            vim.keymap.set("n", "<leader>dt", function()
                local config = vim.diagnostic.config() or {}
                if config.virtual_text then
                    vim.diagnostic.config { virtual_text = false, virtual_lines = false }
                else
                    vim.diagnostic.config { virtual_text = true, virtual_lines = false }
                end
            end, { desc = "Toggle lsp lines" })
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('my.lsp', {}),
                callback = function(args)
                    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
                    if not client then return end


                    client.offset_encoding = "utf-16"

                    vim.keymap.set("n", "<leader>dy", vim.diagnostic.setloclist,
                        { desc = "Yank diagnostic list for current buffer" })

                    -- Enable auto-completion. Note: Use CTRL-Y to select an item. |complete_CTRL-Y|
                    if client:supports_method('textDocument/completion') then
                        -- Optional: trigger autocompletion on EVERY keypress. May be slow!
                        -- local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
                        -- client.server_capabilities.completionProvider.triggerCharacters = chars

                        vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
                    end

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
        end,
    }
}
