# Codex Skills 同步说明

项目内共享 skill 位于：

```text
.codex/skills/
├── flutter-cn-mirror-deps/
└── go-local-proxy-deps/
```

只放在项目内不会被 Codex 自动识别。需要同步到本机 Codex skills 目录：

```bash
./scripts/sync-codex-skills.sh
```

脚本会同步到：

```text
${CODEX_HOME:-$HOME/.codex}/skills
```

同步后需要重启 Codex 才能加载新 skill。
