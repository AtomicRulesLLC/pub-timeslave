// Copyright (c) 2021 Atomic Rules LLC - All Rights Reserved
// This file contains "Licensed Materials" as defined in the Software License
// Agreement (SLA). It is provided strictly under the terms of the SLA.


module timeServo_wrap
  #(
    parameter NUM_NOW=1)
   (
    axil_if.slv                    control,

    input                          ref_clk,
    input                          ref_rstn,

    input                          pps_src,
    output [1:0]                   pfd_monitor,
    output [79:0]                  now_ref,
    output                         now_pps_ref,

    input [NUM_NOW-1:0]        now_clk,
    output [NUM_NOW-1:0] [79:0] now,
    output [NUM_NOW-1:0]       now_pps
);


  wire [31:0]                      now_clk_wire;
  wire [31:0]                      now_pps_wire;
  wire [31:0] [79:0]               now_wire;

generate
     genvar                       i;
     for (i=0;i<32;i=i+1) begin : gen
       if (i<NUM_NOW) begin
         assign now_clk_wire[i] = now_clk[i];
         assign now[i] = now_wire[i];
         assign now_pps[i] = now_pps_wire[i];
       end
       else begin
         assign now_clk_wire[i] = 1'b0;
       end
     end
   endgenerate

   timeServo timeservo_i(.s_axi_aclk(control.clk),
                         .s_axi_aresetn(control.aresetn),
                         .pps_src(pps_src),
                         .pfd_monitor(pfd_monitor),
                         .ref_clk(ref_clk),
                         .ref_rstn(ref_rstn),
                         .now_ref(now_ref),
                         .now_pps_ref(now_pps_ref),
                         .now_clk_0(now_clk_wire[0]),
                         .now_clk_1(now_clk_wire[1]),
                         .now_clk_2(now_clk_wire[2]),
                         .now_clk_3(now_clk_wire[3]),
                         .now_clk_4(now_clk_wire[4]),
                         .now_clk_5(now_clk_wire[5]),
                         .now_clk_6(now_clk_wire[6]),
                         .now_clk_7(now_clk_wire[7]),
                         .now_clk_8(now_clk_wire[8]),
                         .now_clk_9(now_clk_wire[9]),
                         .now_clk_10(now_clk_wire[10]),
                         .now_clk_11(now_clk_wire[11]),
                         .now_clk_12(now_clk_wire[12]),
                         .now_clk_13(now_clk_wire[13]),
                         .now_clk_14(now_clk_wire[14]),
                         .now_clk_15(now_clk_wire[15]),
                         .now_clk_16(now_clk_wire[16]),
                         .now_clk_17(now_clk_wire[17]),
                         .now_clk_18(now_clk_wire[18]),
                         .now_clk_19(now_clk_wire[19]),
                         .now_clk_20(now_clk_wire[20]),
                         .now_clk_21(now_clk_wire[21]),
                         .now_clk_22(now_clk_wire[22]),
                         .now_clk_23(now_clk_wire[23]),
                         .now_clk_24(now_clk_wire[24]),
                         .now_clk_25(now_clk_wire[25]),
                         .now_clk_26(now_clk_wire[26]),
                         .now_clk_27(now_clk_wire[27]),
                         .now_clk_28(now_clk_wire[28]),
                         .now_clk_29(now_clk_wire[29]),
                         .now_clk_30(now_clk_wire[30]),
                         .now_clk_31(now_clk_wire[31]),
                         .now_pps_0(now_pps_wire[0]),
                         .now_pps_1(now_pps_wire[1]),
                         .now_pps_2(now_pps_wire[2]),
                         .now_pps_3(now_pps_wire[3]),
                         .now_pps_4(now_pps_wire[4]),
                         .now_pps_5(now_pps_wire[5]),
                         .now_pps_6(now_pps_wire[6]),
                         .now_pps_7(now_pps_wire[7]),
                         .now_pps_8(now_pps_wire[8]),
                         .now_pps_9(now_pps_wire[9]),
                         .now_pps_10(now_pps_wire[10]),
                         .now_pps_11(now_pps_wire[11]),
                         .now_pps_12(now_pps_wire[12]),
                         .now_pps_13(now_pps_wire[13]),
                         .now_pps_14(now_pps_wire[14]),
                         .now_pps_15(now_pps_wire[15]),
                         .now_pps_16(now_pps_wire[16]),
                         .now_pps_17(now_pps_wire[17]),
                         .now_pps_18(now_pps_wire[18]),
                         .now_pps_19(now_pps_wire[19]),
                         .now_pps_20(now_pps_wire[20]),
                         .now_pps_21(now_pps_wire[21]),
                         .now_pps_22(now_pps_wire[22]),
                         .now_pps_23(now_pps_wire[23]),
                         .now_pps_24(now_pps_wire[24]),
                         .now_pps_25(now_pps_wire[25]),
                         .now_pps_26(now_pps_wire[26]),
                         .now_pps_27(now_pps_wire[27]),
                         .now_pps_28(now_pps_wire[28]),
                         .now_pps_29(now_pps_wire[29]),
                         .now_pps_30(now_pps_wire[30]),
                         .now_pps_31(now_pps_wire[31]),
                         .now_0(now_wire[0]),
                         .now_1(now_wire[1]),
                         .now_2(now_wire[2]),
                         .now_3(now_wire[3]),
                         .now_4(now_wire[4]),
                         .now_5(now_wire[5]),
                         .now_6(now_wire[6]),
                         .now_7(now_wire[7]),
                         .now_8(now_wire[8]),
                         .now_9(now_wire[9]),
                         .now_10(now_wire[10]),
                         .now_11(now_wire[11]),
                         .now_12(now_wire[12]),
                         .now_13(now_wire[13]),
                         .now_14(now_wire[14]),
                         .now_15(now_wire[15]),
                         .now_16(now_wire[16]),
                         .now_17(now_wire[17]),
                         .now_18(now_wire[18]),
                         .now_19(now_wire[19]),
                         .now_20(now_wire[20]),
                         .now_21(now_wire[21]),
                         .now_22(now_wire[22]),
                         .now_23(now_wire[23]),
                         .now_24(now_wire[24]),
                         .now_25(now_wire[25]),
                         .now_26(now_wire[26]),
                         .now_27(now_wire[27]),
                         .now_28(now_wire[28]),
                         .now_29(now_wire[29]),
                         .now_30(now_wire[30]),
                         .now_31(now_wire[31]),

                         .s_axi_awvalid(control.awvalid),
		         .s_axi_awready(control.awready),
		         .s_axi_awaddr(control.awaddr),
		         .s_axi_awprot(control.awprot),
		         .s_axi_wvalid(control.wvalid),
		         .s_axi_wready(control.wready),
		         .s_axi_wdata(control.wdata),
		         .s_axi_wstrb(control.wstrb),
		         .s_axi_bvalid(control.bvalid),
		         .s_axi_bready(control.bready),
		         .s_axi_bresp(control.bresp),
		         .s_axi_arvalid(control.arvalid),
		         .s_axi_arready(control.arready),
		         .s_axi_araddr(control.araddr),
		         .s_axi_arprot(control.arprot),
		         .s_axi_rvalid(control.rvalid),
		         .s_axi_rready(control.rready),
		         .s_axi_rdata(control.rdata),
		         .s_axi_rresp(control.rresp));

endmodule
