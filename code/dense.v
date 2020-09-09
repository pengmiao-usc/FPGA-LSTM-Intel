`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/05/2020 03:53:51 PM
// Design Name: 
// Module Name: dense
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


module dense#(
                  parameter INPUT_SZ   =  2,
                  parameter HIDDEN_SZ  = 64,
                  parameter OUTPUT_SZ  =  1,//NUM_OUTPUT_SYMBOLS = 2,
                  parameter QN        =  6,
                  parameter QM        = 11,
                  parameter DSP48_PER_ROW_G = 2,
                  parameter DSP48_PER_ROW_M = 4,
                  parameter EM_IN=2,
                  parameter EM_DIM=8)
                  (W_DENSE_W,
                  W_DENSE_B,
                  inputVec,
                  clock,
                  reset,
                  dense_enable,
                  dataReady,
                  outputVec,
                  dataReady_out);
 parameter BITWIDTH           = QN + QM + 1;
 parameter FINAL_SIZE = 16;
 parameter LAYER_BITWIDTH     = BITWIDTH*HIDDEN_SZ;
	input  [FINAL_SIZE*LAYER_BITWIDTH-1:0] W_DENSE_W;
	input  [FINAL_SIZE*BITWIDTH-1:0] W_DENSE_B;
	input                            clock;
	input [HIDDEN_SZ*BITWIDTH-1:0]        inputVec;
	input                            reset;
	input  dense_enable;
	input  dataReady;
    output reg [FINAL_SIZE*BITWIDTH-1:0]  outputVec;
    output reg dataReady_out;
    reg [FINAL_SIZE*BITWIDTH-1:0] bD;
    wire wDw_out;
    reg colAddressRead_Dw=0;
    reg dense_enable_innter=0;
    reg  sigmoidEnable=1;
    wire reset_sigm;
    wire [FINAL_SIZE*BITWIDTH-1:0] C;
    wire [FINAL_SIZE*BITWIDTH-1:0] D;
    wire [FINAL_SIZE*BITWIDTH-1:0]  pre_outputVec;
    //wire [BITWIDTH-1:0] D;
    //reg enable;
    
    
   // weightRAM  #(EM_DIM,  EM_IN, BITWIDTH)  WRAM_DENSE_W (2'b0, colAddressRead_Dw, 0, clock, reset, 0, wDw_out);
//  weightRAM  #(EM_DIM,  EM_IN, BITWIDTH)  WRAM_Dense_b (2'b0, colAddressRead_Em, 0, clock, reset, 0, wDb_out);
    //always @(clk posedge)begin
    
    
	assign reset_sigm = reset || !sigmoidEnable;
	
	genvar i;
	generate
        for (i = 0; i < FINAL_SIZE; i = i + 1) begin
            MulandAddTree
            #(
            .BIT_WIDTH(BITWIDTH),
            .N(HIDDEN_SZ)
            )
            MAT_i(
            .clk(clock),
            .rst(reset),
            .A(inputVec[HIDDEN_SZ*BITWIDTH-1:0]),
            .B(W_DENSE_W[HIDDEN_SZ*BITWIDTH*i +: HIDDEN_SZ*BITWIDTH]),
            .C(C[i*BITWIDTH +: BITWIDTH])
            );
            
            Adder#(.BIT_WIDTH(BITWIDTH)) Add_Bias_i
                (
                .clk(clock), 
                .b(C[i*BITWIDTH +: BITWIDTH]),   // 3*8-1,
                .a(W_DENSE_B[BITWIDTH*i +: BITWIDTH]),    
                .res(D[i*BITWIDTH +: BITWIDTH])     
                );
            sigmoid #(QN,QM) sigmoid_i (D[i*BITWIDTH +: BITWIDTH], clock, reset_sigm, pre_outputVec[i*BITWIDTH +: BITWIDTH]);
        end
	endgenerate
	


    always @(negedge clock) begin
        if(dataReady==1 && dense_enable==1)
            dense_enable_innter<=1;
    
        if(dense_enable_innter==1)begin
            //outputVec[HIDDEN_SZ*BITWIDTH-1:0] <= inputVec[HIDDEN_SZ*BITWIDTH-1:0];
         //   outputVec[FINAL_SIZE*BITWIDTH-1:0] <= W_DENSE_W[FINAL_SIZE*BITWIDTH-1:0];  
            outputVec<=pre_outputVec;
            dataReady_out<=1;
        end
    //    newSample_out <=newSample_in;
     // a<=~a;
    end
  
   
    
    
    
    /*
    wire   [LAYER_BITWIDTH-1:0]  wEm_out;
    //wire   [LAYER_BITWIDTH-1:0]  wEm_out1;
    wire   [ADDR_BITWIDTH_X-1:0] colAddressRead_Em;
    
    weightRAM  #(EM_DIM,  1, BITWIDTH)  WRAM_Em (2'b0, colAddressRead_Em, 0, clock, reset, 0, wEm_out);
    
    //always @(clk posedge)begin
    always @(negedge clock) begin
        outputVec[INPUT_BITWIDTH-1:0] <= inputVec[INPUT_BITWIDTH-1:0];
        newSample_out <=newSample_in;
    end
    */
    
    
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

