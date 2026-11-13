.data
bitmap: .space 16384

black: .word 0x00000000
hole:  .word 0x00D3D3D3     # Grey
mole:  .word 0x00FF0000     # Red
hammer: .word 0x000080FF    # Blue
score: .word 0

score_label: .asciiz "Current score: "
score_nextline: .asciiz "\n"

#===============================================
# Don't change these registers
#===============================================
# $s1 = starting time
# $s4 = mole position (1-9)
# $s5 = converted user input
#===============================================

.text
.globl main

main:
    # Get game start time
    li $v0, 30
    syscall
    move $s1, $a0         # Save starting time

game_loop:
    # Check if 30 seconds have passed
    jal total_time
    beq $v0, 1, game_over

    # Generate random mole position (1-9)
    li $v0, 42
    li $a0, 0
    li $a1, 9
    syscall
    addi $s4, $a0, 1

    # Draw board
    jal draw_board

    # Draw mole
    jal draw_mole
    
    # Get the user input
    jal get_input
    
    # Convert the user input
    move $a0, $v0 # $a0 = the user input
    jal convert_input
    
    # Draw a hammer
    move $a0, $v0 # $a0 = the converted user input
    move $s5, $v0 # $s5 = the converted user input
    lw $a1, hammer # $a1 = hammer color
    jal draw_hammer
    
    # Check the user input
    move $a0, $s5 # $a0 = the converted user input
    jal check_input
    
    # Add point
    move $a0, $v0 # $a0 = (0 == not correct) or (1 == correct)
    jal point_add
    
    # Print the current point
    jal print_current_score
    
    # Delay
    jal delay
    
    # Erase the hammer
    move $a0, $s5 # $a0 = the converted user input
    lw $a1, black # $a1 = black color
    jal draw_hammer

    j game_loop

game_over:
    li $v0, 10
    syscall


#===================================================================================================
# draw_board procedure starts
#===================================================================================================
# No inputs
# No return values
#======================================

# Function to draw all 9 holes
draw_board:
    la $t0, bitmap
    addi $t0, $t0, 3120
    lw $t1, hole
    li $t2, 0

row:
    li $t3, 0
    move $t4, $t0

col:
    li $t5, 0
    move $t6, $t4

pixel_row:
    li $t7, 0

pixel_col:
    sw $t1, 0($t6)
    addi $t6, $t6, 4
    addi $t7, $t7, 1
    blt $t7, 8, pixel_col

    addi $t6, $t6, 224
    addi $t5, $t5, 1
    blt $t5, 8, pixel_row

    addi $t4, $t4, 64
    addi $t3, $t3, 1
    blt $t3, 3, col

    addi $t0, $t0, 4096
    addi $t2, $t2, 1
    blt $t2, 3, row

    jr $ra
    
#===================================================================================================
# draw_board procedure ends
#===================================================================================================

#===================================================================================================
# draw_mole procedure starts
#===================================================================================================
# No inputs
# No return values
#======================================

# Function to draw mole at random position
draw_mole:
    # Convert position from 1-9 to 0-8
    addi $t0, $s4, -1

    # Calculate row and column
    li $t1, 3
    div $t0, $t1
    mflo $t2              # Row
    mfhi $t3              # Column

    # Get starting position
    la $t0, bitmap
    addi $t0, $t0, 3120

    # Move to correct row
    sll $t2, $t2, 12
    addu $t0, $t0, $t2

    # Move to correct column
    sll $t3, $t3, 6
    addu $t0, $t0, $t3

    # Save mole starting position
    move $t8, $t0

    # Get mole color
    lw $t1, mole

    # Draw 8x8 mole
    li $t2, 0

mole_row:
    li $t3, 0
    move $t4, $t0

mole_col:
    # Skip the corners
    beq $t2, $zero, check_corner
    li $t5, 7
    beq $t2, $t5, check_corner
    j draw_red

check_corner:
    beq $t3, $zero, skip_pixel
    li $t5, 7
    beq $t3, $t5, skip_pixel

draw_red:
    sw $t1, 0($t4)

skip_pixel:
    addi $t4, $t4, 4
    addi $t3, $t3, 1
    blt $t3, 8, mole_col

    addi $t0, $t0, 256
    addi $t2, $t2, 1
    blt $t2, 8, mole_row

    # Get black color
    lw $t1, black

    # Draw eyes
    sw $t1, 520($t8)
    sw $t1, 532($t8)

    # Draw mouth
    sw $t1, 1288($t8)
    sw $t1, 1292($t8)
    sw $t1, 1296($t8)
    sw $t1, 1300($t8)

    jr $ra
    
