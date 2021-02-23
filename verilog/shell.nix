with import <nixpkgs> {}; mkShell {
  buildInputs = [
    verilog gtkwave
    verilator
    yosys trellis nextpnr fujprog
  ];

  TRELLIS = trellis;
}
