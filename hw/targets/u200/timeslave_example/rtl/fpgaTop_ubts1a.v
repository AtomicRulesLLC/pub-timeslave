// Copyright (c) 2016-2020 Atomic Rules LLC - ALL RIGHTS RESERVED

`timescale 1ps / 1ps

module fpgaTop_ubts1a
  #(
    parameter P = 16             // number of PCIe lanes
    )
   (

    input wire        sys300_clk_p,
    input wire        sys300_clk_n,    

    input wire  [0:0] enet_refclk_p,
    input wire  [0:0] enet_refclk_n,

    output wire [3:0] qsfp0_txp,
    output wire [3:0] qsfp0_txn,
    input  wire [3:0] qsfp0_rxp,
    input  wire [3:0] qsfp0_rxn,

    output wire [0:0] qsfp_lp,       // FPGA Out 0= Normal Power
    output wire [0:0] qsfp_rst_l,    // FPGA Out Active-Low Reset
    output wire [0:0] qsfp_modsel_l,
    input  wire [0:0] qsfp_prsnt_l,  // FPGA In Cage: 0=Present, 1=Empty
    input  wire [0:0] qsfp_int_l     // FPGA In Interrupt, active-low
);

   wire             clk_300;         // 300 MHz
   wire             clk_100;         // 100 MHz
   reg              clk_100_rst;     // Active-Low Reset in 100 Mhz domain
   reg   [15:0]     reset_count = 0;
   
   wire             MAC_CLK;
   wire             MAC_RESETN;


   reg [3:0]        qsfp_prsntd_l, qsfp_plugev;
   reg [15:0]       qsfp0, qsfp1, qsfp2, qsfp3;

   // 300, 100 MHz clocks
   IBUFDS ibufds_0 (.O(clk_300_i), .I(sys300_clk_p), .IB(sys300_clk_n));
   BUFGCE_DIV #(.BUFGCE_DIVIDE(1)) clk300_buf_0 (.O(clk_300), .CE(1'b1), .I(clk_300_i));
   BUFGCE_DIV #(.BUFGCE_DIVIDE(3)) clk100_buf_0 (.O(clk_100), .CE(1'b1), .I(clk_300_i));
 

   always @(posedge clk_100) begin
     if (reset_count!=16'hFFFF) reset_count <= reset_count + 1;
     clk_100_rst <= (reset_count!=16'hFFFF);  // De-Assert when terminal count reached
   end


  timeslave_cmac timeslave_cmac
       (.clk_100MHz        (clk_100),
        .clk_100_reset     (clk_100_rst),
        .ref_clk_300    (clk_300),
        .gt_ref_clk_n   (enet_refclk_n),
        .gt_ref_clk_p   (enet_refclk_p),
        .gt_grx_n   (qsfp0_rxn),
        .gt_grx_p   (qsfp0_rxp),
        .gt_gtx_n   (qsfp0_txn),
        .gt_gtx_p   (qsfp0_txp)

        
        );

      ///////////////////////////////////////////////////////////////////////////
   // Four CMACs and QSFP28s...
   assign qsfp_lp     = 4'b0000;      // Always drive these pins low

   // When any QSFP reset reaches terminal count, release its reset
   // Ensures that each QSFP reset is held active-low asserted for ~260 uS after plug-in
   assign qsfp_rst_l = {(qsfp3==16'hFFFF),(qsfp2==16'hFFFF),(qsfp1==16'hFFFF),(qsfp0==16'hFFFF)};

   always @(posedge clk_100) begin
      qsfp_prsntd_l <=  qsfp_prsnt_l;  // pipeline delay the prsnt signal to differentiate
      qsfp_plugev   <= ~qsfp_prsnt_l & qsfp_prsntd_l;  // detect plug event plug-in edge

      // See SFF-8069 for minimum ResetL Assertion Time
      // 64K * 4 ns = ~262 uS ; this is about 200x minimum spec of 2 uS "t_reset_init" from SFF-8069
      // For each QSFP, maintain 16-bit count that starts on plug-in event,
      // and saturates at 16'hFFFF
      if (qsfp_plugev[0] | clk_100_rst) qsfp0 <= 0;
      else if (qsfp0 != 16'hFFFF)     qsfp0 <=  qsfp0 + 1;
      if (qsfp_plugev[1] | clk_100_rst) qsfp1 <= 0;
      else if (qsfp1 != 16'hFFFF)     qsfp1 <=  qsfp1 + 1;
      if (qsfp_plugev[2] | clk_100_rst) qsfp2 <= 0;
      else if (qsfp2 != 16'hFFFF)     qsfp2 <=  qsfp2 + 1;
      if (qsfp_plugev[3] | clk_100_rst) qsfp3 <= 0;
      else if (qsfp3 != 16'hFFFF)     qsfp3 <=  qsfp3 + 1;
   end

endmodule
