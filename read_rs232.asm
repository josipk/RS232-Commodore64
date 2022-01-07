.var SETLFS = $FFBA
.var OPEN = $FFC0
.var SETNAM = $FFBD
.var READST = $FFB7
.var CHKOUT = $FFC9
.var CHROUT = $FFD2
.var CHKIN = $FFC6
.var CHRIN = $FFCF
.var PLOT = $FFF0
.var GETIN = $FFE4
.var SETMSG = $FF90
.var CLOSE = $FFC3
.var SCINIT = $FF81
.var CLRCHN = $FFCC
.var RSSTAT = $0297
.var RDTIM = $FFDE

.var RS232_INBUF_PTR = $f7
.var RS232_OUTBUF_PTR = $f9

//BasicUpstart2(mainProg)

//----------------------------------------------------
//                      Main Program
//----------------------------------------------------
//sys49152
*=$c000

mainProg: { 

	jsr rs232_open
	
	ldx #3
	jsr CHKIN       // select file 3 as input channel

loop1:

		//jsr CHRIN	
		//lda $9f00
			
		jsr GETIN       // try and read from rs232 buffer


		cmp #0
		beq continue

		
		ldy counter
		sta $0400,y

		inc counter
	
continue:

		//jsr CLRCHN

	jmp loop1

}


// ----------------------------------------------------------------------
// Opens rs232 channel on file #3
// ----------------------------------------------------------------------
rs232_open: {
		
		lda #<input_buffer
		sta RS232_INBUF_PTR
		lda #>input_buffer
		sta RS232_INBUF_PTR+1

		lda #<output_buffer
		sta RS232_OUTBUF_PTR
		lda #>output_buffer
		sta RS232_OUTBUF_PTR+1
		

		lda #3          // file #
		ldx #2          // 2 = rs-232 device
		ldy #0          // no cmd
		jsr SETLFS		

		lda #0		// no name
        jsr SETNAM
				  
		lda #%00001010  // 2400 baud, 8 bits per char
		sta $0293

		lda #%10100001  // 2400 baud, 8 bits per char
		sta $0294


		jsr OPEN
		rts
}

// ----------------------------------------------------------------------
// Returns: A
// If no data available, will return immediately with \0 and bit #3 in RSSTAT will be 1
// ----------------------------------------------------------------------
rs232_try_read_byte: {
		
		//$029b -> number of bytes waitning!!!


		ldx #3
		jsr CHKIN       // select file 3 as input channel
		

		jsr CHRIN	
		//lda $9f00
			
		jsr GETIN       // try and read from rs232 buffer
		
		tay             // CLRCHN uses A, so move data to Y reg
		jsr CLRCHN
		tya             // ... and back again
		
		rts
}
// ----------------------------------------------------------------------
// A: byte to write
// ----------------------------------------------------------------------
rs232_write_byte: {
		ldx #3
		tay
		jsr CHKOUT       // select file 3 as input channel
		tya
		jsr CHROUT
		jsr CLRCHN
		rts
}		

// ----------------------------------------------------------------------
file_name: .byte 6, 0
output_buffer: .byte 256, 0
input_buffer: .byte 256, 0
tmp: .byte 0
counter: .byte 0
