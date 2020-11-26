with import <nixpkgs> { };
mkShell {
  name = "honorslab";
  buildInputs = [ graphviz yarn ];
}
