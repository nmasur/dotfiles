-- =======================================================================
-- Language Server
-- =======================================================================

local M = {}

M.packer = function(use)
    -- Language server engine
    use({
        "neovim/nvim-lspconfig",
        requires = { "hrsh7th/cmp-nvim-lsp" },
        config = function()
            local function on_path(program)
                return vim.fn.executable(program) == 1
            end

            local capabilities = require("cmp_nvim_lsp").update_capabilities(
                vim.lsp.protocol.make_client_capabilities()
            )
            if on_path("lua-language-server") then
                require("lspconfig").sumneko_lua.setup({
                    capabilities = capabilities,
                    -- Turn off errors for vim global variable
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = { "vim" },
                            },
                        },
                    },
                })
            end
            if on_path("rust-analyzer") then
                require("lspconfig").rust_analyzer.setup({ capabilities = capabilities })
            end
            if on_path("tflint") then
                require("lspconfig").tflint.setup({ capabilities = capabilities })
            end
            if on_path("terraform-ls") then
                require("lspconfig").terraformls.setup({ capabilities = capabilities })
            end
            if on_path("pyright") then
                require("lspconfig").pyright.setup({
                    on_attach = function()
                        -- set keymaps (requires 0.7.0)
                        -- vim.keymap.set("n", "", "", {buffer=0})
                    end,
                    capabilities = capabilities,
                })
            end

            vim.keymap.set("n", "gd", vim.lsp.buf.definition)
            vim.keymap.set("n", "gT", vim.lsp.buf.type_definition)
            vim.keymap.set("n", "gi", vim.lsp.buf.implementation)
            vim.keymap.set("n", "gh", vim.lsp.buf.hover)
            -- vim.keymap.set("n", "gr", telescope.lsp_references)
            vim.keymap.set("n", "<Leader>R", vim.lsp.buf.rename)
            vim.keymap.set("n", "]e", vim.diagnostic.goto_next)
            vim.keymap.set("n", "[e", vim.diagnostic.goto_prev)
            vim.keymap.set("n", "<Leader>e", vim.diagnostic.open_float)
            vim.keymap.set("n", "<Leader>E", vim.lsp.buf.code_action)
        end,
    })

    -- Pretty highlights
    use("folke/lsp-colors.nvim")

    -- Linting
    use({
        "jose-elias-alvarez/null-ls.nvim",
        branch = "main",
        requires = {
            "nvim-lua/plenary.nvim",
            "neovim/nvim-lspconfig",
        },
        config = function()
            local function on_path(program)
                return vim.fn.executable(program) == 1
            end

            require("null-ls").setup({
                sources = {
                    require("null-ls").builtins.formatting.stylua.with({
                        condition = function()
                            return on_path("stylua")
                        end,
                    }),
                    require("null-ls").builtins.formatting.black.with({
                        condition = function()
                            return on_path("black")
                        end,
                    }),
                    require("null-ls").builtins.formatting.fish_indent.with({
                        condition = function()
                            return on_path("fish_indent")
                        end,
                    }),
                    require("null-ls").builtins.formatting.nixfmt.with({
                        condition = function()
                            return on_path("nixfmt")
                        end,
                    }),
                    require("null-ls").builtins.formatting.rustfmt.with({
                        condition = function()
                            return on_path("rustfmt")
                        end,
                    }),
                    require("null-ls").builtins.diagnostics.shellcheck.with({
                        condition = function()
                            return on_path("shellcheck")
                        end,
                    }),
                    require("null-ls").builtins.formatting.shfmt.with({
                        extra_args = { "-i", "4", "-ci" },
                        condition = function()
                            return on_path("shfmt")
                        end,
                    }),
                    require("null-ls").builtins.formatting.terraform_fmt.with({
                        condition = function()
                            return on_path("terraform")
                        end,
                    }),
                    -- require("null-ls").builtins.diagnostics.luacheck,
                    -- require("null-ls").builtins.diagnostics.markdownlint,
                    -- require("null-ls").builtins.diagnostics.pylint,
                },
                -- Format on save
                on_attach = function(client)
                    if client.resolved_capabilities.document_formatting then
                        local id = vim.api.nvim_create_augroup("LspFormatting", {
                            clear = true,
                        })
                        vim.api.nvim_create_autocmd("BufWritePre", {
                            group = id,
                            pattern = "*",
                            callback = vim.lsp.buf.formatting_seq_sync,
                        })
                    end
                end,
            })
        end,
    })
end

return M
