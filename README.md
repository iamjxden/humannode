# HumanNode

Local-first AI workspace for mobile. Run LLMs directly on your device.

**Download APK:** https://github.com/iamjxden/humannode/releases

## What it does

HumanNode is a self-contained AI workspace for Android/iOS. It runs GGUF language models on-device via llama.cpp with GPU acceleration. No cloud. No telemetry. No account.

## Features

- On-device LLM inference via llama.cpp (Metal/NNAPI)
- Agentic mode with 11 builtin tools
- Streaming token-by-token responses
- Conversations (create, rename, pin, search, delete)
- Markdown with syntax highlighting
- Model catalog with in-app downloads
- Notes with full CRUD
- Material Design 3 dark/light themes
- 5 languages

## Quick Start

```bash
git clone --recursive https://github.com/iamjxden/humannode.git
cd humannode
flutter pub get
flutter build apk --release
```

## Architecture

Flutter UI -> Riverpod Providers -> Agent Loop -> Inference Engine -> dart:ffi -> llama.cpp

Tech: Flutter 3.24+ | Dart 3.5+ | Riverpod | GoRouter | llama.cpp

## License

MIT (c) iamjxden
