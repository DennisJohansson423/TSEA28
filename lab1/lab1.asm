;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; Mall fÃ¶r lab1 i TSEA28 Datorteknik Y
;;
;; 210105 KPa: Modified for distance version
;;

	;; Ange att koden Ã¤r fÃ¶r thumb mode
	.thumb
	.text
	.align 2

	;; Ange att labbkoden startar hÃ¤r efter initiering
	.global	main
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Ange vem som skrivit koden
;;               student LiU-ID: _____Denjo163____________
;; + ev samarbetspartner LiU-ID:_____Anthu456_______
;;
;; Placera programmet hÃ¤r

main:				; Start av programmet
    bl inituart
    bl initGPIOE
    bl initGPIOF

    bl setcode

start:
	bl getkey
	cmp r4, #0xA
	bne start
    b mainloop

mainloop:
    bl activatealarm
    bl clearinput

getinput:
    bl getkey
    cmp r4, #0xF
    beq entercode
    bl addkey
    b getinput

entercode:
    bl checkcode
    cmp r4, #0
    bne rightcode
    adr r4, felkod
    mov r5, #13
    bl printstring
    b getinput

rightcode:
    bl deactivatealarm

getinputagain:
    bl getkey
    cmp r4, #0xA
    beq mainloop
    cmp r4, #0xC
    bne getinputagain
    bl setnewcode
    bl addkey
    bl addnewkey
    b getinput

endloop:
    nop 
    nop 
    b endloop

felkod:
    .align 4
    .string "Felaktig kod!",10,13



;;Satter koden for laset
setcode:
    mov r0, #(0x20001013 & 0xffff)
    movt r0, #(0x20001013 >> 16)
    mov r1, #2
    strb r1, [r0]

    mov r0, #(0x20001012 & 0xffff)
    movt r0, #(0x20001012 >> 16)
    mov r1, #2
    strb r1, [r0]

    mov r0, #(0x20001011 & 0xffff)
    movt r0, #(0x20001011 >> 16)
    mov r1, #2
    strb r1, [r0]

    mov r0, #(0x20001010 & 0xffff)
    movt r0, #(0x20001010 >> 16)
    mov r1, #2
    strb r1, [r0]
    
    bx lr


;;Satter den nya koden
setnewcode:
    mov r0, #(0x20001013 & 0xffff)
    movt r0, #(0x20001013 >> 16)
    mov r1, #(0x20001003 & 0xffff)
    movt r1, #(0x20001003 >> 16)
    ldrb r2, [r1]
    strb r2, [r0]

    mov r0, #(0x20001012 & 0xffff)
    movt r0, #(0x20001012 >> 16)
    mov r1, #(0x20001002 & 0xffff)
    movt r1, #(0x20001002 >> 16)
    ldrb r2, [r1]
    strb r2, [r0]

    mov r0, #(0x20001011 & 0xffff)
    movt r0, #(0x20001011 >> 16)
    mov r1, #(0x20001001 & 0xffff)
    movt r1, #(0x20001001 >> 16)
    ldrb r2, [r1]
    strb r2, [r0]

    mov r0, #(0x20001010 & 0xffff)
    movt r0, #(0x20001010 >> 16)
    mov r1, #(0x20001000 & 0xffff)
    movt r1, #(0x20001000 >> 16)
    ldrb r2, [r1]
    strb r2, [r0]

    ;;mov r4, #1
    bl controllcode


;;Inargument: Pekare till strangen i r4
;;            Laangd pa strangen i r5
;;Utargument: Inga
;;Funktion: Skriver ut strangen mha subrutinen printchar
printstring:
    push {lr}
    mov r3, #0
    add r8, r8, #1
stringloop:
    ldrb r0, [r4]
    bl printchar

    add r4, r4, #1
    add r3, r3, #1
    cmp r3, r5
    bne stringloop

    mov r0, r8
    bl printchar

    mov r0, #0x0d
    bl printchar
    mov r0, #0x0a
    bl printchar
    pop {lr}
    bx lr


;;Inargument: Inga
;;Utargument: Inga
;;Funktion: Tander gron lysdiod (bit 3 = 1, bit 2 = 0, bit 1 = 0)
deactivatealarm:
    mov r10, #0
    mov r0, #8
    mov r1, #(GPIOF_GPIODATA & 0xffff)
    movt r1, #(GPIOF_GPIODATA >> 16)
    strb r0, [r1]
    bx lr


;;Inargument: Inga
;;Utargument: Inga
;;Funktion: Tander rod lysdiod (bit 3 = 0, bit 2 = 0, bit 1 = 1)
activatealarm:
    mov r10, #1
    mov r0, #0x2
    mov r1, #(GPIOF_GPIODATA & 0xffff)
    movt r1, #(GPIOF_GPIODATA >> 16)
    strb r0, [r1]
    bx lr


