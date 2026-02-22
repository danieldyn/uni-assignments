section .bss
    substring resb 150
    answer resb 150

section .text

global check_palindrome
global composite_palindrome

extern strcmp
extern strcpy
extern strcat
extern strlen
extern malloc

; check_palindrome(const char *str, const int len);

check_palindrome:
    ; create a new stack frame
    enter 0, 0
    ; calling convention
    push ebx
    push edi
    push esi

    mov esi, [ebp + 8]      ; str
    mov edx, [ebp + 12]     ; len
    ; use ecx and edx as left and right indices
    dec edx
    xor ecx, ecx
    ; assume the string is a palindrome
    mov eax, 1

iterate_string:
    ; compare elements that should be equal
    mov bh, byte [esi + ecx]
    mov bl, byte [esi + edx]
    cmp bh, bl
    jne not_palindrome
    ; update indices
    inc ecx
    dec edx
    ; check if the middle has been reached
    cmp ecx, edx
    jl iterate_string
    jmp end

not_palindrome: 
    xor eax, eax

end:
    ; calling convention
    pop esi
    pop edi
    pop ebx

    leave
    ret

; composite_palindrome(const char **strs, const int len);

composite_palindrome:
    ; create a new stack frame
    enter 0, 0
    ; calling convention
    push ebx
    push esi
    push edi
    ; initialise answer with null string
    mov byte [answer], 0
    ; get the start address of the word array
    mov esi, [ebp + 8]
    ; initialise mask
    mov edx, 1

check_combination:
    ; initialise index for the array
    xor ecx, ecx

concatenate:
    ; check which bits from the mask are set 
    mov ebx, 1
    shl ebx, cl
    test ebx, edx
    jz skip_concatenate
    ; save registers
    push edx
    push ecx
    ; extract the start of the word to concatenate
    mov eax, [esi + 4 * ecx]
    push eax
    push substring
    call strcat
    add esp, 8
    ; restore registers
    pop ecx
    pop edx

skip_concatenate:
    ; move to the next position in the bitmask
    inc ecx
    cmp ecx, 15
    jl concatenate
    ; check if substring is palindrome
    ; save mask
    push edx
    ; find length of substring
    push substring
    call strlen
    add esp, 4
    ; perform palindrome check
    push eax
    push substring
    call check_palindrome
    add esp, 8
    ; restore mask
    pop edx
    ; check function result
    cmp eax, 0
    je skip_palindrome
    ; check if the found palindrome is a better answer
    ; save mask
    push edx
    ; find length of answer
    push answer
    call strlen
    add esp, 4
    ; move into safe register
    mov ebx, eax
    ; find length of substring
    push substring
    call strlen
    add esp, 4
    ; store result
    mov ecx, eax
    ; restore mask
    pop edx
    ; compare lengths
    cmp ecx, ebx
    jl skip_palindrome
    jg new_answer
    ; for equal length, let strcmp decide
    ; save mask
    push edx
    ; call strcmp function
    push answer
    push substring
    call strcmp
    add esp, 8
    ; restore mask
    pop edx
    ; check function result
    cmp eax, 0
    jge skip_palindrome
    
new_answer:
    ; save mask
    push edx
    ; copy new answer
    push substring
    push answer
    call strcpy
    add esp, 8
    ; restore mask
    pop edx

skip_palindrome:
    ; reinitialise substring for next iteration 
    mov byte [substring], 0
    ; increment mask
    inc edx
    ; 32767 = 2 ^ 15 - 1 possible combinations
    cmp edx, 32767
    jle check_combination
    ; find the size of the answer
    push answer
    call strlen
    add esp, 4
    ; allocate memory for length + 1 bytes
    inc eax
    push eax
    call malloc
    add esp, 4
    ; copy answer on the heap
    push answer
    push eax
    call strcpy
    add esp, 8
    ; calling convention
    pop edi
    pop esi
    pop ebx
    
    leave
    ret
