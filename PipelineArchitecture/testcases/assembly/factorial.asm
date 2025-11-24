    lw      x15, 128(x0)        # Load n from memory address 128 into x15
    c.addi16sp sp, 192          # Initialize stack pointer (sp += 192s)
    
    c.li    x14, 1              # Load immediate 1 into x14 (base case value)
    c.li    x13, 1              # Load immediate 1 into x13 (comparison value)
    
    bge     x15, x13, 8         # If n >= 1, skip base case (jump +8 bytes)
    c.mv    x15, x14            # Base case: n < 1, return 1 (x15 = 1)
    c.jr    x1                  # Return to caller (jump to return address)
    
    # Recursive case: n >= 1
    c.addi16sp sp, -16          # Allocate 16 bytes on stack (sp -= 16)
    c.swsp  x1, 12              # Save return address at sp+12
    c.swsp  x15, 8              # Save current n at sp+8
    
    c.addi  x15, x15, -1        # Decrement n (x15 = n - 1)
    c.jal   -20                 # Recursive call: factorial(n-1), jump back 20 bytes
    
    c.lwsp  x14, 8              # Restore original n from stack into x14
    mul     x15, x15, x14       # Multiply: result = factorial(n-1) × n
    
    c.lwsp  x1, 12              # Restore return address from stack
    c.addi16sp sp, 16           # Deallocate stack frame (sp += 16)
    
    beq     x1, x0, 6           # If return address is 0 (shouldn't happen), skip return
    c.jr    x1                  # Return to caller
    
    c.ebreak                    # Breakpoint/halt (error case)
