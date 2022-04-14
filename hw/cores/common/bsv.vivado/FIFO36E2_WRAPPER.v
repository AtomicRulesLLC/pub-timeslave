//  Copyright 2008-2022 Atomic Rules LLC
// Wrapper for FIFO36E2.
// See comments in FIFO18E2_WRAPPER.
module FIFO36E2_WRAPPER
#(
  parameter CASCADE_ORDER = "NONE",
  parameter CLOCK_DOMAINS = "COMMON",
  parameter FIRST_WORD_FALL_THROUGH = "TRUE",
  parameter REGISTER_MODE = "REGISTERED",
  parameter integer W = 64
 )
 (
  output [W-1:0] CASDOUT,
  output         CASNXTEMPTY,
  output         CASPRVRDEN,
  output [W-1:0] DOUT,
  output         EMPTY_N,
  output         FULL_N,
  output         RDRSTBUSY,
  output         WRRSTBUSY,

  input [W-1:0]  CASDIN,
  input          CASNXTRDEN,
  input          CASPRVEMPTY,
  input          CLR,
  input [W-1:0]  DIN,
  input          RDCLK,
  input          RDEN,
  input          RST_N,
  input          WRCLK,
  input          WREN

  );

  wire          EMPTY;
  wire          FULL;

  wire          resetn = ~(~RST_N || CLR);

  wire [63:0]   CASDOUT64;
  wire [7:0]    CASDOUTP;

  wire [63:0]   DOUT64;
  wire [7:0]    DOUTP;

  wire [63:0]   CASDIN64;
  wire [7:0]    CASDINP;

  wire [63:0]   DIN64;
  wire [7:0]    DINP;

  localparam WIDTH = (W <= 4) ? 4 : ((W <= 9) ? 9 : ((W <= 18) ? 18 : ((W <= 36) ? 36 : 72)));

  // FIFO36E2: 36Kb FIFO (First-In-First-Out) Block RAM Memory
  // UltraScale
  // Xilinx HDL Libraries Guide, version 2015.4
  FIFO36E2
  #(
    .CASCADE_ORDER           (CASCADE_ORDER),           // FIRST, LAST, MIDDLE, NONE, PARALLEL
    .CLOCK_DOMAINS           (CLOCK_DOMAINS),           // COMMON, INDEPENDENT
    .EN_ECC_PIPE             ("FALSE"),                 // ECC pipeline register, (FALSE, TRUE)
    .EN_ECC_READ             ("FALSE"),                 // Enable ECC decoder, (FALSE, TRUE)
    .EN_ECC_WRITE            ("FALSE"),                 // Enable ECC encoder, (FALSE, TRUE)
    .FIRST_WORD_FALL_THROUGH (FIRST_WORD_FALL_THROUGH), // FALSE, TRUE
    .INIT                    (72'h000000000000000000),  // Initial values on output port
    .PROG_EMPTY_THRESH       (256),                     // Programmable Empty Threshold
    .PROG_FULL_THRESH        (256),                     // Programmable Full Threshold
    // Programmable Inversion Attributes: Specifies the use of the built-in programmable inversion
    .IS_RDCLK_INVERTED       (1'b0),                    // Optional inversion for RDCLK
    .IS_RDEN_INVERTED        (1'b0),                    // Optional inversion for RDEN
    .IS_RSTREG_INVERTED      (1'b0),                    // Optional inversion for RSTREG
    .IS_RST_INVERTED         (1'b1),                    // Optional inversion for RST - NOTE: ACTIVE-LOW
    .IS_WRCLK_INVERTED       (1'b0),                    // Optional inversion for WRCLK
    .IS_WREN_INVERTED        (1'b0),                    // Optional inversion for WREN
    .RDCOUNT_TYPE            ("EXTENDED_DATACOUNT"),    // EXTENDED_DATACOUNT, RAW_PNTR, SIMPLE_DATACOUNT, SYNC_PNTR
    .READ_WIDTH              (WIDTH),                   // 4,9,18,36,72
    .REGISTER_MODE           (REGISTER_MODE),           // DO_PIPELINED, REGISTERED, UNREGISTERED
    .RSTREG_PRIORITY         ("RSTREG"),                // REGCE, RSTREG
    .SLEEP_ASYNC             ("FALSE"),                 // FALSE, TRUE
    .SRVAL                   (72'h000000000000000000),  // SET/reset value of the FIFO outputs
    .WRCOUNT_TYPE            ("EXTENDED_DATACOUNT"),    // EXTENDED_DATACOUNT, RAW_PNTR, SIMPLE_DATACOUNT, SYNC_PNTR
    .WRITE_WIDTH             (WIDTH)                    // 4,9,18,36,72
  ) FIFO36E2_i
   (
    // Cascade Signals outputs: Multi-FIFO cascade signals
    .CASDOUT        (CASDOUT64),     // O 64: Data cascade output bus
    .CASDOUTP       (CASDOUTP),      // O 8: Parity data cascade output bus
    .CASNXTEMPTY    (CASNXTEMPTY),   // O 1: Cascade next empty
    .CASPRVRDEN     (CASPRVRDEN),    // O 1: Cascade previous read enable
    // ECC Signals outputs: Error Correction Circuitry ports
    .DBITERR        (),              // O 1: Double bit error status
    .ECCPARITY      (),              // O 8: Generated error correction parity
    .SBITERR        (),              // O 1: Single bit error status
    // Read Data outputs: Read output data
    .DOUT           (DOUT64),        // O 64: FIFO data output bus
    .DOUTP          (DOUTP),         // O 8: FIFO parity output bus
    // Status outputs: Flags and other FIFO status outputs
    .EMPTY          (EMPTY),         // O 1: Empty
    .FULL           (FULL),          // O 1: Full
    .PROGEMPTY      (),              // O 1: Programmable empty
    .PROGFULL       (),              // O 1: Programmable full
    .RDCOUNT        (),              // O 14: Read count
    .RDERR          (),              // O 1: Read error
    .RDRSTBUSY      (RDRSTBUSY),     // O 1: Reset busy (sync to RDCLK)
    .WRCOUNT        (),              // O 14: Write count
    .WRERR          (),              // O 1: Write Error
    .WRRSTBUSY      (WRRSTBUSY),     // O 1: Reset busy (sync to WRCLK)
    // Cascade Signals inputs: Multi-FIFO cascade signals
    .CASDIN         (CASDIN64),      // I 64: Data cascade input bus
    .CASDINP        (CASDINP),       // I 8: Parity data cascade input bus
    .CASDOMUX       (1'b0),          // I 1: Cascade MUX select
    .CASDOMUXEN     (1'b0),          // I 1: Enable for cascade MUX select
    .CASNXTRDEN     (CASNXTRDEN),    // I 1: Cascade next read enable
    .CASOREGIMUX    (1'b0),          // I 1: Cascade output MUX select
    .CASOREGIMUXEN  (1'b0),          // I 1: Cascade output MUX select enable
    .CASPRVEMPTY    (CASPRVEMPTY),   // I 1: Cascade previous empty
    // ECC Signals inputs: Error Correction Circuitry ports
    .INJECTDBITERR  (1'b0),          // I 1: Inject a double bit error
    .INJECTSBITERR  (1'b0),          // I 1: Inject a single bit error
    // Read Control Signals inputs: Read clock, enable and reset input signals
    .RDCLK          (RDCLK),         // I 1: Read clock
    .RDEN           (RDEN),          // I 1: Read enable
    .REGCE          (1'b1),          // I 1: Output register clock enable (only when REGISTER_MODE=DO_PIPELINED)
    .RSTREG         (1'b0),          // I 1: Output register reset (only when REGISTER_MODE=DO_PIPELINED)
    .SLEEP          (1'b0),          // I 1: Sleep Mode
    // Write Control Signals inputs: Write clock and enable input signals
    .RST            (resetn),        // I 1: Reset - NOTE: ACTIVE-LOW via IS_RST_INVERTED param
    .WRCLK          (WRCLK),         // I 1: Write clock
    .WREN           (WREN),          // I 1: Write enable
    // Write Data inputs: Write input data
    .DIN            (DIN64),         // I 64: FIFO data input bus
    .DINP           (DINP)           // I 8: FIFO parity input bus
    );

  assign EMPTY_N = ~EMPTY;
  assign FULL_N  = ~FULL;

  generate
    if ((W <= 8) || ((W > 9) && (W <= 16)) || ((W > 18) && (W <= 32)) || ((W > 36) && (W <= 64))) begin
      assign DOUT    = DOUT64[W-1:0];
      assign CASDOUT = CASDOUT64[W-1:0];
      assign {DINP, DIN64}       = {{(8+64-W){1'b0}}, DIN[W-1:0]};
      assign {CASDINP, CASDIN64} = {{(8+64-W){1'b0}}, CASDIN[W-1:0]};
    end
    else if (W == 9) begin
      assign DOUT    = {DOUTP[0],    DOUT64[7:0]};
      assign CASDOUT = {CASDOUTP[0], CASDOUT64[7:0]};
      assign {DINP, DIN64}       = {{7{1'b0}}, DIN[8], {(64-8){1'b0}}, DIN[7:0]};
      assign {CASDINP, CASDIN64} = {{7{1'b0}}, CASDIN[8], {(64-8){1'b0}}, CASDIN[7:0]};
    end
    else if ((W >= 17) && (W <= 18)) begin
      assign DOUT    = {DOUTP[W-17:0],    DOUT64[15:0]};
      assign CASDOUT = {CASDOUTP[W-17:0], CASDOUT64[15:0]};
      assign {DINP, DIN64}       = {{(24-W){1'b0}}, DIN[W-1:16], {(64-16){1'b0}}, DIN[15:0]};
      assign {CASDINP, CASDIN64} = {{(24-W){1'b0}}, CASDIN[W-1:16], {(64-16){1'b0}}, CASDIN[15:0]};
    end
    else if ((W >= 33) && (W <= 36)) begin
      assign DOUT    = {DOUTP[W-33:0],    DOUT64[31:0]};
      assign CASDOUT = {CASDOUTP[W-33:0], CASDOUT64[31:0]};
      assign {DINP, DIN64}       = {{(40-W){1'b0}}, DIN[W-1:32], {32{1'b0}}, DIN[31:0]};
      assign {CASDINP, CASDIN64} = {{(40-W){1'b0}}, CASDIN[W-1:32], {32{1'b0}}, CASDIN[31:0]};
    end
    else if ((W >= 65) && (W <= 72)) begin
      assign DOUT    = {DOUTP[W-65:0],    DOUT64[63:0]};
      assign CASDOUT = {CASDOUTP[W-65:0], CASDOUT64[63:0]};
      if (W < 72) begin
        assign {DINP, DIN64}       = {{(72-W){1'b0}}, DIN[W-1:0]};
        assign {CASDINP, CASDIN64} = {{(72-W){1'b0}}, CASDIN[W-1:0]};
      end
      else begin
        // Special case to get rid of cvc warning
        // WARN** [3109] concatenate repeat value of 0 causes removal of concatenate
        assign {DINP, DIN64}       = DIN[W-1:0];
        assign {CASDINP, CASDIN64} = CASDIN[W-1:0];
      end
    end
  endgenerate

endmodule
