with import <nixpkgs> {}; mkShell {
  buildInputs = [
    verilog
    verilator
    yosys trellis nextpnr fujprog
  ];

  TRELLIS = trellis;
}
