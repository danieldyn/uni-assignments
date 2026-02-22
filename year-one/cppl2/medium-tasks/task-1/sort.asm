;   struct node {
;    int val;
;    struct node* next;
;   };

struc node
    val resd 1
    next resd 1
endstruc

section .text

global sort

;; struct node* sort(int n, struct node* node);
;   The function will link the nodes in the array
;   in ascending order and will return the address
;   of the new found head of the list
; @params:
;   n -> the number of nodes in the array
;   node -> a pointer to the beginning in the array
;   @returns:
;   the address of the head of the sorted list

sort:
    ; create a new stack frame
    enter 0, 0
    
    ; calling convention
    push esi
    push edi
    push ebx

    ; local variable to store the function result
    sub esp, 4

    mov edi, [ebp + 8]         ; number of nodes
    mov esi, [ebp + 12]         ; list head
    
    ; search for the head of the list first
    mov edx, 1

find_value:
    ; save list head before searching
    push esi
    xor ecx, ecx

find_current:
    ; compare the current node's value
    lea eax, [esi + val]
    cmp [eax], edx
    je found_current

    ; move to the next node
    add esi, node_size
    inc ecx
    cmp ecx, edi
    jb find_current

found_current:
    ; check if the current node is the head of the new list
    cmp edx, 1
    jne not_head

    ; store the head's address in the local variable
    mov [ebp - 4], eax

not_head:
    ; restore list start before new search
    pop esi
    
    ; search for the successor similarly
    inc edx
    xor ecx, ecx
    push esi

find_next:
    ; compare the current node's value
    lea ebx, [esi + val]
    cmp [ebx], edx
    je found_next

    ; move to the next node
    add esi, node_size
    inc ecx
    cmp ecx, edi
    jb find_next

found_next:
    ; restore the start of the list
    pop esi

    ; update the next field
    mov [eax + next], ebx

    ; search until reaching n
    cmp edx, edi
    jb find_value
    
    ; return the right result
    mov eax, [ebp - 4]

    ; calling convention
    pop ebx
    pop edi
    pop esi

    leave
    ret
