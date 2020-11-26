with import <nixpkgs> {}; mkShell {
  buildInputs = [
    verilog
    verilator
  ];
}
