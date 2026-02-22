global check_row
global check_column
global check_box

section .text

; function signature:
; int check_row(char* sudoku, int row);

check_row:
    ; create new stack frame and save registers
    push    ebp
    mov     ebp, esp
    pushad

    mov esi, [ebp + 8]          ; pointer to 81-long char array
    mov edx, [ebp + 12]         ; row 

find_row:
    cmp edx, 0
    je found_row

    ; move to the beginning of the next line
    dec edx
    add esi, 9
    jmp find_row

found_row:
    ; check the found row
    xor ecx, ecx

iterate_row_i:
    ; check for disallowed numbers
    mov bl, byte [esi + ecx]
    cmp bl, '1'
    jb invalid_row
    cmp bl, '9'
    ja invalid_row
    
    ; check all pairs
    mov edx, ecx
    inc edx

iterate_row_j:
    mov bh, byte [esi + edx]
    cmp bh, bl
    je invalid_row

    ; inner loop goes up to the final number
    inc edx
    cmp edx, 9
    jne iterate_row_j

    ; outer loop goes up to the penultimate number
    inc ecx
    cmp ecx, 8
    jne iterate_row_i

    ; the line is valid
    popad
    mov eax, 1
    jmp end_check_row

invalid_row:
    popad
    mov eax, 2
    
end_check_row:
    
    leave
    ret
    
; function signature:
; int check_column(char* sudoku, int column);

check_column:
    ; create new stack frame and save registers
    push    ebp
    mov     ebp, esp
    pushad

    mov esi, [ebp + 8]          ; pointer to 81-long char array
    mov edx, [ebp + 12]         ; column 

find_column:
    cmp edx, 0
    je found_column

    ; move to the beginning of the next column
    dec edx
    inc esi
    jmp find_column

found_column:
    ; check the found column
    xor ecx, ecx

iterate_column_i:
    ; find the position of the current element in the array
    push ecx
    push edx

    mov eax, 9
    mul ecx     ; the low part in eax matters
    
    ; extract the correct element
    mov ecx, eax
    mov bl, byte [esi + ecx]
    
    pop edx
    pop ecx
    
    ; check for disallowed numbers
    cmp bl, '1'
    jb invalid_column
    cmp bl, '9'
    ja invalid_column
    
    ; check all pairs
    mov edx, ecx
    inc edx

iterate_column_j:
    ; determine the other element in the pair similarly
    push ecx
    push edx

    mov ecx, edx
    mov eax, 9
    mul edx     ; the low part in eax matters

    ; extract the current element
    mov ecx, eax
    mov bh, byte [esi + ecx]
    
    pop edx
    pop ecx
    
    cmp bh, bl
    je invalid_column
    
    ; the inner loop goes up to the final number
    inc edx
    cmp edx, 9
    jne iterate_column_j

    ; the outer loop goes up to the penultimate number
    inc ecx
    cmp ecx, 8
    jne iterate_column_i

    ; the column is valid
    popad
    mov eax, 1
    jmp end_check_column

invalid_column:
    popad
    mov eax, 2

end_check_column:
    
    leave
    ret

; function signature:
; int check_box(char* sudoku, int box);

check_box:
    ; create new stack frame and save registers
    push ebp
    mov ebp, esp
    pushad

    mov esi, [ebp + 8]          ; pointer to 81-long char array
    mov edx, [ebp + 12]         ; box 

find_top_left:
    cmp edx, 0
    je found_top_left

    xor ecx, ecx
find_box:
    ; move to the next box
    add esi, 3
    dec edx
    cmp edx, 0
    je found_top_left

    ; the inner loop checks the three top left box corners on each line
    inc ecx
    cmp ecx, 2
    jb find_box

    ; the outer loop skips two lines every time esi isn't on the top line
    add esi, 21
    dec edx
    jmp find_top_left

found_top_left:
    ; check the found box
    xor ecx, ecx

iterate_box_i:
    ; check for disallowed numbers
    mov bl, byte [esi + ecx]
    cmp bl, '1'
    jb invalid_box
    cmp bl, '9'
    ja invalid_box

    ; determine the offset of the next element
    push ebx

    mov eax, ecx
    mov bl, 3
    div bl      ; remainder in ah, quotiennt in al
    
    pop ebx
    
    cmp ah, 2
    jb same_line_i
    
    ; here the next element is on the next line, different offset
    mov edx, ecx
    add edx, 7
    add ecx, 7
    jmp iterate_box_j

same_line_i:
    ; increment offsets
    mov edx, ecx
    inc edx
    inc ecx

iterate_box_j:
    ; check all pairs
    mov bh, byte [esi + edx]
    cmp bh, bl
    je invalid_box
    
    ; determine the offset of the other element in the pair
    push ebx

    mov eax, edx
    mov bl, 3
    div bl      ; remainder in ah, quotient in al
    
    pop ebx
    
    cmp ah, 2
    jb same_line_j
    
    ; check if there are other elements to compare
    cmp edx, 20
    je next_number

    ; here the other element in the pair is on the next line
    add edx, 7
    jmp iterate_box_j

same_line_j:
    ; the inner loop goes up to the last number in the box
    inc edx
    cmp edx, 20
    jbe iterate_box_j

next_number
    ; the outer loop goes up to the penultimate number in the box
    cmp ecx, 20    
    jb iterate_box_i

    popad
    mov eax, 1
    jmp end_check_box

invalid_box:
    popad
    mov eax, 2

end_check_box:
    
    leave
    ret
