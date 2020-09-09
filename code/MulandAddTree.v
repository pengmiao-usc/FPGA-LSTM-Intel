`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2020 03:53:24 PM
// Design Name: 
// Module Name: MulandAddTree
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


module MulandAddTree #( 
     parameter BIT_WIDTH = 18,//k
     parameter N=4
     )
 (
    input clk,
    input rst,
    input [BIT_WIDTH*N-1:0] A,
    input [BIT_WIDTH*N-1:0] B,

    output [BIT_WIDTH-1:0] C
    );

wire [BIT_WIDTH-1:0] A_row [0:N-1];
wire [BIT_WIDTH-1:0] B_col [0:N-1];
//for checking the result on simulation	
	genvar m;
	generate
	for(m=0;m<N;m=m+1) begin
	    assign A_row[m]= A[(m+1)*BIT_WIDTH-1:m*BIT_WIDTH];
	    assign B_col[m]= B[(m+1)*BIT_WIDTH-1:m*BIT_WIDTH];
	end
	endgenerate


wire [BIT_WIDTH*N-1:0] mult_res;

genvar i,j;
generate 
    for (i = 0; i < N; i = i + 1) begin: Multipliers               
        Multiplier #(.BIT_WIDTH(BIT_WIDTH))mult 
        (
          .clk(clk), 
          .a(A[(i+1)*BIT_WIDTH-1:i*BIT_WIDTH]),     
          .b(B[(i+1)*BIT_WIDTH-1:i*BIT_WIDTH]),      
          .res(mult_res[(i+1)*BIT_WIDTH-1:i*BIT_WIDTH])      // 4, 4*8=32-1=31~0
        );
     end
endgenerate

wire [BIT_WIDTH-1:0] add_res[0:N][0:N];
generate//b=8,n=8
    for (i=N/2;i>=1;i=i/2) begin: Adder_Tree    //4,2,1
        for (j=i;j>0;j=j-1) begin: Adder_Layer //4,3,2,1;2,1;1
            if(i == N/2) begin
                Adder#(.BIT_WIDTH(BIT_WIDTH)) Adder_1 
                (
                .clk(clk), 
                .b(mult_res[j*2*BIT_WIDTH-1:(j*2-1)*BIT_WIDTH]),   // 3*8-1,
                .a(mult_res[(j*2-1)*BIT_WIDTH-1:(j*2-2)*BIT_WIDTH]),    
                .res(add_res[i][j-1])     
                );
                end
                    
             else if (i< N/2) begin
                 Adder#(.BIT_WIDTH(BIT_WIDTH)) Adder_i 
                  (
                  .clk(clk),  // input wire CLK
                  .b(add_res[i*2][2*j-1]),   // 3*8-1,
                  .a(add_res[i*2][2*j-2]),    
                  .res(add_res[i][j-1])     
                   );
                   end
         
         end 
     end
     assign C=add_res[1][0];
endgenerate
endmodule
