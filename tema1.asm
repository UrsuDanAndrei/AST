%include "includes/io.inc"

extern getAST
extern freeAST

struc Node
    .value:  resd 1
    .left:  resd 1
    .right: resd 1
endstruc

section .bss
    ; La aceasta adresa, scheletul stocheaza radacina arborelui
    root: resd 1

section .text

; primeste adresa unui string, returneaza string-ul ca numar pozitiv
string2num_poz:
    push ebp
    mov ebp, esp
    
    ; salveaza in esi adresa de inceput a string-ului    
    mov esi, [ebp + 8]
    xor eax, eax
    mov ebx, 10

form_number:
    xor ecx, ecx
    mov cl, [esi]
    sub cl, '0'
    mul ebx
    add eax, ecx

    inc esi
    
    cmp byte [esi], 0
    jne form_number

    leave
    ret


; primeste adresa unui string, returneaza string-ul ca numar
string2num:
    push ebp
    mov ebp, esp
    
    ; se retine in esi adresa de inceput a string-ului   
    mov esi, [ebp + 8]
    xor ebx, ebx
    
    ; se verifica semnul numarului
    cmp byte [esi], '-'
    jne positive

    ; se sare peste '-'
    inc esi
    push esi
    call string2num_poz
    pop esi
    
    ; se schimba semnul lui eax
    neg eax

    jmp end_string2num

positive:
    push esi
    call string2num_poz
    add esp, 4

end_string2num: 
    leave
    ret

; primeste adresa radacinii unui arbore, returneaza valoarea acestuia
calculate_tree:
    push ebp
    mov ebp, esp
    
    ; ebx va deveni root pentru subarborele curent
    mov ebx, [ebp + 8]
    
    ; se verifica daca in root este un numar sau un operator
    cmp dword [ebx + Node.left], 0x00
    jne operator
    
    cmp dword [ebx + Node.right], 0x00
    je number

operator:
    ; se calculeaza subarborele stang
    push ebx
    push dword [ebx + Node.left]
    call calculate_tree
    add esp, 4
    pop ebx
    
    ; se pune rezultatul subarborelui stang pe stiva
    push eax
    
    ; se calculeaza subarborele drept
    push ebx
    push dword [ebx + Node.right]
    call calculate_tree
    add esp, 4
    pop ebx
    
    ; rezultatul subarborelui drept se muta in ecx
    mov ecx, eax

    ; se ia de pe stiva rezultatul subarborelui stang
    pop eax

    ; se retine in edx operatorul
    mov edx, [ebx + Node.value]
    mov edx, [edx]
    
    ; se determina operatia ce trebuie efectuata
    cmp edx, '+'
    je addition
    
    cmp edx, '-'
    je subtraction

    cmp edx, '*'
    je multiplication

    cmp edx, '/'
    je division                  

addition:
    add eax, ecx
    jmp end_calculate_tree

subtraction:
    sub eax, ecx
    jmp end_calculate_tree

multiplication:
    imul ecx
    jmp end_calculate_tree

division:
    xor edx, edx
    cdq    
    idiv ecx
    jmp end_calculate_tree

number:
    push dword [ebx + Node.value]
    call string2num
    add esp, 4
    
end_calculate_tree:
    leave
    ret

global main
main:
    ; NU MODIFICATI
    push ebp
    mov ebp, esp
    
    ; se citeste arborele si se scrie la adresa indicata mai sus
    call getAST
    mov [root], eax
    xor eax, eax

    ; se calculeaza valoarea arborelui cu radacina root
    push dword [root]
    call calculate_tree
    add esp, 4
    
    PRINT_DEC 4, eax
    NEWLINE
    
    ; NU MODIFICATI
    ; se elibereaza memoria alocata pentru arbore
    push dword [root]
    call freeAST
    
    xor eax, eax
    leave
    ret
