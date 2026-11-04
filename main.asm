.data

title:          .asciiz "\n========================================\n              WHACK-A-MOLE\n========================================\n"

board_title:    .asciiz "\n             GAME BOARD\n\n"

time_msg:       .asciiz "\nTIME REMAINING: "
seconds_msg:    .asciiz " SECONDS\n"

mole_msg:       .asciiz "\nA MOLE HAS APPEARED AT POSITION "
mole_msg2:      .asciiz "!\nYou have 2 seconds to hit it!\n"

input_msg:      .asciiz "\nEnter position (1-9): "

correct_msg:    .asciiz "\nNICE! YOU HIT THE MOLE!\n"
wrong_msg:      .asciiz "\nWRONG POSITION! THE MOLE ESCAPED!\n"
late_msg:       .asciiz "\nTOO LATE! THE MOLE ESCAPED!\n"
invalid_msg:    .asciiz "\nINVALID POSITION!\n"

score_msg:      .asciiz "\nSCORE: "

game_over_msg:  .asciiz "\n\n========================================\n                GAME OVER\n========================================\n"

final_score:    .asciiz "\nYOUR FINAL SCORE: "

newline:        .asciiz "\n"
space:          .asciiz "     "

mole:           .asciiz "[M]"
empty:          .asciiz "[ ]"


.text
.globl main

main:

    # Display title

    li $v0, 4
    la $a0, title
    syscall

    # Initialize score

    li $s0, 0

    # Game duration: 30 seconds

    li $s1, 30000

    # Save starting time

    li $v0, 30
    syscall

    move $s2, $a0


game_loop:

    # Get current time

    li $v0, 30
    syscall

    # Calculate elapsed time

    subu $t0, $a0, $s2

    # Calculate remaining time

    subu $s3, $s1, $t0

    # Check if game is over

    blez $s3, game_over


    # Display remaining seconds

    li $v0, 4
    la $a0, time_msg
    syscall

    li $t1, 1000
    div $s3, $t1
    mflo $a0

    li $v0, 1
    syscall

    li $v0, 4
    la $a0, seconds_msg
    syscall


    # Generate random mole position (0-8)

    li $v0, 42
    li $a0, 0
    li $a1, 9
    syscall

    # Convert position to 1-9

    addi $s4, $a0, 1


    # Display game board title

    li $v0, 4
    la $a0, board_title
    syscall


    # Display all nine positions

    li $a0, 1
    jal display_position

    li $a0, 2
    jal display_position

    li $a0, 3
    jal display_position

    li $a0, 4
    jal display_position

    li $a0, 5
    jal display_position

    li $a0, 6
    jal display_position

    li $a0, 7
    jal display_position

    li $a0, 8
    jal display_position

    li $a0, 9
    jal display_position


    # Display mole location

    li $v0, 4
    la $a0, mole_msg
    syscall

    move $a0, $s4

    li $v0, 1
    syscall

    li $v0, 4
    la $a0, mole_msg2
    syscall


    # Save mole appearance time

    li $v0, 30
    syscall

    move $s5, $a0


    # Ask player for position

    li $v0, 4
    la $a0, input_msg
    syscall

    # Read player input

    li $v0, 5
    syscall

    move $s6, $v0


    # Get time after input

    li $v0, 30
    syscall

    # Calculate response time

    subu $t2, $a0, $s5

    # Maximum response time: 2000 ms

    li $t3, 2000

    bgt $t2, $t3, too_late


    # Validate player input

    blt $s6, 1, invalid

    bgt $s6, 9, invalid


    # Check whether player hit mole

    beq $s6, $s4, correct

    j wrong


correct:

    # Increase score

    addi $s0, $s0, 1

    li $v0, 4
    la $a0, correct_msg
    syscall

    j display_score


wrong:

    li $v0, 4
    la $a0, wrong_msg
    syscall

    j display_score


too_late:

    li $v0, 4
    la $a0, late_msg
    syscall

    j display_score


invalid:

    li $v0, 4
    la $a0, invalid_msg
    syscall


display_score:

    li $v0, 4
    la $a0, score_msg
    syscall

    move $a0, $s0

    li $v0, 1
    syscall

    j game_loop



# ========================================
# DISPLAY POSITION SUBROUTINE
# ========================================

display_position:

    # Save original position

    move $t5, $a0

    # Check whether this is the mole position

    beq $t5, $s4, show_mole

    # Display empty position

    li $v0, 4
    la $a0, empty
    syscall

    j position_spacing


show_mole:

    li $v0, 4
    la $a0, mole
    syscall


position_spacing:

    li $v0, 4
    la $a0, space
    syscall

    # Check if position is divisible by 3

    li $t6, 3

    div $t5, $t6

    mfhi $t7

    bnez $t7, return_position

    # Print newline after every third position

    li $v0, 4
    la $a0, newline
    syscall


return_position:

    jr $ra



# ========================================
# GAME OVER
# ========================================

game_over:

    li $v0, 4
    la $a0, game_over_msg
    syscall

    li $v0, 4
    la $a0, final_score
    syscall

    move $a0, $s0

    li $v0, 1
    syscall

    # Exit program

    li $v0, 10
    syscall
