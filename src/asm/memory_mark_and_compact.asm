;; ——————————————————————————————————————————————————————————————————————
;; Progetto BreadCaml / The BreadCaml Project
;; Copyright (C) 21-Apr-2026 Piero Furiesi
;; 
;; Questo  programma  è software  libero;  può  essere ridistribuito  e/o
;; modificato nei termini della licenza GNU GPL ver. 2,  come specificato
;; nel file LICENZA-it nella cartella principale del progetto.
;; 
;; This program is  free software; you can redistribute  it and/or modify
;; it under the terms of the GNU  General Public License (GPL) ver. 2, as
;; specified in the LICENSE-en file in the project root folder.
;; ——————————————————————————————————————————————————————————————————————
;;; ==========================================================================
;;; MEMORY MANAGEMENT - HEAP ALLOCATION AND GARBAGE COLLECTION
;;; ==========================================================================

        ;; MARK AND COMPACT
        ;; IN CIMA ALLO HEAP C'È LA BLOCK ALLOCATION MAP (BAM)
        ;; USA 1 BIT OGNI WORD -> HEAP DIVISO IN 17 PARTI: 16 DATA + 1 BAM

caml_heap_end   = caml_stack_start
caml_heap_start = caml_glob_init_end
caml_heap_sz    = caml_heap_end - caml_heap_start
caml_bam_end    = caml_heap_end
caml_bam_sz     = (caml_heap_end - caml_heap_start + 16) DIV 17
caml_bam_start  = caml_bam_end - caml_bam_sz
caml_data_end   = caml_bam_start
caml_data_start = caml_heap_start
caml_data_sz    = caml_data_end - caml_data_start

caml_heap_init
        +setw HEAP,a, caml_glob_init_end,k, _inc ; Init the heap pointer        
        RTS

        ;; -----------------------------------------------------------
        ;; HEAP ALLOCATION
        ;; -----------------------------------------------------------
        
caml_alloc
        ;; Allocate a block. NOT FOR ATOMS.
        ;; Called with A=tag, X=size > 0, Y=0.
        ;; Return block address in TMP+1:TMP, A=X=size, Y=0.
        ;; Raise Out_of_memory if GC fails.
!zn
        STA .TAG                        ; save tag
        STX .SIZE                       ; save size
        STY .GCFLAG                     ; gc flag <- 0
        ;; TMP <- HEAP
-       +setw TMP,a, HEAP,a, _inc
        ;; HEAP <- HEAP + 2 * (size + 1)
        INX
        BNE +
        ;; size = 255
        INC HEAP + 1
        INC HEAP + 1
        JMP ++
        ;; size < 255
+       TXA
        ASL
        BCC +
        INC HEAP + 1
        CLC
+       ADC HEAP
        STA HEAP
        BCC ++
        INC HEAP + 1
        ;; if HEAP <= caml_data_end
++      +cmpw caml_data_end,k, HEAP,a, _inc
        BCC .try_gc
        ;; then allocate block
.TAG    = * + 1
        LDA # <.TAG                     ; self-mod code
        STA (TMP),y
        INC TMP
.SIZE   = * + 1
        LDX # <.SIZE                    ; self-mod code
        TXA
        STA (TMP),y
        +incw TMP
        RTS                             ; return to caller
        ;; else do a GC, if not done yet
.GCFLAG = * + 1
.try_gc LDA # <.GCFLAG                  ; self-mod code
        BEQ +
        ;; GC already done: raise exception
        +setw HEAP,a, TMP,a, _inc
        +caml_raise Out_of_memory
        ;; GC not done yet: call garbage collector & try again
+       JSR caml_garbage_collection
        INC .GCFLAG                     ; gc flag <- 1
        LDX .SIZE                       ; reload size
        JMP -                           ; redo from start


        ;; -----------------------------------------------------------
        ;; BLOCK ALLOCATION MAP
        ;; -----------------------------------------------------------
        
caml_BAMmsk0    
        !byte %.#######
        !byte %#.######
        !byte %##.#####
        !byte %###.####
        !byte %####.###
        !byte %#####.##
        !byte %######.#
        !byte %#######.
        
caml_BAMmsk1
        !byte %########
        !byte %.#######
        !byte %..######
        !byte %...#####
        !byte %....####
        !byte %.....###
        !byte %......##
        !byte %.......#
        
caml_BAMmskN
        !byte %#.......
        !byte %##......
        !byte %###.....
        !byte %####....
        !byte %#####...
        !byte %######..
        !byte %#######.
        !byte %########
        
caml_BAMtest
        !byte %#.......
        !byte %.#......
        !byte %..#.....
        !byte %...#....
        !byte %....#...
        !byte %.....#..
        !byte %......#.
        !byte %.......#

!macro  caml_bam_addr .ADR {
        ;; convert the heap address .ADR to the BAM matching address
        ;; and set X = #bit (counting from 0=MSB to 7=LSB).
        ;; BAM address = caml_bam_start + (ADR - caml_data_start) div 16,
        ;; #bit = (ADR - caml_data_start) mod 16 / 2
        SEC
        LDA .ADR
        SBC # <caml_data_start
        STA .ADR
        LDA .ADR + 1
        SBC # >caml_data_start
        LSR
        TAY
        ROR .ADR
        LDA # %00000111
        AND .ADR
        TAX
        TYA
        LSR
        ROR .ADR
        LSR
        ROR .ADR
        LSR
        ROR .ADR
        STA .ADR + 1
        CLC
        +adcw .ADR,a, caml_bam_start,k, _inc
}

!macro  caml_bam_test .ADR {
        ;; Test bit. X = #bit, .ADR = BAM address. Result in Z flag.
        ;; assert(Y = 0).
        LDA (.ADR),y
        AND caml_BAMtest,x
}
        
