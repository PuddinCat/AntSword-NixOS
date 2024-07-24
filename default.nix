{ pkgs, lib }:
let
  libPath = with pkgs; lib.makeLibraryPath [
    alsa-lib.out
    at-spi2-atk.out
    cairo.out
    cups.lib
    dbus.lib
    expat.out
    gdk-pixbuf.out
    glib.out
    gtk3.out
    libuuid.lib
    nspr.out
    nss.out
    pango.out
    xorg.libX11.out
    xorg.libXScrnSaver.out
    xorg.libXcomposite.out
    xorg.libXcursor.out
    xorg.libXdamage.out
    xorg.libXext.out
    xorg.libXfixes.out
    xorg.libXi.out
    xorg.libXrandr.out
    xorg.libXrender.out
    xorg.libXtst.out
    xorg.libxcb.out
  ];
in
pkgs.stdenv.mkDerivation (with pkgs; rec {
  pname = "AntSword-Loader";
  version = "4.0.3";


  nativeBuildInputs = [ makeWrapper ];

  sourceRoot = ".";
  unpackCmd = "${pkgs.unzip}/bin/unzip $src";

  dontConfigure = true;
  dontBuild = true;

  # ---- WARNING ----
  # the sed line is really a cursed hack
  # the software writes .antSword.json to program's `resources/` directory
  # which is not allowed in NixOS, which install programs to readonly /nix/store/
  # however we can patch some javascript code inside .asar binary files to fix that.
  # but, the .asar file also write the length of the javascript code into itself,
  # so we can only replace code that has the same length, 
  # in this case we need to replace exactly 52 characters, that's what the space character is for
  # the AntSword project is unmaintained for years, but lots of chinese hackers are still using it
  # for its plugin system.

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -R AntSword-Loader-v${version}-linux-x64 $out/share
    ${pkgs.gnused}/bin/sed -i "s/ path.join(process.resourcesPath, '.antSword.json')/path.join(require('os').homedir(),'.antSword.json')/g" $out/share/resources/*.asar
    runHook postInstall
  '';


  postFixup = ''
    # Do not create `GPUCache` in current directory
    makeWrapper $out/share/AntSword $out/bin/AntSword-Loader \
      --prefix LD_LIBRARY_PATH : ${libPath}:$out/share \
      --chdir /tmp \
      --argv0 "/tmp/a" \
      "''${gappsWrapperArgs[@]}"
  '';

  src = pkgs.fetchurl {
    url = "https://github.com/AntSwordProject/AntSword-Loader/releases/download/${version}/AntSword-Loader-v${version}-linux-x64.zip";
    sha256 = "sha256-GP6CTOZ3nekmnQVsU/mJ9Tmy75MrjKMWJeqhgmLLPoE=";
  };

  meta = with lib; {
    description = "AntSword is a program for controlling PHP backdoors (webshells) and other kinds of webshells";
    homepage = "https://github.com/AntSwordProject/antSword";
    license = licenses.mit;
    maintainers = with maintainers; [ "PuddinCat07" ]; # TODO
    platforms = platforms.linux;
    mainProgram = "AntSword-Loader";
  };

})
