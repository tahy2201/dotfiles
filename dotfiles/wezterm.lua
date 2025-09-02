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

-- 手動設定されたタブ名を管理
local manual_tab_names = {}

-- タブリネームイベントハンドラー
wezterm.on('rename-tab', function(window, pane)
    local choices = {
        { id = '🏠 Home', label = '🏠 Home' },
        { id = '💼 Work', label = '💼 Work' },
        { id = '🛠️ Dev', label = '🛠️ Dev' },
        { id = '🧪 Test', label = '🧪 Test' },
        { id = '🐛 Debug', label = '🐛 Debug' },
        { id = '🔨 Build', label = '🔨 Build' },
        { id = '📝 Logs', label = '📝 Logs' },
        { id = '📊 Monitor', label = '📊 Monitor' },
        { id = '🌐 Server', label = '🌐 Server' },
        { id = '📱 Mobile', label = '📱 Mobile' },
        { id = 'backend', label = 'backend' },
        { id = 'frontend', label = 'frontend' },
        { id = 'database', label = 'database' },
        { id = 'api', label = 'api' },
        { id = 'docker', label = 'docker' },
        { id = 'config', label = 'config' },
        { id = 'deploy', label = 'deploy' },
        { id = 'local', label = 'local' },
        { id = 'staging', label = 'staging' },
        { id = 'prod', label = 'prod' }
    }
    
    window:perform_action(wezterm.action.InputSelector {
        title = 'Choose tab name',
        choices = choices,
        fuzzy = true,
        action = wezterm.action.EmitEvent('set-tab-name')
    }, pane)
end)

-- タブ名設定イベントハンドラー
wezterm.on('set-tab-name', function(window, pane, id, label)
    if label then
        local tab = window:active_tab()
        local tab_id = tostring(tab.tab_id)
        manual_tab_names[tab_id] = label
        tab:set_title(label)
    end
end)

-- タブの表示をカスタマイズ
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local tab_index = tab.tab_index + 1
  local tab_id = tostring(tab.tab_id)
  
  -- Copymode時のみ、"Copymode..."というテキストを表示
  if tab.is_active and string.match(tab.active_pane.title, 'Copy mode:') ~= nil then
    return string.format(' %d %s ', tab_index, 'Copy mode...')
  end
  
  -- 手動設定された名前があれば最優先で使用
  local manual_title = manual_tab_names[tab_id]
  if manual_title and manual_title ~= '' then
    return string.format(' %d:%s ', tab_index, manual_title)
  end
  
  -- それ以外はアクティブペインのタイトルを使用（weztermのデフォルト動作）
  if tab.active_pane.title and tab.active_pane.title ~= '' then
    return string.format(' %d:%s ', tab_index, tab.active_pane.title)
  end
  
  return string.format(' %d ', tab_index)
end)

-- タブが閉じられたときに名前をクリーンアップ
wezterm.on('window-close-tab', function(window, tab)
  local tab_id = tostring(tab.tab_id)
  manual_tab_names[tab_id] = nil
end)

-- ステータスバーの右側に存在するワークスペースを全部表示して、アクティブなやつを強調表示しますわよ！
wezterm.on('update-right-status', function(window, pane)
    -- 現在アクティブなワークスペース名を取得しますの
    local active_workspace = window:active_workspace() or "default"
    -- 存在するワークスペース名を全部取得しますの
    local all_workspaces = wezterm.mux.get_workspace_names() or {}

    -- もしワークスペースリストが空なら、現在のワークスペースを追加
    if #all_workspaces == 0 then all_workspaces = {active_workspace} end

    -- 名前順にソート
    table.sort(all_workspaces)

    -- 全ワークスペースをカンマ区切りで結合
    local all_workspaces_text = table.concat(all_workspaces, ', ')

    -- 指定されたフォーマットで組み立て
    local status_text = string.format('workspace: %s | all workspace: %s ',
                                      active_workspace, all_workspaces_text)

    window:set_right_status(status_text)
end)
-- 1秒ごとにステータスを更新するように設定しますの
config.status_update_interval = 1000

-- デフォルトで起動するプログラムを設定（自動ログ付き）
config.default_prog = {
    '/bin/zsh', 
    '-l',
    '-c', 
    'mkdir -p ~/wezterm_logs && echo "🎯 自動ログ開始: $(LC_TIME=C date)" && exec script -q ~/wezterm_logs/session_$(date +%Y%m%d_%H%M%S).log'
}

return config

