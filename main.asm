.data
black: .word 0x00000000
hole:  .word 0x00333333     # Grey
mole:  .word 0x00FF0000     # Red

welcome: .asciiz "Welcome to Whack-a-Mole!\n"

.text
.globl main

main:
    li $v0, 4
    la $a0, welcome
    syscall

    li $v0, 10
    syscall

game_loop:


    jal draw_board

draw_board:
