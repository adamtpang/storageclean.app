# StorageClean for Windows

This is the native, read-only StorageClean beta.

## Safety boundary

The beta scans and exports measurements. It does not delete, move, compress, uninstall, deduplicate, or change files. Reparse points are counted and skipped. Filesystem errors are reported in aggregate instead of hidden.

## Projects

- `StorageClean.Core`: memory-bounded filesystem scanner and audit model.
- `StorageClean.App`: .NET 8 WPF user interface.
- `StorageClean.SelfTest`: dependency-free fixture test for ranking and byte accounting.

## Build

From the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\scripts\build-windows.ps1"
```

Build intermediates and release artifacts default to `E:\Aether-generated-deps\storageclean-build` when E: is available. Pass `-BuildRoot` to choose another location.

The script runs the self-test, publishes a self-contained single-file `win-x64` application, compiles the installer when Inno Setup 6 is available, and writes SHA-256 release metadata.

## Release gates

- The public download remains beta until install, launch, scan, export, and uninstall are tested on a clean Windows account.
- The current package is unsigned unless the release manifest says otherwise.
- Broad production positioning waits for a trusted code-signing certificate and signed updates.
