`timescale 10ns / 1ns

module get_trace();

    reg       sys_clk;
    reg       sys_reset_n;
    
    initial begin
	    sys_clk = 1'b0;
	    sys_reset_n = 1'b0;
	    # 100
	    sys_reset_n = 1'b1;
    end
    
    always begin
	    # 5 sys_clk = ~sys_clk;
    end

    // Open trace file;
    integer trace_file;
    initial begin
        trace_file = $fopen(`TRACE_FILE, "w");
    end

	cpu_test_top_golden    u_cpu_test_golden (
		.sys_clk	    (sys_clk),
		.sys_reset_n	(sys_reset_n)
	);

	`define MEM_WEN		u_cpu_test_golden.u_cpu.MemWrite
	`define MEM_ADDR	u_cpu_test_golden.u_cpu.Address
	`define MEM_WDATA	u_cpu_test_golden.u_cpu.Write_data

    wire [31:0] pc_rt       = u_cpu_test_golden.u_cpu.inst_retire[31:0 ];
    wire [31:0] rf_wdata_rt = u_cpu_test_golden.u_cpu.inst_retire[63:32];
    wire [4 :0] rf_waddr_rt = u_cpu_test_golden.u_cpu.inst_retire[68:64];
    wire        rf_en_rt    = u_cpu_test_golden.u_cpu.inst_retire[69];

    wire [31:0] wdata_mask;
    wire [31:0] wdata;
    genvar i;
    generate for (i = 0; i < 32; i = i + 1) begin
        assign wdata[i] = rf_wdata_rt[i] === 1'bx ? 1'b0 : rf_wdata_rt[i];
        assign wdata_mask[i] = rf_wdata_rt[i] === 1'bx ? 1'b0 : 1'b1;
    end
        
    endgenerate 
    // Generate golden record
    always @(posedge sys_clk)
    begin
        if(rf_en_rt && rf_waddr_rt != 5'd0)
        begin
                $fdisplay(trace_file, "1 %h %2d %h %h 0", pc_rt, rf_waddr_rt, wdata, wdata_mask);
        end
    end

    // End
    always @(posedge sys_clk)
    begin
        if ((`MEM_WEN == 1'b1) & (`MEM_ADDR == 32'h0C) & (`MEM_WDATA == 32'h0))
        begin
            $display("=================================================");
            $display("Trace generate successfully!!!");
            $display("=================================================");
	        $fclose(trace_file);
            $finish;
        end
    end

    reg [4095:0] dumpfile;
	initial begin
		if ($value$plusargs("DUMP=%s", dumpfile)) begin
			$dumpfile(dumpfile);
			$dumpvars();
		end
	end

endmodule
