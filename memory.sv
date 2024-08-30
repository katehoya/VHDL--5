module memory(input DataMEMRead, DataNPUWrite,
      input DataMEMWrite, clk, reset,
      input reg [23:0] S_data,
      output reg [23:0]R_data,
      input reg [71:0] N_data,
      input [5:0] address,//enable 27, 28<address - non
      input [2:0] N_address);//ebalbe 6, 7<N_address-non
   reg [431:0]     mem; 
  
always @(posedge clk) begin
   if(reset) begin
      mem <= 432'b1;
      R_data <= 24'b0;
   end
   else begin
      if(DataMEMRead) begin
 R_data <= mem[24*address+: 24];
      end
      if(DataMEMWrite) begin
 mem[24*address+: 24] <= S_data;
      end
      if(DataNPUWrite) begin
 mem[72*N_address+: 72] <= N_data;
      end
   end // else: !if(reset)
 end // always @ (posedge clk)
 endmodule // memory
