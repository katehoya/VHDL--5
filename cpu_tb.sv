`timescale 1ns / 1ns

`include "RegisterFile.sv"
`include "alu.sv"
`include "HazardDetector.sv"
`include "AlwaysNTPredictor.sv"
`include "control.sv"
`include "cpu.sv"
`include "memory.sv"
`include "MAC.sv"
`include "MMU.sv"
`include "adder.sv"
`include "con_input.sv"
`include "multiplier.sv"
`include "pe.sv"
`include "top_module.sv"
`include "conv.sv"
/*`include "cpu_synth.v"
`include "/home/vlsiadmin/TannerEDA/TannerTools_v2021.2/Process/Generic_250nm/Generic_250nm_LogicGates/stdcells.v"*/

module cpu_tb;
    logic clk;
    logic reset;

    // Instruction memory interface
    logic i_readM;
    logic i_writeM;
    logic [`WORD_SIZE-1:0] i_address;
    tri [`WORD_SIZE-1:0] i_data;

    // Data memory interface
    logic d_readM;
    logic d_writeM;
    logic [`WORD_SIZE-1:0] d_address;
    tri [`WORD_SIZE-1:0] d_data;

    // Outputs
    logic [`WORD_SIZE-1:0] num_inst;
    logic [`WORD_SIZE-1:0] output_port;
    logic is_halted;

    // Internal signals for tri-state buffers
    logic [`WORD_SIZE-1:0] i_data_out;
    logic i_data_en;
    logic [`WORD_SIZE-1:0] d_data_out;
    logic d_data_en;

    cpu uut (
        .clk(clk),
        .reset(reset),
        .i_readM(i_readM),
        .i_writeM(i_writeM),
        .i_address(i_address),
        .i_data(i_data),
        .d_readM(d_readM),
        .d_writeM(d_writeM),
        .d_address(d_address),
        .d_data(d_data),
        .num_inst(num_inst),
        .output_port(output_port),
        .is_halted(is_halted)
    );

   always #5 clk = ~clk;

   // Tri-state 버퍼 제어 (instruction memory)
    assign i_data = i_data_en ? i_data_out : 'b0;

    // Tri-state 버퍼 제어 (data memory)
  //  assign d_data = d_data_en ? d_data_out : 'b0;

   
   initial begin
      //$sdf_annotate("cpu.sdf", uut, , , "maximum");
      clk = 1;
      reset = 1;
      d_data_out = 0;
   //   d_data_en = 0;
      i_data_en = 0;
      i_data_out = 0;
      //i_data_out = 16'b1000_00_01_00_000010;;//initialization:store words=> sw $1, 2($0)
      i_address = 0;
      
      #10 reset = 0;

	i_data_en=1;
	/*i_data_out = 16'b1000_00_01_00_000001;//store words=> sw $1, 2($0)
     // #10
	//i_data_out = 16'b1000_00_10_00_000100;//store words=> sw $2, 4($0)
      #20
	i_data_out = 16'b0111_00_11_00_000001;
      #20
	i_data_out = 16'b1111_11_01_10_000000;
      #20
	i_data_out = 16'b1000_00_10_00_001000;*/
      i_data_out = 16'b1101_01_10_00_000000;
      #200
	i_data_out = 16'b0111_11_00_00_000000;
      #100
	i_data_out = 16'b1111_10_01_11_000000;
      #100
	i_data_out = 16'b1000_11_11_00_000010;
      #100
	i_data_out = 16'b1101_11_10_00_000000;
      
      #200 i_data_en = 0;

      #200;
      // Halt 신호 확인
      if (is_halted) begin
         $display("CPU halted successfully.");
      end else begin
         $display("CPU did not halt as expected.");
      end

      // 실행된 명령어 수 출력
      $display("Number of instructions executed: %d", num_inst);

      // 출력 포트 값 출력
      $display("Output port value: %h", output_port);

      $finish;
   end
endmodule // cpu_tb
