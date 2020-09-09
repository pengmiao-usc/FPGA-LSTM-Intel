`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2020 03:53:24 PM
// Design Name: 
// Module Name: Adder
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

module Adder#( 
     parameter BIT_WIDTH = 18//k
     )
 (
    input clk,
    input  [BIT_WIDTH-1:0] a,
    input  [BIT_WIDTH-1:0] b,
    output reg [BIT_WIDTH-1:0] res
 );

    always @(posedge clk)
    begin
        res <= a[BIT_WIDTH-1:0]+b[BIT_WIDTH-1:0];
    end
endmodule