;;Inargument: Inga
;;Utargument: Tryckt knappt returneras i r4
;;Funktion: Hamtar tecken fran hextangent bordet
getkey:
    mov r1, #(GPIOE_GPIODATA & 0xffff)
	movt r1, #(GPIOE_GPIODATA >> 16)

	ldrb r4, [r1]
	ands r5, r4, #16
	beq getkey

getkeyloop:
	ldrb r4, [r1]
	ands r5, r4, #16
	bne getkeyloop
	bx lr


;;Inargument: Vald tangent i r4
;;Utargument: Inga
;;Funktion: Flyttar innehallet pa 0x20001000-0x20001002 framat en byte
;;          till 0x20001001-0x20001003. Lagrar sedan innehallet i r4 pa
;;          adress 0x20001000.
addkey:
    mov r3, #(0x20001003 & 0xffff)
    movt r3, #(0x20001003 >> 16)

    mov r2, #(0x20001002 & 0xffff)
    movt r2, #(0X20001002 >> 16)

    mov r1, #(0x20001001 & 0xffff)
    movt r1, #(0x20001001 >> 16)

    mov r0, #(0x20001000 & 0xffff)
    movt r0, #(0x20001000 >> 16)

    ldrb r5, [r2]
    strb r5, [r3]
    ldrb r5, [r1]
    strb r5, [r2]
    ldrb r5, [r0]
    strb r5, [r1]

    strb r4, [r0]
    bx lr


;;satter nyckeln till den nya koden på samma sätt som addkey
addnewkey:
    mov r3, #(0x20001007 & 0xffff)
    mov r3, #(0x20001007 >> 16)
    
    mov r2, #(0x20001006 & 0xffff)
    movt r2, #(0X20001006 >> 16)

    mov r1, #(0x20001005 & 0xffff)
    movt r1, #(0x20001005 >> 16)

    mov r0, #(0x20001004 & 0xffff)
    movt r0, #(0x20001004 >> 16)

    ldrb r5, [r2]
    strb r5, [r3]
    ldrb r5, [r1]
    strb r5, [r2]
    ldrb r5, [r0]
    strb r5, [r1]

    strb r6, [r0]
    bx lr


;;Inargument: Inga
;;Utargument: Inga
;;Funktion: Satter innehallet pa 0x20001000-0x20001003 till 0xFF
clearinput:
    mov r0, #0xFF

    mov r1, #(0x20001003 & 0xffff)
    movt r1, #(0x20001003 >> 16)
    strb r0, [r1]

    mov r1, #(0x20001002 & 0xffff)
    movt r1, #(0x20001002 >> 16)
    strb r0, [r1]

    mov r1, #(0x20001001 & 0xffff)
    movt r1, #(0x20001001 >> 16)
    strb r0, [r1]

    mov r1, #(0x20001000 & 0xffff)
    movt r1, #(0x20001000 >> 16)
    strb r0, [r1]
    bx lr


;;Inargument: Inga
;;Utargument: Returnerar 1 i r4 om koden var korrekt, annars 0 i r4
;;Funktion: Kollar om ratt kod skrivits in
checkcode:
    mov r0, #(0x20001010 & 0xffff)
    movt r0, #(0x20001010 >> 16)
    ldr r2, [r0]

    mov r1, #(0x20001000 & 0xffff)
    movt r1, #(0x20001000 >> 16)
    ldr r3, [r1]

    cmp r2, r3
    bne wrongcode
    mov r4, #1
    bx lr


;;Anroppas om den nya kodan ska kontrolleras
checknewcode:
    mov r0, #(0x20001000 & 0xffff)
    movt r0, #(0x20001000 >> 16)
    ldr r2, [r0]

    mov r1, #(0x20001004 & 0xffff)
    movt r1, #(0x20001004 >> 16)
    ldr r3, [r1]

    mov r4, #1
    cmp r2, r3
    beq mainloop
    mov r4, #0
    b getinputagain


;;Kontrollerar om den nya koden ar godtagbar
;;Kontrollerar om alla siffror i nya koden ar siffror
controllcode:
    bl getkey
    cmp r4, #0xA
    beq mainloop

    cmp r4, #0xB
    beq mainloop

    cmp r4, #0xC
    beq mainloop

    cmp r4, #0xD
    beq mainloop

    cmp r4, #0xE
    beq mainloop

    cmp r4, #0xF
    beq mainloop

    bl checknewcode

;;Anroppas om fel kod skrivits in
wrongcode:
    mov r4, #0
    bx lr


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,
;;;
;;; Allt hÃ¤r efter ska inte Ã¤ndras
;;;
;;; Rutiner fÃ¶r initiering
;;; Se labmanual fÃ¶r vilka namn som ska anvÃ¤ndas
;;;
	
	.align 4

