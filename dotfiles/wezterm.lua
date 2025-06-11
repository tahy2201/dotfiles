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
}

-- タブの表示をカスタマイズ
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local tab_index = tab.tab_index + 1

  -- Copymode時のみ、"Copymode..."というテキストを表示
  if tab.is_active and string.match(tab.active_pane.title, 'Copy mode:') ~= nil then
    return string.format(' %d %s ', tab_index, 'Copy mode...')
  end

  return string.format(' %d ', tab_index)
end)

return config

