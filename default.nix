with import <nixpkgs> {};
let
  rubyEnv = bundlerEnv {
    name = "capnproto-ruby";
    gemdir = ./.;
    group = [ "default" "development" ];
    gemConfig = pkgs.defaultGemConfig // {
      sorbet-static = attrs:
        if pkgs.stdenv.isLinux then rec {
          version = attrs.version + "-x86_64-linux";
          nativeBuildInputs = with pkgs; [ autoPatchelfHook ];
        } else attrs;
    };
  };
in stdenv.mkDerivation {
  name = "capnproto-ruby";
  buildInputs = [
    rubyEnv
    rubyEnv.wrappedRuby
    bundix
    capnproto
  ];
}
