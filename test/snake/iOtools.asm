
;;; external functions for snake.ml

;;IOtools_get_key
;;	LDY # 0
;;	STY ACCU + 1                            ;ACCUh := 0
;;	JSR C64_GETIN				;A:=get char from keyboard queue
;;	SEC
;;	ROL
;;	STA ACCU                                ;ACCUl := <Val_char(A)
;;	ROL ACCU + 1                            ;ACCUh := >Val_char(A)
;;	RTS

IOtools_get_key
	LSR ACCU				;X := max retries (0-127)
	LDX ACCU
	STY ACCU + 1                            ;ACCUh := 0
-       JSR C64_GETIN				;A:=get char from keyboard queue
	BNE +
	DEX					;if null, retry (max X times)
	BNE -
+       SEC
        ROL
        STA ACCU                                ;ACCUl := <Val_char(A)
        ROL ACCU + 1                            ;ACCUh := >Val_char(A)
        RTS

IOtools_videoram_read
        ;; ACCU is address, relative to start of video RAM; 0 <= ACCU <= 999
        LSR ACCU + 1
        ROR ACCU                                ;ACCU := Int_val(ACCU)
        LDA # >1024                             ;1024 = start of video RAM
        CLC
        ADC ACCU + 1
        STA ACCU + 1                            ;ACCU := address to peek
        LDY # 0
        LDA (ACCU),Y                            ;A := peek(address)
        STY ACCU + 1                            ;ACCUh := 0
        SEC
        ROL
        STA ACCU                                ;ACCUl := <Val_int(A)
        ROL ACCU + 1                            ;ACCUh := >Val_int(A)
        RTS

IOtools_videoram_write
        ;; ACCU is address, relative to start of video RAM; 0 <= ACCU <= 999
        ;; SP[0] is value to write, 0 <= SP[0] <= 255
        LSR ACCU + 1
        ROR ACCU                                ;ACCU := Int_val(ACCU)
        LDA # >1024                             ;1024 = start of video RAM
        CLC
        ADC ACCU + 1
        STA ACCU + 1                            ;ACCU := address to poke
        LDY #1
        LDA (SP),Y                              ;A := >SP[0]
        LSR
        DEY
        LDA (SP),Y                              ;A := <SP[0]
        ROR
        STA (ACCU),Y                            ;write memory
        LDA # Val_unit
        STA ACCU                                ;ACCUl := <Val_unit
        STY ACCU + 1                            ;ACCUh := >Val_unit
        RTS

IOtools_set_cursor_position
        ;; Int_val(ACCU) = 256 * row + column
        LDA ACCU + 1
        LSR
        TAX                                     ;X := row
        LDA ACCU
        ROR
        TAY                                     ;Y := column
        CLC                                     ;Carry clear = set crsr position
        JSR C64_PLOT
        LDY #0
        LDA # Val_unit
        STA ACCU                                ;ACCUl := <Val_unit
        STY ACCU + 1                            ;ACCUh := >Val_unit
        RTS
