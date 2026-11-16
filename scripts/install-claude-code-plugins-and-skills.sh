#!/usr/bin/env bash
# Claude Code のプラグインとスキルを、利用者の設定ディレクトリ（既定は ~/.claude）に入れる。
#
# 入れたものは、次に起動した Claude Code のセッションから使える。
# 起動済みのセッションに反映するには、そのセッションで /reload-plugins を実行する。
# 何度実行してもよい。入っているものは入れ直さず、スキルは最新の内容で置き換える。
#
# クラウドのセッションでは、環境のセットアップスクリプトからこのスクリプトを呼ぶ。
# セットアップスクリプトは Claude Code の起動前に走るので、最初のターンから使える。
set -euo pipefail
# macOS の bash 3.2 と BSD find でも動くよう、mapfile・連想配列・find -printf を使わない。
# bash 3.2 の set -u は空の配列の "${a[@]}" をエラーにするので、${a[@]+"${a[@]}"} と書く。

# shellcheck source=SCRIPTDIR/claude-code-plugins.sh
source "$(dirname "${BASH_SOURCE[0]}")/claude-code-plugins.sh"

# スキルを並べただけのリポジトリ。マーケットプレイスではないので、スキルの置き場へ複写する。
skill_collection_repository_url="https://github.com/seiei-sogen/agent-skills"
# skills/ の直下にあるグループのうち、入れないもの。
skill_collection_excluded_group_names=("anma-tsukatte-nai")

claude_skills_directory="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills"
# このスクリプトが置いたディレクトリの目印。目印のないディレクトリは、利用者のものとして触らない。
installed_marker_file_name=".installed-from-skill-collection-repository"

for marketplace_source_and_plugin_name in "${marketplace_sources_and_plugin_names[@]}"; do
  read -r marketplace_source plugin_name <<<"$marketplace_source_and_plugin_name"
  claude plugin install "$plugin_name" --marketplace "$marketplace_source" --scope user
done

skill_collection_checkout_directory="$(mktemp -d)"
trap 'rm -rf "$skill_collection_checkout_directory"' EXIT
git clone --quiet --depth 1 "$skill_collection_repository_url" "$skill_collection_checkout_directory"

excluded_group_find_arguments=()
for excluded_group_name in ${skill_collection_excluded_group_names[@]+"${skill_collection_excluded_group_names[@]}"}; do
  excluded_group_find_arguments+=(-not -path "$skill_collection_checkout_directory/skills/$excluded_group_name/*")
done

# プラグインの形をしたもの（.claude-plugin/plugin.json を持つ）は、ディレクトリごと置く。
# スキルの置き場に置いたプラグインは、Claude Code が <名前>@skills-dir として読み込む。
# それ以外は、SKILL.md を持つディレクトリを、グループの階層を外して置き場の直下に並べる。
plugin_shaped_directories=()
while IFS= read -r plugin_shaped_directory; do
  plugin_shaped_directories+=("$plugin_shaped_directory")
done < <(
  find "$skill_collection_checkout_directory/skills" ${excluded_group_find_arguments[@]+"${excluded_group_find_arguments[@]}"} \
    -path '*/.claude-plugin/plugin.json' | sed 's|/\.claude-plugin/plugin\.json$||' | sort
)
plugin_shaped_find_arguments=()
for plugin_shaped_directory in ${plugin_shaped_directories[@]+"${plugin_shaped_directories[@]}"}; do
  plugin_shaped_find_arguments+=(-not -path "$plugin_shaped_directory/*")
done
plain_skill_directories=()
while IFS= read -r plain_skill_directory; do
  plain_skill_directories+=("$plain_skill_directory")
done < <(
  find "$skill_collection_checkout_directory/skills" ${excluded_group_find_arguments[@]+"${excluded_group_find_arguments[@]}"} \
    ${plugin_shaped_find_arguments[@]+"${plugin_shaped_find_arguments[@]}"} -name SKILL.md | sed 's|/SKILL\.md$||' | sort
)

mkdir -p "$claude_skills_directory"
# 入れたものの「名前<TAB>リポジトリ内のパス」を1行ずつ持つ。
installed_names_and_sources=""
installed_count=0
for source_directory in ${plugin_shaped_directories[@]+"${plugin_shaped_directories[@]}"} \
  ${plain_skill_directories[@]+"${plain_skill_directories[@]}"}; do
  installed_name="$(basename "$source_directory")"
  source_path_in_repository="${source_directory#"$skill_collection_checkout_directory"/}"
  destination_directory="$claude_skills_directory/$installed_name"

  first_installed_source="$(printf '%s' "$installed_names_and_sources" |
    awk -F '\t' -v name="$installed_name" '$1 == name { print $2; exit }')"
  if [[ -n "$first_installed_source" ]]; then
    echo "警告: $source_path_in_repository は入れない。同じ名前の" \
      "$first_installed_source を先に入れた。" >&2
    continue
  fi
  if [[ -e "$destination_directory" && ! -e "$destination_directory/$installed_marker_file_name" ]]; then
    echo "警告: $source_path_in_repository は入れない。" \
      "$destination_directory が既にあり、このスクリプトが置いたものではない。" >&2
    continue
  fi

  rm -rf "$destination_directory"
  cp -R "$source_directory" "$destination_directory"
  echo "$source_path_in_repository" >"$destination_directory/$installed_marker_file_name"
  installed_names_and_sources+="$installed_name"$'\t'"$source_path_in_repository"$'\n'
  installed_count=$((installed_count + 1))
done

echo "$skill_collection_repository_url から $installed_count 個を $claude_skills_directory に入れた。"
