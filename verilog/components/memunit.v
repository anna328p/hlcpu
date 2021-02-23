`include "micron16m16/delay_gen150us.v"
`include "micron16m16/lfsr_count64.v"
`include "micron16m16/lfsr_count255.v"
`include "micron16m16/autorefresh_counter.v"
`include "micron16m16/sdram_control_fsm.v"
`include "micron16m16/sdram_controller.v"

module memunit(
    input  wire        clk,
    input  wire        nrst,
    input  wire [15:0] addr,
    input  wire        enable,
    input  wire        rwn,
    input  wire [15:0] data_in,

    output reg         ready,
    output wire [15:0] data_out,
    output wire        o_data_valid,

    output wire [12:0] o_sdram_addr,
    output wire  [1:0] o_sdram_blkaddr,
    output wire        o_sdram_casn,
    output wire        o_sdram_cke,
    output wire        o_sdram_csn,
    output wire  [1:0] o_sdram_dqm,
    output wire        o_sdram_rasn,
    output wire        o_sdram_wen,
    output wire        o_sdram_clk,
    inout  wire [15:0] io_sdram_dq
);

reg o_nrst,
    adv;

wire
    burststop_req = 0,
    disable_active = 0,
    disable_precharge = 0,
    loadmod_req = 0,
    precharge_req = 0,
    power_down = 0,
    selfrefresh_req = 0,
    disable_autorefresh = 0;


wire
    write_done,
    read_done,
    data_req,
    busy,
    init_done,
    ack;

sdram_controller #(.CPU_ADDR_WIDTH(16)) ram (
    .i_clk(clk),
    .i_rst(o_nrst),
    .i_adv(adv),
    .i_rwn(rwn),
    .i_addr(27'b0 | addr),
    .i_selfrefresh_req(selfrefresh_req),
    .i_loadmod_req(loadmod_req),
    .i_burststop_req(burststop_req),
    .i_disable_active(disable_active),
    .i_disable_precharge(disable_precharge),
    .i_precharge_req(precharge_req),
    .i_data(data_in),
    .i_power_down(power_down),
    .i_disable_autorefresh(disable_autorefresh),

    .o_data(data_out),
    .o_write_done(write_done),
    .o_read_done(read_done),
    .o_data_valid(o_data_valid),
    .o_data_req(data_req),
    .o_busy(busy),
    .o_init_done(init_done),
    .o_ack(ack),

    .o_sdram_addr(o_sdram_addr),
    .o_sdram_blkaddr(o_sdram_blkaddr),
    .o_sdram_casn(o_sdram_casn),
    .o_sdram_cke(o_sdram_cke),
    .o_sdram_csn(o_sdram_csn),
    .o_sdram_dqm(o_sdram_dqm),
    .o_sdram_rasn(o_sdram_rasn),
    .o_sdram_wen(o_sdram_wen),
    .o_sdram_clk(o_sdram_clk),
    .io_sdram_dq(io_sdram_dq)
);

reg [4:0] state;
reg [2:0] counter;

always @(*) if (!nrst) begin
    state = 5'b00000;
    counter = 0;
    adv = 0;
    ready = 0;
end

always @(posedge clk) begin
    casex (state)
        // INIT
        5'b00000: // Reset
            if (counter < 3) begin
                o_nrst <= 1;
                counter = counter + 1;
            end else begin
                counter = 0;
                o_nrst <= 0;
                state <= 5'b00001;
            end
        5'b00001: // wait for init_done
            state <= init_done ? 5'b00010 : 5'b00001;
        5'b00010: begin // wait for enable
            ready <= 1;
            adv <= 0;
            if (enable) begin
                ready <= 0;
                adv <= 1;
                state[4:3] <= 2'b11;
                state[2:1] <= 2'b00;
                state[0] <= rwn;
            end
        end

        // OPERATIONS
        5'b1100x: // busy wait 
            if (!busy) state[3] = 0;

        // WRITE
        5'b10000: begin // begin write
            state <= 5'b10010;
        end
        5'b10010: // write, wait for data_req
            if (data_req) begin
                state <= 5'b10110;
                adv <= 0;
            end
        5'b10100: // wait one cycle
            state <= 5'b10110;
        5'b10110: // wait for write done
            if (write_done) state = 5'b00010;

        // READ
        5'b10001: begin // begin read
            adv <= 1;
            state <= 5'b10101;
        end
        5'b10101: // wait for data_valid
            if (read_done || o_data_valid) begin
                state <= 5'b10111;
                adv <= 0;
            end
        5'b10111: // return to main menu
            if (read_done || !o_data_valid) state <= 5'b00010;

        default: state <= 0;
    endcase
end

endmodule // memunit
