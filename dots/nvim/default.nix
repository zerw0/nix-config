{
    pkgs,
    lib,
    ...
}:
{
    home.packages = with pkgs; [ ripgrep nodejs ];

    programs.nixvim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        defaultEditor = true;
        colorscheme = "gruvbox";

        opts = {
            compatible = false;
            shell = "fish";
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
        };

        globals = {
            mapleader = " ";
            python_highlight_all = 1;
            NVIM_TUI_ENABLE_CURSOR_SHAPE = 0;
        };

        colorschemes.gruvbox = {
            enable = true;
            settings.contrast = "hard";
        };

        plugins = {
            fugitive.enable = true;
            gitgutter.enable = true;
            startify.enable = true;
            emmet.enable = true;
            indent-blankline.enable = true;
        };

        extraPlugins = with pkgs.vimPlugins; [
            goyo-vim
            nerdtree
            nerdtree-git-plugin
            ctrlp-vim
            vim-sneak
            coc-nvim
        ];

        autoCmd = [
            {
                event = [ "BufNewFile" "BufRead" ];
                pattern = "*.py";
                command = "setlocal tabstop=4 softtabstop=4 shiftwidth=4 textwidth=79 expandtab autoindent fileformat=unix";
            }
            {
                event = [ "BufNewFile" "BufRead" ];
                pattern = [ "*.js" "*.html" "*.css" ];
                command = "setlocal tabstop=2 softtabstop=2 shiftwidth=2";
            }
            {
                event = [ "BufNewFile" "BufRead" ];
                pattern = "*.md";
                command = "Goyo | set nonumber";
            }
            {
                event = "BufEnter";
                pattern = "*";
                command = "if (winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree()) | q | endif";
            }
            {
                event = "VimEnter";
                pattern = "*";
                command = "wincmd p";
            }
        ];

        keymaps = [
            { mode = "n"; key = ";g"; action = ":Goyo<CR>"; }
            { mode = "n"; key = "q"; action = "<Nop>"; }
            { mode = "n"; key = "Q"; action = "<Nop>"; }
            { mode = "n"; key = ",c"; action = ":lcl<CR>:pc<CR>:cclose<CR>"; }
            { mode = "n"; key = ",N"; action = ":NERDTreeToggle<CR>"; }
            { mode = "n"; key = "]h"; action = "<Plug>(GitGutterNextHunk)"; }
            { mode = "n"; key = "[h"; action = "<Plug>(GitGutterPrevHunk)"; }
            { mode = "n"; key = "ghs"; action = "<Plug>(GitGutterStageHunk)"; }
            { mode = "n"; key = "ghu"; action = "<Plug>(GitGutterUndoHunk)"; }
        ];

        extraConfigVim = ''
            let g:goyo_width = "80%"
            let g:goyo_height = "80%"
            let NERDTreeIgnore=['\.pyc$', '\~$']
            let NERDTreeShowBookmarks=1
            let g:startify_bookmarks = systemlist("cut -sd' ' -f 2- ~/.NERDTreeBookmarks")
            let g:NERDTreeGitStatusIndicatorMapCustom = {
                \ "Modified"  : "✹",
                \ "Staged"    : "✚",
                \ "Untracked" : "✭",
                \ "Renamed"   : "➜",
                \ "Unmerged"  : "═",
                \ "Deleted"   : "",
                \ "Dirty"     : "✗",
                \ "Clean"     : "✔︎",
                \ 'Ignored'   : '☒',
                \ "Unknown"   : "?"
                \ }
            let g:gitgutter_sign_added = '✚'
            let g:gitgutter_sign_modified = '✹'
            let g:gitgutter_sign_removed = '-'
            let g:gitgutter_sign_removed_first_line = '-'
            let g:gitgutter_sign_modified_removed = '-'
            let g:startify_files_number = 18
            let g:startify_session_persistence = 1
            let g:startify_lists = [
                \ { 'type': 'dir',       'header': ['   Recent files'] },
                \ { 'type': 'sessions',  'header': ['   Saved sessions'] },
                \ ]
            let g:startify_custom_header = [
                \ "  ",
                \ '   ╻ ╻   ╻   ┏┳┳',
                \ '   ┃┏┛   ┃   ┃┃┃',
                \ '   ┗┛    ╹   ╹ ╹',
                \ '   ',
                \ ]
            let g:coc_global_extensions = [
                \ 'coc-json',
                \ 'coc-git',
                \ 'coc-eslint',
                \ 'coc-tsserver',
                \ 'coc-python',
                \ 'coc-tabnine',
                \ 'coc-html',
                \ 'coc-snippets',
                \ 'coc-rls'
                \ ]
            hi StatusLine ctermbg=none cterm=bold
            hi StatusLineNC ctermfg=white
            syntax on
        '';
    };
}
