-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
    config = wezterm.config_builder()
end


-- ここまでは定型文
-- この先でconfigに各種設定を書いていく

-- フォント
config.font_size = 12.0
config.font = wezterm.font('JetBrains Mono', { weight = 'Bold' })

-- 背景の非透過率（1なら完全に透過させない）
config.window_background_opacity = 0.90

-- タブバーも設定
config.enable_tab_bar = true
config.color_scheme = 'Qualia (base16)'

-- アクティブなペインをわかりやすくする設定
config.inactive_pane_hsb = {
    saturation = 1.0,
    brightness = 0.2,
}

-- キーバインド
config.keys = {

    -- Command+Dで横にペイン分割
    {
        key = "d",
        mods = "CMD",
        action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" }
    },
    -- Command+Shift+Dで縦にペイン分割
    {
        key = "d",
        mods = "CMD|SHIFT",
        action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" }
    },
    -- [で前のペインに移動
    {
        key = "[",
        mods = "CMD",
        action = wezterm.action.ActivatePaneDirection "Prev"
    },
    -- ]で次のペインに移動
    {
        key = "]",
        mods = "CMD",
        action = wezterm.action.ActivatePaneDirection "Next"
    },
    -- Command+Wで現在のペインを閉じる
    {
        key = "w",
        mods = "CMD",
        action = wezterm.action.CloseCurrentPane { confirm = true }
    },
    -- Command+Qでweztermを終了
    {
        key = "q",
        mods = "CMD",
        action = wezterm.action.QuitApplication
    },
    -- Command+Rでweztermを再起動
    {
        key = "r",
        mods = "CMD",
        action = wezterm.action.ReloadConfiguration
    },
    -- quick select
    {
        key = "c",
        mods = "CTRL|SHIFT",
        action = wezterm.action.QuickSelect,
    },
    -- 30行上に移動
    {
        key = "UpArrow",
        mods = "CMD|SHIFT",
        action = wezterm.action.ScrollByLine(-30)
    },
    -- 30行下に移動
    {
        key = "DownArrow",
        mods = "CMD|SHIFT",
        action = wezterm.action.ScrollByLine(30)
    },
    -- タブを左に移動
    {
        key = "LeftArrow",
        mods = "CMD|ALT",
        action = wezterm.action.MoveTabRelative(-1)
    },
    -- タブを右に移動
    {
        key = "RightArrow",
        mods = "CMD|ALT",
        action = wezterm.action.MoveTabRelative(1)
    },
    -- タブ名を変更
    {
        key = "t",
        mods = "CMD|ALT",
        action = wezterm.action.EmitEvent('rename-tab')
    }
}

-- デフォルトで起動するプログラムを設定. claude codeの表示が壊れるのでコメントアウト
-- config.default_prog = {
--     '/bin/zsh', 
--     '-l',
--     '-c', 
--     'mkdir -p ~/wezterm_logs && echo "🎯 自動ログ開始: $(LC_TIME=C date)" && exec script -q ~/wezterm_logs/session_$(date +%Y%m%d_%H%M%S).log'
-- }

-- Tab bar
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.tab_max_width = 100

-- tabline.wez
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup({
    options = {
        theme = "Google Dark (Gogh)",
        section_separators = {
            left = wezterm.nerdfonts.ple_upper_left_triangle,
            right = wezterm.nerdfonts.ple_lower_right_triangle,
        },
        component_separators = {
            left = wezterm.nerdfonts.ple_forwardslash_separator,
            right = wezterm.nerdfonts.ple_forwardslash_separator,
        },
        tab_separators = {
            left = wezterm.nerdfonts.ple_upper_left_triangle,
            right = wezterm.nerdfonts.ple_lower_right_triangle,
        },
        -- color_overrides = {
        theme_overrides = {
            tab = {
                active = { fg = "#091833", bg = "#59c2c6" },
            },
        },
    },
    sections = {
        tab_active = {
            "index",
            { "process", padding = { left = 0, right = 1 } },
            "",
            { "cwd",     padding = { left = 1, right = 0 } },
            { "zoomed",  padding = 1 },
        },
        tab_inactive = {
            "index",
            { "process", padding = { left = 0, right = 1 } },
            "󰉋",
            { "cwd",     padding = { left = 1, right = 0 } },
            { "zoomed",  padding = 1 },
        },
    },
})

return config