;; 	Initiering av seriekommunikation
;;	FÃ¶rstÃ¶r r0, r1 
	
inituart:
	mov r1,#(RCGCUART & 0xffff)		; Koppla in serieport
	movt r1,#(RCGCUART >> 16)
	mov r0,#0x01
	str r0,[r1]

	mov r1,#(RCGCGPIO & 0xffff)
	movt r1,#(RCGCGPIO >> 16)
	ldr r0,[r1]
	orr r0,r0,#0x01
	str r0,[r1]		; Koppla in GPIO port A

	nop			; vÃ¤nta lite
	nop
	nop

	mov r1,#(GPIOA_GPIOAFSEL & 0xffff)
	movt r1,#(GPIOA_GPIOAFSEL >> 16)
	mov r0,#0x03
	str r0,[r1]		; pinnar PA0 och PA1 som serieport

	mov r1,#(GPIOA_GPIODEN & 0xffff)
	movt r1,#(GPIOA_GPIODEN >> 16)
	mov r0,#0x03
	str r0,[r1]		; Digital I/O pÃ¥ PA0 och PA1

	mov r1,#(UART0_UARTIBRD & 0xffff)
	movt r1,#(UART0_UARTIBRD >> 16)
	mov r0,#0x08
	str r0,[r1]		; SÃ¤tt hastighet till 115200 baud
	mov r1,#(UART0_UARTFBRD & 0xffff)
	movt r1,#(UART0_UARTFBRD >> 16)
	mov r0,#44
	str r0,[r1]		; Andra vÃ¤rdet fÃ¶r att fÃ¥ 115200 baud

	mov r1,#(UART0_UARTLCRH & 0xffff)
	movt r1,#(UART0_UARTLCRH >> 16)
	mov r0,#0x60
	str r0,[r1]		; 8 bit, 1 stop bit, ingen paritet, ingen FIFO
	
	mov r1,#(UART0_UARTCTL & 0xffff)
	movt r1,#(UART0_UARTCTL >> 16)
	mov r0,#0x0301
	str r0,[r1]		; BÃ¶rja anvÃ¤nda serieport

	bx  lr

; Definitioner fÃ¶r registeradresser (32-bitars konstanter) 
GPIOHBCTL	.equ	0x400FE06C
RCGCUART	.equ	0x400FE618
RCGCGPIO	.equ	0x400fe608
UART0_UARTIBRD	.equ	0x4000c024
UART0_UARTFBRD	.equ	0x4000c028
UART0_UARTLCRH	.equ	0x4000c02c
UART0_UARTCTL	.equ	0x4000c030
UART0_UARTFR	.equ	0x4000c018
UART0_UARTDR	.equ	0x4000c000
GPIOA_GPIOAFSEL	.equ	0x40004420
GPIOA_GPIODEN	.equ	0x4000451c
GPIOE_GPIODATA	.equ	0x400240fc
GPIOE_GPIODIR	.equ	0x40024400
GPIOE_GPIOAFSEL	.equ	0x40024420
GPIOE_GPIOPUR	.equ	0x40024510
GPIOE_GPIODEN	.equ	0x4002451c
GPIOE_GPIOAMSEL	.equ	0x40024528
GPIOE_GPIOPCTL	.equ	0x4002452c
GPIOF_GPIODATA	.equ	0x4002507c
GPIOF_GPIODIR	.equ	0x40025400
GPIOF_GPIOAFSEL	.equ	0x40025420
GPIOF_GPIODEN	.equ	0x4002551c
GPIOF_GPIOLOCK	.equ	0x40025520
GPIOKEY		.equ	0x4c4f434b
GPIOF_GPIOPUR	.equ	0x40025510
GPIOF_GPIOCR	.equ	0x40025524
GPIOF_GPIOAMSEL	.equ	0x40025528
GPIOF_GPIOPCTL	.equ	0x4002552c

