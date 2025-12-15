# llama.cpp-binaries

A simple bash script to download the latest pre-compiled binaries from the [llama.cpp](https://github.com/ggml-org/llama.cpp) repository.

## Description

This repository provides a convenient way to download the latest llama.cpp binaries without having to compile from source. The script automatically fetches the most recent release from the official llama.cpp GitHub repository based on your specified platform and architecture.

## Prerequisites

- `bash`
- `curl`
- `jq`
- `wget`

## Usage

1. Clone this repository:
```bash
git clone https://github.com/mounta11n/llama.cpp-binaries.git
cd llama.cpp-binaries
```

2. Edit the `dl-latest-llamacpp.sh` script and set the `FILE_PATTERN` variable to match your platform and architecture:
```bash
FILE_PATTERN="macos-arm64.tar.gz"  # Change this to your platform
```

Available patterns typically include:
- `macos-arm64.tar.gz` - macOS (Apple Silicon)
- `macos-x64.tar.gz` - macOS (Intel)
- `linux-x64.tar.gz` - Linux (x64)
- `windows-x64.zip` - Windows (x64)

3. Make the script executable and run it:
```bash
chmod +x dl-latest-llamacpp.sh
./dl-latest-llamacpp.sh
```

4. The script will download the latest binaries to your current directory.

## License

MIT License - see [LICENSE](LICENSE) file for details.
