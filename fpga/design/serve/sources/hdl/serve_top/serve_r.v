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
	DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    jtag_tms,
    jtag_tck,
    jtag_tdo,
    jtag_tdi,
    btn,
    sw
	);

  inout [14:0] DDR_addr;
  inout [2:0] DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0] DDR_dm;
  inout [31:0] DDR_dq;
  inout [3:0] DDR_dqs_n;
  inout [3:0] DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;

  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  
  input jtag_tms;
  input jtag_tck;
  output jtag_tdo;
  input jtag_tdi;

  input [3:0] btn;
  input [1:0] sw;
  
  wire IRQ_P2F_ENET0;
  wire IRQ_P2F_SDIO0;
  wire IRQ_P2F_UART0;
  wire IRQ_P2F_USB0;

  wire FCLK_RESET0_N;
  wire clk;
  wire reset;
  
  wire [31:0]io_front_axi_araddr;
  wire [1:0]io_front_axi_arburst;
  wire [3:0]io_front_axi_arcache;
  wire [7:0]io_front_axi_arlen;
  wire [0:0]io_front_axi_arlock;
  wire [2:0]io_front_axi_arprot;
  wire [3:0]io_front_axi_arqos;
  wire io_front_axi_arready;
  wire [3:0]io_front_axi_arregion;
  wire [2:0]io_front_axi_arsize;
  wire io_front_axi_arvalid;
  wire [31:0]io_front_axi_awaddr;
  wire [1:0]io_front_axi_awburst;
  wire [3:0]io_front_axi_awcache;
  wire [7:0]io_front_axi_awlen;
  wire [0:0]io_front_axi_awlock;
  wire [2:0]io_front_axi_awprot;
  wire [3:0]io_front_axi_awqos;
  wire io_front_axi_awready;
  wire [3:0]io_front_axi_awregion;
  wire [2:0]io_front_axi_awsize;
  wire io_front_axi_awvalid;
  wire io_front_axi_bready;
  wire [1:0]io_front_axi_bresp;
  wire io_front_axi_bvalid;
  wire [63:0]io_front_axi_rdata;
  wire io_front_axi_rlast;
  wire io_front_axi_rready;
  wire [1:0]io_front_axi_rresp;
  wire io_front_axi_rvalid;
  wire [63:0]io_front_axi_wdata;
  wire io_front_axi_wlast;
  wire io_front_axi_wready;
  wire [7:0]io_front_axi_wstrb;
  wire io_front_axi_wvalid;

  wire        mem_axi_0_awready;
  wire        mem_axi_0_awvalid;
  wire [3:0]  mem_axi_0_awid;
  wire [28:0] mem_axi_0_awaddr;
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
  wire [28:0] mem_axi_0_araddr;
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

  wire [31:0]mmio_axi_0_araddr;
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
  wire [31:0]mmio_axi_0_awaddr;
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

  wire [31:0]mmio_axi_1_araddr;
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
  wire [31:0]mmio_axi_1_awaddr;
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

  serve_r_system system_i
       (.DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),

		.FCLK_CLK0(clk),
        .FCLK_RESET0_N(FCLK_RESET0_N),
    .soc_reset(soc_reset),

        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),

		.IRQ_P2F_ENET0(IRQ_P2F_ENET0),
		.IRQ_P2F_SDIO0(IRQ_P2F_SDIO0),
		.IRQ_P2F_UART0(IRQ_P2F_UART0),
		.IRQ_P2F_USB0(IRQ_P2F_USB0),

		.io_front_axi_araddr	(io_front_axi_araddr),
        .io_front_axi_arburst	(io_front_axi_arburst),
        .io_front_axi_arcache	(io_front_axi_arcache),
        .io_front_axi_arlen		(io_front_axi_arlen),
        .io_front_axi_arlock	(io_front_axi_arlock),
        .io_front_axi_arprot	(io_front_axi_arprot),
        .io_front_axi_arqos		(io_front_axi_arqos),
        .io_front_axi_arready	(io_front_axi_arready),
        .io_front_axi_arsize	(io_front_axi_arsize),
        .io_front_axi_arvalid	(io_front_axi_arvalid),
		.io_front_axi_arregion	(),
        .io_front_axi_awaddr		(io_front_axi_awaddr),
        .io_front_axi_awburst	(io_front_axi_awburst),
        .io_front_axi_awcache	(io_front_axi_awcache),
        .io_front_axi_awlen		(io_front_axi_awlen),
        .io_front_axi_awlock		(io_front_axi_awlock),
        .io_front_axi_awprot		(io_front_axi_awprot),
        .io_front_axi_awqos		(io_front_axi_awqos),
        .io_front_axi_awready	(io_front_axi_awready),
        .io_front_axi_awsize		(io_front_axi_awsize),
        .io_front_axi_awvalid	(io_front_axi_awvalid),
		.io_front_axi_awregion	(),
        .io_front_axi_bready		(io_front_axi_bready),
        .io_front_axi_bresp		(io_front_axi_bresp),
        .io_front_axi_bvalid		(io_front_axi_bvalid),
        .io_front_axi_rdata		(io_front_axi_rdata),
        .io_front_axi_rlast		(io_front_axi_rlast),
        .io_front_axi_rready		(io_front_axi_rready),
        .io_front_axi_rresp		(io_front_axi_rresp),
        .io_front_axi_rvalid		(io_front_axi_rvalid),
        .io_front_axi_wdata		(io_front_axi_wdata),
        .io_front_axi_wlast		(io_front_axi_wlast),
        .io_front_axi_wready		(io_front_axi_wready),
        .io_front_axi_wstrb		(io_front_axi_wstrb),
        .io_front_axi_wvalid		(io_front_axi_wvalid),

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
        .mmio_axi_1_wvalid(mmio_axi_1_wvalid)
  );

  assign reset = !FCLK_RESET0_N ;
  
  wire jtag_tdo_data, jtag_tdo_driven;
  assign jtag_tdo = jtag_tdo_driven ? jtag_tdo_data : 1'bz;

  SERVETop top(
   .clock(clk),
   .reset(soc_reset),
   .io_mac_int(IRQ_P2F_ENET0 ),
   .io_sdio_int(IRQ_P2F_SDIO0),
   .io_uart_int(IRQ_P2F_UART0),

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

   .front_axi_0_ar_valid 		(io_front_axi_arvalid),
   .front_axi_0_ar_ready 		(io_front_axi_arready),
   .front_axi_0_ar_bits_addr 	(io_front_axi_araddr),
   .front_axi_0_ar_bits_id 	(),
   .front_axi_0_ar_bits_size 	(io_front_axi_arsize),
   .front_axi_0_ar_bits_len 	(io_front_axi_arlen),
   .front_axi_0_ar_bits_burst 	(io_front_axi_arburst),
   .front_axi_0_ar_bits_cache 	(io_front_axi_arcache),
   .front_axi_0_ar_bits_lock 	(io_front_axi_arlock),
   .front_axi_0_ar_bits_prot 	(io_front_axi_arprot),
   .front_axi_0_ar_bits_qos 	(io_front_axi_arqos),
   .front_axi_0_aw_valid 		(io_front_axi_awvalid),
   .front_axi_0_aw_ready 		(io_front_axi_awready),
   .front_axi_0_aw_bits_addr 	(io_front_axi_awaddr),
   .front_axi_0_aw_bits_id 	(),
   .front_axi_0_aw_bits_size 	(io_front_axi_awsize),
   .front_axi_0_aw_bits_len 	(io_front_axi_awlen),
   .front_axi_0_aw_bits_burst 	(io_front_axi_awburst),
   .front_axi_0_aw_bits_cache 	(io_front_axi_awcache),
   .front_axi_0_aw_bits_lock 	(io_front_axi_awlock),
   .front_axi_0_aw_bits_prot 	(io_front_axi_awprot),
   .front_axi_0_aw_bits_qos 	(io_front_axi_awqos),
   .front_axi_0_w_valid 		(io_front_axi_wvalid),
   .front_axi_0_w_ready 		(io_front_axi_wready),
   .front_axi_0_w_bits_strb 	(io_front_axi_wstrb),
   .front_axi_0_w_bits_data 	(io_front_axi_wdata),
   .front_axi_0_w_bits_last 	(io_front_axi_wlast),
   .front_axi_0_b_valid 		(io_front_axi_bvalid),
   .front_axi_0_b_ready 		(io_front_axi_bready),
   .front_axi_0_b_bits_resp 	(io_front_axi_bresp),
   .front_axi_0_b_bits_id 		(),
   .front_axi_0_r_valid 		(io_front_axi_rvalid),
   .front_axi_0_r_ready 		(io_front_axi_rready),
   .front_axi_0_r_bits_resp 	(io_front_axi_rresp),
   .front_axi_0_r_bits_id 		(),
   .front_axi_0_r_bits_data 	(io_front_axi_rdata),
   .front_axi_0_r_bits_last 	(io_front_axi_rlast),
   
   .io_jtag_TCK                 (jtag_tck),
   .io_jtag_TMS                 (jtag_tms),
   .io_jtag_TDI                 (jtag_tdi),
   .io_jtag_TDO_data            (jtag_tdo_data),
   .io_jtag_TDO_driven          (jtag_tdo_driven),

   .io_gpio_btns    (gpio_btns),
   .io_gpio_sws     (gpio_sws)
  );

endmodule
