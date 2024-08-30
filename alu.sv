 `include "opcode.sv"
 module alu(
    input logic signed [23:0] A,
    input logic signed [23:0] B,
    input logic [3:0] OP,
    output logic signed [23:0] C,
    output logic branch_cond
 );
 always_comb begin
    case (OP)
        4'd0: C = A + B; // ADD, ADI, LWD, SWD
        4'd1: C = A - B; // SUB
        4'd2: C = A & B; // AND
        4'd3: C = A | B; // ORR, ORI
        4'd4: C = ~A; // NOT
        4'd5: C = ~A + 1'b1; // TCP
        4'd6: C = A << 1; // SHL
        4'd7: C = A >>> 1; // SHR
        4'd8: C = {B[11:0], 12'b0}; // LHI
        4'd9: C = A - B; // BNE
        4'd10: C = A - B; // BEQ
        4'd11: C = A; // BGZ
        4'd12: C = A; // BLZ
        default: C = 24'b0;
    endcase
 end // always_comb
   
   // Using assign, C and branch_cond change at the same time.
   // The timing would have been different if they were inside a single always block.
   assign branch_cond = (OP == 4'd9) ? (C != 0) : //BNE
 (OP == 4'd10) ? (C == 0) : //BEQ
 (OP == 4'd11) ? (C > 0) : //BGZ
 (OP == 4'd12) ? (C < 0) : 0; //BLZ
 endmodule // ALU
