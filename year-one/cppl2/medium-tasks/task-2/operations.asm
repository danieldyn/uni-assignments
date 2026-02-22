section .text

global sort
global get_words

extern qsort
extern strlen
extern strcmp

;  sort(char **words, int number_of_words, int size)

sort:
    ; create a new stack frame
    enter 0, 0
    ; calling convention
    push esi
    push edi
    push ebx

    push compare            ; auxiliary function 
    push dword [ebp + 16]   ; size
    push dword [ebp + 12]   ; number of words
    push dword [ebp + 8]    ; array of words
    call qsort
    add esp, 16
    ; calling convention
    pop ebx
    pop edi
    pop esi
    
    leave
    ret

;  compare(char **string1, char **string2)

compare:
    ; create a new stack frame
    enter 0, 0
    ; calling convention
    push esi
    push edi
    push ebx
    ; determine the length of the first string
    mov eax, [ebp + 8]
    push dword [eax]
    call strlen
    add esp, 4
    mov ecx, eax
    ; save the result on the stack
    push ecx
    ; determine the length of the second string
    mov eax, [ebp + 12]
    push dword [eax]
    call strlen
    add esp, 4
    mov edx, eax
    ; compare the lengths
    pop ecx
    cmp ecx, edx
    jne diff_length
    ; use the result of strcmp to compare lexicographically
    mov eax, [ebp + 12]
    mov ebx, [ebp + 8]
    push dword [eax]
    push dword [ebx]
    call strcmp
    add esp, 8
    jmp end

diff_length:
    ; the result will be length1 - length2
    mov eax, ecx
    sub eax, edx
     
end:
    ; calling convention
    pop ebx
    pop edi
    pop esi

    leave
    ret

;  get_words(char *s, char **words, int number_of_words)

get_words:
    ; create a new stack frame
    enter 0, 0
    ; calling convention
    push esi
    push edi
    push ebx
    
    mov esi, [ebp + 8]      ; s
    mov edi, [ebp + 12]     ; words
    mov edx, [ebp + 16]     ; number_of_words
    ; initialise counter
    xor ecx, ecx

iterate_string:
    ; check if the current character is a separator
    mov al, byte [esi]
    cmp al, ','
    je next_char
    cmp al, '.'
    je next_char
    cmp al, ' '
    je next_char
    cmp al, 10      ; '\n'
    je next_char
    ; copy the start address of the word
    mov [edi + 4 * ecx], esi
    ; search for the end of the word 
    inc ecx
    inc esi

skip_word:
    ; similarly, check for separators
    mov al, byte [esi]
    cmp al, 0       ; '\0'
    je terminator
    cmp al, ','
    je terminator
    cmp al, '.'
    je terminator
    cmp al, ' '
    je terminator
    cmp al, 10      ; '\n'
    je terminator
    ; move to the next character
    inc esi
    jmp skip_word

terminator:
    ; place string terminator where the separator was encountered
    mov byte [esi], 0

next_char:
    ; iterate until the final character
    inc esi
    cmp ecx, edx
    jb iterate_string
    
    ; calling convention
    pop ebx
    pop edi
    pop esi
    
    leave
    ret
