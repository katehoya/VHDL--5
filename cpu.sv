`define WORD_SIZE 16    // address word size
`define DATA_SIZE 24    // data word size 
`include "opcode.sv"

module cpu (
	    /* verilator lint_off UNUSED */
	    /* verilator lint_off UNDRIVEN */
	    input logic			  clk, 
	    input logic			  reset, 

	    // Instruction memory interface
	    output logic		  i_readM, 
	    output logic		  i_writeM, 
	    output logic [`DATA_SIZE-1:0] i_address, 
	    inout logic [`WORD_SIZE-1:0]  i_data, 

	    // Data memory interface
	    output logic		  d_readM, 
	    output logic		  d_writeM, 
	    output logic [`DATA_SIZE-1:0] d_address, 
	    inout logic [`DATA_SIZE-1:0]  d_data, 

	    output logic [`WORD_SIZE-1:0] num_inst, 
	    output logic [`DATA_SIZE-1:0] output_port, 
	    output logic		  is_halted                       // 1 if the cpu is halted
	    /* verilator lint_on UNUSED */
	    /* verilator lint_on UNDRIVEN */
	    );

   ///////////////////////////// Declarations and Instantiations ///////////////////////////// 
  // Register and wire declarations
   // Testbench purposes
   /* verilator lint_off UNUSED */
   /* verilator lint_off UNDRIVEN */
   logic [`WORD_SIZE-1:0]		  internal_num_inst;     // only show num_inst value for exactly one cycle in each instruction
   logic [`WORD_SIZE-1:0]		  jump_mispredict_penalty, branch_mispredict_penalty, stall_penalty;
   
   // Program Counter related
   logic [`DATA_SIZE-1:0]		  PC, nextPC, R_read;
   
   // IF/ID pipeline registers. no control signals
   logic [`DATA_SIZE-1:0]		  IF_ID_PC, IF_ID_nextPC;
   logic [`WORD_SIZE-1:0]		  IF_ID_Inst;
   
   // ID/EX pipeline registers
   // non - control signals
   logic [`DATA_SIZE-1:0]		  ID_EX_RFRead1, ID_EX_RFRead2, ID_EX_SignExtendedImm, ID_EX_PC, ID_EX_nextPC;
   logic [1:0]				  ID_EX_RFWriteAddress;
   // control signals
   logic				  ID_EX_IsBranch, ID_EX_ALUSrcA, ID_EX_DataMemRead, ID_EX_DataMemWrite, ID_EX_RegWrite, ID_EX_Halt, ID_EX_RegSrc, ID_EX_NPUSrcA, ID_EX_NPUSrcB, ID_EX_DataNPUWrite;
   logic [1:0]				  ID_EX_RegDst, ID_EX_ALUSrcB;
   logic [3:0]				  ID_EX_ALUOp;
   
   // EX/MEM pipeline registers
   // non - control signals
   logic [`DATA_SIZE-1:0]		  EX_MEM_RFRead2, EX_MEM_PC, EX_MEM_ALUResult;
   logic [1:0]				  EX_MEM_RFWriteAddress;
   // control signals
   logic				  EX_MEM_DataMemRead, EX_MEM_DataMemWrite, EX_MEM_RegWrite, EX_MEM_RegSrc,EX_MEM_DataNPUWrite;
   
   // MEM/WB pipeline registers
   //non - control signals
   logic [`DATA_SIZE-1:0]		  MEM_WB_RFRead2, MEM_WB_MemData, MEM_WB_ALUResult;
   logic [1:0]				  MEM_WB_RFWriteAddress;
   // control signals
   logic				  MEM_WB_RegWrite, MEM_WB_RegSrc;
   
   // Control signals
   logic				  IsBranch, IsJump, JumpType, DataMemRead, DataMemWrite, RegWrite, PCWrite, IFIDWrite, IFFlush, IDEXWrite, ALUSrcA, RegSrc, Halt, OpenPort;
   logic [1:0]				  RegDst, ALUSrcB;
   logic [3:0]				  ALUOp;
   
   // Data hazard detection
   logic				  BranchMisprediction, JumpMisprediction, Stall;
   
   // Branch Prediction
   logic [`DATA_SIZE-1:0]		  Prediction;
   logic [`WORD_SIZE-1:0]		  ActualBranchTarget;
   logic				  Correct;
   
   // RegisterFile
   logic [`DATA_SIZE-1:0]		  WriteData;
   logic [`DATA_SIZE-1:0]		  RFRead1, RFRead2;
   
   // ALU
   logic [`DATA_SIZE-1:0]		  ALUin1, ALUin2;
   logic [`DATA_SIZE-1:0]		  ALUResult;
   logic				  BranchTaken;
   //NPU
   logic [`DATA_SIZE-1:0]		  NPUin1, NPUin2;
   logic [71:0]				  NPUout1,  N_data;
   logic [15:0]				  NPUout2;
   logic				  DataNPUWrite,NPUSrcA,NPUSrcB;
   logic				  NPUType1,NPUType2;
   logic				  fin;
   /* verilator lint_on UNUSED */
   /* verilator lint_on UNDRIVEN */
   
   // Module instantiations
   // Control module is located at the ID stage.
   control control (.opcode(IF_ID_Inst[15:12]),
                    .func(IF_ID_Inst[5:0]),
                    .BranchMisprediction(BranchMisprediction),
                    .JumpMisprediction(JumpMisprediction),
                    .Stall(Stall),
                    .IsBranch(IsBranch),
                    .IsJump(IsJump),
                    .JumpType(JumpType),
                    .DataMemRead(DataMemRead),
                    .DataMemWrite(DataMemWrite),
		    .DataNPUWrite(DataNPUWrite),
                    .RegWrite(RegWrite),
                    .PCWrite(PCWrite),
                    .IFIDWrite(IFIDWrite),
                    .IFFlush(IFFlush),
                    .IDEXWrite(IDEXWrite),
                    .RegSrc(RegSrc),
                    .ALUSrcA(ALUSrcA),
                    .Halt(Halt),
                    .OpenPort(OpenPort),
                    .RegDst(RegDst),
                    .ALUSrcB(ALUSrcB),
                    .ALUOp(ALUOp),
		    .NPUType1(NPUType1),
		    .NPUType2(NPUType2),
		    .NPUSrcA(NPUSrcA),
		    .NPUSrcB(NPUSrcB),
		    .fin(fin));
   
   // Hazard Detector module is located at the ID stage.
   HazardDetector hazard_detector (.inst(IF_ID_Inst), 
                                   .ID_EX_RFWriteAddress(ID_EX_RFWriteAddress),
                                   .EX_MEM_RFWriteAddress(EX_MEM_RFWriteAddress),
                                   .MEM_WB_RFWriteAddress(MEM_WB_RFWriteAddress),
                                   .ID_EX_RegWrite(ID_EX_RegWrite),
                                   .EX_MEM_RegWrite(EX_MEM_RegWrite),
                                   .MEM_WB_RegWrite(MEM_WB_RegWrite),
                                   .Stall(Stall));
   
   // Branch Predictor module is located at the IF stage.
   AlwaysNTPredictor branch_predictor (.PC(PC),
                                       .Correct(Correct),
                                       .ActualBranchTarget(ActualBranchTarget),
                                       .Prediction(Prediction));

   RegisterFile rf (.write(MEM_WB_RegWrite),
		    .clk(clk),
		    .reset(reset),
		    .addr1(IF_ID_Inst[11:10]),
		    .addr2(IF_ID_Inst[9:8]),
		    .addr3(MEM_WB_RFWriteAddress),
		    .data1(RFRead1),
		    .data2(RFRead2),
		    .data3(WriteData));
   
   alu alu (.A(ALUin1),
            .B(ALUin2),
            .OP(ID_EX_ALUOp),
            .C(ALUResult),
            .branch_cond(BranchTaken));
   memory memory(
		 .DataMEMRead		(EX_MEM_DataMemRead),
		 .DataMEMWrite		(EX_MEM_DataMemWrite),
		 .clk			(clk),
		 .reset			(reset),
		 .S_data		(EX_MEM_RFRead2),
		 .R_data		(R_read),
		 .address		(d_address[5:0]),
		 .N_data		(N_data),
		 .N_address		(d_address[2:0]),
		 .DataNPUWrite		(EX_MEM_DataNPUWrite));
   MMU uut (
	    .clk(clk),
	    .control(NPUType1),
	    .reset(reset),
	    .data_arr(NPUin1),
	    .wt_arr(NPUin2),
	    .acc_out(NPUout1));
   conv con(
	    .clk(clk),
	    .rst(reset),
	    .data(NPUin1),
	    .wt(NPUin2),
	    .send(NPUType2),
	    .output_data(NPUout2),
	    .fin(fin));
   ///////////////////////////////////////////////////////////////////////////////////////////
   
   
   /////////////////////////////////////// CPU reset ///////////////////////////////////////
   /*    always_ff @(posedge clk) begin
    if (reset) begin    
    PC <= 0;
    internal_num_inst <= 0;
    jump_mispredict_penalty <= 0;
    branch_mispredict_penalty <= 0;
    stall_penalty <= 0;
        end
    end
    */
   ///////////////////////////////////////////////////////////////////////////////////////////
   
   
   /////////////////////////////// Pipeline register transfers /////////////////////////////// 
   always_ff @(posedge clk) begin
      if (!reset) begin    
         // IF/ID registers
         if (IFIDWrite || internal_num_inst==0) begin
            IF_ID_PC      <= PC;
            IF_ID_nextPC  <= nextPC;
         end else if (IFFlush) begin
            IF_ID_Inst    <= `WORD_SIZE'hffff;
            IF_ID_PC      <= 0;
            IF_ID_nextPC  <= 0;
         end
         // ID/EX registers
         if (IDEXWrite) begin
            case (RegDst)
              2'b00: ID_EX_RFWriteAddress <= IF_ID_Inst[9:8];
              2'b01: ID_EX_RFWriteAddress <= IF_ID_Inst[7:6];
              2'b10: ID_EX_RFWriteAddress <= 2'b10;
              default: begin end
            endcase
            ID_EX_SignExtendedImm   <= {{12{IF_ID_Inst[11]}}, IF_ID_Inst[11:0]};
            ID_EX_RFRead1           <= RFRead1;
            ID_EX_RFRead2           <= RFRead2;
            ID_EX_PC                <= IF_ID_PC;
            ID_EX_nextPC            <= IF_ID_nextPC;
            ID_EX_IsBranch          <= IsBranch;
            ID_EX_ALUSrcA           <= ALUSrcA;
            ID_EX_ALUSrcB           <= ALUSrcB;
            ID_EX_DataMemRead       <= DataMemRead; 
            ID_EX_DataMemWrite      <= DataMemWrite;
            ID_EX_RegWrite          <= RegWrite;
            ID_EX_RegSrc            <= RegSrc;
            ID_EX_RegDst            <= RegDst;
            ID_EX_ALUOp             <= ALUOp;
            ID_EX_Halt              <= Halt;
	    ID_EX_DataNPUWrite      <= DataNPUWrite;
	    ID_EX_NPUSrcA	    <= NPUSrcA;
	    ID_EX_NPUSrcB	    <= NPUSrcB;
	 end else begin
	    ID_EX_RFWriteAddress    <= 0;
	    ID_EX_PC                <= 0;
	    ID_EX_nextPC            <= 0;
	    ID_EX_IsBranch          <= 0;
	    ID_EX_DataMemRead       <= 0;
	    ID_EX_DataMemWrite      <= 0;
	    ID_EX_RegWrite          <= 0;
	    ID_EX_Halt              <= 0;
	    ID_EX_DataNPUWrite	    <= 0;
	    ID_EX_NPUSrcA 	    <= 0;
	    ID_EX_NPUSrcB           <= 0;
	 end
         // EX/MEM registers
         EX_MEM_RFRead2        <= ID_EX_RFRead2;
         EX_MEM_PC             <= ID_EX_PC;
         EX_MEM_ALUResult      <= ALUResult;
         EX_MEM_RFWriteAddress <= ID_EX_RFWriteAddress;
         EX_MEM_DataMemRead    <= ID_EX_DataMemRead;
         EX_MEM_DataMemWrite   <= ID_EX_DataMemWrite;
         EX_MEM_RegWrite       <= ID_EX_RegWrite;
         EX_MEM_RegSrc         <= ID_EX_RegSrc;
	 EX_MEM_DataNPUWrite	<= ID_EX_DataNPUWrite;
         // MEM/WB registers
         MEM_WB_RFRead2        <= EX_MEM_RFRead2;
         MEM_WB_RFWriteAddress <= EX_MEM_RFWriteAddress;
         MEM_WB_RegWrite       <= EX_MEM_RegWrite;
         MEM_WB_RegSrc         <= EX_MEM_RegSrc;
         MEM_WB_ALUResult      <= EX_MEM_ALUResult;
      end
   end
   ///////////////////////////////////////////////////////////////////////////////////////////

   
   ///////////////////////////////////// Outward Signals /////////////////////////////////////
   // Only open output_port when control signal OpenPort is asserted,
   assign output_port = OpenPort ? RFRead1 : `DATA_SIZE'b0;
   
   // HLT should be serviced when it is guaranteed not to be flushed.
   assign is_halted = ID_EX_Halt;
   
   /* 
    num_inst is output when OpenPort is asserted, which means the current instruction is WWD.
    
    internal_num_inst        : assumes CPI = 1. increments every cycle
    branch_mispredict_penalty: 2 cycle penalty  
    jump_mispredict_penalty  : 1 cycle penalty
    stall_penalty            : As long as the stall

    Thus internal_num_inst - branch_mispredict_penalty - stall_penalty - jump_mispredict_penalty is the number of instructions processed (including the current one)
    */
   assign num_inst = OpenPort ? (internal_num_inst - branch_mispredict_penalty - stall_penalty - jump_mispredict_penalty) : `WORD_SIZE'b0;
   
   always_ff @(posedge clk) begin
      if (!reset) internal_num_inst <= internal_num_inst + 1;
   end
   always_ff @(negedge clk) begin     // Used negedge because of glitches in the signals at transition yielded random increments
      if (BranchMisprediction)    branch_mispredict_penalty  <= branch_mispredict_penalty + 2;
      else if (Stall)             stall_penalty              <= stall_penalty + 1;
      else if (JumpMisprediction) jump_mispredict_penalty    <= jump_mispredict_penalty + 1;
   end
   ///////////////////////////////////////////////////////////////////////////////////////////
   
   
   ////////////////////////////////////// Memory Access //////////////////////////////////////
   // Fetch instruction every cycle
   assign i_address = (IFIDWrite || internal_num_inst==0) ? PC : `DATA_SIZE'b0;
   assign i_readM = (IFIDWrite || internal_num_inst==0) ? 1 : 0;
   
   
   // When the IF stage needs to be flushed, discard the fetched instruction.
   // Else, fetch instruction directly into the pipeline register.
   always_ff @(posedge clk) begin
      if (IFFlush) IF_ID_Inst <= `WORD_SIZE'hffff;
      // No control signals during the IF stage of the first instruction. Manually enable IF/ID pipeline register write,
      else if (IFIDWrite || internal_num_inst==0) IF_ID_Inst <= i_data;
   end
   
   // Data memory access
   always_ff @(posedge clk) begin
      if(NPUType1) N_data <= NPUout1;
      else if(NPUType2) N_data <= {56'b0,NPUout2};
      else begin
	 if(N_data>0) begin
	    N_data <= N_data;
	 end
	 else
	   N_data <=0;
      end
      
   end
   
   assign d_data = (EX_MEM_DataMemWrite) ? EX_MEM_RFRead2 : R_read;
   assign d_readM = EX_MEM_DataMemRead;
   assign d_writeM = EX_MEM_DataMemWrite;
   assign d_address = (EX_MEM_DataMemRead || EX_MEM_DataMemWrite) ? EX_MEM_ALUResult : `DATA_SIZE'b0;
   
   
   // Fetch data directly into the pipeline register.
   always_ff @(posedge clk) begin
      if (EX_MEM_DataMemRead) MEM_WB_MemData <= d_data;
   end
   ///////////////////////////////////////////////////////////////////////////////////////////
   
   
   /////////////////////////////////////// Updating PC ///////////////////////////////////////
   // Branch mispredictions have higher priority 
   // since it is detected at the EX stage, whereas jump mispredictions are detected at the ID stage, hence being older.
   always_comb begin
      if (ID_EX_IsBranch && BranchMisprediction) begin
         if (BranchTaken) nextPC = ID_EX_PC + 1 + ID_EX_SignExtendedImm;  // Branch should have been taken
         else nextPC = ID_EX_PC + 1;                                      // Branch shouldn't have been taken
      end else if (IsJump && JumpMisprediction) begin
         if (JumpType) nextPC = RFRead1;                     // JPR, JRL
         else nextPC = {IF_ID_PC[23:12], IF_ID_Inst[11:0]};  // JMP, JAL
      end else begin
         nextPC = Prediction;    // by the branch_predictor. Always PC+1 in the baseline model.
      end
   end
   
   // Update PC at clock posedge
   always_ff @(posedge clk) begin
      if (!reset) 
        // No control signals before the ID stage of the first instruction. Manually enable PCwrite,
        if (PCWrite || internal_num_inst==0) PC <= nextPC;
   end
   ///////////////////////////////////////////////////////////////////////////////////////////
	 

   ////////////////////////////////////// Register File //////////////////////////////////////
	always_comb begin
           case (MEM_WB_RegSrc)
             1'b0: WriteData = MEM_WB_ALUResult;
             1'b1: WriteData = MEM_WB_MemData;
             default: WriteData = `DATA_SIZE'b0;//replace with a default value instead of 'bz'
           endcase
	end
   ///////////////////////////////////////////////////////////////////////////////////////////


   /////////////////////////////////////////// ALU ///////////////////////////////////////////
   always_comb begin
      case (ID_EX_ALUSrcA)
        1'b0: ALUin1 = ID_EX_RFRead1;
        1'b1: ALUin1 = ID_EX_PC;
        default: ALUin1 = `DATA_SIZE'b0;
      endcase
   end
   always_comb begin
      case (ID_EX_ALUSrcB)
        2'b00: ALUin2 = ID_EX_RFRead2;
        2'b01: ALUin2 = ID_EX_SignExtendedImm;
        2'b10: ALUin2 = 1;
        default: ALUin2 = `DATA_SIZE'b0;
      endcase
   end
   ///////////////////////////////////////////////////////////////////////////////////////////
   
   //////////////////////////////////////////NPU//////////////////////////////////////////////
   always_comb begin
      case(ID_EX_NPUSrcA)
	1'b0: NPUin1 = ID_EX_RFRead1;
	default: NPUin1 = `DATA_SIZE'b0;
      endcase // case (ID_EX_NPUSrcA)
   end
   always_comb begin
      case (ID_EX_NPUSrcB)
	1'b0: NPUin2 = ID_EX_RFRead2;
	default: NPUin2 = `DATA_SIZE'b0;
      endcase // case (ID_EX_NPUSrcB)
   end

   ///////////////////////////////// Control Hazard Detection ////////////////////////////////
   assign BranchMisprediction = ID_EX_IsBranch && ((BranchTaken && ID_EX_nextPC!=ALUResult) || (!BranchTaken && ID_EX_nextPC!=ID_EX_PC+1));
   assign JumpMisprediction = IsJump && ((JumpType && RFRead1!=IF_ID_nextPC) || (!JumpType && {IF_ID_PC[23:12], IF_ID_Inst[11:0]}!=IF_ID_nextPC));
   ///////////////////////////////////////////////////////////////////////////////////////////
   
endmodule // cpu
