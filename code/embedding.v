`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/05/2020 02:24:27 AM
// Design Name: 
// Module Name: embedding
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module embedding#(parameter RAW_INPUT_BIT = 1,
                  parameter RAW_INPUT_SZ = 1,
                  parameter INPUT_SZ   =  2,
                  parameter HIDDEN_SZ  = 64,
                  parameter OUTPUT_SZ  =  1,//NUM_OUTPUT_SYMBOLS = 2,
                  parameter QN        =  6,
                  parameter QM        = 11,
                  parameter DSP48_PER_ROW_G = 2,
                  parameter DSP48_PER_ROW_M = 4,
                  parameter EM_IN=2,
                  parameter EM_DIM=8)
                  (inputVec,
                  clock,
                  reset,
                  newSample_in,
                  newSample_out,
                  outputVec);
                   
    parameter BITWIDTH           = QN + QM + 1;
    parameter INPUT_BITWIDTH     = BITWIDTH*INPUT_SZ;
    parameter MULT_BITWIDTH      = (2*BITWIDTH+2);
    parameter ELEMWISE_BITWIDTH  = MULT_BITWIDTH*HIDDEN_SZ;
    parameter OUTPUT_BITWIDTH    = OUTPUT_SZ * BITWIDTH; //log2(NUM_OUTPUT_SYMBOLS);
	parameter ADDR_BITWIDTH      = log2(HIDDEN_SZ);
	parameter ADDR_BITWIDTH_X    = log2(INPUT_SZ);
	parameter MUX_BITWIDTH		  = log2(DSP48_PER_ROW_M);  
	parameter N_DSP48            = HIDDEN_SZ/DSP48_PER_ROW_M; 
	parameter LAYER_BITWIDTH     = BITWIDTH*EM_DIM;
	
	input                            clock;
	input [RAW_INPUT_BIT-1:0]        inputVec;
	input                            reset;
	input newSample_in;
	output reg newSample_out;
    output  reg [INPUT_BITWIDTH-1:0] outputVec;
    
    wire   [LAYER_BITWIDTH-1:0]  wEm_out;
    reg   [ADDR_BITWIDTH_X-1:0] colAddressRead_Em;
    reg a=0;
    always @(*) begin
        if (newSample_in==1) begin
        if(inputVec==0)
            colAddressRead_Em<={ADDR_BITWIDTH_X{1'b0}};
        else
            colAddressRead_Em<={ADDR_BITWIDTH_X{1'b1}};
        end
    end
    
    
    weightRAM  #(EM_DIM,  EM_IN, BITWIDTH)  WRAM_Em (1'b0, colAddressRead_Em, 0, clock, reset, 0, wEm_out);
    
    //always @(clk posedge)begin
    always @(negedge clock) begin
        outputVec[INPUT_BITWIDTH-1:0] <= wEm_out;
        newSample_out <=newSample_in;
       // a<=~a;
    end
    

    
    
    function integer log2;
		input [31:0] argument;
		integer k;
		begin
			 log2 = -1;
			 k = argument;  
			 while( k > 0 ) begin
				log2 = log2 + 1;
				k = k >> 1;
			 end
		end
	endfunction
          
endmodule
