with import <nixpkgs> {} ;
pkgs.mkShell {
  buildInputs = with pkgs; [
    clangStdenv
    ponyc
    pony-corral
  ];
}
