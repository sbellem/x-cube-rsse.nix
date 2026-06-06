# x-cube-rsse.nix

Nix packaging for **X-CUBE-RSSe** — STMicroelectronics' STM32Cube expansion
package that ships the **RSS extension binaries** (RSSe). These signed
binaries are used by STM32CubeProgrammer to drive on-die secure services
such as **Key Wrap** (`-rssekw`) for exporting wrapped DUA keys.

The current package pins **version 2.0.0** of the X-CUBE-RSSe archive.
Inside, the STM32U3-relevant artifacts are:

- `RSSe/STM32U3/RSSe_KW_U375_U385_v1.0.0.bin` — Key Wrap service binary
- `RSSe/STM32U3/RSSe_SFI_U375_U385_v1.0.0.bin` — Secure Firmware Install binary
- `Option_Bytes_Template/STM32U3/OB_U375_U385_v1.0.0.csv` — option-byte template
- `Perso_Data/STM32U3/Perso_Data_U375_U385_45403017_SFI._v1.0.0.bin` — perso data

## Prerequisite: stage the archive in the Nix store

X-CUBE-RSSe is delivered under SLA0048 and is **not redistributable**.
This package uses `requireFile`, so **Nix will not download the archive
for you** — fetch it from ST yourself and stage it locally once:

1. Go to https://www.st.com/en/embedded-software/x-cube-rsse.html and
   download the v2.0.0 archive. ST typically serves it as
   `en.x-cube-rsse-v2-0-0.zip`; rename to `x-cube-rsse-v2-0-0.zip` if
   needed.

2. Verify the hash:

   ```bash
   sha256sum x-cube-rsse-v2-0-0.zip
   # expected: d738148bf165da15c7115d2883e0540949f4752202f92a46e8281279c0fe0b26
   ```

   If the hash differs, ST has bumped the package version. Update
   `version` and `sha256` in `x-cube-rsse.nix` to match.

3. Add the file to the Nix store:

   ```bash
   nix-store --add-fixed sha256 x-cube-rsse-v2-0-0.zip
   ```

   One-shot operation; the file lives in `/nix/store/` from then on.

## Build

```bash
nix build
ls result/RSSe/STM32U3/RSSe_KW_U375_U385_v1.0.0.bin
```

## Use as a flake input

```nix
{
  inputs.x-cube-rsse.url = "path:/path/to/x-cube-rsse.nix";
  inputs.x-cube-rsse.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, x-cube-rsse, ... }: {
    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      packages = [ x-cube-rsse.packages.x86_64-linux.default ];
      shellHook = ''
        export RSSE_PKG=${x-cube-rsse.packages.x86_64-linux.default}
        export RSSE_KW_U3=$RSSE_PKG/RSSe/STM32U3/RSSe_KW_U375_U385_v1.0.0.bin
      '';
    };
  };
}
```

## Notes

- **License: unfree** (SLA0048). `config.allowUnfree = true` is required
  wherever this is consumed.
- The RSSe binaries are signed and encrypted by ST; they only run on
  specific STM32 devices. Don't try to disassemble or modify them.
- Despite the host-platform-neutral content, the upstream archive is
  versioned and curated by ST; we treat it as `platforms.all` in `meta`
  but expect consumption from `x86_64-linux` (where `STM32_Programmer_CLI`
  runs).
- See `Initial_Attestation_KWE/export_DUA_key.sh` in `STM32CubeU3` for the
  canonical command sequence that uses `RSSe_KW_U375_U385_v1.0.0.bin`.
