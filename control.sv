`include "opcode.sv"
module control(
    input logic [3:0] opcode,
    input logic [5:0] func,
    input logic BranchMisprediction, JumpMisprediction, Stall,
    output logic IsBranch, IsJump, JumpType, DataMemRead, DataMemWrite, RegWrite, PCWrite, IFIDWrite, IFFlush, IDEXWrite, ALUSrcA, RegSrc, Halt, OpenPort,
    output logic [1:0] RegDst, ALUSrcB,
    output logic [3:0] ALUOp
    );
    /*
    [CPU control module]
    Functionality:
        By looking at the opcode and func field of an instruction, this module outputs appropriate control signals.
        Also, when notified of branch/jump misprediction or pipeline stall, this module outputs control signals that
            flush or stall part of the pipeline.
    
    Inputs:
        opcode and function code of the current instruction
        BranchMisprediction, JumpMisprediction, are asserted when its name is detected at the CPU module.
        Stall is asserted when the pipeline needs to stall due to data hazards.
    
    Outputs: only those that are different from the lecture slide are explained here.
        JumpType    : Which type of jump destination? JumpAddress(0) or Rs(1)
        RegSrc      : Data being written to the RF.   ALUResult(0) or MDR(1)
        RegDst[1:0] : Address of register to write to. Rt(00) or Rd(01) or 2(10)
        ALUSrcA     : First input to ALU.             RFRead1(0) or PC(1)
        ALUSrcB[1:0]: Second input to ALU.            RFRead2(0) or sign-extended immediate(1) or 1(2)
        IFIDWrite   : Write enable bit for IF/ID pipeline register
        IFFlush     : Flush IF stage if enabled
        IDEXWrite   : Write enable bit for ID/EX pipeline register
    */
    
    // Determine PCWrite, IFIDWrite, IFFlush, IDEXWrite separately according to state priority
    always_comb begin
        if (BranchMisprediction) begin
            PCWrite = 1;
            IFIDWrite = 0;
            IFFlush = 1;
            IDEXWrite = 0;
        end else if (Stall) begin
            PCWrite = 0;
            IFIDWrite = 0;
            IFFlush = 0;
            IDEXWrite = 0;
        end else if (JumpMisprediction) begin
            PCWrite = 1;
            IFIDWrite = 0;
            IFFlush = 1;
            IDEXWrite = 1;
        end else begin
            PCWrite = 1;
            IFIDWrite = 1;
            IFFlush = 0;
            IDEXWrite = 1;
        end
    end
    
    // Determine usual control signals
    always_comb begin
        JumpType = (opcode==`OPCODE_R & (func==`FUNC_JPR | func==`FUNC_JRL));
        DataMemRead = !Stall & (opcode==`OPCODE_LWD);
        DataMemWrite = !Stall & (opcode==`OPCODE_SWD);
        RegWrite = !Stall & ((opcode==`OPCODE_R & (func==`FUNC_ADD | func==`FUNC_SUB | func==`FUNC_AND | func==`FUNC_ORR | func==`FUNC_NOT | func==`FUNC_TCP | func==`FUNC_SHL | func==`FUNC_SHR | func==`FUNC_JRL)) | opcode==`OPCODE_ADI | opcode==`OPCODE_ORI | opcode==`OPCODE_LHI | opcode==`OPCODE_LWD | opcode==`OPCODE_JAL | opcode==`OPCODE_SWD);//수정된 부분
        IsBranch = (opcode==`OPCODE_BEQ | opcode==`OPCODE_BNE | opcode==`OPCODE_BGZ | opcode==`OPCODE_BLZ);
        IsJump = (opcode==`OPCODE_JMP | opcode==`OPCODE_JAL | (opcode==`OPCODE_R & (func==`FUNC_JPR | func==`FUNC_JRL)));
        ALUSrcA = (opcode==`OPCODE_JAL | (opcode==`OPCODE_R & func==`FUNC_JRL));
        RegSrc = (opcode==`OPCODE_LWD);
        Halt = (opcode==`OPCODE_R & func==`FUNC_HLT);
        OpenPort =  !BranchMisprediction & !JumpMisprediction & !Stall & (opcode==`OPCODE_R & func==`FUNC_WWD);
        
        if (opcode==`OPCODE_JAL | (opcode==`OPCODE_R & func==`FUNC_JRL)) ALUSrcB = 2;
        else if (opcode==`OPCODE_ADI | opcode==`OPCODE_ORI | opcode==`OPCODE_LHI | opcode==`OPCODE_LWD | opcode==`OPCODE_SWD) ALUSrcB = 1;
        else ALUSrcB = 0;
        
        if (opcode==`OPCODE_JAL | (opcode==`OPCODE_R & func==`FUNC_JRL)) RegDst = 2;
        else if (opcode==`OPCODE_R) RegDst = 1;
        else RegDst = 0;
    end
    
    // Determine usual ALU operation
    always_comb begin
        if (opcode==`OPCODE_R & func<8) ALUOp = func[3:0];
        else if (opcode==`OPCODE_ADI | opcode==`OPCODE_LWD | opcode==`OPCODE_SWD | opcode==`OPCODE_JAL | (opcode==`OPCODE_R & func==`FUNC_JRL)) ALUOp = 0;
        else if (opcode==`OPCODE_ORI) ALUOp = 3;
        else if (opcode==`OPCODE_LHI) ALUOp = 8;
        else if (opcode==`OPCODE_BNE) ALUOp = 9;
        else if (opcode==`OPCODE_BEQ) ALUOp = 10;
        else if (opcode==`OPCODE_BGZ) ALUOp = 11;
        else if (opcode==`OPCODE_BLZ) ALUOp = 12;
        else ALUOp = 15;    // undefined operation
    end
    
endmodule // Control
