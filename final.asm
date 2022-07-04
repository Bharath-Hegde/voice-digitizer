#make_bin#

#LOAD_SEGMENT=FFFFh#
#LOAD_OFFSET=0000h#

#CS=0000h#
#IP=0000h#

#DS=0000h#
#ES=0000h#

#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#



; add your code here
jmp start1


db  509 dup(0)

;IVT 80h- record
dw  str_isr
dw  0000h

;IVT 81h- replay
dw  replay
dw  0000h

;IVT 82h- stop
dw  0000h              
dw  0000h

;IVT 83h- 1ms
dw  ms1
dw  0000h

;IVT 84h- nms
;dw  play_str
dw  DACout
dw  0000h

;IVT 85h- next ADC Input 
dw  0000h
dw  0000h

;IVT 86h- DAC next output
dw  0000h
dw  0000h

;IVT 87h- --
dw  0000h
dw  0000h       


db  480 dup(0)                          


; kb table
TABLE_K     DB     07DH,0EEh,0EDH,0EBH,0DEH,0DDH,0DBH,0BEH,0BDH,0BBH
			DB     07EH,07BH
;display table
TABLE_D  DB     3FH,  06H, 5BH, 4FH, 66H, 6DH
         DB     7DH,  27H, 7FH, 6FH



sio_dac equ 70h
sioadc equ 72h
siobsr equ 74h
siocreg equ 76h

dio_sta equ 10h
dioled equ 12h
diokbd equ 14h
diocreg equ 16h

tiocnt0 equ 20h
tiocnt1 equ 22h
tiocnt2 equ 24h
tiocreg equ 26h

irhreg0 equ 30h
irhreg1 equ 32h





           

;main program
start1:      
cli
; intialize ds, es,ss to start of RAM
mov       ax,0200h
mov       ds,ax
mov       es,ax
mov       ss,ax
mov       sp,0FFFEH



;DATA DECLARATIONS
AUDIO_DATA  db 6000 dup(0);for data storage
SIZE        dw 00h        ;For size
DELAY       db 00h        ;delay entered
STATUS      db 00h        ;current status
LED         db 00h        ;output status

nop
nop
nop
nop

;initialize sio- portA:o/p, portB:i/p, portC:o/p
mov       al,82h
out       siocreg,al    
mov       al, 00h
out       sio_dac,al
;mov        al, 0FCh
;out        siobsr, al ; set gates as 0 and LEDs as 1   



mov        al,88h
out        diocreg,al  

mov        al,0ffh
out        dioled,al

     

;initialize timers- timer0:mode3 ; timer1:mode2
mov        al,34h
out        tiocreg,al   ;timer0 setup 
mov        al,74h
out        tiocreg,al   ;timer1 setup 



;mov        al,88h                       
;out        tiocnt0,al
;mov        al,13h       
;out        tiocnt0,al   ;count for timer0    - 5000d
mov         al,1h                       
out         tiocnt0,al
mov         al,0h       
out         tiocnt0,al
;count of timer 1
mov        al,00h                       
out        tiocnt1,al
mov        al,00h       
out        tiocnt1,al      



;initialize PIC- EOI required, no cascade, edge-triggered, vectors from 80h, 
mov     al, 13h
out     irhreg0, al ;icw1

mov     al, 80h
out     irhreg1, al ;icw2 - vector no.

mov     al, 01h
out     irhreg1, al ;icw4

mov     al, 00h
out     irhreg1, al ;ocw1 - IMR    
     
;ADD IN EACH INTERRUPT
;mov    al, 20h
;out    irhreg0, al ;ocw2 - EOI                        
                                
                                
;PROGRAM STARTS HERE, WAIT FOR RECORD SIGNAL



;turns off all LEDs and gates
    mov LED, 0fh                      
    mov al, LED
    out dio_sta,al
red:mov STATUS,00h
    mov al,80h
    out 00h,al                           
       
sti                    
                           
st1:
cmp STATUS, 00h
jz st1



rec_start:

;recording input goes here    
;turns on rec LED and adc clock and ALE for adcand start 1ms interrupts
mov LED, 9eh 
mov al, LED
out dio_sta,al;start timer count, and show recording

mov di, 00h      ;clear SI for use
mov SIZE, 00h    ;clear memory also      

mov    al,00h
out     siobsr,al

mov    al,80h
out     siobsr,al

con_rec:         ;continue recording
mov al,83h
out 00h,al                         
cmp SIZE,6000d
jnz con_rec      ;keep recording till we get 6000 samples(6s X 1000 samples/sec)


cli

mov LED, 1Dh
mov al, LED
out dio_sta,al;stop timer count, and  recording

mov di, 00h 

mov al,00h             
out sio_dac,al

;input delay here 
mov al, 0bfh
out dioled,al

X0: MOV  AL,00H
    OUT  diokbd, AL
X1: IN   AL, diokbd
    AND  AL,0F0H
    CMP  AL,0F0H
    JNZ  X1
    CALL D20MS
    MOV  AL,00H
    OUT  diokbd ,AL
