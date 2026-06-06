# https://www.st.com/en/embedded-software/x-cube-rsse.html
{ lib, stdenv, requireFile, unzip }:

let
  pname = "stm32-x-cube-rsse";
  version = "2.0.0";
  fileVerStr = builtins.replaceStrings [ "." ] [ "-" ] version;
in
stdenv.mkDerivation {
  inherit version pname;

  src = requireFile rec {
    name = "x-cube-rsse-v${fileVerStr}.zip";
    url = "https://www.st.com/en/embedded-software/x-cube-rsse.html";
    sha256 = "d738148bf165da15c7115d2883e0540949f4752202f92a46e8281279c0fe0b26";
  };

  nativeBuildInputs = [ unzip ];

  unpackPhase = ''
    runHook preUnpack
    unzip $src
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r STM32CubeExpansion_RSSe_V${version}/* $out/
    runHook postInstall
  '';

  meta = with lib; {
    description = "STMicroelectronics RSS extension binaries (X-CUBE-RSSe) for STM32";
    longDescription = ''
      X-CUBE-RSSe is the STM32Cube expansion package providing RSS extension
      binaries (RSSe). The RSS extensions are signed, encrypted binaries
      delivered by STMicroelectronics that extend the security services of
      a chip's on-die Root Security Services (RSS). STM32CubeProgrammer
      uploads them transiently to the chip to perform advanced provisioning
      operations such as Key Wrap export (the -rssekw service).

      This package extracts the X-CUBE-RSSe archive verbatim. Consumers
      reference signed binaries directly, e.g. for STM32U3:

        $out/RSSe/STM32U3/RSSe_KW_U375_U385_v1.0.0.bin

      and option-byte templates:

        $out/Option_Bytes_Template/STM32U3/OB_U375_U385_v1.0.0.csv

      The binaries are encrypted/authenticated by ST; only specific STM32
      devices can execute them. There is no host-platform-specific code.
    '';
    homepage = "https://www.st.com/en/embedded-software/x-cube-rsse.html";
    license = licenses.unfree;
    platforms = platforms.all;
  };
}
