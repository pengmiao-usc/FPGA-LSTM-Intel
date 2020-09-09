`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/20/2020 04:56:08 PM
// Design Name: 
// Module Name: weightRAM
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
/*
module weightRAM #(parameter NROW = 16,
                   parameter NCOL = 16,
                   parameter BITWIDTH = 18)
                  (addressIn,
                   addressOut,
                   writeEn,
                   clk,
                   reset,
                   rowIn,
                   rowOut);
   
    // Dependent parameters
    parameter OUTPUT_PORT_SIZE = BITWIDTH*NROW;
    parameter ADDR_BITWIDTH    = log2(NCOL);
    
    // The input/output definitions
    input       [ADDR_BITWIDTH-1:0]     addressIn;
    input       [ADDR_BITWIDTH-1:0]     addressOut;
    input                               clk;
    input                               reset;
    input                               writeEn;
    output reg  [OUTPUT_PORT_SIZE-1:0]  rowOut;
    input       [OUTPUT_PORT_SIZE-1:0]  rowIn;

    // The RAM registers
    (* ramstyle = "M4K" *) reg [OUTPUT_PORT_SIZE-1:0] RAM_matrix [NCOL-1:0];    

    // Loading the RAM with dummy values
    integer i, j;
    
    initial begin        
        for(i = 0; i < NROW-1; i = i + 1) begin
            for(j = 0; j < NCOL-1; j = j + 1) begin
                //$readmemb("goldenIn_W.bin", RAM_matrix);
                RAM_matrix[i][j] <= (j)<<<11; 
            end
        end
    end
    
    
    always @(negedge clk) begin
        if(writeEn == 1'b1) begin
            RAM_matrix[addressIn] <= rowIn;
        end
        else begin
            if(reset == 1'b1) 
                rowOut <= {OUTPUT_PORT_SIZE{1'b0}};
            else
                rowOut <= RAM_matrix[addressOut];
        end
    end

function integer log2;
    input [31:0] argument;
    integer i;
    begin
         log2 = -1;
         i = argument;  
         while( i > 0 ) begin
            log2 = log2 + 1;
            i = i >> 1;
         end
    end
endfunction
endmodule



*/




module weightRAM #(parameter NROW = 16,
                   parameter NCOL = 16,
                   parameter BITWIDTH = 18)
                  (addressIn,
                   addressOut,
                   writeEn,
                   clock,
                   reset,
                   rowIn,
                   rowOut);
                                      

    // Dependent parameters
    parameter OUTPUT_PORT_SIZE = BITWIDTH*NROW;
    parameter ADDR_BITWIDTH    = log2(NCOL);
    
    // The input/output definitions
    input       [ADDR_BITWIDTH-1:0]     addressIn;
    input       [ADDR_BITWIDTH-1:0]     addressOut;
    input                               clock;
    input                               reset;
    input                               writeEn;
    output   [OUTPUT_PORT_SIZE-1:0]  rowOut;
    input       [OUTPUT_PORT_SIZE-1:0]  rowIn;
    
    //wire ram_out;

WRAM RAM_matrix (
		.data    (rowIn),    //   input,  width = 288,    data.datain
		.q       (rowOut),       //  output,  width = 288,       q.dataout
		.address (addressOut), //   input,   width = 8, address.address
		.wren    (writeEn),    //   input,   width = 1,    wren.wren
		.clock   (clock)    //   input,   width = 1,   clock.clk
	);

   
function integer log2;
    input [31:0] argument;
    integer i;
    begin
         log2 = -1;
         i = argument;  
         while( i > 0 ) begin
            log2 = log2 + 1;
            i = i >> 1;
         end
    end
endfunction
endmodule

