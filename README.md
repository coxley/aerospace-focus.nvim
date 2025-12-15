# aerospace-focus.nvim

Seamlessly navigate between Neovim and
[AeroSpace](https://github.com/nikitabobko/AeroSpace) windows using the same keybinds.
I was tired of jumbling contextual controls for split navigation, especially on macOS
where there are fewer vacant combinations to override.

This plugin was inspired by [zellij.vim](https://github.com/fresh2dev/zellij.vim).
Similar to that plugin, it requires configuring both Neovim and Aerospace to work
in harmony.

## Configuring Neovim

Examples are for `lazy.nvim`, but should be similar for your favorite package manager.
Choose the bindings that work best for you; these are simply my preferences.

> [!NOTE]
> To use `CTRL-l` seamlessly, you'll need to configure your terminal emulator to use
> another sequence for clearing the screen. I use `keybind = cmd+l=text:\x0C` in
> Ghostty.
> 
> This by itself is probably reason to use an alternative.

```lua
return {
    {
        'coxley/aerospace-focus.nvim',
        -- Required when sharing the same keybinds as aerospace, as it will swallow the
        -- keypress before lazy.nvim has a chance to load the plugin.
        lazy = false, 
        keys = {
            { "<C-h>", ":AeroSpaceFocus left<CR>",  noremap = true, silent = true },
            { "<C-j>", ":AeroSpaceFocus down<CR>",  noremap = true, silent = true },
            { "<C-k>", ":AeroSpaceFocus up<CR>",    noremap = true, silent = true },
            { "<C-l>", ":AeroSpaceFocus right<CR>", noremap = true, silent = true },
        },
    }
}
```

Additional arguments can be passed through to `aerospace focus`:

```lua
return {
    {
        'coxley/aerospace-focus.nvim',
        lazy = false,
        opts = {
            extra_argv = {
                '--boundaries-action',
                'wrap-around-the-workspace'
            },
        },
        keys = {
            { "<C-h>", ":AeroSpaceFocus left<CR>",  noremap = true, silent = true },
            { "<C-j>", ":AeroSpaceFocus down<CR>",  noremap = true, silent = true },
            { "<C-k>", ":AeroSpaceFocus up<CR>",    noremap = true, silent = true },
            { "<C-l>", ":AeroSpaceFocus right<CR>", noremap = true, silent = true },
        },
    }
}
```

## Configuring AeroSpace

The plugin generates a script when configured that contextually decides whether to
navigate within Neovim or AeroSpace. Configure the same keybinds to call it.

```toml
[mode.main.binding]
    ctrl-h = 'exec-and-forget ~/.local/state/nvim/aerospace-focus/move.sh left'
    ctrl-j = 'exec-and-forget ~/.local/state/nvim/aerospace-focus/move.sh down'
    ctrl-k = 'exec-and-forget ~/.local/state/nvim/aerospace-focus/move.sh up'
    ctrl-l = 'exec-and-forget ~/.local/state/nvim/aerospace-focus/move.sh right'
```

## Debugging

Run `:checkhealth aerospace-focus` from within Neovim. Submit an issue if you think the
plugin could fix it. Ideally, the plugin becomes a no-op if AeroSpace isn't functional.
