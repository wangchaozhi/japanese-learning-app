# japanese-learning-app

一个基于 Go 后端、React 管理端和 Flutter 移动端的日语学习项目起点。当前保留了账号、角色、菜单、按钮权限和头像等基础能力，并把移动端首页调整为日语学习场景。学习功能已落地**五十音练习**（平假名/片假名图浏览，清音/浊音/拗音分组 + 按组选择题测验）和**单词卡片**（N5 词库翻卡，前后切换，含例句，并支持看词选义的单词测验）。单词卡片支持**收藏与错题本**（星标收藏、测验答错自动收录），并可点喇叭朗读发音。**听力跟读**（听发音选释义）基于 TTS 实现。首页的**学习记录**（今日复习、连续学习天数、已学单词、N5 进度、每日目标进度）由本地学习行为实时统计，点右上角图标可查看近 14 天复习柱状图。后续可继续扩展课程和云端复习记录。

> 发音与听力依赖设备的日语 TTS 引擎（`flutter_tts`），需在真机上验证语音效果；模拟器或缺少日语语音包的设备可能无声。

## 项目结构

```text
.
├── docker-compose.yml                 # PostgreSQL + MinIO 本地开发环境
├── backend/                           # Go 后端模块
│   ├── go.mod / go.sum                # 后端依赖
│   ├── cmd/server/main.go             # Go 服务入口
│   └── internal/
│       ├── admin/                     # 管理端接口
│       ├── auth/                      # 登录接口
│       ├── server/                    # 路由和 CORS
│       └── store/                     # GORM、PostgreSQL、SQL 迁移
│           └── migrations/            # 模块化 SQL 迁移文件
├── front/admin/                       # React + TypeScript + Vite 学习运营后台
└── front/mobile/                      # Flutter 日语学习端
```

## 环境要求

- Docker / Docker Compose
- Go 1.26+
- Node.js 和 npm
- Flutter SDK 3.10+

## 启动 PostgreSQL 和 MinIO

```bash
docker compose up -d postgres minio
```

PostgreSQL 默认连接信息：

```text
host=localhost
port=5432
database=japanese_learning_app
user=japanese_learning
password=japanese_learning_password
```

后端默认会使用上面的连接。也可以通过 `DATABASE_DSN` 覆盖：

```bash
cd backend
DATABASE_DSN="host=localhost port=5432 user=japanese_learning password=japanese_learning_password dbname=japanese_learning_app sslmode=disable TimeZone=Asia/Shanghai" go run ./cmd/server
```

后端配置文件位于 `backend/configs/`，默认加载 `local.yml`。可通过 `APP_ENV` 切换环境：

```bash
cd backend
APP_ENV=local go run ./cmd/server
APP_ENV=dev go run ./cmd/server
APP_ENV=prod DATABASE_DSN="..." MINIO_ENDPOINT="..." MINIO_ACCESS_KEY="..." MINIO_SECRET_KEY="..." go run ./cmd/server
```

也可以通过 `CONFIG_FILE` 指定完整配置文件路径。服务本地默认监听 `0.0.0.0:8080`，便于桌面端、Android 模拟器和同网段真机访问。

MinIO 默认信息：

```text
API:     http://localhost:9000
Console: http://localhost:9001
user:    japanese_learning
password: japanese_learning_password
bucket:  japanese-learning-avatars
```

也可以通过环境变量覆盖：

```text
MINIO_ENDPOINT
MINIO_ACCESS_KEY
MINIO_SECRET_KEY
MINIO_USE_SSL
MINIO_AVATAR_BUCKET
```

## 启动后端

```bash
cd backend
go mod download
go run ./cmd/server
```

服务默认运行在：

```text
http://localhost:8080
```

首次启动会自动执行 `backend/internal/store/migrations/*.sql`。已执行版本记录在 `schema_migrations` 表中。
后端也会自动创建头像 bucket。用户主题、头像对象 key 和缩略图对象 key 由迁移文件写入 `admin_users` 扩展字段。

健康检查：

```text
GET /api/health
```

## 启动学习运营后台

```bash
cd front/admin
npm install
npm run dev
```

后台默认账号：

```text
admin / 123456
operator / 123456
```

`admin` 拥有全部菜单和按钮权限。按钮权限包括：

```text
user:create
user:edit
user:delete
role:create
role:edit
role:delete
menu:create
menu:edit
menu:delete
```

## 启动日语学习端

```bash
cd front/mobile
flutter pub get
flutter run
```

学习端默认账号：

```text
user / 123456
```

学习端 API 地址支持平台默认值和编译参数覆盖：

```text
Android 模拟器: http://10.0.2.2:8080
macOS/iOS/Windows/Linux/Web: http://127.0.0.1:8080
```

真机调试时传入宿主机局域网 IP：

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080
```

Release CI 构建 Android APK 时会通过 `--dart-define` 固定 API 地址。默认值是：

```text
http://192.168.1.23:8080
```

如需调整，在 GitHub 仓库变量中设置 `MOBILE_API_BASE_URL`。如果要让 CI 产物使用正式 release 签名，在 GitHub Secrets 中配置：

```text
ANDROID_KEYSTORE_BASE64
ANDROID_KEYSTORE_PASSWORD
ANDROID_KEY_ALIAS
ANDROID_KEY_PASSWORD
```

其中 `ANDROID_KEYSTORE_BASE64` 是 `.jks` 文件的 Base64 内容；未配置完整 secrets 时，CI 会回退到 debug 签名，方便继续生成测试 APK。

## 后端接口

```text
POST   /api/admin/login
GET    /api/admin/profile
PUT    /api/admin/profile/theme
POST   /api/admin/profile/avatar
GET    /api/admin/profile/assets/avatar
GET    /api/admin/profile/assets/thumbnail
POST   /api/mobile/login
GET    /api/mobile/words
GET    /api/admin/users
POST   /api/admin/users
PUT    /api/admin/users/{id}
DELETE /api/admin/users/{id}
GET    /api/admin/app-users
POST   /api/admin/app-users
PUT    /api/admin/app-users/{id}
DELETE /api/admin/app-users/{id}
GET    /api/admin/roles
POST   /api/admin/roles
PUT    /api/admin/roles/{id}
DELETE /api/admin/roles/{id}
GET    /api/admin/menus
POST   /api/admin/menus
PUT    /api/admin/menus/{id}
DELETE /api/admin/menus/{id}
```

统一响应格式：

```json
{
  "code": 0,
  "msg": "ok",
  "data": {}
}
```

## 常用命令

```bash
# PostgreSQL + MinIO
docker compose up -d postgres minio
docker compose logs -f postgres
docker compose logs -f minio

# 后端
cd backend
go run ./cmd/server
go test ./...

# 学习运营后台
cd front/admin
npm run dev
npm run build

# 日语学习端
cd front/mobile
flutter run
```
