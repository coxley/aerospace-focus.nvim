local utils = require('aerospace-focus.utils')
local M = {}

function M.check()
    vim.health.start("aerospace-focus report")

    if utils.ensure_state_dir() == 0 then
        vim.health.error(string.format("couldn't created state dir: %s", utils.state_dir()))
    else
        vim.health.ok(string.format("state dir: %s", utils.state_dir()))
    end

    local lock_contents = utils.read_file(utils.lock_file())
    if lock_contents == "" then
        vim.health.error(string.format("lock file missing (assuming vim is actively focused): %s", utils.lock_file()))
    else
        vim.health.ok(string.format("lock file present: %s", utils.lock_file()))
        vim.health.info(string.format("RPC for active window: %s", lock_contents))
    end

    if utils.aerospace_exists() == 0 then
        vim.health.error(
            "'aerospace' executable is missing, plugin is limited to navigating window panes of the focused vim instance")
    else
        vim.health.ok("'aerospace' exists")
    end

    local code, err = utils.aerospace_status()
    if code ~= 0 then
        vim.health.error(err)
    else
        vim.health.ok("aerospace is actively running")
    end
end

return M
