`include "opcode.sv"
 `define WORD_SIZE 16    // data and address word size
 `define DATA_SIZE 24
 module AlwaysNTPredictor (
  /* verilator lint_off UNUSED */
    input logic [`DATA_SIZE-1:0]  PC,
    input logic  Correct,
    input logic [`WORD_SIZE-1:0]  ActualBranchTarget,
    output logic [`DATA_SIZE-1:0] Prediction
  /* verilator lint_on UNUSED */
    );
    /*
    [Always not-taken branch predictor module]
    Purpose:
        A placeholder(or framework) for future possibility of implementing a better 
branch predictor.
        Always predicts PC+1 for any jump or branch instruction.
    */
    
    assign Prediction = PC + 1;
    
endmodule // AlwaysNTPredictor
