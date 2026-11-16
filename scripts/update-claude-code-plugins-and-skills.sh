#!/usr/bin/env bash
# Claude Code のプラグインとスキルを最新にする。
#
# 一覧のうち入っていないプラグインを入れ、スキルを最新の内容で置き換えたあと、一覧のプラグインとこのプラグインを更新する。
# このプラグインの更新は最後に行うので、このプラグインで変えた一覧は次の実行から効く。
# 起動済みのセッションに反映するには、そのセッションで /reload-plugins を実行する。
# 何度実行してもよい。
set -euo pipefail

script_directory="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=SCRIPTDIR/claude-code-plugins.sh
source "$script_directory/claude-code-plugins.sh"

bash "$script_directory/install-claude-code-plugins-and-skills.sh"

# claude plugin update は、最近取得したマーケットプレイスを取得し直さないので、先にすべて取得し直す。
# 一覧と関係のないマーケットプレイスで失敗しても、プラグインの更新は続ける。
claude plugin marketplace update || echo "警告: 取得し直せなかったマーケットプレイスがある。そこから入れたプラグインは更新されないことがある。" >&2

# 入れたときのマーケットプレイス名は取得元と違う（pstack@cursor-plugins など）ので、プラグイン名だけで指定する。
# 1つが失敗しても残りとこのプラグインの更新は続け、最後に失敗として終える。
update_failed=0
for marketplace_source_and_plugin_name in "${marketplace_sources_and_plugin_names[@]}"; do
  read -r _ plugin_name <<<"$marketplace_source_and_plugin_name"
  claude plugin update "$plugin_name" --scope user || update_failed=1
done

# 利用者がどのスコープに入れたか分からないので、スコープは Claude Code に探させる。
claude plugin update agent-plugin-setting || update_failed=1
exit "$update_failed"
