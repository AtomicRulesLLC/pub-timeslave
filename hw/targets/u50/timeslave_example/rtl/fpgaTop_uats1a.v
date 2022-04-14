// Copyright (c) 2016-2022 Atomic Rules LLC - ALL RIGHTS RESERVED

`timescale 1ps / 1ps

module fpgaTop_uats1a
  #(
    parameter P = 16             // number of PCIe lanes
    )
   (
    output wire        HBM_CATTRIP,
    input wire        sys100_clk_p,
    input wire        sys100_clk_n,    

    input wire  [0:0] enet_refclk_p,
    input wire  [0:0] enet_refclk_n,

    output wire [3:0] qsfp0_txp,
    output wire [3:0] qsfp0_txn,
    input  wire [3:0] qsfp0_rxp,
    input  wire [3:0] qsfp0_rxn);

  
   wire             clk_100;         // 100 MHz
   reg              clk_100_rst;     // Active-Low Reset in 100 Mhz domain
   reg   [15:0]     reset_count = 0;
   
   wire             MAC_CLK;
   wire             MAC_RESETN;


   reg [3:0]        qsfp_prsntd_l, qsfp_plugev;
   reg [15:0]       qsfp0, qsfp1, qsfp2, qsfp3;

   assign HBM_CATTRIP = 1'b0;
   
   // 100 MHz clocks
   IBUFDS ibufds_0 (.O(clk_100), .I(sys100_clk_p), .IB(sys100_clk_n));
   

   always @(posedge clk_100) begin
     if (reset_count!=16'hFFFF) reset_count <= reset_count + 1;
     clk_100_rst <= (reset_count!=16'hFFFF);  // De-Assert when terminal count reached
   end


  timeslave_cmac timeslave_cmac
       (.clk_100MHz        (clk_100),
        .clk_100_reset     (clk_100_rst),
        .gt_ref_clk_n   (enet_refclk_n),
        .gt_ref_clk_p   (enet_refclk_p),
        .gt_grx_n   (qsfp0_rxn),
        .gt_grx_p   (qsfp0_rxp),
        .gt_gtx_n   (qsfp0_txn),
        .gt_gtx_p   (qsfp0_txp)

        
        );


endmodule
