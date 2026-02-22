section .text

global kfib

; kfib(int n, int K)

kfib:
    ; create a new stack frame
    enter 0, 0
    ; calling convention
    push esi
    push edi
    push ebx

    mov ecx, [ebp + 8]      ; n
    mov edx, [ebp + 12]     ; K
    
    ; check for base case ns <= K
    cmp ecx, edx
    jl zero
    je one
    ; initialise sum of recursive calls and counter
    xor ebx, ebx
    mov esi, 1

recursive:
    ; save local values held by ecx and edx
    push edx
    push ecx
    ; edi = n - index
    mov edi, ecx
    sub edi, esi
    ; recursively call with n - index
    push edx
    push edi
    call kfib
    add esp, 8
    ; restore local ecx and edx
    pop ecx
    pop edx
    ; accumulate sum in ebx
    add ebx, eax
    ; move to the next index
    inc esi
    cmp esi, edx
    jbe recursive
    ; move the result in eax
    mov eax, ebx
    jmp end

one:
    ; result is 1
    mov eax, 1
    jmp end

zero:
    ; result is 0
    xor eax, eax

end:
    ; calling convention
    pop ebx
    pop edi
    pop esi

    leave
    ret
