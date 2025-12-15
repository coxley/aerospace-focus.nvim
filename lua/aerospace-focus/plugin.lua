local utils = require('aerospace-focus.utils')
local M = {}

local is_healthy = false
local extra_argv = {}
local directions = {
    left  = 'h',
    down  = 'j',
    up    = 'k',
    right = 'l',
}

function M.move(direction)
    -- Grab window ID and try to move in the requested direction
    local start_win = vim.fn.winnr()
    vim.cmd.wincmd(directions[direction])

    -- If we navigated out of the window, then vim wins. Otherwise if aerospace isn't
    -- available or working properly, avoid spamming error messages.
    if vim.fn.winnr() ~= start_win or is_healthy == false then
        return
    end

    -- Otherwise, there was nowhere to navigate to. Let's try changing aerospace focus.
    local cmd = {
        'aerospace',
        'focus',
        direction,
    }

    for _, v in ipairs(extra_argv) do
        table.insert(cmd, v)
    end

    vim.system(cmd, {}, function(obj)
        if obj.code ~= 0 then
            utils.process_error(cmd, obj)
        end
    end)
end

function M.focus()
    if utils.ensure_state_dir() == 0 then
        utils.notify_once("failed to create state dir")
        return
    end

    is_healthy = utils.is_healthy() == 1

    -- Mark vim focus state as active by writing the current RPC socket location to the
    -- lock file
    local sock_path = vim.v.servername
    if sock_path == "" then
        utils.notify_once("cannot find RPC socket")
    end
    utils.replace_file(utils.lock_file(), sock_path)
end

function M.blur()
    if utils.ensure_state_dir() == 0 then
        utils.notify_once("failed to create state dir")
        return
    end

    -- Mark vim focus state as inactive by removing our file
    vim.fs.rm(utils.lock_file(), { force = true })
end

function M.setup(opts)
    if opts and opts.extra_argv then
        for _, v in ipairs(opts.extra_argv) do
            table.insert(extra_argv, v)
        end
    end

    if utils.ensure_state_dir() == 0 then
        utils.notify_once("failed to create state dir")
        return
    end

    utils.update_script(string.format([[
#!/usr/bin/env bash

DIRECTION=$1
LOCK="%s"

if [ -f "$LOCK" ]; then
    SOCK=$(cat "$LOCK")
    echo "lua local chan = vim.fn.sockconnect('pipe', '$SOCK', { rpc = true }); vim.fn.rpcrequest(chan, 'nvim_command', 'AeroSpaceFocus $DIRECTION')" \
        | nvim -u NORC -es
else
    aerospace focus $DIRECTION %s
fi
]], utils.lock_file(), table.concat(extra_argv, " ")))

    vim.api.nvim_create_autocmd({ "VimEnter", "VimResume", "FocusGained" }, {
        callback = M.focus,
    })

    vim.api.nvim_create_autocmd({ "VimLeave", "VimSuspend", "FocusLost" }, {
        callback = M.blur,
    })
end

return M
