c.addi  x1, 5          # x1 = 5
c.addi  x2, -2         # x2 = -2
c.addi  x8,  10        # x8 = 10
c.addi  x9,  31        # x9 = 31
c.addi  x10, 8         # x10 = 8
c.addi  x11, 3         # x11 = 3
c.addi  x12, 6         # x12 = 6
c.addi  x13, 5         # x13 = 5
c.addi  x14, 20        # x14 = 20
c.addi  x15, 9         # x15 = 9
c.add   x1, x2         # x1 = 5 + (-2)
c.slli  x1, 1          # x1 = (5 + -2) << 1
c.xor   x8,  x9        # x8  = 10 ^ 31
c.or    x10, x11       # x10 = 8 | 3
c.and   x12, x13       # x12 = 6 & 5
c.sub   x14, x15       # x14 = 20 - 9
c.mv    x3, x1         # x3 = x1
c.lui   x4, 2          # x4 = 2 << 12
c.addi16sp 16          # sp = sp + 16
c.addi4spn x9, 32      # x9 = sp + 32
c.swsp x1, 0(sp)       # store x1 to stack[0]
c.lwsp x2, 0(sp)       # load back into x2
c.sw   x8, 12(x9)      # MEM[x9+12] = x8
c.lw   x10, 12(x9)     # x10 = MEM[x9+12]
c.srli  x1, 2          # x1 = ((5 + -2) << 1) >> 2
c.srli  x1, 1          # x1 = (((5 + -2) << 1) >> 2) >> 1
c.andi x8, 4        # x8 = x8 & 4
c.j    4            # pc += 4
c.addi x6, 1        # x6 = x6 + 1
c.jal  6           # x1 = pc+2 ; pc +=  6
c.addi x7, -3       # x7 = x7 - 3
c.bnez x11, 4        # if x11 != 0 -> pc += 4
c.jr   x1 # pc = x1

c.nop  
c.ebreak
  