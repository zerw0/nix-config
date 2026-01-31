{
    pkgs,
    lib,
    ...
}:
{
    home.packages = with pkgs; [
        ripgrep
        nodejs
];

    programs.nixvim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        defaultEditor = true;
        colorscheme = "gruvbox";
        opts = {
            termguicolors = true;
            background = "dark";
        };
        colorschemes.gruvbox = {
            enable = true;
            settings = {
                contrast = "hard";
            };
        };
    };
}
