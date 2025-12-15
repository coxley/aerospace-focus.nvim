local M = {}

function M.is_healthy()
    if M.aerospace_exists() ~= 0 then
        return 1
    end

    local code = M.aerospace_status()
    if code == 0 then
        return 1
    end
    return 0
end

function M.aerospace_exists()
    return vim.fn.executable("aerospace")
end

function M.aerospace_status()
    local check_cmd = { 'aerospace', 'list-workspaces', '--focused' }
    local obj = vim.system(check_cmd, {}):wait()
    if obj.code ~= 0 then
        return obj.code, string.format([[
aerospace isn't actively running
cmd: %s
code: %d
signal: %d
signal: %d
stdout: %s
stderr: %s
]], table.concat(check_cmd, " "), obj.code, obj.signal, obj.stdout, obj.stderr)
    end
    return 0, ""
end

function M.replace_file(path, contents)
    local file, err = io.open(path, 'w+')
    if file == nil then
        M.notify_once("failed replacing file: %s\n\n%s", path, err)
        return
    end

    file:write(contents)
    file:close()
end

function M.read_file(path)
    local file, err = io.open(path, 'r')
    if err ~= nil then
        return ""
    end
    if file == nil then
        return ""
    end
    return file:read()
end

function M.update_script(content)
    -- Script is already up to date
    if content == M.read_file(M.script_file()) then
        return
    end

    local path = M.script_file()
    M.replace_file(path, content)
    vim.fn.setfperm(path, 'rwx--x---')
end

function M.process_error(cmd, obj)
    local msg = string.format([[
aerospace focus failed
cmd: %s
code: %d
signal: %d
stdout: %s
stderr: %s
]], table.concat(cmd, " "), obj.code, obj.signal, obj.stdout, obj.stderr)
    vim.notify(msg, vim.log.levels.ERROR)
end

function M.notify_once(format, ...)
    vim.notify_once(
        string.format("aerospace-focus: " .. format, ...),
        vim.log.levels.ERROR
    )
end

function M.state_dir()
    return vim.fs.joinpath(vim.fn.stdpath("state"), "aerospace-focus")
end

function M.lock_file()
    return vim.fs.joinpath(M.state_dir(), "vim.lock")
end

function M.script_file()
    return vim.fs.joinpath(M.state_dir(), "move.sh")
end

function M.ensure_state_dir()
    local dir = M.state_dir()
    if vim.fn.isdirectory(dir) == 1 then
        return 1
    end
    return vim.fn.mkdir(dir, 'p')
end

return M
