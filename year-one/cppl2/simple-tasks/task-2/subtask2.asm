; struct declarations
struc date
    day: resb 1
    month: resb 1
    year: resw 1
endstruc

struc event
    name: resb 31
    valid: resb 1
    ev_date: resb date_size
endstruc

global sort_events

section .text

; function signature: 
; void sort_events(struct event *events, int len);

sort_events:
    ; create stack frame and save registers
    push ebp
    mov ebp, esp
    pusha

    mov ebx, [ebp + 8]      ; events pointer
    mov ecx, [ebp + 12]     ; number of events

    ; outer loop goes up to the penultimate event
    dec ecx

iterate_events_i:
    mov edx, ecx        ; inner loop counter
    mov esi, ebx        ; pointer to current structure

iterate_events_j:
    ; compare validity
    xor eax, eax
    mov al, byte [esi + valid]
    mov ah, byte [esi + event_size + valid]
    cmp al, ah
    jb swap
    ja skip_swap

    ; compare year
    push edx
    mov ax, word [esi + ev_date + year]
    mov dx, word [esi + event_size + ev_date + year]
    cmp ax, dx
    pop edx
    ja swap
    jb skip_swap

    ; compare month
    mov al, byte [esi + ev_date + month]
    mov ah, byte [esi + event_size + ev_date + month]
    cmp al, ah
    ja swap
    jb skip_swap

    ; compare day
    mov al, byte [esi + ev_date + day]
    mov ah, byte [esi + event_size + ev_date + day]
    cmp al, ah
    ja swap
    jb skip_swap

    ; compare names lexicographically byte by byte
    push ecx
    push esi
    mov  ecx, event_size
    dec  ecx
    xor  eax, eax

compare_chars:
    mov al, byte [esi]
    mov ah, byte [esi + event_size]
    cmp al, ah
    ja fix_stack_and_swap
    jb fix_stack_and_skip_swap

    ; move to the next char
    inc esi
    dec ecx
    cmp ecx, 0
    jne compare_chars

fix_stack_and_skip_swap:
    pop esi
    pop ecx
    jmp skip_swap

fix_stack_and_swap:
    pop esi
    pop ecx
    ; continue with swap

swap:
    ; swap the two event structures byte by byte
    push ecx
    push esi
    mov ecx, event_size
    xor eax, eax

swap_bytes:
    mov al, byte [esi]
    mov ah, byte [esi + event_size]
    mov byte [esi + event_size], al
    mov byte [esi], ah
    
    ; move to the next byte
    inc esi
    dec ecx
    cmp ecx, 0
    jne swap_bytes

    ; fix the stack after the swap
    pop esi
    pop ecx

skip_swap:
    ; inner loop advancement
    add esi, event_size
    dec edx
    cmp edx, 0
    jne iterate_events_j

    ; outer loop advancement
    dec ecx
    cmp ecx, 0
    jne iterate_events_i

    ; restore registers and return
    popa
    leave
    ret