X2: IN   AL, diokbd
    AND  AL,0F0H
    CMP  AL,0F0H
    JZ   X2
    CALL D20MS
    MOV  AL,00H
    OUT  diokbd ,AL
    IN   AL, diokbd
    AND  AL,0F0H
    CMP  AL,0F0H
    JZ   X2
    MOV  AL, 0EH
    MOV  BL,AL
    OUT  diokbd,AL
    IN   AL,diokbd
    AND  AL,0F0H
    CMP  AL,0F0H
    JNZ  X3
    MOV  AL, 0DH
    MOV  BL,AL
    OUT  diokbd ,AL
    IN   AL,diokbd
    AND  AL,0F0H
    CMP  AL,0F0H
    JNZ  X3
    MOV  AL, 0BH
    MOV  BL,AL
    OUT  diokbd,AL
    IN   AL,diokbd
    AND  AL,0F0H
    CMP  AL,0F0H
    JNZ  X3
    MOV  AL, 07H
    MOV  BL,AL
    OUT  diokbd,AL
    IN   AL,diokbd
    AND  AL,0F0H
    CMP  AL,0F0H
    JZ   X2
X3: OR   AL,BL
    MOV  CX,0FH
    MOV  DI,00H
X4: CMP  AL,CS:TABLE_K[DI]
    JZ   X5
    INC  DI
    LOOP X4
X5:   
    LEA  BX, TABLE_D
    MOV  AL, CS:[BX+DI]
    NOT  AL
    
    CMP  DI, 0Ah
    JNZ  X6
    MOV  AL, 0BFh
    OUT  dioled, AL
    MOV  DX, 0h
    MOV  DI, 0h
    JMP  X0
     
X6: CMP  DI, 0Bh
    JZ   X7
    OUT  dioled,AL
    MOV  DX, DI
    JMP  X0
    
X7: LEA  BX, TABLE_D
    CMP  DX, 0h
    JZ   X0
    MOV  DI, DX
    MOV  AL, CS:[BX+DI]
    NOT  AL
    AND  AL, 7Fh
    OUT  dioled,al 


mov DELAY, dl
;INPUT FINISHES HERE--- OUTPUT IS IN DI and DX
mov LED, 1Bh
mov al, LED
out dio_sta,al

;Put number in timer 1 so that we have rate-generator for DAC    
;mov ax,1388h
mov ax,1h
mov dh,0h
mov bx,dx
mul bx
;mov al,dl      ;changed here-------------------------------------------------------------------   
inc dl              
out tiocnt1,al
mov al,ah       
out tiocnt1,al ;count for timer1

	
ready:              
;mov LED, 05Bh
;mov al, LED
;out dio_sta,al  ;put READY LED ON

sti
;WAIT FOR PLAY SIGNAL HERE


mov al,81h
out 00h,al
play_wait:
cmp STATUS, 0Ah
jne play_wait
	

mov SI, 00h
mov DI, 00h

mov LED, 57h
mov al, LED
out dio_sta,al  ;put PLAYING ON
 
 


playing:

mov al,84h
out 00h,al
cmp SI,SIZE
jnz playing      


cli


mov LED, 0fh
mov al, LED
out dio_sta,al  ;put READY LED ON, PLAYING OFF

             
mov al,00h             
out sio_dac,al

sti
jmp red





D20MS: mov  cx,2220 ; delay generated will be approx 0.45 secs
xn:    loop xn
ret



;ISR TO RECORD NEXT DIGITAL INPUT
ADCrecord: 
	cmp STATUS, 01h
	jnz AD
	
	lea     bx, AUDIO_DATA
	in      al,sioadc
	mov     [bx+DI],al
	inc     DI
	mov     SIZE,DI  

AD:	mov     al, 20h
	out     irhreg0, al ;ocw2 - EOI
	iret





	
;ISR TO START PLAYING	
play_str:
	cmp STATUS, 07h
	jnz ex2
	
	mov STATUS, 0Fh


ex2:mov     al, 20h
	out     irhreg0, al ;ocw2 - EOI
	iret



;ISR TO PLAY NEXT OUTPUT TO DAC
DACout:	
	lea     bx, AUDIO_DATA
	
	mov     al,[BX+SI]
	;mov     al,11111000b  
	out     sio_dac,al
	inc     SI  

DA:	mov     al, 20h
	out     irhreg0, al ;ocw2 - EOI
	iret

	
	
	
ms1: 	;mov al,82h
        ;out 00h,al
;        lop:    cmp STATUS,0Eh
;                jnz lop  

;      	mov     al, 20h
;        out     irhreg0, al ;ocw2 - EOI
;        iret
        
nest:   ;mov     STATUS,0Eh
        
        lea     bx, AUDIO_DATA
    	in      al,sioadc
    	mov     [bx+DI],al
    	inc     DI
    	mov     SIZE,DI  
        mov    al,00h
        out     siobsr,al

        mov    al,80h
        out     siobsr,al
        nop
        nop
        nop
        nop
        mov     al, 20h
    	out     irhreg0, al ;ocw2 - EOI
    	iret

replay: mov    STATUS,0Ah
        nop
        mov     al, 20h
	    out     irhreg0, al ;ocw2 - EOI
	    iret
            	
;ISR TO START RECORDING
str_isr:
	mov STATUS, 01h


ex1:mov     al, 20h
	out     irhreg0, al ;ocw2 - EOI
	iret
	
		


