# shellcheck shell=bash disable=SC2034
# 入れるプラグインの一覧。インストールと更新の両方のスクリプトが source で読む。

# 「マーケットプレイスの取得元 プラグイン名」の組。
# pstack は cursor/plugins の harness/pstack/claude-code（Claude Code 向けの生成版）が入る。
marketplace_sources_and_plugin_names=(
  "cursor/plugins pstack"
  "obra/superpowers superpowers"
  "mattpocock/skills mattpocock-skills"
  "dietrichgebert/ponytail ponytail"
)
