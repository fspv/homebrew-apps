# Homebrew Apps Tap

This repository contains Homebrew formulas for custom applications.

## Installation

### Add the tap

```bash
brew tap fspv/apps
```

### Install chef-de-vibe

```bash
brew install fspv/apps/chef-de-vibe
```

Or install directly without adding the tap:

```bash
brew install fspv/apps/chef-de-vibe
```

### Install development version

To install the latest development version from the master branch:

```bash
brew install --HEAD fspv/apps/chef-de-vibe
```

Note: The HEAD installation builds from source and requires Rust, Node.js, and other build dependencies.

## Available Formulas

### chef-de-vibe

A Rust application with embedded React frontend.

- **Homepage**: https://github.com/fspv/chef-de-vibe
- **License**: MIT
- **Platforms**: macOS (Intel & Apple Silicon), Linux x86_64

## Updating

To get the latest version of a formula:

```bash
brew update
brew upgrade fspv/apps/chef-de-vibe
```

## Uninstallation

```bash
brew uninstall chef-de-vibe
brew untap fspv/apps  # Optional: remove the tap
```

## Development

### Automatic Formula Updates

This tap uses GitHub Actions to automatically update formulas when new releases are published in the source repositories. The workflow:

1. Monitors for new releases in the chef-de-vibe repository
2. Downloads the pre-built binaries
3. Calculates SHA256 checksums
4. Updates the formula
5. Creates a pull request with the changes

### Manual Update

To manually trigger a formula update:

1. Go to the [Actions tab](https://github.com/fspv/homebrew-apps/actions)
2. Select "Update Formula" workflow
3. Click "Run workflow"
4. Optionally specify a version (e.g., `v1.0.0`)

### Testing

The formulas are automatically tested on:
- macOS latest (Intel and ARM)
- Ubuntu latest

Tests run on every push and pull request that modifies formulas.

## Troubleshooting

### Installation Issues

If you encounter issues during installation:

```bash
# Update Homebrew and retry
brew update
brew doctor
brew install fspv/apps/chef-de-vibe
```

### Binary Compatibility

The pre-built binaries are compiled for:
- macOS Intel (x86_64)
- macOS Apple Silicon (ARM64)
- Linux x86_64

For other platforms, use the `--HEAD` option to build from source.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally: `brew install --build-from-source ./Formula/chef-de-vibe.rb`
5. Submit a pull request

## License

The formulas in this repository are provided under the same licenses as their respective software packages.