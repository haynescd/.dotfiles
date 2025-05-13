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
                        { path = "${3rp}/luv/library", words = { "vim%.uv" } },
                    },
                },
            },
            { 'saghen/blink.cmp' },
        },
        config = function(_, opts)
            local capabilities = vim.lsp.protocol.make_client_capabilities()

            capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)

            capabilities.textDocument.semanticTokens.multilineTokenSupport = true

            capabilities.textDocument.completion.completionItem.snippetSupport = true

            vim.lsp.config('*', {
                capabilities = capabilities,
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

            vim.lsp.enable({ 'lua_ls', 'basedpyright', 'ts_ls' })

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
                callback = function(args)
                    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
                    if not client then return end


                    client.offset_encoding = "utf-16"

                    vim.keymap.set("n", "<leader>dy", vim.diagnostic.setloclist,
                        { desc = "Yank diagnostic list for current buffer" })

                    ---- Find references for the word under your cursor.
                    --vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references,
                    --    { buffer = 0, desc = 'LSP: [G]oto [R]eferences' })

                    ---- Jump to the implementation of the word under your cursor.
                    ----  Useful when your language has ways of declaring types without an actual implementation.
                    --vim.keymap.set('n', 'gi', require('telescope.builtin').lsp_implementations,
                    --    { buffer = 0, desc = 'LSP: [G]oto [I]mplementation' })

                    ---- Jump to the definition of the word under your cursor.
                    ----  This is where a variable was first declared, or where a function is defined, etc.
                    ----  To jump back, press <C-t>.
                    vim.keymap.set('n', 'gd', require('telescope.builtin').lsp_definitions,
                        { buffer = 0, desc = 'LSP: [G]oto [D]efinition' })

                    ---- Fuzzy find all the symbols in your current document.
                    ----  Symbols are things like variables, functions, types, etc.
                    vim.keymap.set('n', '<leader>gw', require('telescope.builtin').lsp_document_symbols,
                        { buffer = 0, desc = 'LSP: Open Document Symbols' })

                    ---- Jump to the type of the word under your cursor.
                    ----  Useful when you're not sure what type a variable is and you want to see
                    ----  the definition of its *type*, not where it was *defined*.
                    --vim.keymap.set('n', 'gT', vim.lsp.buf.lsp_type_definitions,
                    --    { buffer = 0, desc = 'LSP: [G]oto [T]ype Definition' })

                    -- Enable auto-completion. Note: Use CTRL-Y to select an item. |complete_CTRL-Y|
                    if client:supports_method('textDocument/completion') then
                        -- Optional: trigger autocompletion on EVERY keypress. May be slow!
                        -- local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
                        -- client.server_capabilities.completionProvider.triggerCharacters = chars

                        --vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
                    end

                    -- Auto-format ("lint") on save.
                    -- Usually not needed if server supports "textDocument/willSaveWaitUntil".
                    if not client:supports_method('textDocument/willSaveWaitUntil')
                        and client:supports_method('textDocument/formatting') then
                        vim.api.nvim_create_autocmd('BufWritePre', {
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
