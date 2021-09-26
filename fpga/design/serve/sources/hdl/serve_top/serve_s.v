`timescale 1 ps / 1 ps
//`include "clocking.vh"

module debounce (
  input clk,
  input reset,
  input sig_i,
  output reg sig_o
);

  reg [15:0] cnt;

  always @(posedge clk) begin
    if (reset)
      cnt <= 16'h0;
    else if (sig_i == sig_o)
      cnt <= 16'h0;
    else
      cnt <= cnt + 16'h1;
  end

  always @(posedge clk) begin
    if (reset)
      sig_o <= 1'b0;
    else if (cnt == 16'hffff)
      sig_o <= sig_i;
  end

endmodule

module serve (
	);
  
  wire jtag_tms = 0;
  wire jtag_tck = 0;
  wire jtag_tdo = 0;
  wire jtag_tdi = 0;

  wire [3:0] btn = 0;
  wire [1:0] sw = 0;
  
  wire ps_pl_irq_enet3_0;
  wire ps_pl_irq_sdio1_0;
  wire ps_pl_irq_uart0_0;

  wire FCLK_RESET0_N;
  wire clk;
  wire reset;
  
  wire [39:0]io_front_axi_0_araddr;
  wire [1:0]io_front_axi_0_arburst;
  wire [3:0]io_front_axi_0_arcache;
  wire [7:0]io_front_axi_0_arlen;
  wire [0:0]io_front_axi_0_arlock;
  wire [2:0]io_front_axi_0_arprot;
  wire [3:0]io_front_axi_0_arqos;
  wire io_front_axi_0_arready;
  wire [2:0]io_front_axi_0_arsize;
  wire io_front_axi_0_arvalid;
  wire [39:0]io_front_axi_0_awaddr;
  wire [1:0]io_front_axi_0_awburst;
  wire [3:0]io_front_axi_0_awcache;
  wire [7:0]io_front_axi_0_awlen;
  wire [0:0]io_front_axi_0_awlock;
  wire [2:0]io_front_axi_0_awprot;
  wire [3:0]io_front_axi_0_awqos;
  wire io_front_axi_0_awready;
  wire [2:0]io_front_axi_0_awsize;
  wire io_front_axi_0_awvalid;
  wire io_front_axi_0_bready;
  wire [1:0]io_front_axi_0_bresp;
  wire io_front_axi_0_bvalid;
  wire [63:0]io_front_axi_0_rdata;
  wire io_front_axi_0_rlast;
  wire io_front_axi_0_rready;
  wire [1:0]io_front_axi_0_rresp;
  wire io_front_axi_0_rvalid;
  wire [63:0]io_front_axi_0_wdata;
  wire io_front_axi_0_wlast;
  wire io_front_axi_0_wready;
  wire [7:0]io_front_axi_0_wstrb;
  wire io_front_axi_0_wvalid;

  wire [39:0]io_front_axi_1_araddr;
  wire [1:0]io_front_axi_1_arburst;
  wire [3:0]io_front_axi_1_arcache;
  wire [7:0]io_front_axi_1_arlen;
  wire [0:0]io_front_axi_1_arlock;
  wire [2:0]io_front_axi_1_arprot;
  wire [3:0]io_front_axi_1_arqos;
  wire io_front_axi_1_arready;
  wire [2:0]io_front_axi_1_arsize;
  wire io_front_axi_1_arvalid;
  wire [39:0]io_front_axi_1_awaddr;
  wire [1:0]io_front_axi_1_awburst;
  wire [3:0]io_front_axi_1_awcache;
  wire [7:0]io_front_axi_1_awlen;
  wire [0:0]io_front_axi_1_awlock;
  wire [2:0]io_front_axi_1_awprot;
  wire [3:0]io_front_axi_1_awqos;
  wire io_front_axi_1_awready;
  wire [2:0]io_front_axi_1_awsize;
  wire io_front_axi_1_awvalid;
  wire io_front_axi_1_bready;
  wire [1:0]io_front_axi_1_bresp;
  wire io_front_axi_1_bvalid;
  wire [63:0]io_front_axi_1_rdata;
  wire io_front_axi_1_rlast;
  wire io_front_axi_1_rready;
  wire [1:0]io_front_axi_1_rresp;
  wire io_front_axi_1_rvalid;
  wire [63:0]io_front_axi_1_wdata;
  wire io_front_axi_1_wlast;
  wire io_front_axi_1_wready;
  wire [7:0]io_front_axi_1_wstrb;
  wire io_front_axi_1_wvalid;

  wire        mem_axi_0_awready;
  wire        mem_axi_0_awvalid;
  wire [3:0]  mem_axi_0_awid;
  wire [35:0] mem_axi_0_awaddr;
  wire [7:0]  mem_axi_0_awlen;
  wire [2:0]  mem_axi_0_awsize;
  wire [1:0]  mem_axi_0_awburst;
  wire        mem_axi_0_awlock;
  wire [3:0]  mem_axi_0_awcache;
  wire [2:0]  mem_axi_0_awprot;
  wire [3:0]  mem_axi_0_awqos;
  wire         mem_axi_0_wready;
  wire        mem_axi_0_wvalid;
  wire [63:0] mem_axi_0_wdata;
  wire [7:0]  mem_axi_0_wstrb;
  wire        mem_axi_0_wlast;
  wire        mem_axi_0_bready;
  wire         mem_axi_0_bvalid;
  wire  [3:0]  mem_axi_0_bid;
  wire  [1:0]  mem_axi_0_bresp;
  wire         mem_axi_0_arready;
  wire        mem_axi_0_arvalid;
  wire [3:0]  mem_axi_0_arid;
  wire [35:0] mem_axi_0_araddr;
  wire [7:0]  mem_axi_0_arlen;
  wire [2:0]  mem_axi_0_arsize;
  wire [1:0]  mem_axi_0_arburst;
  wire        mem_axi_0_arlock;
  wire [3:0]  mem_axi_0_arcache;
  wire [2:0]  mem_axi_0_arprot;
  wire [3:0]  mem_axi_0_arqos;
  wire        mem_axi_0_rready;
  wire         mem_axi_0_rvalid;
  wire  [3:0]  mem_axi_0_rid;
  wire  [63:0] mem_axi_0_rdata;
  wire  [1:0]  mem_axi_0_rresp;
  wire         mem_axi_0_rlast;

  wire        mem_axi_1_awready;
  wire        mem_axi_1_awvalid;
  wire [3:0]  mem_axi_1_awid;
  wire [35:0] mem_axi_1_awaddr;
  wire [7:0]  mem_axi_1_awlen;
  wire [2:0]  mem_axi_1_awsize;
  wire [1:0]  mem_axi_1_awburst;
  wire        mem_axi_1_awlock;
  wire [3:0]  mem_axi_1_awcache;
  wire [2:0]  mem_axi_1_awprot;
  wire [3:0]  mem_axi_1_awqos;
  wire         mem_axi_1_wready;
  wire        mem_axi_1_wvalid;
  wire [63:0] mem_axi_1_wdata;
  wire [7:0]  mem_axi_1_wstrb;
  wire        mem_axi_1_wlast;
  wire        mem_axi_1_bready;
  wire         mem_axi_1_bvalid;
  wire  [3:0]  mem_axi_1_bid;
  wire  [1:0]  mem_axi_1_bresp;
  wire         mem_axi_1_arready;
  wire        mem_axi_1_arvalid;
  wire [3:0]  mem_axi_1_arid;
  wire [35:0] mem_axi_1_araddr;
  wire [7:0]  mem_axi_1_arlen;
  wire [2:0]  mem_axi_1_arsize;
  wire [1:0]  mem_axi_1_arburst;
  wire        mem_axi_1_arlock;
  wire [3:0]  mem_axi_1_arcache;
  wire [2:0]  mem_axi_1_arprot;
  wire [3:0]  mem_axi_1_arqos;
  wire        mem_axi_1_rready;
  wire         mem_axi_1_rvalid;
  wire  [3:0]  mem_axi_1_rid;
  wire  [63:0] mem_axi_1_rdata;
  wire  [1:0]  mem_axi_1_rresp;
  wire         mem_axi_1_rlast;

  wire [35:0]mmio_axi_0_araddr;
  wire [1:0]mmio_axi_0_arburst;
  wire [3:0]mmio_axi_0_arcache;
  wire [3:0]mmio_axi_0_arid;
  wire [7:0]mmio_axi_0_arlen;
  wire [0:0]mmio_axi_0_arlock;
  wire [2:0]mmio_axi_0_arprot;
  wire [3:0]mmio_axi_0_arqos;
  wire mmio_axi_0_arready;
  wire [2:0]mmio_axi_0_arsize;
  wire mmio_axi_0_arvalid;
  wire [35:0]mmio_axi_0_awaddr;
  wire [1:0]mmio_axi_0_awburst;
  wire [3:0]mmio_axi_0_awcache;
  wire [3:0]mmio_axi_0_awid;
  wire [7:0]mmio_axi_0_awlen;
  wire [0:0]mmio_axi_0_awlock;
  wire [2:0]mmio_axi_0_awprot;
  wire [3:0]mmio_axi_0_awqos;
  wire mmio_axi_0_awready;
  wire [2:0]mmio_axi_0_awsize;
  wire mmio_axi_0_awvalid;
  wire [3:0]mmio_axi_0_bid;
  wire mmio_axi_0_bready;
  wire [1:0]mmio_axi_0_bresp;
  wire mmio_axi_0_bvalid;
  wire [63:0]mmio_axi_0_rdata;
  wire [3:0]mmio_axi_0_rid;
  wire mmio_axi_0_rlast;
  wire mmio_axi_0_rready;
  wire [1:0]mmio_axi_0_rresp;
  wire mmio_axi_0_rvalid;
  wire [63:0]mmio_axi_0_wdata;
  wire mmio_axi_0_wlast;
  wire mmio_axi_0_wready;
  wire [7:0]mmio_axi_0_wstrb;
  wire mmio_axi_0_wvalid;

  wire [35:0]mmio_axi_1_araddr;
  wire [1:0]mmio_axi_1_arburst;
  wire [3:0]mmio_axi_1_arcache;
  wire [3:0]mmio_axi_1_arid;
  wire [7:0]mmio_axi_1_arlen;
  wire [0:0]mmio_axi_1_arlock;
  wire [2:0]mmio_axi_1_arprot;
  wire [3:0]mmio_axi_1_arqos;
  wire mmio_axi_1_arready;
  wire [2:0]mmio_axi_1_arsize;
  wire mmio_axi_1_arvalid;
  wire [35:0]mmio_axi_1_awaddr;
  wire [1:0]mmio_axi_1_awburst;
  wire [3:0]mmio_axi_1_awcache;
  wire [3:0]mmio_axi_1_awid;
  wire [7:0]mmio_axi_1_awlen;
  wire [0:0]mmio_axi_1_awlock;
  wire [2:0]mmio_axi_1_awprot;
  wire [3:0]mmio_axi_1_awqos;
  wire mmio_axi_1_awready;
  wire [2:0]mmio_axi_1_awsize;
  wire mmio_axi_1_awvalid;
  wire [3:0]mmio_axi_1_bid;
  wire mmio_axi_1_bready;
  wire [1:0]mmio_axi_1_bresp;
  wire mmio_axi_1_bvalid;
  wire [63:0]mmio_axi_1_rdata;
  wire [3:0]mmio_axi_1_rid;
  wire mmio_axi_1_rlast;
  wire mmio_axi_1_rready;
  wire [1:0]mmio_axi_1_rresp;
  wire mmio_axi_1_rvalid;
  wire [63:0]mmio_axi_1_wdata;
  wire mmio_axi_1_wlast;
  wire mmio_axi_1_wready;
  wire [7:0]mmio_axi_1_wstrb;
  wire mmio_axi_1_wvalid;

  wire [35:0]mmio_axi_2_araddr;
  wire [1:0]mmio_axi_2_arburst;
  wire [3:0]mmio_axi_2_arcache;
  wire [3:0]mmio_axi_2_arid;
  wire [7:0]mmio_axi_2_arlen;
  wire [0:0]mmio_axi_2_arlock;
  wire [2:0]mmio_axi_2_arprot;
  wire [3:0]mmio_axi_2_arqos;
  wire mmio_axi_2_arready;
  wire [2:0]mmio_axi_2_arsize;
  wire mmio_axi_2_arvalid;
  wire [35:0]mmio_axi_2_awaddr;
  wire [1:0]mmio_axi_2_awburst;
  wire [3:0]mmio_axi_2_awcache;
  wire [3:0]mmio_axi_2_awid;
  wire [7:0]mmio_axi_2_awlen;
  wire [0:0]mmio_axi_2_awlock;
  wire [2:0]mmio_axi_2_awprot;
  wire [3:0]mmio_axi_2_awqos;
  wire mmio_axi_2_awready;
  wire [2:0]mmio_axi_2_awsize;
  wire mmio_axi_2_awvalid;
  wire [3:0]mmio_axi_2_bid;
  wire mmio_axi_2_bready;
  wire [1:0]mmio_axi_2_bresp;
  wire mmio_axi_2_bvalid;
  wire [63:0]mmio_axi_2_rdata;
  wire [3:0]mmio_axi_2_rid;
  wire mmio_axi_2_rlast;
  wire mmio_axi_2_rready;
  wire [1:0]mmio_axi_2_rresp;
  wire mmio_axi_2_rvalid;
  wire [63:0]mmio_axi_2_wdata;
  wire mmio_axi_2_wlast;
  wire mmio_axi_2_wready;
  wire [7:0]mmio_axi_2_wstrb;
  wire mmio_axi_2_wvalid;

  /* button debounce */
  wire [3:0] gpio_btns;
  wire [1:0] gpio_sws;

  genvar i;
  
  generate
    for (i=0; i<4; i=i+1) begin
      debounce u_debounce_btn(
        .clk(clk),
        .reset(reset),
        .sig_i(btn[i]),
        .sig_o(gpio_btns[i])
      );
    end
    for (i=0; i<2; i=i+1) begin
      debounce u_debounce_sw(
        .clk(clk),
        .reset(reset),
        .sig_i(sw[i]),
        .sig_o(gpio_sws[i])
      );
    end
  endgenerate
  
  wire soc_reset;

  serve_s_system system_i
  (
		.FCLK_CLK0(clk),
        .FCLK_RESET0_N(FCLK_RESET0_N),

		.ps_pl_irq_enet3_0(ps_pl_irq_enet3_0),
		.ps_pl_irq_sdio1_0(ps_pl_irq_sdio1_0),
		.ps_pl_irq_uart0_0(ps_pl_irq_uart0_0),

    .soc_reset(soc_reset),

		.io_front_axi_0_araddr	(io_front_axi_0_araddr),
        .io_front_axi_0_arburst	(io_front_axi_0_arburst),
        .io_front_axi_0_arcache	(io_front_axi_0_arcache),
        .io_front_axi_0_arlen		(io_front_axi_0_arlen),
        .io_front_axi_0_arlock	(io_front_axi_0_arlock),
        .io_front_axi_0_arprot	(io_front_axi_0_arprot),
        .io_front_axi_0_arqos		(io_front_axi_0_arqos),
        .io_front_axi_0_arready	(io_front_axi_0_arready),
        .io_front_axi_0_arsize	(io_front_axi_0_arsize),
        .io_front_axi_0_arvalid	(io_front_axi_0_arvalid),
        .io_front_axi_0_awaddr		(io_front_axi_0_awaddr),
        .io_front_axi_0_awburst	(io_front_axi_0_awburst),
        .io_front_axi_0_awcache	(io_front_axi_0_awcache),
        .io_front_axi_0_awlen		(io_front_axi_0_awlen),
        .io_front_axi_0_awlock		(io_front_axi_0_awlock),
        .io_front_axi_0_awprot		(io_front_axi_0_awprot),
        .io_front_axi_0_awqos		(io_front_axi_0_awqos),
        .io_front_axi_0_awready	(io_front_axi_0_awready),
        .io_front_axi_0_awsize		(io_front_axi_0_awsize),
        .io_front_axi_0_awvalid	(io_front_axi_0_awvalid),
        .io_front_axi_0_bready		(io_front_axi_0_bready),
        .io_front_axi_0_bresp		(io_front_axi_0_bresp),
        .io_front_axi_0_bvalid		(io_front_axi_0_bvalid),
        .io_front_axi_0_rdata		(io_front_axi_0_rdata),
        .io_front_axi_0_rlast		(io_front_axi_0_rlast),
        .io_front_axi_0_rready		(io_front_axi_0_rready),
        .io_front_axi_0_rresp		(io_front_axi_0_rresp),
        .io_front_axi_0_rvalid		(io_front_axi_0_rvalid),
        .io_front_axi_0_wdata		(io_front_axi_0_wdata),
        .io_front_axi_0_wlast		(io_front_axi_0_wlast),
        .io_front_axi_0_wready		(io_front_axi_0_wready),
        .io_front_axi_0_wstrb		(io_front_axi_0_wstrb),
        .io_front_axi_0_wvalid		(io_front_axi_0_wvalid),

		.io_front_axi_1_araddr	(io_front_axi_1_araddr),
        .io_front_axi_1_arburst	(io_front_axi_1_arburst),
        .io_front_axi_1_arcache	(io_front_axi_1_arcache),
        .io_front_axi_1_arlen		(io_front_axi_1_arlen),
        .io_front_axi_1_arlock	(io_front_axi_1_arlock),
        .io_front_axi_1_arprot	(io_front_axi_1_arprot),
        .io_front_axi_1_arqos		(io_front_axi_1_arqos),
        .io_front_axi_1_arready	(io_front_axi_1_arready),
        .io_front_axi_1_arsize	(io_front_axi_1_arsize),
        .io_front_axi_1_arvalid	(io_front_axi_1_arvalid),
        .io_front_axi_1_awaddr		(io_front_axi_1_awaddr),
        .io_front_axi_1_awburst	(io_front_axi_1_awburst),
        .io_front_axi_1_awcache	(io_front_axi_1_awcache),
        .io_front_axi_1_awlen		(io_front_axi_1_awlen),
        .io_front_axi_1_awlock		(io_front_axi_1_awlock),
        .io_front_axi_1_awprot		(io_front_axi_1_awprot),
        .io_front_axi_1_awqos		(io_front_axi_1_awqos),
        .io_front_axi_1_awready	(io_front_axi_1_awready),
        .io_front_axi_1_awsize		(io_front_axi_1_awsize),
        .io_front_axi_1_awvalid	(io_front_axi_1_awvalid),
        .io_front_axi_1_bready		(io_front_axi_1_bready),
        .io_front_axi_1_bresp		(io_front_axi_1_bresp),
        .io_front_axi_1_bvalid		(io_front_axi_1_bvalid),
        .io_front_axi_1_rdata		(io_front_axi_1_rdata),
        .io_front_axi_1_rlast		(io_front_axi_1_rlast),
        .io_front_axi_1_rready		(io_front_axi_1_rready),
        .io_front_axi_1_rresp		(io_front_axi_1_rresp),
        .io_front_axi_1_rvalid		(io_front_axi_1_rvalid),
        .io_front_axi_1_wdata		(io_front_axi_1_wdata),
        .io_front_axi_1_wlast		(io_front_axi_1_wlast),
        .io_front_axi_1_wready		(io_front_axi_1_wready),
        .io_front_axi_1_wstrb		(io_front_axi_1_wstrb),
        .io_front_axi_1_wvalid		(io_front_axi_1_wvalid),

        .mem_axi_0_araddr({3'd0, mem_axi_0_araddr}),
        .mem_axi_0_arburst(mem_axi_0_arburst),
        .mem_axi_0_arcache(mem_axi_0_arcache),
        .mem_axi_0_arid(mem_axi_0_arid),
        .mem_axi_0_arlen(mem_axi_0_arlen),
        .mem_axi_0_arlock(mem_axi_0_arlock),
        .mem_axi_0_arprot(mem_axi_0_arprot),
        .mem_axi_0_arqos(mem_axi_0_arqos),
        .mem_axi_0_arready(mem_axi_0_arready),
        .mem_axi_0_arsize(mem_axi_0_arsize),
        .mem_axi_0_arvalid(mem_axi_0_arvalid),
        .mem_axi_0_awaddr({3'd0, mem_axi_0_awaddr}),
        .mem_axi_0_awburst(mem_axi_0_awburst),
        .mem_axi_0_awcache(mem_axi_0_awcache),
        .mem_axi_0_awid(mem_axi_0_awid),
        .mem_axi_0_awlen(mem_axi_0_awlen),
        .mem_axi_0_awlock(mem_axi_0_awlock),
        .mem_axi_0_awprot(mem_axi_0_awprot),
        .mem_axi_0_awqos(mem_axi_0_awqos),
        .mem_axi_0_awready(mem_axi_0_awready),
        .mem_axi_0_awsize(mem_axi_0_awsize),
        .mem_axi_0_awvalid(mem_axi_0_awvalid),
        .mem_axi_0_bid(mem_axi_0_bid),
        .mem_axi_0_bready(mem_axi_0_bready),
        .mem_axi_0_bresp(mem_axi_0_bresp),
        .mem_axi_0_bvalid(mem_axi_0_bvalid),
        .mem_axi_0_rid(mem_axi_0_rid),
        .mem_axi_0_rdata(mem_axi_0_rdata),
        .mem_axi_0_rlast(mem_axi_0_rlast),
        .mem_axi_0_rready(mem_axi_0_rready),
        .mem_axi_0_rresp(mem_axi_0_rresp),
        .mem_axi_0_rvalid(mem_axi_0_rvalid),
        .mem_axi_0_wdata(mem_axi_0_wdata),
        .mem_axi_0_wlast(mem_axi_0_wlast),
        .mem_axi_0_wready(mem_axi_0_wready),
        .mem_axi_0_wstrb(mem_axi_0_wstrb),
        .mem_axi_0_wvalid(mem_axi_0_wvalid),

        .mem_axi_1_araddr({3'd0, mem_axi_1_araddr}),
        .mem_axi_1_arburst(mem_axi_1_arburst),
        .mem_axi_1_arcache(mem_axi_1_arcache),
        .mem_axi_1_arid(mem_axi_1_arid),
        .mem_axi_1_arlen(mem_axi_1_arlen),
        .mem_axi_1_arlock(mem_axi_1_arlock),
        .mem_axi_1_arprot(mem_axi_1_arprot),
        .mem_axi_1_arqos(mem_axi_1_arqos),
        .mem_axi_1_arready(mem_axi_1_arready),
        .mem_axi_1_arsize(mem_axi_1_arsize),
        .mem_axi_1_arvalid(mem_axi_1_arvalid),
        .mem_axi_1_awaddr({3'd0, mem_axi_1_awaddr}),
        .mem_axi_1_awburst(mem_axi_1_awburst),
        .mem_axi_1_awcache(mem_axi_1_awcache),
        .mem_axi_1_awid(mem_axi_1_awid),
        .mem_axi_1_awlen(mem_axi_1_awlen),
        .mem_axi_1_awlock(mem_axi_1_awlock),
        .mem_axi_1_awprot(mem_axi_1_awprot),
        .mem_axi_1_awqos(mem_axi_1_awqos),
        .mem_axi_1_awready(mem_axi_1_awready),
        .mem_axi_1_awsize(mem_axi_1_awsize),
        .mem_axi_1_awvalid(mem_axi_1_awvalid),
        .mem_axi_1_bid(mem_axi_1_bid),
        .mem_axi_1_bready(mem_axi_1_bready),
        .mem_axi_1_bresp(mem_axi_1_bresp),
        .mem_axi_1_bvalid(mem_axi_1_bvalid),
        .mem_axi_1_rid(mem_axi_1_rid),
        .mem_axi_1_rdata(mem_axi_1_rdata),
        .mem_axi_1_rlast(mem_axi_1_rlast),
        .mem_axi_1_rready(mem_axi_1_rready),
        .mem_axi_1_rresp(mem_axi_1_rresp),
        .mem_axi_1_rvalid(mem_axi_1_rvalid),
        .mem_axi_1_wdata(mem_axi_1_wdata),
        .mem_axi_1_wlast(mem_axi_1_wlast),
        .mem_axi_1_wready(mem_axi_1_wready),
        .mem_axi_1_wstrb(mem_axi_1_wstrb),
        .mem_axi_1_wvalid(mem_axi_1_wvalid),

        .mmio_axi_0_araddr(mmio_axi_0_araddr),
        .mmio_axi_0_arburst(mmio_axi_0_arburst),
        .mmio_axi_0_arcache(mmio_axi_0_arcache),
        .mmio_axi_0_arid(mmio_axi_0_arid),
        .mmio_axi_0_arlen(mmio_axi_0_arlen),
        .mmio_axi_0_arlock(mmio_axi_0_arlock),
        .mmio_axi_0_arprot(mmio_axi_0_arprot),
        .mmio_axi_0_arqos(mmio_axi_0_arqos),
        .mmio_axi_0_arready(mmio_axi_0_arready),
        .mmio_axi_0_arsize(mmio_axi_0_arsize),
        .mmio_axi_0_arvalid(mmio_axi_0_arvalid),
        .mmio_axi_0_awaddr(mmio_axi_0_awaddr),
        .mmio_axi_0_awburst(mmio_axi_0_awburst),
        .mmio_axi_0_awcache(mmio_axi_0_awcache),
        .mmio_axi_0_awid(mmio_axi_0_awid),
        .mmio_axi_0_awlen(mmio_axi_0_awlen),
        .mmio_axi_0_awlock(mmio_axi_0_awlock),
        .mmio_axi_0_awprot(mmio_axi_0_awprot),
        .mmio_axi_0_awqos(mmio_axi_0_awqos),
        .mmio_axi_0_awready(mmio_axi_0_awready),
        .mmio_axi_0_awsize(mmio_axi_0_awsize),
        .mmio_axi_0_awvalid(mmio_axi_0_awvalid),
        .mmio_axi_0_bid(mmio_axi_0_bid),
        .mmio_axi_0_bready(mmio_axi_0_bready),
        .mmio_axi_0_bresp(mmio_axi_0_bresp),
        .mmio_axi_0_bvalid(mmio_axi_0_bvalid),
        .mmio_axi_0_rid(mmio_axi_0_rid),
        .mmio_axi_0_rdata(mmio_axi_0_rdata),
        .mmio_axi_0_rlast(mmio_axi_0_rlast),
        .mmio_axi_0_rready(mmio_axi_0_rready),
        .mmio_axi_0_rresp(mmio_axi_0_rresp),
        .mmio_axi_0_rvalid(mmio_axi_0_rvalid),
        .mmio_axi_0_wdata(mmio_axi_0_wdata),
        .mmio_axi_0_wlast(mmio_axi_0_wlast),
        .mmio_axi_0_wready(mmio_axi_0_wready),
        .mmio_axi_0_wstrb(mmio_axi_0_wstrb),
        .mmio_axi_0_wvalid(mmio_axi_0_wvalid),

        .mmio_axi_1_araddr(mmio_axi_1_araddr),
        .mmio_axi_1_arburst(mmio_axi_1_arburst),
        .mmio_axi_1_arcache(mmio_axi_1_arcache),
        .mmio_axi_1_arid(mmio_axi_1_arid),
        .mmio_axi_1_arlen(mmio_axi_1_arlen),
        .mmio_axi_1_arlock(mmio_axi_1_arlock),
        .mmio_axi_1_arprot(mmio_axi_1_arprot),
        .mmio_axi_1_arqos(mmio_axi_1_arqos),
        .mmio_axi_1_arready(mmio_axi_1_arready),
        .mmio_axi_1_arsize(mmio_axi_1_arsize),
        .mmio_axi_1_arvalid(mmio_axi_1_arvalid),
        .mmio_axi_1_awaddr(mmio_axi_1_awaddr),
        .mmio_axi_1_awburst(mmio_axi_1_awburst),
        .mmio_axi_1_awcache(mmio_axi_1_awcache),
        .mmio_axi_1_awid(mmio_axi_1_awid),
        .mmio_axi_1_awlen(mmio_axi_1_awlen),
        .mmio_axi_1_awlock(mmio_axi_1_awlock),
        .mmio_axi_1_awprot(mmio_axi_1_awprot),
        .mmio_axi_1_awqos(mmio_axi_1_awqos),
        .mmio_axi_1_awready(mmio_axi_1_awready),
        .mmio_axi_1_awsize(mmio_axi_1_awsize),
        .mmio_axi_1_awvalid(mmio_axi_1_awvalid),
        .mmio_axi_1_bid(mmio_axi_1_bid),
        .mmio_axi_1_bready(mmio_axi_1_bready),
        .mmio_axi_1_bresp(mmio_axi_1_bresp),
        .mmio_axi_1_bvalid(mmio_axi_1_bvalid),
        .mmio_axi_1_rid(mmio_axi_1_rid),
        .mmio_axi_1_rdata(mmio_axi_1_rdata),
        .mmio_axi_1_rlast(mmio_axi_1_rlast),
        .mmio_axi_1_rready(mmio_axi_1_rready),
        .mmio_axi_1_rresp(mmio_axi_1_rresp),
        .mmio_axi_1_rvalid(mmio_axi_1_rvalid),
        .mmio_axi_1_wdata(mmio_axi_1_wdata),
        .mmio_axi_1_wlast(mmio_axi_1_wlast),
        .mmio_axi_1_wready(mmio_axi_1_wready),
        .mmio_axi_1_wstrb(mmio_axi_1_wstrb),
        .mmio_axi_1_wvalid(mmio_axi_1_wvalid),

        .mmio_axi_2_araddr(mmio_axi_2_araddr),
        .mmio_axi_2_arburst(mmio_axi_2_arburst),
        .mmio_axi_2_arcache(mmio_axi_2_arcache),
        .mmio_axi_2_arid(mmio_axi_2_arid),
        .mmio_axi_2_arlen(mmio_axi_2_arlen),
        .mmio_axi_2_arlock(mmio_axi_2_arlock),
        .mmio_axi_2_arprot(mmio_axi_2_arprot),
        .mmio_axi_2_arqos(mmio_axi_2_arqos),
        .mmio_axi_2_arready(mmio_axi_2_arready),
        .mmio_axi_2_arsize(mmio_axi_2_arsize),
        .mmio_axi_2_arvalid(mmio_axi_2_arvalid),
        .mmio_axi_2_awaddr(mmio_axi_2_awaddr),
        .mmio_axi_2_awburst(mmio_axi_2_awburst),
        .mmio_axi_2_awcache(mmio_axi_2_awcache),
        .mmio_axi_2_awid(mmio_axi_2_awid),
        .mmio_axi_2_awlen(mmio_axi_2_awlen),
        .mmio_axi_2_awlock(mmio_axi_2_awlock),
        .mmio_axi_2_awprot(mmio_axi_2_awprot),
        .mmio_axi_2_awqos(mmio_axi_2_awqos),
        .mmio_axi_2_awready(mmio_axi_2_awready),
        .mmio_axi_2_awsize(mmio_axi_2_awsize),
        .mmio_axi_2_awvalid(mmio_axi_2_awvalid),
        .mmio_axi_2_bid(mmio_axi_2_bid),
        .mmio_axi_2_bready(mmio_axi_2_bready),
        .mmio_axi_2_bresp(mmio_axi_2_bresp),
        .mmio_axi_2_bvalid(mmio_axi_2_bvalid),
        .mmio_axi_2_rid(mmio_axi_2_rid),
        .mmio_axi_2_rdata(mmio_axi_2_rdata),
        .mmio_axi_2_rlast(mmio_axi_2_rlast),
        .mmio_axi_2_rready(mmio_axi_2_rready),
        .mmio_axi_2_rresp(mmio_axi_2_rresp),
        .mmio_axi_2_rvalid(mmio_axi_2_rvalid),
        .mmio_axi_2_wdata(mmio_axi_2_wdata),
        .mmio_axi_2_wlast(mmio_axi_2_wlast),
        .mmio_axi_2_wready(mmio_axi_2_wready),
        .mmio_axi_2_wstrb(mmio_axi_2_wstrb),
        .mmio_axi_2_wvalid(mmio_axi_2_wvalid)
  );

  assign reset = !FCLK_RESET0_N ;
  
  wire jtag_tdo_data, jtag_tdo_driven;
  assign jtag_tdo = jtag_tdo_driven ? jtag_tdo_data : 1'bz;

  SERVETop top(
   .clock(clk),
   .reset(soc_reset),
   .io_mac_int(ps_pl_irq_enet3_0),
   .io_sdio_int(ps_pl_irq_sdio1_0),
   .io_uart_int(ps_pl_irq_uart0_0),

   .mem_axi_0_ar_valid (mem_axi_0_arvalid),
   .mem_axi_0_ar_ready (mem_axi_0_arready),
   .mem_axi_0_ar_bits_addr (mem_axi_0_araddr),
   .mem_axi_0_ar_bits_id (mem_axi_0_arid),
   .mem_axi_0_ar_bits_size (mem_axi_0_arsize),
   .mem_axi_0_ar_bits_len (mem_axi_0_arlen),
   .mem_axi_0_ar_bits_burst (mem_axi_0_arburst),
   .mem_axi_0_ar_bits_cache (mem_axi_0_arcache),
   .mem_axi_0_ar_bits_lock (mem_axi_0_arlock),
   .mem_axi_0_ar_bits_prot (mem_axi_0_arprot),
   .mem_axi_0_ar_bits_qos (mem_axi_0_arqos),
   .mem_axi_0_aw_valid (mem_axi_0_awvalid),
   .mem_axi_0_aw_ready (mem_axi_0_awready),
   .mem_axi_0_aw_bits_addr (mem_axi_0_awaddr),
   .mem_axi_0_aw_bits_id (mem_axi_0_awid),
   .mem_axi_0_aw_bits_size (mem_axi_0_awsize),
   .mem_axi_0_aw_bits_len (mem_axi_0_awlen),
   .mem_axi_0_aw_bits_burst (mem_axi_0_awburst),
   .mem_axi_0_aw_bits_cache (mem_axi_0_awcache),
   .mem_axi_0_aw_bits_lock (mem_axi_0_awlock),
   .mem_axi_0_aw_bits_prot (mem_axi_0_awprot),
   .mem_axi_0_aw_bits_qos (mem_axi_0_awqos),
   .mem_axi_0_w_valid (mem_axi_0_wvalid),
   .mem_axi_0_w_ready (mem_axi_0_wready),
   .mem_axi_0_w_bits_strb (mem_axi_0_wstrb),
   .mem_axi_0_w_bits_data (mem_axi_0_wdata),
   .mem_axi_0_w_bits_last (mem_axi_0_wlast),
   .mem_axi_0_b_valid (mem_axi_0_bvalid),
   .mem_axi_0_b_ready (mem_axi_0_bready),
   .mem_axi_0_b_bits_resp (mem_axi_0_bresp),
   .mem_axi_0_b_bits_id (mem_axi_0_bid),
   .mem_axi_0_r_valid (mem_axi_0_rvalid),
   .mem_axi_0_r_ready (mem_axi_0_rready),
   .mem_axi_0_r_bits_resp (mem_axi_0_rresp),
   .mem_axi_0_r_bits_id (mem_axi_0_rid),
   .mem_axi_0_r_bits_data (mem_axi_0_rdata),
   .mem_axi_0_r_bits_last (mem_axi_0_rlast),

   .mem_axi_1_ar_valid (mem_axi_1_arvalid),
   .mem_axi_1_ar_ready (mem_axi_1_arready),
   .mem_axi_1_ar_bits_addr (mem_axi_1_araddr),
   .mem_axi_1_ar_bits_id (mem_axi_1_arid),
   .mem_axi_1_ar_bits_size (mem_axi_1_arsize),
   .mem_axi_1_ar_bits_len (mem_axi_1_arlen),
   .mem_axi_1_ar_bits_burst (mem_axi_1_arburst),
   .mem_axi_1_ar_bits_cache (mem_axi_1_arcache),
   .mem_axi_1_ar_bits_lock (mem_axi_1_arlock),
   .mem_axi_1_ar_bits_prot (mem_axi_1_arprot),
   .mem_axi_1_ar_bits_qos (mem_axi_1_arqos),
   .mem_axi_1_aw_valid (mem_axi_1_awvalid),
   .mem_axi_1_aw_ready (mem_axi_1_awready),
   .mem_axi_1_aw_bits_addr (mem_axi_1_awaddr),
   .mem_axi_1_aw_bits_id (mem_axi_1_awid),
   .mem_axi_1_aw_bits_size (mem_axi_1_awsize),
   .mem_axi_1_aw_bits_len (mem_axi_1_awlen),
   .mem_axi_1_aw_bits_burst (mem_axi_1_awburst),
   .mem_axi_1_aw_bits_cache (mem_axi_1_awcache),
   .mem_axi_1_aw_bits_lock (mem_axi_1_awlock),
   .mem_axi_1_aw_bits_prot (mem_axi_1_awprot),
   .mem_axi_1_aw_bits_qos (mem_axi_1_awqos),
   .mem_axi_1_w_valid (mem_axi_1_wvalid),
   .mem_axi_1_w_ready (mem_axi_1_wready),
   .mem_axi_1_w_bits_strb (mem_axi_1_wstrb),
   .mem_axi_1_w_bits_data (mem_axi_1_wdata),
   .mem_axi_1_w_bits_last (mem_axi_1_wlast),
   .mem_axi_1_b_valid (mem_axi_1_bvalid),
   .mem_axi_1_b_ready (mem_axi_1_bready),
   .mem_axi_1_b_bits_resp (mem_axi_1_bresp),
   .mem_axi_1_b_bits_id (mem_axi_1_bid),
   .mem_axi_1_r_valid (mem_axi_1_rvalid),
   .mem_axi_1_r_ready (mem_axi_1_rready),
   .mem_axi_1_r_bits_resp (mem_axi_1_rresp),
   .mem_axi_1_r_bits_id (mem_axi_1_rid),
   .mem_axi_1_r_bits_data (mem_axi_1_rdata),
   .mem_axi_1_r_bits_last (mem_axi_1_rlast),

   .mmio_axi_0_ar_valid (mmio_axi_0_arvalid),
   .mmio_axi_0_ar_ready (mmio_axi_0_arready),
   .mmio_axi_0_ar_bits_addr (mmio_axi_0_araddr),
   .mmio_axi_0_ar_bits_id (mmio_axi_0_arid),
   .mmio_axi_0_ar_bits_size (mmio_axi_0_arsize),
   .mmio_axi_0_ar_bits_len (mmio_axi_0_arlen),
   .mmio_axi_0_ar_bits_burst (mmio_axi_0_arburst),
   .mmio_axi_0_ar_bits_cache (mmio_axi_0_arcache),
   .mmio_axi_0_ar_bits_lock (mmio_axi_0_arlock),
   .mmio_axi_0_ar_bits_prot (mmio_axi_0_arprot),
   .mmio_axi_0_ar_bits_qos (mmio_axi_0_arqos),
   .mmio_axi_0_aw_valid (mmio_axi_0_awvalid),
   .mmio_axi_0_aw_ready (mmio_axi_0_awready),
   .mmio_axi_0_aw_bits_addr (mmio_axi_0_awaddr),
   .mmio_axi_0_aw_bits_id (mmio_axi_0_awid),
   .mmio_axi_0_aw_bits_size (mmio_axi_0_awsize),
   .mmio_axi_0_aw_bits_len (mmio_axi_0_awlen),
   .mmio_axi_0_aw_bits_burst (mmio_axi_0_awburst),
   .mmio_axi_0_aw_bits_cache (mmio_axi_0_awcache),
   .mmio_axi_0_aw_bits_lock (mmio_axi_0_awlock),
   .mmio_axi_0_aw_bits_prot (mmio_axi_0_awprot),
   .mmio_axi_0_aw_bits_qos (mmio_axi_0_awqos),
   .mmio_axi_0_w_valid (mmio_axi_0_wvalid),
   .mmio_axi_0_w_ready (mmio_axi_0_wready),
   .mmio_axi_0_w_bits_strb (mmio_axi_0_wstrb),
   .mmio_axi_0_w_bits_data (mmio_axi_0_wdata),
   .mmio_axi_0_w_bits_last (mmio_axi_0_wlast),
   .mmio_axi_0_b_valid (mmio_axi_0_bvalid),
   .mmio_axi_0_b_ready (mmio_axi_0_bready),
   .mmio_axi_0_b_bits_resp (mmio_axi_0_bresp),
   .mmio_axi_0_b_bits_id (mmio_axi_0_bid),
   .mmio_axi_0_r_valid (mmio_axi_0_rvalid),
   .mmio_axi_0_r_ready (mmio_axi_0_rready),
   .mmio_axi_0_r_bits_resp (mmio_axi_0_rresp),
   .mmio_axi_0_r_bits_id (mmio_axi_0_rid),
   .mmio_axi_0_r_bits_data (mmio_axi_0_rdata),
   .mmio_axi_0_r_bits_last (mmio_axi_0_rlast),

   .mmio_axi_1_ar_valid (mmio_axi_1_arvalid),
   .mmio_axi_1_ar_ready (mmio_axi_1_arready),
   .mmio_axi_1_ar_bits_addr (mmio_axi_1_araddr),
   .mmio_axi_1_ar_bits_id (mmio_axi_1_arid),
   .mmio_axi_1_ar_bits_size (mmio_axi_1_arsize),
   .mmio_axi_1_ar_bits_len (mmio_axi_1_arlen),
   .mmio_axi_1_ar_bits_burst (mmio_axi_1_arburst),
   .mmio_axi_1_ar_bits_cache (mmio_axi_1_arcache),
   .mmio_axi_1_ar_bits_lock (mmio_axi_1_arlock),
   .mmio_axi_1_ar_bits_prot (mmio_axi_1_arprot),
   .mmio_axi_1_ar_bits_qos (mmio_axi_1_arqos),
   .mmio_axi_1_aw_valid (mmio_axi_1_awvalid),
   .mmio_axi_1_aw_ready (mmio_axi_1_awready),
   .mmio_axi_1_aw_bits_addr (mmio_axi_1_awaddr),
   .mmio_axi_1_aw_bits_id (mmio_axi_1_awid),
   .mmio_axi_1_aw_bits_size (mmio_axi_1_awsize),
   .mmio_axi_1_aw_bits_len (mmio_axi_1_awlen),
   .mmio_axi_1_aw_bits_burst (mmio_axi_1_awburst),
   .mmio_axi_1_aw_bits_cache (mmio_axi_1_awcache),
   .mmio_axi_1_aw_bits_lock (mmio_axi_1_awlock),
   .mmio_axi_1_aw_bits_prot (mmio_axi_1_awprot),
   .mmio_axi_1_aw_bits_qos (mmio_axi_1_awqos),
   .mmio_axi_1_w_valid (mmio_axi_1_wvalid),
   .mmio_axi_1_w_ready (mmio_axi_1_wready),
   .mmio_axi_1_w_bits_strb (mmio_axi_1_wstrb),
   .mmio_axi_1_w_bits_data (mmio_axi_1_wdata),
   .mmio_axi_1_w_bits_last (mmio_axi_1_wlast),
   .mmio_axi_1_b_valid (mmio_axi_1_bvalid),
   .mmio_axi_1_b_ready (mmio_axi_1_bready),
   .mmio_axi_1_b_bits_resp (mmio_axi_1_bresp),
   .mmio_axi_1_b_bits_id (mmio_axi_1_bid),
   .mmio_axi_1_r_valid (mmio_axi_1_rvalid),
   .mmio_axi_1_r_ready (mmio_axi_1_rready),
   .mmio_axi_1_r_bits_resp (mmio_axi_1_rresp),
   .mmio_axi_1_r_bits_id (mmio_axi_1_rid),
   .mmio_axi_1_r_bits_data (mmio_axi_1_rdata),
   .mmio_axi_1_r_bits_last (mmio_axi_1_rlast),

   .mmio_axi_2_ar_valid (mmio_axi_2_arvalid),
   .mmio_axi_2_ar_ready (mmio_axi_2_arready),
   .mmio_axi_2_ar_bits_addr (mmio_axi_2_araddr),
   .mmio_axi_2_ar_bits_id (mmio_axi_2_arid),
   .mmio_axi_2_ar_bits_size (mmio_axi_2_arsize),
   .mmio_axi_2_ar_bits_len (mmio_axi_2_arlen),
   .mmio_axi_2_ar_bits_burst (mmio_axi_2_arburst),
   .mmio_axi_2_ar_bits_cache (mmio_axi_2_arcache),
   .mmio_axi_2_ar_bits_lock (mmio_axi_2_arlock),
   .mmio_axi_2_ar_bits_prot (mmio_axi_2_arprot),
   .mmio_axi_2_ar_bits_qos (mmio_axi_2_arqos),
   .mmio_axi_2_aw_valid (mmio_axi_2_awvalid),
   .mmio_axi_2_aw_ready (mmio_axi_2_awready),
   .mmio_axi_2_aw_bits_addr (mmio_axi_2_awaddr),
   .mmio_axi_2_aw_bits_id (mmio_axi_2_awid),
   .mmio_axi_2_aw_bits_size (mmio_axi_2_awsize),
   .mmio_axi_2_aw_bits_len (mmio_axi_2_awlen),
   .mmio_axi_2_aw_bits_burst (mmio_axi_2_awburst),
   .mmio_axi_2_aw_bits_cache (mmio_axi_2_awcache),
   .mmio_axi_2_aw_bits_lock (mmio_axi_2_awlock),
   .mmio_axi_2_aw_bits_prot (mmio_axi_2_awprot),
   .mmio_axi_2_aw_bits_qos (mmio_axi_2_awqos),
   .mmio_axi_2_w_valid (mmio_axi_2_wvalid),
   .mmio_axi_2_w_ready (mmio_axi_2_wready),
   .mmio_axi_2_w_bits_strb (mmio_axi_2_wstrb),
   .mmio_axi_2_w_bits_data (mmio_axi_2_wdata),
   .mmio_axi_2_w_bits_last (mmio_axi_2_wlast),
   .mmio_axi_2_b_valid (mmio_axi_2_bvalid),
   .mmio_axi_2_b_ready (mmio_axi_2_bready),
   .mmio_axi_2_b_bits_resp (mmio_axi_2_bresp),
   .mmio_axi_2_b_bits_id (mmio_axi_2_bid),
   .mmio_axi_2_r_valid (mmio_axi_2_rvalid),
   .mmio_axi_2_r_ready (mmio_axi_2_rready),
   .mmio_axi_2_r_bits_resp (mmio_axi_2_rresp),
   .mmio_axi_2_r_bits_id (mmio_axi_2_rid),
   .mmio_axi_2_r_bits_data (mmio_axi_2_rdata),
   .mmio_axi_2_r_bits_last (mmio_axi_2_rlast),

   .front_axi_0_ar_valid 		(io_front_axi_0_arvalid),
   .front_axi_0_ar_ready 		(io_front_axi_0_arready),
   .front_axi_0_ar_bits_addr 	(io_front_axi_0_araddr),
   .front_axi_0_ar_bits_id 	(),
   .front_axi_0_ar_bits_size 	(io_front_axi_0_arsize),
   .front_axi_0_ar_bits_len 	(io_front_axi_0_arlen),
   .front_axi_0_ar_bits_burst 	(io_front_axi_0_arburst),
   .front_axi_0_ar_bits_cache 	(io_front_axi_0_arcache),
   .front_axi_0_ar_bits_lock 	(io_front_axi_0_arlock),
   .front_axi_0_ar_bits_prot 	(io_front_axi_0_arprot),
   .front_axi_0_ar_bits_qos 	(io_front_axi_0_arqos),
   .front_axi_0_aw_valid 		(io_front_axi_0_awvalid),
   .front_axi_0_aw_ready 		(io_front_axi_0_awready),
   .front_axi_0_aw_bits_addr 	(io_front_axi_0_awaddr),
   .front_axi_0_aw_bits_id 	(),
   .front_axi_0_aw_bits_size 	(io_front_axi_0_awsize),
   .front_axi_0_aw_bits_len 	(io_front_axi_0_awlen),
   .front_axi_0_aw_bits_burst 	(io_front_axi_0_awburst),
   .front_axi_0_aw_bits_cache 	(io_front_axi_0_awcache),
   .front_axi_0_aw_bits_lock 	(io_front_axi_0_awlock),
   .front_axi_0_aw_bits_prot 	(io_front_axi_0_awprot),
   .front_axi_0_aw_bits_qos 	(io_front_axi_0_awqos),
   .front_axi_0_w_valid 		(io_front_axi_0_wvalid),
   .front_axi_0_w_ready 		(io_front_axi_0_wready),
   .front_axi_0_w_bits_strb 	(io_front_axi_0_wstrb),
   .front_axi_0_w_bits_data 	(io_front_axi_0_wdata),
   .front_axi_0_w_bits_last 	(io_front_axi_0_wlast),
   .front_axi_0_b_valid 		(io_front_axi_0_bvalid),
   .front_axi_0_b_ready 		(io_front_axi_0_bready),
   .front_axi_0_b_bits_resp 	(io_front_axi_0_bresp),
   .front_axi_0_b_bits_id 		(),
   .front_axi_0_r_valid 		(io_front_axi_0_rvalid),
   .front_axi_0_r_ready 		(io_front_axi_0_rready),
   .front_axi_0_r_bits_resp 	(io_front_axi_0_rresp),
   .front_axi_0_r_bits_id 		(),
   .front_axi_0_r_bits_data 	(io_front_axi_0_rdata),
   .front_axi_0_r_bits_last 	(io_front_axi_0_rlast),
   
   .front_axi_1_ar_valid 		(io_front_axi_1_arvalid),
   .front_axi_1_ar_ready 		(io_front_axi_1_arready),
   .front_axi_1_ar_bits_addr 	(io_front_axi_1_araddr),
   .front_axi_1_ar_bits_id 	(),
   .front_axi_1_ar_bits_size 	(io_front_axi_1_arsize),
   .front_axi_1_ar_bits_len 	(io_front_axi_1_arlen),
   .front_axi_1_ar_bits_burst 	(io_front_axi_1_arburst),
   .front_axi_1_ar_bits_cache 	(io_front_axi_1_arcache),
   .front_axi_1_ar_bits_lock 	(io_front_axi_1_arlock),
   .front_axi_1_ar_bits_prot 	(io_front_axi_1_arprot),
   .front_axi_1_ar_bits_qos 	(io_front_axi_1_arqos),
   .front_axi_1_aw_valid 		(io_front_axi_1_awvalid),
   .front_axi_1_aw_ready 		(io_front_axi_1_awready),
   .front_axi_1_aw_bits_addr 	(io_front_axi_1_awaddr),
   .front_axi_1_aw_bits_id 	(),
   .front_axi_1_aw_bits_size 	(io_front_axi_1_awsize),
   .front_axi_1_aw_bits_len 	(io_front_axi_1_awlen),
   .front_axi_1_aw_bits_burst 	(io_front_axi_1_awburst),
   .front_axi_1_aw_bits_cache 	(io_front_axi_1_awcache),
   .front_axi_1_aw_bits_lock 	(io_front_axi_1_awlock),
   .front_axi_1_aw_bits_prot 	(io_front_axi_1_awprot),
   .front_axi_1_aw_bits_qos 	(io_front_axi_1_awqos),
   .front_axi_1_w_valid 		(io_front_axi_1_wvalid),
   .front_axi_1_w_ready 		(io_front_axi_1_wready),
   .front_axi_1_w_bits_strb 	(io_front_axi_1_wstrb),
   .front_axi_1_w_bits_data 	(io_front_axi_1_wdata),
   .front_axi_1_w_bits_last 	(io_front_axi_1_wlast),
   .front_axi_1_b_valid 		(io_front_axi_1_bvalid),
   .front_axi_1_b_ready 		(io_front_axi_1_bready),
   .front_axi_1_b_bits_resp 	(io_front_axi_1_bresp),
   .front_axi_1_b_bits_id 		(),
   .front_axi_1_r_valid 		(io_front_axi_1_rvalid),
   .front_axi_1_r_ready 		(io_front_axi_1_rready),
   .front_axi_1_r_bits_resp 	(io_front_axi_1_rresp),
   .front_axi_1_r_bits_id 		(),
   .front_axi_1_r_bits_data 	(io_front_axi_1_rdata),
   .front_axi_1_r_bits_last 	(io_front_axi_1_rlast),
   
   .io_jtag_TCK                 (jtag_tck),
   .io_jtag_TMS                 (jtag_tms),
   .io_jtag_TDI                 (jtag_tdi),
   .io_jtag_TDO_data            (jtag_tdo_data),
   .io_jtag_TDO_driven          (jtag_tdo_driven),

   .io_gpio_btns    (gpio_btns),
   .io_gpio_sws     (gpio_sws)
  );

endmodule
