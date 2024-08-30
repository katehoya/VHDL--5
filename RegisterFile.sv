`include "opcode.sv"
 module RegisterFile(
    input logic write,
    input logic clk,
    input logic reset,
    input logic [1:0] addr1,
    input logic [1:0] addr2,
    input logic [1:0] addr3,
    output logic [23:0] data1,
    output logic [23:0] data2,
    input logic [23:0] data3
    );
    logic [95:0] register;
    /*
    register[95:71] == register[24*3+: 24] (addr is 2'b11)
    register[71:48] == register[24*2+: 24] (addr is 2'b10)
    register[47:24] == register[24*1+: 24] (addr is 2'b01)
    register[23: 0] == register[24*0+: 24] (addr is 2'b00)
    */
    
    always_ff @(posedge clk) begin
        // Synchronous active low reset
        if (reset)
            register <= 
96'b000000000000000000000000_000100100110011100101000_1000100001000
 00100100001_000000000000000000000000;
        // Synchronous data write
        else if (write)
            register[24*addr3+: 24] <= data3;
    end
    
    // Asynchronous data read
    assign data1 = register[24*addr1+: 24];
    assign data2 = register[24*addr2+: 24];
    
endmodule
