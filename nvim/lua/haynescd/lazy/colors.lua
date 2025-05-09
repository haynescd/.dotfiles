function ColorMyPencils(color)
    color = color or "rose-pine"
    vim.cmd.colorscheme(color)

    --vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    --vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

-- lua/plugins/rose-pine.lua
return {
    {
        "rose-pine/neovim",
        name = "rose-pine",
        config = function()
            require('rose-pine').setup({
                variant = "moon",
                dark_variant = "moon",
                --disable_background = true,
                styles = {
                    italic = true,
                },
            })
            ColorMyPencils();
        end
    }

}
