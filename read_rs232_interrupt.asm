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
//This works with BASIC memory sotrage!!!!
//----------------------------------------------------
//                      Main Program
//----------------------------------------------------
//sys49152
*=$c000

mainProg: { 

	jsr rs232_open

	sei                           // disable interrupts

	lda #$7f                      // turn off the cia interrupts
	sta $dc0d

	lda $d01a                     // Interrupt control register
	ora #$01					  // enable raster irq
	sta $d01a

	// Screen control register	
	lda $d011                     // clear high bit of raster line
	and #$7f					  // %01111111
	sta $d011

	lda #$95                      // line number to go off at
	sta $d012                     // low byte of raster line

	//Execution address of interrupt service routine.
	lda #<intcode                 // get low byte of target routine
	sta $0314                       // put into interrupt vector
	lda #>intcode                 // do the same with the high byte
	sta $0315

	cli                           // re-enable interrupts
	rts                           // return to caller

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


intcode: {

	jsr rs232_open

	jsr rs232_try_read_byte
	cmp #0
	beq continue1

	/*
	ldy #0
	sta $0400,y
	*/

	ldy #0
	sta $0277,y

	lda #1
	sta $c6,y


continue1:


	lda $d019                     // clear source of interrupts
	sta $d019					  // Acknowledge raster interrupt

	jmp $ea31                     // exit back to rom // sys IRQ handler

	rti
}

// ----------------------------------------------------------------------
// Returns: A
// If no data available, will return immediately with \0 and bit #3 in RSSTAT will be 1
// ----------------------------------------------------------------------
rs232_try_read_byte: {
		ldx #3
		jsr CHKIN       // select file 3 as input channel
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
output_buffer: .fill 256, 0
input_buffer: .fill 256, 0
tmp: .byte 0
