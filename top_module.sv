module top_module (
    input		clk,
    input		rst,
    input logic [7:0]	data_pe0,
    input logic [7:0]	data_pe1,
    input logic [7:0]	data_pe2,
    input logic [7:0]	data_pe3,
    input logic [7:0]	data_pe4,
    input logic [7:0]	data_pe5,
    input logic [7:0]	data_pe6,
    input logic [7:0]	data_pe7,
    input logic [7:0]	data_pe8,
    input logic [7:0]	wt_pe0,
    input logic [7:0]	wt_pe1,
    input logic [7:0]	wt_pe2,
    input logic [7:0]	wt_pe3,
    input logic [7:0]	wt_pe4,
    input logic [7:0]	wt_pe5,
    input logic [7:0]	wt_pe6,
    input logic [7:0]	wt_pe7,
    input logic [7:0]	wt_pe8,
    output logic [15:0]	output_data,
    output logic	fin
);
    // Intermediate wires for accumulation
    logic [15:0]		pe_out0;
    logic [15:0]		pe_out1;
    logic [15:0]		pe_out2;
    logic [15:0]		pe_out3;
    logic [15:0]		pe_out4;
    logic [15:0]		pe_out5;
    logic [15:0]		pe_out6;
    logic [15:0]		pe_out7;
    logic [15:0]		pe_out8;

    // Instantiate processing elements
    pe pe0 (
        .clk(clk),
        .rst(rst),
        .input_data(data_pe0),
        .weight(wt_pe0),
        .accum_in(16'b0),
        .accum_out(pe_out0)
    );

    pe pe1 (
        .clk(clk),
        .rst(rst),
        .input_data(data_pe1),
        .weight(wt_pe1),
        .accum_in(pe_out0),
        .accum_out(pe_out1)
    );

    pe pe2 (
        .clk(clk),
        .rst(rst),
        .input_data(data_pe2),
        .weight(wt_pe2),
        .accum_in(pe_out1),
        .accum_out(pe_out2)
    );

    pe pe3 (
        .clk(clk),
        .rst(rst),
        .input_data(data_pe3),
        .weight(wt_pe3),
        .accum_in(pe_out2),
        .accum_out(pe_out3)
    );

    pe pe4 (
        .clk(clk),
        .rst(rst),
        .input_data(data_pe4),
        .weight(wt_pe4),
        .accum_in(pe_out3),
        .accum_out(pe_out4)
    );

    pe pe5 (
        .clk(clk),
        .rst(rst),
        .input_data(data_pe5),
        .weight(wt_pe5),
        .accum_in(pe_out4),
        .accum_out(pe_out5)
    );

    pe pe6 (
        .clk(clk),
        .rst(rst),
        .input_data(data_pe6),
        .weight(wt_pe6),
        .accum_in(pe_out5),
        .accum_out(pe_out6)
    );

    pe pe7 (
        .clk(clk),
        .rst(rst),
        .input_data(data_pe7),
        .weight(wt_pe7),
        .accum_in(pe_out6),
        .accum_out(pe_out7)
    );

    pe pe8 (
        .clk(clk),
        .rst(rst),
        .input_data(data_pe8),
        .weight(wt_pe8),
        .accum_in(pe_out7),
        .accum_out(pe_out8)
    );

    // Assign final accumulated result to output data
    always_ff @ (posedge clk) begin
       if (rst) begin
	  output_data <= 0;
	  fin <= 0;
       end
       else begin
	     output_data <= pe_out8;
	     fin <= 1'b1;
       end
    end
   
   
endmodule
