return {{
    'mhartington/formatter.nvim',
    config = function()
        require("formatter").setup {
            filetype = {
                go = {
                    require("formatter.filetypes.go").gofumpt,
                },
                python = {
                    require("formatter.filetypes.python").ruff,
                    require("formatter.filetypes.python").black,
                },
                javascript = {
                    require("formatter.filetypes.javascript").prettierd,
                },
                typescript = {
                    require("formatter.filetypes.typescript").prettierd,
                },
            }
        }
    end,
}}
