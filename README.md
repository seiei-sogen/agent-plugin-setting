# agent-plugin-setting
agent-plugin-setting

Claude Code のプラグインと [seiei-sogen/agent-skills](https://github.com/seiei-sogen/agent-skills) のスキルをまとめて入れるスキル `cc-init-plugin-install` を、Claude Code のプラグインとして配る。

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
入れるプラグインとスキルの一覧は `scripts/install-claude-code-plugins-and-skills.sh` の先頭にある。
