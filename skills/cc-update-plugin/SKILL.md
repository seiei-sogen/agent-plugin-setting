---
name: cc-update-plugin
description: Claude Code のプラグイン（pstack、superpowers、mattpocock-skills、ponytail、このプラグイン自身）と seiei-sogen/agent-skills のスキルを、リポジトリのスクリプトで最新にする。プラグインやスキルを更新したい、最新にしたいと言われたときに使う。
---

# Claude Code のプラグインとスキルを最新にする

このプラグインの `scripts/update-claude-code-plugins-and-skills.sh` を実行し、結果を報告する。
スクリプトは、インストール用のスクリプトで足りないプラグインを入れてスキルを置き換えたあと、一覧のプラグインとこのプラグイン自身を更新する。
一覧は `scripts/claude-code-plugins.sh` にある。

## 手順

1. スクリプトを1回実行する。

   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-claude-code-plugins-and-skills.sh"
   ```

   何度実行してもよい。

2. 終了コードが 0 でなければ、失敗したコマンドとその出力を報告して終える。

3. 成功したら、スクリプトの出力から次を報告する。

   - 更新したプラグインと、その版の変化。
     `Plugin "<名前>" updated from <旧版> to <新版>` の行に出る。
     `is already at the latest version` の行は、更新がなかったプラグイン。
   - スキルの置き場に入った個数（`… 個を … に入れた。` の行）。
   - スクリプトが出した「警告:」の行。
     読み方は `${CLAUDE_PLUGIN_ROOT}/skills/cc-init-plugin-install/SKILL.md` の「警告の読み方」にある。
     「取得し直せなかったマーケットプレイスがある」は、そこから入れたプラグインが古いままかもしれないという意味。

4. 最後に、ユーザーに `/reload-plugins` の実行を頼む。
   プラグインは、起動済みのセッションには `/reload-plugins` を実行するまで反映されない。
   これはユーザーが入力するコマンドで、シェルからは実行できない。

5. このプラグインで一覧を変えた場合は、次の実行から効くと伝える。
   スクリプトは更新前のこのプラグインの一覧を読み、このプラグインの更新を最後に行うため。
