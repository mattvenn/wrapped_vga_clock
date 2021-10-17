`default_nettype none
`ifdef FORMAL
    `define MPRJ_IO_PADS 38    
`endif
//`define USE_WB  0
`define USE_LA  1
`define USE_IO  1
//`define USE_MEM 0
//`define USE_IRQ 0

// update this to the name of your module
module wrapped_vga_clock(
`ifdef USE_POWER_PINS
    inout vccd1,
    inout vssd1,
`endif
    // interface as user_proj_example.v
    input wire wb_clk_i,
`ifdef USE_WB
    input wire wb_rst_i,
    input wire wbs_stb_i,
    input wire wbs_cyc_i,
    input wire wbs_we_i,
    input wire [3:0] wbs_sel_i,
    input wire [31:0] wbs_dat_i,
    input wire [31:0] wbs_adr_i,
    output wire wbs_ack_o,
    output wire [31:0] wbs_dat_o,
`endif

    // Logic Analyzer Signals
    // only provide first 32 bits to reduce wiring congestion
`ifdef USE_LA
    input  wire [31:0] la1_data_in,
    output wire [31:0] la1_data_out,
    input  wire [31:0] la1_oenb,
`endif

    // IOs
`ifdef USE_IO
    input  wire [`MPRJ_IO_PADS-1:0] io_in,
    output wire [`MPRJ_IO_PADS-1:0] io_out,
    output wire [`MPRJ_IO_PADS-1:0] io_oeb,
`endif

    // IRQ
`ifdef USE_IRQ
    output wire [2:0] irq,
`endif

`ifdef USE_CLK2
    // extra user clock
    input wire user_clock2,
`endif
    
    // active input, only connect tristated outputs if this is high
    input wire active
);

    // all outputs must be tristated before being passed onto the project
    wire buf_wbs_ack_o;
    wire [31:0] buf_wbs_dat_o;
    wire [31:0] buf_la1_data_out;
    wire [`MPRJ_IO_PADS-1:0] buf_io_out;
    wire [`MPRJ_IO_PADS-1:0] buf_io_oeb;
    wire [2:0] buf_irq;

    `ifdef FORMAL
    // formal can't deal with z, so set all outputs to 0 if not active
    assign wbs_ack_o    = active ? buf_wbs_ack_o    : 1'b0;
    assign wbs_dat_o    = active ? buf_wbs_dat_o    : 32'b0;
    assign la1_data_out = active ? buf_la1_data_out  : 32'b0;
    assign io_out       = active ? buf_io_out       : {`MPRJ_IO_PADS{1'b0}};
    assign io_oeb       = active ? buf_io_oeb       : {`MPRJ_IO_PADS{1'b0}};
    assign irq          = active ? buf_irq          : 3'b0;
    `include "properties.v"
    `else
    // tristate buffers
    
    `ifdef USE_WB
    assign wbs_ack_o    = active ? buf_wbs_ack_o    : 1'bz;
    assign wbs_dat_o    = active ? buf_wbs_dat_o    : 32'bz;
    `endif
    `ifdef USE_LA
    assign la1_data_out  = active ? buf_la1_data_out  : 32'bz;
    `endif
    `ifdef USE_IO
    assign io_out       = active ? buf_io_out       : {`MPRJ_IO_PADS{1'bz}};
    assign io_oeb       = active ? buf_io_oeb       : {`MPRJ_IO_PADS{1'bz}};
    `endif
    `ifdef USE_IRQ
    assign irq          = active ? buf_irq          : 3'bz;
    `endif
    `endif

    // permanently set oeb so that outputs are always enabled: 0 is output, 1 is high-impedance
    assign buf_io_oeb = {`MPRJ_IO_PADS{1'b0}};

    // the vga_clock for MPW1 was instantiated like this
    // vga_clock             proj_2 (.clk(proj2_clk), .reset_n(proj2_reset), .adj_hrs(proj2_io_in[8]), .adj_min(proj2_io_in[9]), .adj_sec(proj2_io_in[10]), .hsync(proj2_io_out[11]), .vsync(proj2_io_out[12]), .rrggbb(proj2_io_out[18:13]));

    vga_clock vga_clock(
        .clk(wb_clk_i),
        .reset_n(la1_data_in[0]),
        .adj_hrs(io_in[8]),
        .adj_min(io_in[9]),
        .adj_sec(io_in[10]),
        .hsync(buf_io_out[11]),
        .vsync(buf_io_out[12]),
        .rrggbb(buf_io_out[18:13])
        );

endmodule 
`default_nettype wire
