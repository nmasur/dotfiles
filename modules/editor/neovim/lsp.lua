-- =======================================================================
-- Language Server
-- =======================================================================

-- Language server engine
use({
    "neovim/nvim-lspconfig",
    requires = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
        local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
        require("lspconfig").rust_analyzer.setup({ capabilities = capabilities })
        require("lspconfig").tflint.setup({ capabilities = capabilities })
        require("lspconfig").terraformls.setup({ capabilities = capabilities })
        require("lspconfig").pyright.setup({
            on_attach = function()
                -- set keymaps (requires 0.7.0)
                -- vim.keymap.set("n", "", "", {buffer=0})
            end,
            capabilities = capabilities,
        })
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
        require("null-ls").setup({
            sources = {
                require("null-ls").builtins.formatting.stylua,
                require("null-ls").builtins.formatting.black,
                require("null-ls").builtins.formatting.fish_indent,
                require("null-ls").builtins.formatting.nixfmt,
                require("null-ls").builtins.formatting.rustfmt,
                require("null-ls").builtins.diagnostics.shellcheck,
                require("null-ls").builtins.formatting.shfmt.with({
                    extra_args = { "-i", "4", "-ci" },
                }),
                require("null-ls").builtins.formatting.terraform_fmt,
                -- require("null-ls").builtins.diagnostics.luacheck,
                -- require("null-ls").builtins.diagnostics.markdownlint,
                -- require("null-ls").builtins.diagnostics.pylint,
            },
            -- Format on save
            on_attach = function(client)
                if client.resolved_capabilities.document_formatting then
                    vim.cmd([[
                        augroup LspFormatting
                            autocmd! * <buffer>
                            autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync()
                        augroup END
                        ]])
                end
            end,
        })
    end,
})
