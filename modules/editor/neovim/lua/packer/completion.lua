-- =======================================================================
-- Completion System
-- =======================================================================

local M = {}

M.packer = function(use)
    -- Completion sources
    use("hrsh7th/cmp-nvim-lsp") --- Language server completion plugin
    use("hrsh7th/cmp-buffer") --- Generic text completion
    use("hrsh7th/cmp-path") --- Local file completion
    use("hrsh7th/cmp-cmdline") --- Command line completion
    use("hrsh7th/cmp-nvim-lua") --- Nvim lua api completion
    use("saadparwaiz1/cmp_luasnip") --- Luasnip completion
    use("lukas-reineke/cmp-rg") --- Ripgrep completion
    use("rafamadriz/friendly-snippets") -- Lots of pre-generated snippets

    -- Completion engine
    use({
        "hrsh7th/nvim-cmp",
        requires = { "L3MON4D3/LuaSnip" },
        config = function()
            local cmp = require("cmp")

            local kind_icons = {
                Text = "",
                Method = "m",
                Function = "",
                Constructor = "",
                Field = "",
                Variable = "",
                Class = "",
                Interface = "",
                Module = "",
                Property = "",
                Unit = "",
                Value = "",
                Enum = "",
                Keyword = "",
                Snippet = "",
                Color = "",
                File = "",
                Reference = "",
                Folder = "",
                EnumMember = "",
                Constant = "",
                Struct = "",
                Event = "",
                Operator = "",
                TypeParameter = "",
            }

            cmp.setup({

                -- Setup snippet completion
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },

                -- Setup completion keybinds
                mapping = {
                    ["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
                    ["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
                    ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
                    ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
                    ["<Esc>"] = function(_)
                        cmp.mapping({
                            i = cmp.mapping.abort(),
                            c = cmp.mapping.close(),
                        })
                        vim.cmd("stopinsert") --- Abort and leave insert mode
                    end,
                    ["<CR>"] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Insert,
                        select = true,
                    }),
                    ["<C-r>"] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    }),
                    ["<C-l>"] = cmp.mapping(function(_)
                        if require("luasnip").expand_or_jumpable() then
                            require("luasnip").expand_or_jump()
                        end
                    end, { "i", "s" }),
                },

                -- Setup completion engines
                sources = {
                    { name = "nvim_lua" },
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "path" },
                    { name = "buffer", keyword_length = 3, max_item_count = 10 },
                    {
                        name = "rg",
                        keyword_length = 6,
                        max_item_count = 10,
                        option = { additional_arguments = "--ignore-case" },
                    },
                },

                -- Visual presentation
                formatting = {
                    fields = { "kind", "abbr", "menu" },
                    format = function(entry, vim_item)
                        vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
                        vim_item.menu = ({
                            luasnip = "[Snippet]",
                            buffer = "[Buffer]",
                            path = "[Path]",
                            rg = "[Grep]",
                            nvim_lsp = "[LSP]",
                            nvim_lua = "[Lua]",
                        })[entry.source.name]
                        return vim_item
                    end,
                },

                -- Docs
                -- window = {
                --     completion = cmp.config.window.bordered(),
                --     documentation = cmp.config.window.bordered(),
                -- },

                -- Extra features
                experimental = {
                    native_menu = false, --- Use cmp menu instead of Vim menu
                    ghost_text = true, --- Show preview auto-completion
                },
            })

            -- Use buffer source for `/`
            cmp.setup.cmdline("/", {
                sources = {
                    { name = "buffer", keyword_length = 5 },
                },
            })

            -- Use cmdline & path source for ':'
            cmp.setup.cmdline(":", {
                sources = cmp.config.sources({
                    { name = "path" },
                }, {
                    { name = "cmdline" },
                }),
            })
        end,
    })
end

return M