#===================================================================================================
# draw_mole procedure ends
#===================================================================================================

#===================================================================================================
# total_time procedure starts
#===================================================================================================
# $s1 = starting time
# $v0 = (0 == Time is not up) or (1 == Time is up)
#======================================

# Check if 30 seconds have passed
total_time:
    li $v0, 30
    syscall

    subu $t0, $a0, $s1    # Time elapsed

    li $v0, 0            # Time not up
    bltu $t0, 30000, time_return

    li $v0, 1            # Time is up

time_return:
    jr $ra
    
#===================================================================================================
# total_time procedure ends
#===================================================================================================

#===================================================================================================
# delay procedure starts
#===================================================================================================
# No inputs
# No return values
#======================================

# Wait 0.5 seconds
delay:

    li $v0, 32
    li $a0, 500
    syscall

    jr $ra
    
#===================================================================================================
# delay procedure ends
#===================================================================================================

#===================================================================================================
# point_add procedure starts
#===================================================================================================
# $a0 = (0 == not correct) or (1 == correct)
# No return values
#======================================

# Add 1 point if correct
point_add:
    
    # If not correct, jump to the end
    beq $a0, $zero, point_add_end

    # If correct, add 1 point
    lw $t5, score
    addi $t5, $t5, 1
    sw $t5, score

point_add_end:

    # Return to the caller
    jr $ra
    
#===================================================================================================
# point_add procedure ends
#===================================================================================================

#===================================================================================================
# draw_hammer procedure starts
#===================================================================================================
# $a0 = Converted user input
# $a1 = Hammer color
# No return values
#======================================

# Draw a hammer above a specific hole based on the user input
draw_hammer:

   # If $a0 == 0 or the user input is NULL, jump to the end
   beq $a0, $zero, draw_hammer_end

   # Load the address of bitmap to $t7
   la $t7, bitmap
   
   # Add hammer color to $t6
   move $t6, $a1
   
   # $t0=x1, $t1=y1, $t2=width, $t3=height
   li $t0, 12	# x1
   li $t1, 6	# y1
   li $t2, 4	# width
   li $t3, 5	# height
   
   # Add based on the user input
   sub $a0, $a0, 1 # Make 1-9 to 0-8
   div $t4, $a0, 3 # Divide the input by 3 = the index of the row
   mul $t5, $t4, 3 # Multiply the index of the row by 3
   sub $t5, $a0, $t5 # Calculate the remainder
   sll $t5, $t5, 4 # x distance = 16
   addu $t0, $t0, $t5 # Adjust x1
   sll $t4, $t4, 4 # y distance = 16
   addu $t1, $t1, $t4 # Adjust y1
   
   # Get the location of the handle
   div $t5, $t3, 2
   add $t5, $t1, $t5
   
   # $t2=x2 and $t3=y2
   add $t2, $t0, $t2 # x2
   add $t3, $t1, $t3 # y2
   
   # Scale x1, y1, x2, and y2
   sll $t0, $t0, 2 # x1 scale by 4
   sll $t1, $t1, 8 # y1 scale by 512 x 4 / 8
   sll $t2, $t2, 2 # x2 scale by 4
   sll $t3, $t3, 8 # y2 scale by 512 x 4 / 8
   
   # Scale the location of handle
   sll $t5, $t5, 8 # scale the location by 512 x 4 / 8
   
   # Calculate the coordinates
   addu $t1, $t7, $t1 # Row starting address
   addu $t3, $t7, $t3 # Row ending address
   addu $t3, $t3, $t0 # Procedure ending address
   addu $t5, $t7, $t5 # Handle row starting address
   addu $t5, $t5, $t2 # Handle starting address
   addu $t0, $t1, $t0 # Hammer starting address (row)
   addu $t2, $t1, $t2 # Hammer ending address (row)
   
draw_hammer_row:
   
   # Create a pointer
   move $t4, $t0

draw_hammer_column:
   
   # Color the pixel
   sw $t6, ($t4)
   
   # Move to the next pixel
   addiu $t4, $t4, 4
   
   # Check if need to loop
   bne $t4, $t2, draw_hammer_column
   
   # Check if need to draw the handle
   bne $t5, $t4, draw_hammer_column_end
   
   # Color the handle
   sw $t6, 0($t5)
   sw $t6, 4($t5)
   sw $t6, 8($t5)
   sw $t6, 12($t5)
   
