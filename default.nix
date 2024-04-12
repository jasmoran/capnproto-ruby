with import <nixpkgs> {};
let
  rubyEnv = bundlerEnv {
    name = "capnproto-ruby";
    gemdir = ./.;
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
