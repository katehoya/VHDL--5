module con_input (
    input	       clk, rst,
    input [23:0]       data,
    input [23:0]       wt,
    input	       send,
    output logic [7:0] data_pe0,
    output logic [7:0] data_pe1,
    output logic [7:0] data_pe2,
    output logic [7:0] data_pe3,
    output logic [7:0] data_pe4,
    output logic [7:0] data_pe5,
    output logic [7:0] data_pe6,
    output logic [7:0] data_pe7,
    output logic [7:0] data_pe8,
    output logic [7:0] wt_pe0,
    output logic [7:0] wt_pe1,
    output logic [7:0] wt_pe2,
    output logic [7:0] wt_pe3,
    output logic [7:0] wt_pe4,
    output logic [7:0] wt_pe5,
    output logic [7:0] wt_pe6,
    output logic [7:0] wt_pe7,
    output logic [7:0] wt_pe8
);

   logic [3:0] cnt;

   logic [7:0]	fdata_pe0;
   logic [7:0]	fdata_pe1;
   logic [7:0]	fdata_pe2;
   logic [7:0]	fdata_pe3;
   logic [7:0]	fdata_pe4;
   logic [7:0]	fdata_pe5;
   logic [7:0]	fdata_pe6;
   logic [7:0]	fdata_pe7;
   logic [7:0]	fdata_pe8;
   logic [7:0]	fwt_pe0;
   logic [7:0]	fwt_pe1;
   logic [7:0]	fwt_pe2;
   logic [7:0]	fwt_pe3;
   logic [7:0]	fwt_pe4;
   logic [7:0]	fwt_pe5;
   logic [7:0]	fwt_pe6;
   logic [7:0]	fwt_pe7;
   logic [7:0]	fwt_pe8;

   always_ff @ (posedge clk) begin
      if (rst) begin
         fdata_pe0 <= 0;
         fdata_pe1 <= 0;
         fdata_pe2 <= 0;
         fdata_pe3 <= 0;
         fdata_pe4 <= 0;
         fdata_pe5 <= 0;
         fdata_pe6 <= 0;
         fdata_pe7 <= 0;
         fdata_pe8 <= 0;
         fwt_pe0   <= 0;
         fwt_pe1   <= 0;
         fwt_pe2   <= 0;
         fwt_pe3   <= 0;
         fwt_pe4   <= 0;
         fwt_pe5   <= 0;
         fwt_pe6   <= 0;
         fwt_pe7   <= 0;
         fwt_pe8   <= 0;
         cnt <= 0;
      end else begin
         if (send) begin
            if (cnt == 0) begin
               fdata_pe6 <= data[23:16];
               fdata_pe7 <= data[15:8];
               fdata_pe8 <= data[7:0];
               fwt_pe6 <= wt[23:16];
               fwt_pe7 <= wt[15:8];
               fwt_pe8 <= wt[7:0];
               cnt <= 1;
            end else if (cnt == 1) begin
               fdata_pe3 <= data[23:16];
               fdata_pe4 <= data[15:8];
               fdata_pe5 <= data[7:0];
               fwt_pe3 <= wt[23:16];
               fwt_pe4 <= wt[15:8];
               fwt_pe5 <= wt[7:0];
               cnt <= 2;
            end else if (cnt == 2) begin
               fdata_pe0 <= data[23:16];
               fdata_pe1 <= data[15:8];
               fdata_pe2 <= data[7:0];
               fwt_pe0 <= wt[23:16];
               fwt_pe1 <= wt[15:8];
               fwt_pe2 <= wt[7:0];
               cnt <= 3;
            end else if (cnt==3) begin
	       data_pe0 <= fdata_pe0;
	       data_pe1 <= fdata_pe1;
	       data_pe2 <= fdata_pe2;
	       data_pe3 <= fdata_pe3;
	       data_pe4 <= fdata_pe4;
	       data_pe5 <= fdata_pe5;
	       data_pe6 <= fdata_pe6;
	       data_pe7 <= fdata_pe7;
	       data_pe8 <= fdata_pe8;

	       wt_pe0 <= fwt_pe0;
	       wt_pe1 <= fwt_pe1;
	       wt_pe2 <= fwt_pe2;
	       wt_pe3 <= fwt_pe3;
	       wt_pe4 <= fwt_pe4;
	       wt_pe5 <= fwt_pe5;
	       wt_pe6 <= fwt_pe6;
	       wt_pe7 <= fwt_pe7;
	       wt_pe8 <= fwt_pe8;
	       cnt <= 4;
	    end else if (cnt==4) begin // if (cnt==3)
	       cnt <= 5;
	    end else if (cnt==5) begin
	       cnt <= 6;
	    end else if (cnt==6) begin
	       cnt <= 7;
            end else if (cnt==7) begin
	       cnt <=8;
            end else if (cnt==8) begin
	       cnt <= 9;
            end else if (cnt==9) begin
	       cnt <= 8;
            end else if (cnt==10) begin
	       cnt <= 9;
            end else if (cnt==11) begin
	       cnt <= 10;
            end else if (cnt==12) begin
	       cnt <= 11;
            end else if (cnt==13) begin
	       cnt <= 12;
            end else if (cnt==14) begin
	       cnt <= 15;
            end else begin
	       cnt <= 0;
	       data_pe0 <= 0;
	       data_pe1 <= 0;
	       data_pe2 <= 0;
	       data_pe3 <= 0;
	       data_pe4 <= 0;
	       data_pe5 <= 0;
	       data_pe6 <= 0;
	       data_pe7 <= 0;
	       data_pe8 <= 0;

	       wt_pe0 <= 0;
	       wt_pe1 <= 0;
	       wt_pe2 <= 0;
	       wt_pe3 <= 0;
	       wt_pe4 <= 0;
	       wt_pe5 <= 0;
	       wt_pe6 <= 0;
	       wt_pe7 <= 0;
	       wt_pe8 <= 0;
	       
	    end
         end // if (send)
	 else begin
	    data_pe0 <= 0;
            data_pe1 <= 0;
	    data_pe2 <= 0;
            data_pe3 <= 0;
            data_pe4 <= 0;
	    data_pe5 <= 0;
            data_pe6 <= 0;
	    data_pe7 <= 0;
            data_pe8 <= 0;

            wt_pe0 <= 0;
            wt_pe1 <= 0;
            wt_pe2 <= 0;
            wt_pe3 <= 0;
            wt_pe4 <= 0;
            wt_pe5 <= 0;
            wt_pe6 <= 0;
            wt_pe7 <= 0;
            wt_pe8 <= 0;
	 end // else: !if(send)
      end
   end
endmodule
 	    
