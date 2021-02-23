# ISA Spec

## Registers

These are the standard registers:

| DEC |  BIN | Name | Width | Purpose                    |
|-----|------|------|-------|----------------------------|
|   0 | 0000 |    Z |    16 | Wired to 0000h             |
|   1 | 0001 |    A |    16 | Accumulator                |
|   2 | 0010 |    B |    16 | General purpose            |
|   3 | 0011 |    C |    16 | General purpose            |
|   4 | 0100 |    D |    16 | General purpose            |
|   5 | 0101 |   IX |    16 | Address index (X)          |
|   6 | 0110 |   IY |    16 | Address index (Y)          |
|   7 | 0111 |   SP |    16 | Stack pointer              |

These special registers are also available:

| DEC |  BIN | Name | Width | Purpose                    |
|-----|------|------|-------|----------------------------|
|  12 | 1100 |   HX |     8 | Top half of IX             |
|  14 | 1110 |   LX |     8 | Bottom half of IX          |
|  13 | 1101 |   HY |     8 | Top half of IY             |
|  15 | 1111 |   LY |     8 | Bottom half of IY          |

This register cannot be explicitly accessed by any instructions:

| DEC |  BIN | Name | Width | Purpose                    |
|-----|------|------|-------|----------------------------|
|   X | XXXX |   PC |    16 | Program counter            |

## Flags

| Name | Bit | Purpose    | Implicit? |
|------|-----|------------|-----------|
|   EQ |   0 | Equal?     |        No |
|   LT |   1 | Less than? |        No |
|   CF |   2 | Carry      |       Yes |
|   OF |   2 | Overflow   |       Yes |

Non-implicit flags are only set using the `CMP` instruction. They are not set implicitly by the ALU.  
Implicit flags are set by the ALU upon finishing an operation.

## Instruction Format

16 bits:

    TTTOOOMM'VVVVVVVV

| Field | Width | Meaning          |
|-------|-------|------------------|
|     T |     3 | Instruction type |
|     O |     3 | Opcode           |
|     M |     2 | Addressing mode  |
|     V |     8 | Argument         |

### T (3 bits) - Instruction Type

| DEC | BIN | Name        |
|-----|-----|-------------|
|   0 | 000 | Arithmetic  |
|   1 | 001 | Logical     |
|   2 | 010 | Jump        |
|   3 | 011 | Register    |
|   4 | 100 | I/O         |
|   5 | 101 | Stack       |

### O (3 bits) - Opcode

#### Arithmetic `[0, 000b]`

| DEC | BIN | Mnemonic | Description                  |
|-----|-----|----------|------------------------------|
|   0 | 000 | ADD      | A += arg, sets CF and OF     |
|   1 | 001 | SUB      | A -= arg, sets CF and OF     |
|   2 | 010 | CMPU     | Compare A and arg (unsigned) |
|   3 | 011 | CMP      | Compare A and arg (signed)   |
|   4 | 100 | SHL      | A <<= arg                    |
|   5 | 101 | SHR      | A >>= arg                    |
|   6 | 110 | RTL      | Rotate A left by arg bits    |
|   7 | 111 | SAR      | A >>= arg (arithmetic shift) |

#### Logical `[1, 001b]`

| DEC | BIN | Mnemonic | Description      |
|-----|-----|----------|------------------|
|   0 | 000 |      AND | A &= arg         |
|   1 | 001 |     NAND | A = NAND(A, arg) |
|   2 | 010 |       OR | A \|= arg        |
|   3 | 011 |      NOR | A = NOR(A, arg)  |
|   4 | 100 |      XOR | A ^= arg         |
|   5 | 101 |     XNOR | A = XNOR(A, arg) |
|   6 | 110 |      NOP | A = A            |
|   7 | 111 |      NOT | A = ~A           |

#### Jumps `[2, 010b]`

| DEC | BIN | Mnemonic | Description        |
|-----|-----|----------|--------------------|
|   0 | 000 |      JMP | Unconditional jump |
|   1 | 001 |      JEQ | Jump if EQ         |
|   2 | 010 |      JLT | Jump if LT         |
|   3 | 011 |      JLE | Jump if LT \| EQ   |
|   4 | 100 |      NOP | No operation       |
|   5 | 101 |      JCF | Jump if CF         |
|   6 | 110 |      JOF | Jump if OF         |
|   7 | 111 |     INVF | Invert all flags   |

#### Register `[3, 011b]`

| DEC | BIN | Mnemonic | Description                  |
|-----|-----|----------|------------------------------|
|   0 | 000 |     CALL | push pc+1; jmp [pc+arg1]     |
|   1 | 001 |      RET | pop pc                       |
|   2 | 010 |      LDA | mov a, arg1                  |
|   3 | 011 |      STA | mov [arg1], a                |
|   4 | 100 |      SWP | Swaps registers arg1, arg2   |
|   5 | 101 |      MOV | Moves register arg1 to arg2  |
|   6 | 110 |      CMP | Compare arg1 to A, set flags |
|   7 | 111 |       |   |

#### I/O `[4, 100b]`

| DEC | BIN | Mnemonic | Description                     |
|-----|-----|----------|---------------------------------|
|   0 | 000 |      INB | Reads the IO port at arg to A   |
|   1 | 001 |     OUTB | Writes A to the I/O port at arg |
|   2 | 010 |  |  |
|   3 | 011 |  |  |
|   4 | 100 |  |  |
|   5 | 101 |  |  |
|   6 | 110 |  |  |
|   7 | 111 |  |  |

#### Stack `[5, 101b]`

| DEC | BIN | Mnemonic | Description                     |
|-----|-----|----------|---------------------------------|
|   0 | 000 |     PUSH | lda [sp]; add sp, #-1           |
|   1 | 001 |      POP | sta [sp]; sub sp, #1            |
|   2 | 010 |  |  |
|   3 | 011 |  |  |
|   4 | 100 |  |  |
|   5 | 101 |  |  |
|   6 | 110 |  |  |
|   7 | 111 |  |  |

### M (2 bits) - Addressing mode

| DEC | BIN | Mode            |  Mnemonic |
|-----|-----|-----------------|-----------|
|   0 |  00 | Immediate       |    (none) |
|   1 |  01 | Index + Offset  |      X, Y |
|   2 |  10 | Indirect (by A) |         I |
|   3 |  11 | Register        | R or none |

### V (8 bits) - Argument

#### Immediate mode

    VVVVVVVV

Non-jumps: The argument is V (8 bits).

Jumps: The new address is PC + V.

#### Index + Offset mode

    ROOOOOOO

The first bit `R` determines which register to use as the index:

| Bit | Register |
|-----|----------|
|   0 |       IX |
|   1 |       IY |

The next 7 bits of V are a signed offset (-64..63).

The argument is the value in memory at the address `(index + offset)`.

#### Indirect mode

The argument is the value in memory at the address in A. V is unused.

To use the value at an immediate address:

    LDI high_byte
    SHL 8
    ADD low_byte

#### Register mode

    DDDDSSSS

These have two register arguments:

- `DDDD`: destination
- `SSSS`: source

When assigning _to_ 8-bit registers _from_ 16-bit registers, the source value is truncated.
When assigning _from_ 16-bit registers _to_ 8-bit registers, the value is sign-extended.

When an instruction takes only one argument, only S or D is used, depending on the argument.

For example, when jumping, `JMP A` jumps to the address stored in A, in contrast to `JMPI A`, which would jump to the address in the memory location whose address is A.


## Notes

- The instruction `0000h` means `ADDU 0` and is effectively a NOP. This means that when memory is uninitialized or at 0, the processor executes through it until it finds code.
