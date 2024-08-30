module conv(
	    /* verilator lint_off UNUSED */
	    input		clk, rst,
	    input [23:0]	data,
	    input [23:0]	wt,
	    input		send,
	    output logic [15:0]	output_data,
	    output logic	fin
	    /* verilator lint_on UNUSED */
	    );
/* verilator lint_off UNUSED */
   logic [7:0]	data_pe0;
   logic [7:0]	data_pe1;
   logic [7:0]	data_pe2;
   logic [7:0]	data_pe3;
   logic [7:0]	data_pe4;
   logic [7:0]	data_pe5;
   logic [7:0]	data_pe6;
   logic [7:0]	data_pe7;
   logic [7:0]	data_pe8;
   logic [7:0]	wt_pe0;
   logic [7:0]	wt_pe1;
   logic [7:0]	wt_pe2;
   logic [7:0]	wt_pe3;
   logic [7:0]	wt_pe4;
   logic [7:0]	wt_pe5;
   logic [7:0]	wt_pe6;
   logic [7:0]	wt_pe7;
   logic [7:0]	wt_pe8;
   /* verilator lint_on UNUSED */
   con_input in_buf (
		     // Outputs
		     .data_pe0		(data_pe0[7:0]),
		     .data_pe1		(data_pe1[7:0]),
		     .data_pe2		(data_pe2[7:0]),
		     .data_pe3		(data_pe3[7:0]),
		     .data_pe4		(data_pe4[7:0]),
		     .data_pe5		(data_pe5[7:0]),
		     .data_pe6		(data_pe6[7:0]),
		     .data_pe7		(data_pe7[7:0]),
		     .data_pe8		(data_pe8[7:0]),
		     .wt_pe0		(wt_pe0[7:0]),
		     .wt_pe1		(wt_pe1[7:0]),
		     .wt_pe2		(wt_pe2[7:0]),
		     .wt_pe3		(wt_pe3[7:0]),
		     .wt_pe4		(wt_pe4[7:0]),
		     .wt_pe5		(wt_pe5[7:0]),
		     .wt_pe6		(wt_pe6[7:0]),
		     .wt_pe7		(wt_pe7[7:0]),
		     .wt_pe8		(wt_pe8[7:0]),
		     // Inputs
		     .clk		(clk),
		     .rst		(rst),
		     .data		(data[23:0]),
		     .wt		(wt[23:0]),
		     .send		(send));

   top_module con (
		   // Outputs
		   .output_data		(output_data[15:0]),
		   .fin                 (fin),
		   // Inputs
		   .clk			(clk),
		   .rst			(rst),
		   .data_pe0		(data_pe0[7:0]),
		   .data_pe1		(data_pe1[7:0]),
		   .data_pe2		(data_pe2[7:0]),
		   .data_pe3		(data_pe3[7:0]),
		   .data_pe4		(data_pe4[7:0]),
		   .data_pe5		(data_pe5[7:0]),
		   .data_pe6		(data_pe6[7:0]),
		   .data_pe7		(data_pe7[7:0]),
		   .data_pe8		(data_pe8[7:0]),
		   .wt_pe0		(wt_pe0[7:0]),
		   .wt_pe1		(wt_pe1[7:0]),
		   .wt_pe2		(wt_pe2[7:0]),
		   .wt_pe3		(wt_pe3[7:0]),
		   .wt_pe4		(wt_pe4[7:0]),
		   .wt_pe5		(wt_pe5[7:0]),
		   .wt_pe6		(wt_pe6[7:0]),
		   .wt_pe7		(wt_pe7[7:0]),
		   .wt_pe8		(wt_pe8[7:0]));
endmodule // conv
