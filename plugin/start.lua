local valid_args = function()
    return { "left", "down", "up", "right" }
end

vim.api.nvim_create_user_command(
    'AeroSpaceFocus',
    function(opts)
        require('aerospace-focus').move(opts.args)
    end,
    {
        nargs = 1,
        complete = valid_args,
    }
)
