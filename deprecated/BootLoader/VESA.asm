[bits 16]

highestx: dw 0
highesty: dw 0

depth: db 0

modenumber: dw 0
selected: dw 0

vbe_controller_info:
    .signature: dd 0
    .version: dw 0
    .oemstringoff: dw 0 ; far ptr
    .oemstringseg: dw 0
    .capabilities: dd 0
    .videomodesoff: dw 0
    .videomodesseg: dw 0
    .totalmemory: dw 0
    times 492 db 0

video_mode_description:
    .modeatrrib: dw 0
    .winaatrrib: db 0
    .winbatrrib: db 0
    .wingran: dw 0
    .winsize: dw 0
    .winasegment: dw 0
    .winbsegment: dw 0
    .winfuncoff: dw 0
    .winfuncseg: dw 0
    .bytesperscanl: dw 0
    .xres: dw 0
    .yres: dw 0
    .xcharsize: db 0
    .ycharsize: db 0
    .planes: db 0
    .bpp: db 0
    .banks: db 0
    .memorymodel: db 0
    .banksize: db 0
    .imagepages: db 0
    .reserved1: db 1
    .redmasksize: db 0
    .redmaskpos: db 0
    .greenmasksize: db 0
    .greenmaskpos: db 0
    .bluemasksize: db 0
    .bluemaskpos: db 0
    .rsvdmasksize: db 0
    .rsvdmaskpos: db 0
    .colormodeinfo: db 0
    .physbaseaddr: dw 0
    .reserved2: dd 0
    .reserved3: dw 0
    .linbytes: dw 0
    .banknumber: db 0
    .linnumber: db 0
    .linredmasks: db 0
    .linredmaskp: db 0
    .lingreenmasks: db 0
    .lingreenmaskp: db 0
    .linbluemasks: db 0
    .linbluemaskp: db 0
    .linrsvdmasks: db 0
    .linrsvdmaskp: db 0
    .maxpixelclock: db 0
    .reserved4: times 189 db 0

;
; get_controller_info()
; es:di - buffer for VBE Controller Info structure
;

get_controller_info:
    mov ax, 0x4f00
    mov di, vbe_controller_info
    int 0x10

    cmp al, 0x4f
    jne .not_supported

    cmp ah, 0
    jne .not_supported

    cmp byte [vbe_controller_info.signature], 'V'
    jne .not_supported
    cmp byte [vbe_controller_info.signature + 1], 'E'
    jne .not_supported
    cmp byte [vbe_controller_info.signature + 2], 'S'
    jne .not_supported
    cmp byte [vbe_controller_info.signature + 3], 'A'
    jne .not_supported

    ret
    
    .not_supported:
        xor eax, eax
    
        ret

;
; get_mode_info()
; Loads given mode's info into mode info structure.
; ax - mode number
;

get_mode_info:
    mov cx, ax
    mov di, video_mode_description

    mov ax, 0x4f01

    int 0x10

    cmp al, 0x4f
    jne .fail

    cmp ah, 0
    jne .fail

    ret

    .fail:
        xor eax, eax

        ret

;
; setup_video_mode()
; Setups video mode, using mode with highest resolution available.
;

setup_video_mode:
    mov di, vbe_controller_info
    call get_controller_info

    cmp eax, 0
    je .fail

    xor edx, edx

    .loop:
        xor eax, eax
        xor ebx, ebx

        push es
        mov ax, [vbe_controller_info.videomodesseg]
        mov es, ax
        mov ax, [es:vbe_controller_info.videomodesoff + 2 * edx]
        pop es

        cmp ax, 0xffff
        je .selected

        mov word [modenumber], ax

        call get_mode_info

        cmp eax, 0
        je .advance

        mov eax, [video_mode_description.modeatrrib]

        and eax, 0x90
        cmp eax, 0x90
        jne .advance

        cmp byte [video_mode_description.memorymodel], 6
        jne .advance

        cmp byte [video_mode_description.planes], 1
        jne .advance

        mov al, byte [video_mode_description.bpp]
        cmp al, byte [depth]
        jl .advance

        mov ax, word [video_mode_description.xres]
        cmp ax, word [highestx]
        jl .advance

        mov ax, word [video_mode_description.yres]
        cmp ax, word [highesty]
        jl .advance

        ; hack to make entire bochs window visible on my 1600x900 notebook
        cmp ax, 760
        jg .advance

        mov al, byte [video_mode_description.bpp]

        cmp al, 16
        je .bpp

        cmp al, 32
        jne .advance

    .bpp:
        mov ax, word [modenumber]
        mov word [selected], ax

        mov ax, word [video_mode_description.xres]
        mov word [highestx], ax

        mov ax, word [video_mode_description.yres]
        mov word [highesty], ax

        mov al, byte [video_mode_description.bpp]
        mov byte [depth], al

    .advance:
        inc edx

        jmp .loop

    .selected:
        cmp word [selected], 0
        je .failset

        mov bx, word [selected]

        mov ax, bx
        call get_mode_info
        
        xor eax, eax
        mov ax, word [video_mode_description.xres]
        mov ax, word [video_mode_description.yres]
        
        xor eax, eax
        mov al, byte [video_mode_description.bpp]
        
        mov eax, dword [video_mode_description.physbaseaddr]
    
        xor eax, eax

        ; set only bit D14 and D0-D8 (use linar frame buffer mode)
        and bx, 0100000111111111b
        or bx, 0100000000000000b

        mov ax, 0x4f02
        int 0x10

        cmp ah, 0
        jne .failset

        push es
        xor ax, ax
        mov es, ax
        mov di, 0x9000
        call get_bios_vga_font
        pop es

        ret

    .failset:
    .fail:
        mov word [video_mode_description.xres], word 0

        xor eax, eax

        ret

;
; get_bios_vga_font()
; es:di - buffer to load the font to
;

get_bios_vga_font:
    push ds
    push es
    
    mov ax, 0x1130
    mov bh, 6
        
    int 0x10

    push es
    pop ds
    pop es

    mov si, bp
    mov cx, 256 * 16 / 4

    rep movsd

    pop ds

    ret