!macro  caml_bam_set0 .ADR {
        ;; Set a bit to 0; X = #bit, .ADR = byte address
        ;; assert(Y = 0).
        LDA caml_BAMmsk0,x
        AND (.ADR),y
        STA (.ADR),y
}

!macro  caml_bam_set1 .ADR, .NUM {
        ;; Set .NUM bits to 1. X = #1st bit, .ADR = 1st byte address
        ;; assert(Y = 0).

        ;; is .ADR the only byte to set? 
        TXA
        DEC .NUM
        CLC
        ADC .NUM
        TAY                     ; Y & 7 = #last bit
        BCS .gt255
        CMP # 8

        ;; yes: jump
        BCC .only1

        ;; no: calculate last byte offset
        CLC 
.gt255  ROR
        LSR
        LSR
        STA .ofs + 1            ; self-mod code
        
        ;; load last byte mask
        TYA
        AND # 7
        TAY
        LDA caml_BAMmskN,y

        ;; set last byte
.ofs    LDY # $FF               ; ldy #offset
        ORA (.ADR),y
        STA (.ADR),y
        
        ;; set intermediate bytes
        DEY
        BEQ +
        LDA # $FF
-       STA (.ADR),y
        DEY
        BNE -
        
        ;; set first byte
+       LDA caml_BAMmsk1,x
        ORA (.ADR),y
        STA (.ADR),y

        ;; done
        JMP ++
        
        ;; only one byte: merge masks and apply them
.only1  LDA caml_BAMmskN,y
        AND caml_BAMmsk1,x
        LDY # 0
        ORA (.ADR),y
        STA (.ADR),y
++}

!macro caml_bam_clear {
        !set .BAM_SIZE  = caml_bam_end - caml_bam_start
        !set .BAM_PAGES = .BAM_SIZE DIV $100
        !set .BAM_REST  = .BAM_SIZE MOD $100

        TYA
        !if .BAM_PAGES > 0 {
-               !for .P, 0, .BAM_PAGES - 1 { sta (caml_bam_start + $100 * .P),y }
                DEY
                BNE -
        }
        !if .BAM_REST > 0 {
                LDY # .BAM_REST
-               STA (caml_bam_start + $100 * .BAM_PAGES),y
                DEY
                BNE -
                STA (caml_bam_start + $100 * .BAM_PAGES),y
        }       
}

        ;; -----------------------------------------------------------
        ;; GARBAGE COLLECTION
        ;; -----------------------------------------------------------

caml_garbage_collection
        !warn "DA FARE:  caml_garbage_collection"
        RTS

; caml_bam_mark(b) {  // b = block adr
;    if *(b - 2) = infix_tag {
;       size = *(b - 1)                 // size = distanza dalla closurerec
;       bext = b - 2 * size
;       size = *(bext - 1)
;       caml_bam_set1(bext, size)
;       caml_bam_set0(b - 2)            // marca con 0 l'infix header
;    } else {
;       size = *(b - 1)
;       caml_bam_set1(b, size)
;    }
; }

; to_visit(c) = not (is_int(c) | out_of_heap(c) | marked(c))

; gc_mark_and_compact {
;         // MARK
;         caml_bam_clear
;         foreach root in (ACCU,ENV,STACK) {  //GLOB? possono avere ptr to heap?
;               b = *root
;                 if to_visit(b) {
;                    caml_bam_mark(b)
;                  if *(b - 2) < no_scan_tag {
;                     f = b  
;                     p = nil
;                     loop {
;                            // esegue end := indirizzo alla fine del blocco
;                            tag = *(b - 2)
;                            if tag = infix_tag {
;                               size = *(b - 1)    // distanza dalla closurerec
;                               bext = b - 2 * size
;                               size = *(bext - 1)
;                               end = bext + size * 2
;                            } else {
;                               end = b + size * 2
;                            }
         
;                            // cerca nel blocco il prossimo ptr da visitare
;                            while f < end & not to_visit(*f) {
;                               f = f + 2
;                            }
;                            if f < end {               // trovato ptr
;                               caml_bam_mark(*f)
;                               if *(*f - 2) < no_scan_tag {
;                                  b = *f               // nuovo blocco da visitare
;                                  *f = p               // inverte il ptr, ora punta al padre
;                                  p = f                // il nuovo padre è il field attuale
;                                  f = b                // il nuovo field è a inizio blocco
;                               }
            
;                            } else {                   // fine blocco, torna su
;                               if p = nil exit         // finito!
;                               else {
;                                  tmp = *p
;                                  *p = b               // ripristina il puntatore
;                                  f = p + 2            // passa all'eventuale field successivo al padre
;                                  b = blocco(p)        // l'inizio del blocco va cercato nella BAM
;                                  p = tmp              // il nonno è il nuovo padre
;                               }
;                            }
;                          }
;                  }
;               }
;       }



;         // COMPACT
;         slide blocks left    // don't update the BAM!
;         HEAP <- caml_data_start + 2 * (#1's in bitmap)
;         down from caml_data_end, convert the BAM in an ADR-ordered BRKTBL :
;                 - an entry (ADR,OFS) foreach 0's sequence (min 00)
;                 - ADR <- address of next 1 (ok, as 0 is the header....)
;                 - OFS <- #0's encountered from left (calc. incremental)
;         foreach PTR in [caml_data_start..HEAP) {
;                 OFS <- 0
;                 i <- 0
;                 while i < out_of_index AND BRKTBL[i].PTR <= P {
;                         OFS <- BRKTBL[i].OFS
;                         i <- i + 1
;                 }
;                 PTR <- PTR - OFS
;         }
; }

caml_runtime_end
