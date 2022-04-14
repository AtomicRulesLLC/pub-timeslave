// Copyright (c) 2020 Atomic Rules LLC - All Rights Reserved
// This file contains "Licensed Materials" as defined in the Software License
// Agreement (SLA). It is provided strictly under the terms of the SLA.


module  mkIngressCapture #(parameter Stream_Width = 64
                           )
(
 input                              clk,
 input                              resetn,

 input [(Stream_Width * 8) - 1 : 0] mac_s_axis_tdata,
 input [Stream_Width-1 : 0]         mac_s_axis_tkeep,
 input                              mac_s_axis_tlast,
 input [79 : 0]                     mac_s_axis_tuser,
 input                              mac_s_axis_tvalid,
 output                             mac_s_axis_tready,

 output [(Stream_Width * 8) - 1:0]  usr_m_axis_tdata,
 output [Stream_Width-1:0]          usr_m_axis_tkeep,
 output                             usr_m_axis_tlast,
 output [79:0]                      usr_m_axis_tuser,
 output                             usr_m_axis_tvalid,
 input                              usr_m_axis_tready,

 input [11:0]                       s_axi_araddr,
 input [2:0]                        s_axi_arprot,
 output                             s_axi_arready,
 input                              s_axi_arvalid,
 input [11:0]                       s_axi_awaddr,
 input                              s_axi_awprot,
 output                             s_axi_awready,
 input                              s_axi_awvalid,
 input                              s_axi_bready,
 output [1:0]                       s_axi_bresp,
 output                             s_axi_bvalid,
 output [31:0]                      s_axi_rdata,
 input                              s_axi_rready,
 output [1:0]                       s_axi_rresp,
 output                             s_axi_rvalid,
 input [31:0]                       s_axi_wdata,
 output                             s_axi_wready,
 input [3:0]                        s_axi_wstrb,
 input                              s_axi_wvalid
 );

generate
  if (Stream_Width == 8) begin
     mkIngressCapture_8 ic8
       (
        .s_axi_aclk(clk),
        .s_axi_aresetn(resetn),
        .mac_s_axis_tdata(mac_s_axis_tdata),
        .mac_s_axis_tkeep(mac_s_axis_tkeep),
        .mac_s_axis_tlast(mac_s_axis_tlast),
        .mac_s_axis_tready(mac_s_axis_tready),
        .mac_s_axis_tuser(mac_s_axis_tuser),
        .mac_s_axis_tvalid(mac_s_axis_tvalid),
        .usr_m_axis_tdata(usr_m_axis_tdata),
        .usr_m_axis_tkeep(usr_m_axis_tkeep),
        .usr_m_axis_tlast(usr_m_axis_tlast),
        .usr_m_axis_tready(usr_m_axis_tready),
        .usr_m_axis_tuser(usr_m_axis_tuser),
        .usr_m_axis_tvalid(usr_m_axis_tvalid),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arprot(s_axi_arprot),
        .s_axi_arready(s_axi_arready),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awprot(s_axi_awprot),
        .s_axi_awready(s_axi_awready),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rready(s_axi_rready),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wready(s_axi_wready),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wvalid(s_axi_wvalid)
        );
  end
  else if (Stream_Width == 16) begin
     mkIngressCapture_16 ic16
       (
        .s_axi_aclk(clk),
        .s_axi_aresetn(resetn),
        .mac_s_axis_tdata(mac_s_axis_tdata),
        .mac_s_axis_tkeep(mac_s_axis_tkeep),
        .mac_s_axis_tlast(mac_s_axis_tlast),
        .mac_s_axis_tready(mac_s_axis_tready),
        .mac_s_axis_tuser(mac_s_axis_tuser),
        .mac_s_axis_tvalid(mac_s_axis_tvalid),
        .usr_m_axis_tdata(usr_m_axis_tdata),
        .usr_m_axis_tkeep(usr_m_axis_tkeep),
        .usr_m_axis_tlast(usr_m_axis_tlast),
        .usr_m_axis_tready(usr_m_axis_tready),
        .usr_m_axis_tuser(usr_m_axis_tuser),
        .usr_m_axis_tvalid(usr_m_axis_tvalid),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arprot(s_axi_arprot),
        .s_axi_arready(s_axi_arready),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awprot(s_axi_awprot),
        .s_axi_awready(s_axi_awready),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rready(s_axi_rready),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wready(s_axi_wready),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wvalid(s_axi_wvalid)
        );
  end
  else if (Stream_Width == 32) begin
     mkIngressCapture_32 ic32
       (
        .s_axi_aclk(clk),
        .s_axi_aresetn(resetn),
        .mac_s_axis_tdata(mac_s_axis_tdata),
        .mac_s_axis_tkeep(mac_s_axis_tkeep),
        .mac_s_axis_tlast(mac_s_axis_tlast),
        .mac_s_axis_tready(mac_s_axis_tready),
        .mac_s_axis_tuser(mac_s_axis_tuser),
        .mac_s_axis_tvalid(mac_s_axis_tvalid),
        .usr_m_axis_tdata(usr_m_axis_tdata),
        .usr_m_axis_tkeep(usr_m_axis_tkeep),
        .usr_m_axis_tlast(usr_m_axis_tlast),
        .usr_m_axis_tready(usr_m_axis_tready),
        .usr_m_axis_tuser(usr_m_axis_tuser),
        .usr_m_axis_tvalid(usr_m_axis_tvalid),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arprot(s_axi_arprot),
        .s_axi_arready(s_axi_arready),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awprot(s_axi_awprot),
        .s_axi_awready(s_axi_awready),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rready(s_axi_rready),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wready(s_axi_wready),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wvalid(s_axi_wvalid)
        );
  end
  else if (Stream_Width == 64) begin
     mkIngressCapture_64 ic64
       (
        .s_axi_aclk(clk),
        .s_axi_aresetn(resetn),
        .mac_s_axis_tdata(mac_s_axis_tdata),
        .mac_s_axis_tkeep(mac_s_axis_tkeep),
        .mac_s_axis_tlast(mac_s_axis_tlast),
        .mac_s_axis_tready(mac_s_axis_tready),
        .mac_s_axis_tuser(mac_s_axis_tuser),
        .mac_s_axis_tvalid(mac_s_axis_tvalid),
        .usr_m_axis_tdata(usr_m_axis_tdata),
        .usr_m_axis_tkeep(usr_m_axis_tkeep),
        .usr_m_axis_tlast(usr_m_axis_tlast),
        .usr_m_axis_tready(usr_m_axis_tready),
        .usr_m_axis_tuser(usr_m_axis_tuser),
        .usr_m_axis_tvalid(usr_m_axis_tvalid),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arprot(s_axi_arprot),
        .s_axi_arready(s_axi_arready),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awprot(s_axi_awprot),
        .s_axi_awready(s_axi_awready),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rready(s_axi_rready),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wready(s_axi_wready),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wvalid(s_axi_wvalid)
        );
  end
  else begin
    $error ("Invalid Stream_Width");
  end
endgenerate


endmodule
