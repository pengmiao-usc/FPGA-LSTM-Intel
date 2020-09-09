module ti#(parameter INPUT_SZ  = 16,//2,
				  parameter HIDDEN_SZ = 16,// 16,
				  parameter QN = 6,
                  parameter QM = 11,
				  parameter DSP48_PER_ROW = 2)
                 (
                     colAddressWrite_X,
                     colAddressWrite_Y,
                     weightMemInput_X,
                     weightMemInput_Y,
                clock,
                reset,
                beginCalc,
                writeEn_X,
                writeEn_Y,
                inputVec,
                 prevOutVec,
                 biasVec,
					  colAddress_X,
					  colAddress_Y,
					  dataReady_gate,
					  gateOutput
                  );
    
    // Dependent Parameters
    parameter BITWIDTH         = QN + QM + 1;
    parameter INPUT_BITWIDTH   = BITWIDTH*INPUT_SZ;
    parameter LAYER_BITWIDTH   = BITWIDTH*HIDDEN_SZ;
	parameter ADDR_BITWIDTH    = $rtoi($ln(HIDDEN_SZ)/$ln(2));
	parameter ADDR_BITWIDTH_X  = $rtoi($ln(INPUT_SZ)/$ln(2));
    parameter HALF_CLOCK       = 1;
    parameter FULL_CLOCK       = 2*HALF_CLOCK;
    parameter MAX_SAMPLES      = 50;

    // DUT Connecting wires/regs
	input    [ADDR_BITWIDTH_X-1:0] colAddressWrite_X;
	input    [ADDR_BITWIDTH-1:0]   colAddressWrite_Y;
	wire   [ADDR_BITWIDTH_X-1:0] colAddressRead_X;
	wire   [ADDR_BITWIDTH-1:0]   colAddressRead_Y;
	input    [LAYER_BITWIDTH-1:0]  weightMemInput_X;
	wire   [LAYER_BITWIDTH-1:0]  weightMemOutput_X;
	input    [LAYER_BITWIDTH-1:0]  weightMemInput_Y;
	wire   [LAYER_BITWIDTH-1:0]  weightMemOutput_Y;
    wire   [LAYER_BITWIDTH-1:0]  gateOutput;
    wire                         dataReady_gate;
    input  						 clock;
    input  						 reset;
    input  						 beginCalc;
    input                          writeEn_X;
    input                          writeEn_Y;
    reg signed [BITWIDTH-1:0] prevLayerOut ;
    input [BITWIDTH-1:0] inputVec;
	input [BITWIDTH-1:0] prevOutVec;
	input [LAYER_BITWIDTH-1:0] biasVec;
	output        [ADDR_BITWIDTH_X-1:0] 	colAddress_X;
	output        [ADDR_BITWIDTH-1:0]  colAddress_Y;
	output	    					    dataReady_gate;
	output [LAYER_BITWIDTH-1:0]  gateOutput;

    // DUT Instantiation
    gate #(INPUT_SZ, HIDDEN_SZ, QN, QM, DSP48_PER_ROW) GATE   (inputVec, prevOutVec, weightMemOutput_X, weightMemOutput_Y, biasVec, beginCalc,
														     clock, reset, colAddressRead_X, colAddressRead_Y, dataReady_gate, gateOutput);
    weightRAM  #(HIDDEN_SZ,  INPUT_SZ, BITWIDTH)       WRAM_X (colAddressWrite_X, colAddressRead_X, writeEn_X, clock, reset, weightMemInput_X, weightMemOutput_X);
    weightRAM  #(HIDDEN_SZ, HIDDEN_SZ, BITWIDTH)       WRAM_Y (colAddressWrite_Y, colAddressRead_Y, writeEn_Y, clock, reset, weightMemInput_Y, weightMemOutput_Y);
    
endmodule
