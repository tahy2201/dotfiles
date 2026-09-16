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
-- 英数は JetBrains Mono、日本語はヒラギノに落とす
-- 指定しないと macOS が韓国語用の Apple SD Gothic Neo を拾ってしまう
-- 日本語を DemiBold にしているのは英数の Medium と太さの印象を揃えるため
config.font = wezterm.font_with_fallback {
    { family = 'JetBrains Mono', weight = 'Medium' },
    { family = 'Hiragino Kaku Gothic ProN', weight = 'DemiBold' },
}

-- 背景の非透過率（1なら完全に透過させない）
config.window_background_opacity = 1

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
    },
    -- workspace の前後移動
    -- 括弧類は macOS だと SHIFT 込みで別の文字として届き、wezterm 既定の
    -- タブ切り替えに先に拾われるため使わない
    {
        key = ",",
        mods = "CMD",
        action = wezterm.action.SwitchWorkspaceRelative(-1)
    },
    {
        key = ".",
        mods = "CMD",
        action = wezterm.action.SwitchWorkspaceRelative(1)
    },
    -- workspace 一覧
    {
        key = "l",
        mods = "CMD",
        action = wezterm.action.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' }
    },
    -- それ以外の workspace 操作はキーテーブルに集約する
    {
        key = "s",
        mods = "CMD",
        action = wezterm.action.ActivateKeyTable {
            name = 'workspace_mode',
            one_shot = false,
            timeout_milliseconds = 3000,
        }
    }
}

-- CMD+S の後に押すキー。n:新規 r:改名
-- 切替と一覧は CMD+, / CMD+. / CMD+L、閉じるは CMD+W
config.key_tables = {
    workspace_mode = {
        {
            key = "n",
            action = wezterm.action.PromptInputLine {
                description = 'workspace 名',
                action = wezterm.action_callback(function(win, pane, line)
                    if line and line ~= '' then
                        win:perform_action(wezterm.action.SwitchToWorkspace { name = line }, pane)
                    end
                end),
            }
        },
        {
            key = "r",
            action = wezterm.action.PromptInputLine {
                description = 'workspace の新しい名前',
                action = wezterm.action_callback(function(win, pane, line)
                    if line and line ~= '' then
                        wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
                    end
                end),
            }
        },
        { key = "Escape", action = wezterm.action.PopKeyTable },
    },
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

-- セクションに関数を直接置くと tabline の padding オプションが効かない
-- （プラグイン側が create_component を通さず Text をそのまま使うため）ので、
-- 前後の余白は自前で付ける
local function pad(text)
    if text == '' then
        return ''
    end
    return ' ' .. text .. ' '
end

-- workspace 一覧。並び順は名前順で固定し、現在地は色だけで示す
-- （現在のものを別セクションへ移すと切り替えのたびに位置がずれて分かりにくい）
local function workspace_list()
    local active = wezterm.mux.get_active_workspace()
    local names = wezterm.mux.get_workspace_names()
    table.sort(names)
    local elems = {}
    table.insert(elems, { Text = ' ' })
    for i, name in ipairs(names) do
        if i > 1 then
            table.insert(elems, { Foreground = { Color = '#5a5a5a' } })
            table.insert(elems, { Text = '  ' })
        end
        if name == active then
            -- タブのアクティブ色(#59c2c6)と workspace_mode(#f0a500) のどちらとも
            -- 被らない色を選ぶ
            table.insert(elems, { Foreground = { Color = '#f0f0f0' } })
            table.insert(elems, { Background = { Color = '#8b5cf6' } })
            table.insert(elems, { Attribute = { Intensity = 'Bold' } })
            table.insert(elems, { Text = ' ' .. name .. ' ' })
        else
            table.insert(elems, { Foreground = { Color = '#8a8a8a' } })
            table.insert(elems, { Background = { Color = '#1c1c1c' } })
            table.insert(elems, { Attribute = { Intensity = 'Normal' } })
            table.insert(elems, { Text = ' ' .. name .. ' ' })
        end
    end
    table.insert(elems, { Text = ' ' })
    return wezterm.format(elems)
end

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
            -- workspace_mode 中はタブバーの色が変わる（入ったことが一目で分かる）
            workspace_mode = {
                a = { fg = "#091833", bg = "#f0a500" },
                b = { fg = "#f0a500", bg = "#3a3a3a" },
                c = { fg = "#f0a500", bg = "#1c1c1c" },
            },
        },
    },
    sections = {
        tabline_a = { "mode" },
        tabline_b = { workspace_list },
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