draw_hammer_column_end:
   
   # Move on to the next row
   addiu $t0, $t0, 256
   addiu $t2, $t2, 256
   
   # Check if need to loop
   bne $t3, $t0, draw_hammer_row  
   
draw_hammer_end:
   
   # Return to the caller
   jr $ra
   
#===================================================================================================
# draw_hammer procedure ends
#===================================================================================================

#===================================================================================================
# get_input procedure starts
#===================================================================================================
# No inputs
# $v0 = User input
#======================================

# Get an input until time is up or the input is received
get_input:

   # Get the starting time
   li $v0, 30
   syscall
   move $t0, $a0 # $t0 = the starting time

   # Set the time limit
   li $t1, 3000 # $t1 = the time limit == 3 seconds

get_input_check_time:

   # Get the current time
   li $v0, 30
   syscall
   move $t2, $a0 # $t2 = the current time

   # Check if time is up
   sub $t2, $t2, $t0 # $t2 = the current time - the starting time
   bleu $t1, $t2, get_input_end # End if time is up
   
get_input_check_keyboard:
   
   # Check the keyboard control register
   lw $t3, 0xFFFF0000($zero) # Load keyboard control register
   beq $t3, $zero, get_input_check_time # Check time again if no input yet
   
get_input_read_keyboard:

   # Load the keyboard data
   lw $t4, 0xFFFF0004($zero) # Read keyboard data
   move $v0, $t4 # Move the input to $v0
   
get_input_end:
   
   # Return to the caller
   jr $ra
   
#===================================================================================================
# get_input procedure ends
#===================================================================================================

#===================================================================================================
# convert_input procedure starts
#===================================================================================================
# $a0 = the user input (ASCII)
# $v0 = the converted user input (# or NULL=0)
#======================================

# Convert the user input to its corresponding number or NULL=0
convert_input:
   
   # input == 49
   li $v0, 1 # $v0 = 1
   beq $a0, 49, convert_input_end # Do not change $v0 after this
   
   # input == 50
   addi $v0, $v0, 1 # $v0 = 2
   beq $a0, 50, convert_input_end # Do not change $v0 after this
   
   # input == 51
   addi $v0, $v0, 1 # $v0 = 3
   beq $a0, 51, convert_input_end # Do not change $v0 after this
   
   # input == 52
   addi $v0, $v0, 1 # $v0 = 4
   beq $a0, 52, convert_input_end # Do not change $v0 after this
   
   # input == 53
   addi $v0, $v0, 1 # $v0 = 5
   beq $a0, 53, convert_input_end # Do not change $v0 after this
   
   # input == 54
   addi $v0, $v0, 1 # $v0 = 6
   beq $a0, 54, convert_input_end # Do not change $v0 after this
   
   # input == 55
   addi $v0, $v0, 1 # $v0 = 7
   beq $a0, 55, convert_input_end # Do not change $v0 after this
   
   # input == 56
   addi $v0, $v0, 1 # $v0 = 8
   beq $a0, 56, convert_input_end # Do not change $v0 after this
   
   # input == 57
   addi $v0, $v0, 1 # $v0 = 9
   beq $a0, 57, convert_input_end # Do not change $v0 after this
   
   # input == Else
   li $v0, 0 # $v0 = 0
   
convert_input_end:
   
   # Return to the caller
   jr $ra

#===================================================================================================
# convert_input procedure ends
#===================================================================================================

#===================================================================================================
# check_input procedure starts
#===================================================================================================
# $s4 = the mole's position (1-9)
# $a0 = the converted user input (0-9)
# $v0 = (0 == not correct) or (1 == correct)
#======================================

# Compare the user input with the mole's position
check_input:
   
   # Set the initial value of $v0
   li $v0, 0
   
   # Do not change $v0 if not correct
   bne $s4, $a0, check_input_end
   
   # Change $v0 if correct
   li $v0, 1
   
check_input_end:

   # Return to the caller
   jr $ra

#===================================================================================================
# check_input procedure ends
#===================================================================================================

#===================================================================================================
# print_current_score procedure starts
#===================================================================================================
# No inputs
# No return values
#======================================

# Print the current score
print_current_score:

   # Print score_label
   li $v0, 4
   la $a0, score_label
   syscall
   
   # Print score
   li $v0, 1
   lw $a0, score
   syscall
   
   # Print score_nextline
   li $v0, 4
   la $a0, score_nextline
   syscall
   
   # Return to the caller
   jr $ra

#===================================================================================================
# print_current_score procedure ends
#===================================================================================================
