---
name: flutter-cn-mirror-deps
description: Use this when downloading Flutter or Dart dependencies, running flutter pub get or flutter pub upgrade, or when the user asks to use domestic China mirrors for Flutter dependency downloads.
---

# Flutter China Mirror Dependencies

When downloading Flutter/Dart dependencies, run pub commands with command-level mirror environment variables:

```bash
PUB_HOSTED_URL=https://pub.flutter-io.cn FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn flutter pub get
```

Use the same environment variables for related dependency commands:

```bash
PUB_HOSTED_URL=https://pub.flutter-io.cn FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn flutter pub upgrade
PUB_HOSTED_URL=https://pub.flutter-io.cn FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn flutter pub add <package>
```

Prefer command-level environment variables. Do not write these values into shell startup files or global machine configuration unless the user explicitly asks for a persistent setup.

If a project command wraps Flutter, preserve the mirror variables before the command, for example:

```bash
PUB_HOSTED_URL=https://pub.flutter-io.cn FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn <project-command>
```
