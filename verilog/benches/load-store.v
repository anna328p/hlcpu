`timescale 1ns / 1ps

`include "components/memunit.v"
`include "components/regfile.v"
`include "rd1174/testbench/verilog/micron16m16/mt48lc16m16a2.v"

module load_store_bench;

// clock
reg clk;
always begin
    #3.75 clk = 1'b0;
    #3.75 clk = 1'b1;
end

// memory
wire [12:0] Addr;
wire [15:0] Dq;
wire  [1:0] Ba, Dqm;
wire        Clk, Cke, Cs_n, Ras_n, Cas_n, We_n;

reg         m_nrst, m_enable, m_rwn;
reg  [15:0] m_addr;
wire        m_ready, m_data_valid;
wire [15:0] m_idata, m_odata;

mt48lc16m16a2 ram0 (Dq, Addr, Ba, Clk, Cke, 
    Cs_n, Ras_n, Cas_n, We_n, Dqm);

memunit mem (clk, m_nrst,
    m_addr, m_enable, m_rwn, m_idata,

    m_ready, m_odata, m_data_valid,

    Addr, Ba, Cas_n, Cke, Cs_n, Dqm, Ras_n, We_n, Clk, Dq); 

// registers
reg   [3:0]  ri1_sel,  ri2_sel;
wire [15:0]  ri1_data;
reg  [15:0]  ri2_data;

reg          ri1_we,   ri2_we;
reg   [3:0]  ro1_sel,  ro2_sel;
wire [15:0]  ro1_data, ro2_data;

regfile regfile0 (clk,
    ri1_we, ri1_sel, ri1_data,  
    ri2_we, ri2_sel, ri2_data,
            ro1_sel, ro1_data,
            ro2_sel, ro2_data);

assign m_idata = ro1_data;
assign ri1_data = m_odata;

initial begin
    #1;
    m_nrst <= 0;
    m_addr <= 16'hDEAD;
    m_rwn <= 0;

    ri1_we <= 0;

    ri2_we <= 1;
    ri2_sel <= 1;
    ri2_data <= 42;

    ro1_sel <= 1;

    #15;

    ri2_we <= 0;

    #15;

    m_nrst <= 1;
    @(posedge m_ready) #15;

    $display("memunit ready");

    m_enable <= 1;
    @(negedge m_ready);
    $display("begin write");
    m_enable <= 0;

    @(posedge m_ready);
    $display("write complete");

    m_rwn <= 1;

    m_enable <= 1;
    @(negedge m_ready);
    $display("begin read");
    m_enable <= 0;
    ri1_sel <= 2;
    ri1_we <= 1;



    @(posedge m_ready);
    $stop;
end

always @(posedge clk)
    if (m_data_valid) begin
    	ri1_we <= 0;

		ro2_sel <= 2;
        #7;
        $display("read back: %d", ro2_data);
		


        #10000;
        $stop;
    end

endmodule // load_store_bench;
