---
name: go-local-proxy-deps
description: Use this when downloading Go module dependencies, running go mod download, go mod tidy, or go get, or when the user asks to use the local 127.0.0.1:8080 Go module proxy.
---

# Go Local Proxy Dependencies

When downloading Go dependencies, run Go module commands with the local proxy:

```bash
GOPROXY=http://127.0.0.1:8080,direct go mod download
```

Use the same proxy for related dependency commands:

```bash
GOPROXY=http://127.0.0.1:8080,direct go mod tidy
GOPROXY=http://127.0.0.1:8080,direct go get <module>
```

Prefer command-level environment variables. Do not run `go env -w GOPROXY=...` unless the user explicitly asks for a persistent global Go proxy.

Keep existing project-specific values such as `GOPRIVATE`, `GONOSUMDB`, and `GOSUMDB` unchanged unless the user asks to modify them.
