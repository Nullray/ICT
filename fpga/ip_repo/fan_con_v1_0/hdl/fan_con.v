`timescale 1ns / 1ps
module fan_con
(
    input  wire          reset,
    input  wire          clk_100m,
    input  wire          fg,   //风扇转速
    output reg           pwm = 0,  //输出频率为25kHz
    
    input  wire [7:0]    s_axi_lite_awaddr,
    input  wire          s_axi_lite_awvalid,
    output reg           s_axi_lite_awready = 0,
    input  wire [63:0]   s_axi_lite_wdata,
    input  wire [7:0]    s_axi_lite_wstrb,
    input  wire          s_axi_lite_wvalid,
    output reg           s_axi_lite_wready = 0,
    output wire [1:0]    s_axi_lite_bresp,
    output reg           s_axi_lite_bvalid = 0,
    input  wire          s_axi_lite_bready,
    
    input  wire [7:0]    s_axi_lite_araddr,
    input  wire          s_axi_lite_arvalid,
    output reg           s_axi_lite_arready = 0,
    output reg  [63:0]   s_axi_lite_rdata = 0,
    output wire [1:0]    s_axi_lite_rresp,
    output reg           s_axi_lite_rvalid = 0,
    input  wire          s_axi_lite_rready
);



reg [6:0] pwm_duty_reg = 0;  //用于axi_lite设置占空比的寄存器
reg [14:0] fg_reg = 0;   //用于axi_lite读取转速


reg [5:0] cnt = 0;   //用于产生一个2500kHZ的一个虚拟时钟
reg [6:0] pwm_num = 0;  //用于控制占空比

always @(posedge clk_100m)
begin
    if(reset == 1)
    begin
        cnt <= 0;
        pwm_num <= 0;
    end
    else
    begin
        if(cnt >= 39)
        begin
            cnt <= 0;
            if(pwm_num >= 99)
            begin
                pwm_num <= 0;
            end
            else
            begin
                pwm_num <= pwm_num + 1;
            end
        end
        else
        begin
            cnt <= cnt + 1;
        end
    end
    
    
    if(reset == 1)
    begin
        pwm <= 0;
    end
    else
    begin
        if(pwm_num < pwm_duty_reg)
        begin
             pwm <= 1;
        end
        else
        begin
             pwm <= 0;
        end
    end
end




reg  [25:0]     cnt_fg=0;
reg  [14:0]     num_fg=0;
reg             fg_pre=0;

always @(posedge clk_100m)
begin
    if(reset == 1)
    begin
        cnt_fg <= 0;
    end
    else
    begin
        if(cnt_fg < 50000000)  //计时半分钟
        begin
            cnt_fg <= cnt_fg+1;
        end
        else
        begin
            cnt_fg <= 0;
        end
    end
    


    fg_pre         <= fg;
    
    if(reset == 1)
    begin
        fg_reg               <= 0;
        num_fg               <= 0;
    end
    else
    begin
        if(cnt_fg < 50000000)
        begin
            if((fg_pre == 0) & (fg == 1))
            begin
                num_fg   <= num_fg +1;
            end
        end
        else
        begin
            fg_reg     <= num_fg;
            num_fg     <= 0;
        end
    end
end







assign s_axi_lite_bresp = 2'b0;
assign s_axi_lite_rresp = 2'b0;

reg          aw_valid;
reg          ar_valid;
reg          w_valid;
reg  [7:0]   aw;
reg  [7:0]   ar;
reg  [63:0]  w;
reg  [7:0]   strb;


always @(posedge clk_100m)
begin
    if(reset == 1)
    begin
        s_axi_lite_awready   <= 0;
        s_axi_lite_wready    <= 0;
        s_axi_lite_bvalid    <= 0;
        s_axi_lite_arready   <= 0;
        s_axi_lite_rvalid    <= 0;
        aw_valid             <= 0;
        w_valid              <= 0;
        ar_valid             <= 0;
        pwm_duty_reg         <= 0;
        s_axi_lite_rdata     <= 0;
    end
    else
    begin
        //写事务
        if(s_axi_lite_awvalid & s_axi_lite_awready)
        begin
            aw                   <= s_axi_lite_awaddr;
            s_axi_lite_awready   <= 0;
            aw_valid             <= 1;
        end
        else
        begin
            s_axi_lite_awready  <= ~aw_valid;
        end
    
    
        if(s_axi_lite_wvalid & s_axi_lite_wready)
        begin
            w                    <= s_axi_lite_wdata;
            strb                 <= s_axi_lite_wstrb;
            s_axi_lite_wready    <= 0;
            w_valid              <= 1;
        end
        else
        begin
            s_axi_lite_wready    <= ~w_valid;
        end
       
    
        if(aw_valid & w_valid)
        begin
            aw_valid           <= 0;
            w_valid            <= 0;
            s_axi_lite_bvalid  <= 1;
            if(aw == 0)    //写pwm_duty_reg寄存器，只看低7位
            begin
                pwm_duty_reg       <= ({7 {~strb[0]}} & pwm_duty_reg) | ({7 {strb[0]}} & w[6:0]);
            end
            else   //其他地址自动忽略
            begin
            end
        end
    
        if(s_axi_lite_bvalid & s_axi_lite_bready)
        begin
            s_axi_lite_bvalid      <= 0;
        end
    
        //读事务
        if(s_axi_lite_arvalid & s_axi_lite_arready)
        begin
            ar                    <= s_axi_lite_araddr;
            s_axi_lite_arready    <= 0;
            ar_valid              <= 1;
        end
        else
        begin
            s_axi_lite_arready    <= ~ar_valid;
        end
        
        if(ar_valid)
        begin
            ar_valid                 <= 0;
            s_axi_lite_rvalid        <= 1;
            if(ar == 0)
            begin
                s_axi_lite_rdata     <= {57'b0,pwm_duty_reg};
            end
            else if(ar == 8)
            begin
                s_axi_lite_rdata     <= {48'b0,fg_reg,1'b0};  //因为计数时间为半分钟，所以要乘以2
            end
            else
            begin
                s_axi_lite_rdata     <= 0;
            end
        end
        else if(s_axi_lite_rvalid & s_axi_lite_rready)
        begin
            s_axi_lite_rvalid  <= 0;
        end
        
    end
end

endmodule

