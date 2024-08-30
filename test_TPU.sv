`include"MAC.sv"
`include"MMU.sv"
`timescale 1ns / 1ps

// Sample testbench for a 3X3 Systolic Array

module test_TPU;

    // Inputs
    logic clk;
    logic control;
    logic [23:0] data_arr;
    logic [23:0] wt_arr;
   logic	 reset;
    // Outputs
    logic [71:0] acc_out;

    // Instantiate the Unit Under Test (UUT)
    MMU uut (
        .clk(clk),
        .control(control),
        .reset(reset),
        .data_arr(data_arr),
        .wt_arr(wt_arr),
        .acc_out(acc_out)
    );

    // Clock generation
    always
        #5 clk = ~clk;
            // VCD Dump
    initial begin
        $dumpfile("test_TPU.vcd");
        $dumpvars(0, test_TPU);

        clk = 0;
        control = 0;
        data_arr = 0;
        wt_arr = 0;
       reset=1;

       #10 reset=0;
       #100
        control = 1;
        wt_arr = 32'h020304;
       
        data_arr = 32'h000001;
        
       #100
        wt_arr = 32'h010203;
        data_arr = 32'h000102;

        
       #100
        wt_arr = 32'h040102;
               data_arr = 32'h010200;


       #100         data_arr = 32'h010200;

       #100
        wt_arr = 32'h020403;
               data_arr = 32'h030200;

        
       #100
        control = 0;
                
              

       #100
	 $finish();
    end // initial begin
endmodule // test_TPU
