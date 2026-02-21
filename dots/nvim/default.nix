{
    pkgs,
    lib,
    ...
}:
{
    home.packages = with pkgs; [ ripgrep fd ];

    programs.nixvim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        defaultEditor = true;
        colorscheme = "gruvbox";

        opts = {
            compatible = false;
            shell = "zsh";
            textwidth = 0;
            clipboard = "unnamedplus";
            backspace = "indent,eol,start";
            termguicolors = true;
            background = "dark";
            number = true;
            relativenumber = true;
            encoding = "utf-8";
            laststatus = 2;
            signcolumn = "yes";
            updatetime = 300;
            completeopt = ["menu" "menuone" "noselect"];
            # Performance opts
            swapfile = false;
            backup = false;
            undofile = true;
            timeoutlen = 300;
        };

        globals = {
            mapleader = " ";
            maplocalleader = ",";
        };

        colorschemes.gruvbox = {
            enable = true;
            settings.contrast = "hard";
        };

        plugins = {
            # LSP
            lsp = {
                enable = true;
                servers = {
                    ts_ls.enable = true;
                    pyright.enable = true;
                    html.enable = true;
                    cssls.enable = true;
                    jsonls.enable = true;
                    nixd.enable = true;
                };
            };

            # Completion
            cmp = {
                enable = true;
                autoEnableSources = true;
                settings = {
                    sources = [
                        { name = "nvim_lsp"; }
                        { name = "path"; }
                        { name = "buffer"; }
                        { name = "luasnip"; }
                    ];
                    mapping = {
                        "<C-Space>" = "cmp.mapping.complete()";
                        "<C-d>" = "cmp.mapping.scroll_docs(-4)";
                        "<C-f>" = "cmp.mapping.scroll_docs(4)";
                        "<C-e>" = "cmp.mapping.close()";
                        "<CR>" = "cmp.mapping.confirm({ select = true })";
                        "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
                        "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
                    };
                };
            };
            cmp-nvim-lsp.enable = true;
            cmp-buffer.enable = true;
            cmp-path.enable = true;
            luasnip.enable = true;

            # Treesitter
            treesitter = {
                enable = true;
                settings = {
                    indent.enable = true;
                    highlight.enable = true;
                };
            };

            # File explorer
            neo-tree = {
                enable = true;
                settings = {
                    close_if_last_window = true;
                    window.width = 30;
                };
            };

            # Fuzzy finder
            telescope = {
                enable = true;
                keymaps = {
                    "<leader>ff" = "find_files";
                    "<leader>fg" = "live_grep";
                    "<leader>fb" = "buffers";
                    "<leader>fh" = "help_tags";
                };
                extensions.fzf-native.enable = true;
            };

            # Git
            fugitive.enable = true;
            gitsigns = {
                enable = true;
                settings = {
                    signs = {
                        add.text = "✚";
                        change.text = "✹";
                        delete.text = "-";
                        topdelete.text = "-";
                        changedelete.text = "-";
                    };
                };
            };

            # UI
            lualine = {
                enable = true;
                settings.options.theme = "gruvbox";
            };
            web-devicons.enable = true;
            # which-key.enable = true;  # Disabled due to builtins.toFile warning
            indent-blankline.enable = true;
            nvim-autopairs.enable = true;

            # Editing
            comment.enable = true;
            vim-surround.enable = true;
            emmet.enable = true;

            # Other
            startify.enable = true;
        };

        extraPlugins = with pkgs.vimPlugins; [ goyo-vim ];

        autoCmd = [
            {
                event = "FileType";
                pattern = "python";
                command = "setlocal tabstop=4 softtabstop=4 shiftwidth=4 textwidth=79 expandtab autoindent";
            }
            {
                event = "FileType";
                pattern = ["javascript" "typescript" "html" "css" "json"];
                command = "setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab";
            }
            {
                event = "FileType";
                pattern = "markdown";
                command = "Goyo | set nonumber";
            }
        ];

        keymaps = [
            # Goyo
            { mode = "n"; key = ";g"; action = ":Goyo<CR>"; options.desc = "Toggle Goyo"; }

            # Disable q/Q
            { mode = "n"; key = "q"; action = "<Nop>"; }
            { mode = "n"; key = "Q"; action = "<Nop>"; }

            # Close lists
            { mode = "n"; key = "<leader>c"; action = ":lcl<CR>:pc<CR>:cclose<CR>"; options.desc = "Close lists"; }

            # Neo-tree
            { mode = "n"; key = "<leader>e"; action = ":Neotree toggle<CR>"; options.desc = "Toggle file tree"; }

            # Git (gitsigns replaces gitgutter)
            { mode = "n"; key = "]h"; action = ":Gitsigns next_hunk<CR>"; options.desc = "Next hunk"; }
            { mode = "n"; key = "[h"; action = ":Gitsigns prev_hunk<CR>"; options.desc = "Prev hunk"; }
            { mode = "n"; key = "<leader>hs"; action = ":Gitsigns stage_hunk<CR>"; options.desc = "Stage hunk"; }
            { mode = "n"; key = "<leader>hu"; action = ":Gitsigns undo_stage_hunk<CR>"; options.desc = "Undo stage"; }
            { mode = "n"; key = "<leader>hp"; action = ":Gitsigns preview_hunk<CR>"; options.desc = "Preview hunk"; }

            # LSP
            { mode = "n"; key = "gd"; action = "<cmd>lua vim.lsp.buf.definition()<CR>"; options.desc = "Go to definition"; }
            { mode = "n"; key = "gr"; action = "<cmd>lua vim.lsp.buf.references()<CR>"; options.desc = "References"; }
            { mode = "n"; key = "K"; action = "<cmd>lua vim.lsp.buf.hover()<CR>"; options.desc = "Hover"; }
            { mode = "n"; key = "<leader>rn"; action = "<cmd>lua vim.lsp.buf.rename()<CR>"; options.desc = "Rename"; }
            { mode = "n"; key = "<leader>ca"; action = "<cmd>lua vim.lsp.buf.code_action()<CR>"; options.desc = "Code action"; }
        ];

        extraConfigLua = ''
            -- Goyo settings
            vim.g.goyo_width = "80%"
            vim.g.goyo_height = "80%"

            -- Startify settings
            vim.g.startify_files_number = 18
            vim.g.startify_session_persistence = 1
            vim.g.startify_lists = {
                { type = 'dir', header = {'   Recent files'} },
                { type = 'sessions', header = {'   Saved sessions'} },
            }
            vim.g.startify_custom_header = {
                "  ",
                "   ╻ ╻   ╻   ┏┳┓",
                "   ┃┏┛   ┃   ┃┃┃",
                "   ┗┛    ╹   ╹ ╹",
                "   ",
            }

            -- Status line colors
            vim.cmd([[
                hi StatusLine ctermbg=none cterm=bold
                hi StatusLineNC ctermfg=white
            ]])
        '';
    };
}
