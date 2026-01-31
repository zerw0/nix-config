{
    pkgs,
    lib,
    ...
};
{
    home.packages = with pkgs; [
        ripgrep
        nodejs
];

    programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        defaultEditor = true;
        };
    };

    programs.nixvim = {
        enable = true;
        colorscheme.gruvbox = {
            borders = true;
            contrast = true;
        };
    };
};
