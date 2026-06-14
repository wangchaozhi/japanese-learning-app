# VS Code 启动脚本与依赖镜像 Skill 技术文档

## 目标

本次优化新增三类开发辅助能力：

- 为 VS Code 提供后端按指定 yml 启动的脚本。
- 为 VS Code 提供 Admin 端启动脚本。
- 创建两个 Codex skills，分别规范 Flutter 依赖下载国内镜像源和 Go 依赖下载本地代理。

## VS Code 后端启动方案

后端已经支持通过 `CONFIG_FILE` 指定配置文件。本次 VS Code 配置基于该能力提供三套启动入口：

- Backend: Run Local YML
- Backend: Run Dev YML
- Backend: Run Prod YML

每个任务执行：

```bash
go run ./cmd/server
```

并注入：

```text
APP_ENV=local|dev|prod
CONFIG_FILE=${workspaceFolder}/backend/configs/local.yml|dev.yml|prod.yml
```

同时在 `launch.json` 中提供对应 Go 调试配置，便于断点调试。

## VS Code Admin 启动方案

Admin 端提供两个任务：

- Admin: npm install
- Admin: npm run dev

`Admin: npm run dev` 依赖 `Admin: npm install`，确保缺少 `node_modules` 时可以直接启动。

## Flutter 国内镜像 Skill

新增 skill：`flutter-cn-mirror-deps`

触发场景：

- 下载 Flutter/Dart 依赖。
- 执行 `flutter pub get`、`flutter pub upgrade`。
- 用户明确要求使用国内 Flutter 镜像源。

执行约定：

```bash
PUB_HOSTED_URL=https://pub.flutter-io.cn \
FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn \
flutter pub get
```

优先使用命令级环境变量，不默认写入全局 shell 配置，避免污染用户环境。

## Go 本地代理 Skill

新增 skill：`go-local-proxy-deps`

触发场景：

- 下载 Go 依赖。
- 执行 `go mod download`、`go mod tidy`、`go get`。
- 用户明确要求通过本地 `127.0.0.1:8080` 代理下载 Go 模块。

执行约定：

```bash
GOPROXY=http://127.0.0.1:8080,direct go mod download
```

优先使用命令级环境变量，不默认修改 `go env -w`，避免影响其他项目。

## 验收标准

- VS Code 可以通过任务运行后端 local/dev/prod yml。
- VS Code 可以通过任务启动 Admin dev server。
- VS Code 可以通过 Go launch 配置调试后端。
- `~/.codex/skills/flutter-cn-mirror-deps/SKILL.md` 存在且包含国内镜像下载规则。
- `~/.codex/skills/go-local-proxy-deps/SKILL.md` 存在且包含本地 Go proxy 下载规则。
