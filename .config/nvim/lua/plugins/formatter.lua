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
                }
            }
        }
    end,
}}
