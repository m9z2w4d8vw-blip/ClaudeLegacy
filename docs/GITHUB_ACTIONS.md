# GitHub Actions IPA builds (Windows-friendly)

The repository includes `.github/workflows/build-ios.yml`. You do not need macOS locally or a paid Apple Developer account **to compile the unsigned IPA**.

## 1. Upload to GitHub

Create a repository. Upload/extract the **contents** of the `ClaudeWeb17` folder into its repository root, preserving hidden directories. In particular, these files must exist in GitHub:

```
.github/workflows/build-ios.yml
project.yml
ClaudeWeb17/Sources/ClaudeWeb17App.swift
```

GitHub's web upload interface can sometimes cause the hidden `.github` directory to be skipped; verify it appears in the repository. Alternatively, use Git from Windows to push the folder.

## 2. Automatic builds

Pushing to `main` or `master` starts a build. Opening a pull request also builds the project. The workflow runs on **macos-15**, installs XcodeGen, generates `ClaudeWeb17.xcodeproj` from `project.yml`, compiles for physical iPhones (`iphoneos`, not simulator), and packages the compiled `ClaudeWeb17.app` as a `Payload/` IPA archive.

## 3. Build on demand

On GitHub: **Actions → Build iOS IPA → Run workflow → Run workflow**.

If you check **“Also upload the IPA directly to GitHub Releases?”**, the workflow also publishes a prerelease tagged `dev-<7-character commit hash>`. This requires the repository to allow GitHub Actions to create releases with `GITHUB_TOKEN`. If release publishing is restricted by an organization policy, the Actions artifact is still produced.

To publish a versioned release, push a tag such as `v0.1.0`. This also creates a prerelease with a directly downloadable `.ipa` asset.

## 4. Find the result

- **Actions → successful run → Artifacts:** `ClaudeWeb17-iOS17-unsigned-<run number>`. GitHub downloads artifacts inside a ZIP. Extract it to obtain the `.ipa`.
- **Releases:** if you ran with `publish_release` enabled or pushed a `v*` tag, download the `.ipa` file *directly*, without an artifact ZIP wrapper.
- Failed compile? Download `ClaudeWeb17-build-log-<run number>` from the failed run, or read the **Build app** log.

## 5. Installation / signing

This workflow intentionally disables code signing (`CODE_SIGNING_ALLOWED=NO`). The resulting IPA is **unsigned**, so normal iOS installation will reject it. It may be installed using a compatible jailbreak-aware installer or signed separately using your own valid provisioning setup, depending on your device and installation method. Merely renaming the IPA does not sign it.

If you require a normally signed IPA, certificates / provisioning profiles and an additional signing step must be configured; no signing credentials are included in this repository.

## 6. Configuration

- **Minimum supported iOS:** `17.0` in `project.yml`.
- **Bundle identifier:** `PRODUCT_BUNDLE_IDENTIFIER` in `project.yml`; replace `dev.example.ClaudeWeb17` with your identifier before distributing.
- **App display name:** `INFOPLIST_KEY_CFBundleDisplayName` in `project.yml`.

No login HTML, Claude cookies, credentials, tokens, or saved authenticated page captures should be committed to GitHub.
