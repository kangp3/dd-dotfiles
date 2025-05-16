return {{
    'mhartington/formatter.nvim',
    config = function()
        require("formatter").setup {
            filetype = {
                go = {
                    require("formatter.filetypes.go").gofumpt,
                },
                python = {
                    function()
                        return {
                            exe = "ruff",
                            args = {
                                "format",
                                "-q",
                                "--line-length", "120",
                                "--",
                                "-",
                            },
                            stdin = true,
                        }
                    end
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
