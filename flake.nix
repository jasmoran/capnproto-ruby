{
  description = "Ruby support for the Cap'n Proto data interchange format";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        rubyEnv = pkgs.bundlerEnv {
          name = "capnproto";
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
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = [
            rubyEnv
            rubyEnv.wrappedRuby
            pkgs.bundix
            pkgs.capnproto
            pkgs.watchman
          ];
          shellHook = ''
            export RUBYLIB="$PWD/lib:$RUBYLIB"
            export PATH="$PWD/bin:$PATH"
          '';
        };
      }
    );
}
