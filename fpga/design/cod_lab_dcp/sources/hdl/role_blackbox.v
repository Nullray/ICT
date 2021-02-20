`timescale 1 ps / 1 ps

module role_bb
   (aclk,
    aresetn,
    axi_mmio_araddr,
    axi_mmio_arprot,
    axi_mmio_arready,
    axi_mmio_arvalid,
    axi_mmio_awaddr,
    axi_mmio_awprot,
    axi_mmio_awready,
    axi_mmio_awvalid,
    axi_mmio_bready,
    axi_mmio_bresp,
    axi_mmio_bvalid,
    axi_mmio_rdata,
    axi_mmio_rready,
    axi_mmio_rresp,
    axi_mmio_rvalid,
    axi_mmio_wdata,
    axi_mmio_wready,
    axi_mmio_wstrb,
    axi_mmio_wvalid);
  input aclk;
  input aresetn;
  input [31:0]axi_mmio_araddr;
  input [2:0]axi_mmio_arprot;
  output [0:0]axi_mmio_arready;
  input [0:0]axi_mmio_arvalid;
  input [31:0]axi_mmio_awaddr;
  input [2:0]axi_mmio_awprot;
  output [0:0]axi_mmio_awready;
  input [0:0]axi_mmio_awvalid;
  input [0:0]axi_mmio_bready;
  output [1:0]axi_mmio_bresp;
  output [0:0]axi_mmio_bvalid;
  output [31:0]axi_mmio_rdata;
  input [0:0]axi_mmio_rready;
  output [1:0]axi_mmio_rresp;
  output [0:0]axi_mmio_rvalid;
  input [31:0]axi_mmio_wdata;
  output [0:0]axi_mmio_wready;
  input [3:0]axi_mmio_wstrb;
  input [0:0]axi_mmio_wvalid;

  wire aclk;
  wire aresetn;
  wire [31:0]axi_mmio_araddr;
  wire [2:0]axi_mmio_arprot;
  wire [0:0]axi_mmio_arready;
  wire [0:0]axi_mmio_arvalid;
  wire [31:0]axi_mmio_awaddr;
  wire [2:0]axi_mmio_awprot;
  wire [0:0]axi_mmio_awready;
  wire [0:0]axi_mmio_awvalid;
  wire [0:0]axi_mmio_bready;
  wire [1:0]axi_mmio_bresp;
  wire [0:0]axi_mmio_bvalid;
  wire [31:0]axi_mmio_rdata;
  wire [0:0]axi_mmio_rready;
  wire [1:0]axi_mmio_rresp;
  wire [0:0]axi_mmio_rvalid;
  wire [31:0]axi_mmio_wdata;
  wire [0:0]axi_mmio_wready;
  wire [3:0]axi_mmio_wstrb;
  wire [0:0]axi_mmio_wvalid;

endmodule