;; Initiering av port F
;; FÃ¶rstÃ¶r r0, r1, r2
initGPIOF:
	mov r1,#(RCGCGPIO & 0xffff)
	movt r1,#(RCGCGPIO >> 16)
	ldr r0,[r1]
	orr r0,r0,#0x20		; Koppla in GPIO port F
	str r0,[r1]
	nop 			; VÃ¤nta lite
	nop
	nop

	mov r1,#(GPIOHBCTL & 0xffff)	; AnvÃ¤nd apb fÃ¶r GPIO
	movt r1,#(GPIOHBCTL >> 16)
	ldr r0,[r1]
	mvn r2,#0x2f		; bit 5-0 = 0, Ã¶vriga = 1
	and r0,r0,r2
	str r0,[r1]

	mov r1,#(GPIOF_GPIOLOCK & 0xffff)
	movt r1,#(GPIOF_GPIOLOCK >> 16)
	mov r0,#(GPIOKEY & 0xffff)
	movt r0,#(GPIOKEY >> 16)
	str r0,[r1]		; LÃ¥s upp port F konfigurationsregister

	mov r1,#(GPIOF_GPIOCR & 0xffff)
	movt r1,#(GPIOF_GPIOCR >> 16)
	mov r0,#0x1f		; tillÃ¥t konfigurering av alla bitar i porten
	str r0,[r1]

	mov r1,#(GPIOF_GPIOAMSEL & 0xffff)
	movt r1,#(GPIOF_GPIOAMSEL >> 16)
	mov r0,#0x00		; Koppla bort analog funktion
	str r0,[r1]

	mov r1,#(GPIOF_GPIOPCTL & 0xffff)
	movt r1,#(GPIOF_GPIOPCTL >> 16)
	mov r0,#0x00		; anvÃ¤nd port F som GPIO
	str r0,[r1]

	mov r1,#(GPIOF_GPIODIR & 0xffff)
	movt r1,#(GPIOF_GPIODIR >> 16)
	mov r0,#0x0e		; styr LED (3 bits), andra bitar Ã¤r ingÃ¥ngar
	str r0,[r1]

	mov r1,#(GPIOF_GPIOAFSEL & 0xffff)
	movt r1,#(GPIOF_GPIOAFSEL >> 16)
	mov r0,#0		; alla portens bitar Ã¤r GPIO
	str r0,[r1]

	mov r1,#(GPIOF_GPIOPUR & 0xffff)
	movt r1,#(GPIOF_GPIOPUR >> 16)
	mov r0,#0x11		; svag pull-up fÃ¶r tryckknapparna
	str r0,[r1]

	mov r1,#(GPIOF_GPIODEN & 0xffff)
	movt r1,#(GPIOF_GPIODEN >> 16)
	mov r0,#0xff		; alla pinnar som digital I/O
	str r0,[r1]

	bx lr


;; Initiering av port E
;; FÃ¶rstÃ¶r r0, r1
initGPIOE:
	mov r1,#(RCGCGPIO & 0xffff)    ; Clock gating port (slÃ¥ pÃ¥ I/O-enheter)
	movt r1,#(RCGCGPIO >> 16)
	ldr r0,[r1]
	orr r0,r0,#0x10		; koppla in GPIO port B
	str r0,[r1]
	nop			; vÃ¤nta lite
	nop
	nop

	mov r1,#(GPIOE_GPIODIR & 0xffff)
	movt r1,#(GPIOE_GPIODIR >> 16)
	mov r0,#0x0		; alla bitar Ã¤r ingÃ¥ngar
	str r0,[r1]

	mov r1,#(GPIOE_GPIOAFSEL & 0xffff)
	movt r1,#(GPIOE_GPIOAFSEL >> 16)
	mov r0,#0		; alla portens bitar Ã¤r GPIO
	str r0,[r1]

	mov r1,#(GPIOE_GPIOAMSEL & 0xffff)
	movt r1,#(GPIOE_GPIOAMSEL >> 16)
	mov r0,#0x00		; anvÃ¤nd inte analoga funktioner
	str r0,[r1]

	mov r1,#(GPIOE_GPIOPCTL & 0xffff)
	movt r1,#(GPIOE_GPIOPCTL >> 16)
	mov r0,#0x00		; anvÃ¤nd inga specialfunktioner pÃ¥ port B	
	str r0,[r1]

	mov r1,#(GPIOE_GPIOPUR & 0xffff)
	movt r1,#(GPIOE_GPIOPUR >> 16)
	mov r0,#0x00		; ingen pullup pÃ¥ port B
	str r0,[r1]

	mov r1,#(GPIOE_GPIODEN & 0xffff)
	movt r1,#(GPIOE_GPIODEN >> 16)
	mov r0,#0xff		; alla pinnar Ã¤r digital I/O
	str r0,[r1]

	bx lr


;; Utskrift av ett tecken pÃ¥ serieport
;; r0 innehÃ¥ller tecken att skriva ut (1 byte)
;; returnerar fÃ¶rst nÃ¤r tecken skickats
;; fÃ¶rstÃ¶r r0, r1 och r2 
printchar:
	mov r1,#(UART0_UARTFR & 0xffff)	; peka pÃ¥ serieportens statusregister
	movt r1,#(UART0_UARTFR >> 16)
loop1:
	ldr r2,[r1]			; hÃ¤mta statusflaggor
	ands r2,r2,#0x20		; kan ytterligare tecken skickas?
	bne loop1			; nej, fÃ¶rsÃ¶k igen
	mov r1,#(UART0_UARTDR & 0xffff)	; ja, peka pÃ¥ serieportens dataregister
	movt r1,#(UART0_UARTDR >> 16)
	str r0,[r1]			; skicka tecken
	bx lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
