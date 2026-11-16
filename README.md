# agent-plugin-setting
agent-plugin-setting

Claude Code のプラグインと [seiei-sogen/agent-skills](https://github.com/seiei-sogen/agent-skills) のスキルをまとめて入れるスキル `cc-init-plugin-install` と、最新にするスキル `cc-update-plugin` を、Claude Code のプラグインとして配る。

## 入れ方

```bash
claude plugin marketplace add seiei-sogen/agent-plugin-setting
claude plugin install agent-plugin-setting@agent-plugin-setting
```

1行で入れるなら、次のとおり。

```bash
claude plugin install agent-plugin-setting --marketplace seiei-sogen/agent-plugin-setting --scope user
```

起動済みのセッションに反映するには、そのセッションで `/reload-plugins` を実行する。

## 使い方

Claude Code のセッションで `/agent-plugin-setting:cc-init-plugin-install` を実行する。
入れたプラグインとスキルを最新にするには、`/agent-plugin-setting:cc-update-plugin` を実行する。
入れるプラグインの一覧は `scripts/claude-code-plugins.sh` にある。
