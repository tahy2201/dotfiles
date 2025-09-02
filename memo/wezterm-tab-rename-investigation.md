# wezterm タブ名直接入力ができない問題の調査結果

## 🔍 調査概要

weztermでタブ名を直接入力（任意の文字列）で変更しようとした際に発生した問題と、その調査結果をまとめる。

## 📋 試行した方法と結果

### 1️⃣ PromptInputLine + action_callback ❌

```lua
wezterm.action.PromptInputLine {
    description = 'Enter new name for tab',
    action = wezterm.action_callback(function(window, pane, line)
        if line then
            local tab = window:active_tab()
            local tab_id = tostring(tab.tab_id)
            manual_tab_names[tab_id] = line
            tab:set_title(line)
        end
    end)
}
```

**結果**: コールバック関数が**一切実行されない**
- **症状**: プロンプトは表示されるが、入力後のコールバックが呼ばれない
- **ログ**: 「CALLBACK TRIGGERED」メッセージが出力されない
- **キーバインド**: `Cmd + Shift + E` で試行

### 2️⃣ InputSelector + action_callback ❌

```lua  
wezterm.action.InputSelector {
    title = 'Choose tab name',
    choices = { ... },
    fuzzy = true,
    action = wezterm.action_callback(function(window, pane, id, label)
        -- 処理内容
    end)
}
```

**結果**: 同様にコールバック関数が実行されない
- **症状**: 選択UIは表示されるが、選択後の処理が動作しない
- **キーバインド**: `Cmd + Alt + T` で試行

### 3️⃣ 直接的なaction_callback ❌

```lua
{
    key = "1", 
    mods = "CMD|ALT",
    action = wezterm.action_callback(function(window, pane)
        wezterm.log_info('*** DIRECT CALLBACK TEST TRIGGERED ***')
        -- テスト処理
    end)
}
```

**結果**: キーバインド自体が機能しない
- **症状**: 「DIRECT CALLBACK TEST TRIGGERED」ログが出力されない
- **推測**: `wezterm.action_callback` 自体が動作していない

### 4️⃣ EmitEvent + wezterm.on ✅ **成功！**

```lua
-- キーバインド
{
    key = "1",
    mods = "CMD|ALT", 
    action = wezterm.action.EmitEvent('rename-tab')
}

-- イベントハンドラー
wezterm.on('rename-tab', function(window, pane)
    wezterm.log_info('*** RENAME-TAB EVENT TRIGGERED ***')
    local tab = window:active_tab()
    local tab_id = tostring(tab.tab_id)
    local test_name = "TestName"
    manual_tab_names[tab_id] = test_name
    tab:set_title(test_name)
end)
```

**結果**: 正常に動作！
- **症状**: ログ出力され、タブ名変更が成功
- **ログ確認**: `tail ~/.local/share/wezterm/wezterm-gui-log-15119.txt` で動作確認

## 🎯 根本原因の推定

### 主な問題
**`wezterm.action_callback` が全く機能していない**

### 考えられる原因

1. **weztermバージョンの問題**
   - 使用バージョン: `20240203-110809-5046fc22`
   - `PromptInputLine`導入バージョン: `20230408-112425-69ae8472`
   - バージョン間での不具合や仕様変更の可能性

2. **Luaの環境問題**
   - 設定ファイル内でのコールバック実行環境の制限
   - スコープや実行タイミングの問題

3. **macOS固有の問題**
   - Darwin環境での制約
   - システム固有の動作制限

## 💡 解決策

### 採用した回避策
**`EmitEvent` + `wezterm.on` の組み合わせ**を使用

```lua
-- 動作する方法
action = wezterm.action.EmitEvent('custom-event-name')
wezterm.on('custom-event-name', function(window, pane) ... end)
```

### 試行した外部解決策
- **AppleScript**: 動作するが大掛かりで不適切
- **外部コマンド**: 複雑性が高い

## ❓ 直接入力ができない理由

1. **PromptInputLine**: コールバックが動作しないため使用不可
2. **InputSelector**: 選択式UIの仕様上、任意文字の直接入力には対応していない
3. **外部ツール**: 技術的には可能だが、設定の複雑化を招く

## 📊 最終的な実装方針

### 実装した機能

#### 選択式タブリネーム ✅
- **基本セット**: `Cmd + Alt + T` (10個の選択肢)
- **拡張セット**: `Cmd + Alt + R` (20個の選択肢)
- **動作方式**: `EmitEvent` + `wezterm.on`
- **検索機能**: ファジー検索対応

#### タブ表示ロジック
```lua
-- 優先順位
1. 手動設定された名前 (manual_tab_names)
2. tab:set_title()で設定した名前 (tab.tab_title)
3. アクティブペインのタイトル (tab.active_pane.title)
4. 番号のみ (フォールバック)
```

#### その他の機能
- **タブ移動**: `Cmd + Alt + ←/→` でタブの順番入れ替え
- **デバッグログ**: 動作確認用のログ出力

### 制限事項
- **任意文字直接入力**: ❌ weztermの制約により実現困難
- **回避策**: 豊富な選択肢（20個）で大部分のニーズをカバー

## 📝 技術的な学び

1. **weztermのバージョン依存**: 特定機能が環境によって動作しない場合がある
2. **回避策の重要性**: `EmitEvent`による間接実行が有効
3. **ログ活用**: `wezterm.log_info()`による動作確認が重要
4. **段階的デバッグ**: シンプルな機能から複雑な機能へ段階的に検証

## 🔗 関連情報

- **weztermバージョン**: `20240203-110809-5046fc22`
- **設定ファイル**: `~/.config/wezterm/wezterm.lua`
- **ログファイル**: `~/.local/share/wezterm/wezterm-gui-log-*.txt`
- **参考ドキュメント**: https://wezterm.org/config/lua/keyassignment/PromptInputLine.html

---

**調査日**: 2025-09-02  
**調査者**: Claude (Anthropic)  
**環境**: macOS, wezterm 20240203-110809-5046fc22