# 优化技术文档

## 目标

本次优化覆盖后端配置体系、桌面端和 Android 端本地网络访问、App 用户与 Admin 用户隔离、数据库迁移和 Admin 菜单权限完善。

## 当前问题

- 后端配置写在代码默认值和环境变量中，缺少统一配置结构，环境切换不清晰。
- Flutter mobile 固定请求 `http://127.0.0.1:8080`，Android 模拟器访问的是模拟器自身，无法访问宿主机服务。
- macOS 桌面端在后端只监听或客户端地址配置不合理时，容易出现本地服务不可达。
- 当前已经存在 `admin_users` 和 `mobile_users`，但命名、迁移和后续扩展需要统一到 App/Admin 两类用户的边界。
- Admin 端菜单已有用户、角色、菜单管理，需要补齐 App 用户管理入口和后端接口，确保后台用户与 App 用户分开维护。

## 后端配置方案

新增 `backend/internal/config` 包，负责加载和归一化配置。

配置文件目录：

```text
backend/configs/
├── local.yml
├── dev.yml
└── prod.yml
```

环境选择规则：

- 默认环境为 `local`。
- 通过 `APP_ENV` 指定 `local`、`dev` 或 `prod`。
- 通过 `CONFIG_FILE` 指定完整配置文件路径时，优先使用该文件。
- 保留关键环境变量覆盖能力，便于容器和 CI 注入密钥。

配置结构：

```yaml
server:
  host: "0.0.0.0"
  port: 8080
database:
  dsn: "host=localhost port=5432 user=japanese_learning password=japanese_learning_password dbname=japanese_learning_app sslmode=disable TimeZone=Asia/Shanghai"
minio:
  endpoint: "localhost:9000"
  accessKey: "japanese_learning"
  secretKey: "japanese_learning_password"
  useSSL: false
  avatarBucket: "japanese-learning-avatars"
cors:
  allowOrigins:
    - "*"
  allowHeaders:
    - "Content-Type"
    - "Authorization"
  allowMethods:
    - "GET"
    - "POST"
    - "PUT"
    - "DELETE"
    - "OPTIONS"
```

代码调整：

- `cmd/server/main.go` 加载配置并按 `server.host/server.port` 启动。
- `store.Init` 接收数据库和 MinIO 配置，不再依赖散落的默认常量。
- `server.NewRouter` 接收 CORS 配置。

## 本地网络访问方案

后端本地默认监听 `0.0.0.0:8080`，让 macOS、Android 模拟器和同网段真机都能访问宿主机服务。

Flutter mobile API 地址选择：

- 编译参数 `--dart-define=API_BASE_URL=...` 优先级最高。
- Android 默认使用 `http://10.0.2.2:8080`。
- macOS、iOS、Windows、Linux、Web 默认使用 `http://127.0.0.1:8080`。
- 真机调试时使用宿主机局域网 IP，例如：

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080
```

## 用户隔离与命名方案

数据模型按业务端拆分：

- Admin 用户：后台登录、后台权限、角色、菜单。
- App 用户：移动端登录和 App 业务用户资料。

数据库：

- 保留并继续使用 `admin_users`。
- 将现有 `mobile_users` 迁移为 `app_users`。
- 为兼容已有数据，迁移脚本会从 `mobile_users` 复制数据到 `app_users`，再由代码使用 `app_users`。

接口：

```text
POST   /api/admin/login
POST   /api/mobile/login
GET    /api/admin/users
POST   /api/admin/users
PUT    /api/admin/users/{id}
DELETE /api/admin/users/{id}
GET    /api/admin/app-users
POST   /api/admin/app-users
PUT    /api/admin/app-users/{id}
DELETE /api/admin/app-users/{id}
```

## 菜单与权限方案

新增 Admin 菜单：

- `移动端管理`，路径 `/mobile`。
- `App用户`，路径 `/mobile/app-user`，作为 `移动端管理` 的子菜单。

新增按钮权限：

- `app-user:create`
- `app-user:edit`
- `app-user:delete`

迁移脚本负责：

- 创建 `app_users`。
- 复制旧 `mobile_users` 数据。
- 插入 App 用户管理菜单和按钮权限。
- 更新超级管理员角色菜单集合。

Admin 前端调整：

- 新增 App 用户管理页签。
- 后台用户页签继续只操作 `admin_users`。
- App 用户页签只操作 `app_users`。

## 执行步骤

1. 新增技术文档。
2. 新增后端配置包和 `local/dev/prod` 配置。
3. 改造后端启动、数据库、MinIO 和 CORS 初始化。
4. 新增 `app_users` 迁移、后端模型和 Admin App 用户 CRUD 接口。
5. 完善 Admin 端 App 用户管理入口。
6. 修复 Flutter mobile 平台默认 API 地址。
7. 运行格式化、后端测试、Admin 构建，并尽量执行 Flutter 静态检查。

## 验收标准

- `APP_ENV=local go run ./cmd/server` 能从 `local.yml` 启动。
- 后端启动地址为 `0.0.0.0:8080`，桌面端可访问 `127.0.0.1:8080`。
- Android 模拟器默认请求 `10.0.2.2:8080`。
- Admin 用户和 App 用户分别登录、分别管理。
- Admin 超级管理员可看到 App 用户管理入口，并具备新增、编辑、删除权限。
- `go test ./...` 和 Admin 构建通过。
