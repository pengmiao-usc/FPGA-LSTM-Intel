module top_gate();
    
	parameter INPUT_SZ  = 4;
	parameter HIDDEN_SZ = 32;
	parameter QN = 6;
    parameter QM = 11;
	parameter DSP48_PER_ROW = 2;
    
    // Dependent Parameters
    parameter BITWIDTH         = QN + QM + 1;
    parameter INPUT_BITWIDTH   = BITWIDTH*INPUT_SZ;
    parameter LAYER_BITWIDTH   = BITWIDTH*HIDDEN_SZ;
	parameter ADDR_BITWIDTH    = $ln(HIDDEN_SZ)/$ln(2);
	parameter ADDR_BITWIDTH_X  = $ln(INPUT_SZ)/$ln(2);
    parameter HALF_CLOCK       = 1;
    parameter FULL_CLOCK       = 2*HALF_CLOCK;
    parameter MAX_SAMPLES      = 50;

    // DUT Connecting wires/regs
	reg    [ADDR_BITWIDTH_X-1:0] colAddressWrite_X;
	reg    [ADDR_BITWIDTH-1:0]   colAddressWrite_Y;
	wire   [ADDR_BITWIDTH_X-1:0] colAddressRead_X;
	wire   [ADDR_BITWIDTH-1:0]   colAddressRead_Y;
	reg    [LAYER_BITWIDTH-1:0]  weightMemInput_X;
	wire   [LAYER_BITWIDTH-1:0]  weightMemOutput_X;
	reg    [LAYER_BITWIDTH-1:0]  weightMemInput_Y;
	wire   [LAYER_BITWIDTH-1:0]  weightMemOutput_Y;
    wire   [LAYER_BITWIDTH-1:0]  gateOutput;
    wire                         dataReady_gate;
    reg  						 clock;
    reg  						 reset;
    reg  						 beginCalc;
    reg                          writeEn_X;
    reg                          writeEn_Y;
    reg signed [BITWIDTH-1:0] prevLayerOut ;
    input reg signed [BITWIDTH-1:0] inputVec;
	input reg signed [BITWIDTH-1:0] prevOutVec;
	input reg signed [LAYER_BITWIDTH-1:0] biasVec;

    // DUT Instantiation
    gate #(INPUT_SZ, HIDDEN_SZ, QN, QM, DSP48_PER_ROW) GATE   (inputVec, prevOutVec, weightMemOutput_X, weightMemOutput_Y, biasVec, beginCalc,
														     clock, reset, colAddressRead_X, colAddressRead_Y, dataReady_gate, gateOutput);
    weightRAM  #(HIDDEN_SZ,  INPUT_SZ, BITWIDTH)       WRAM_X (colAddressWrite_X, colAddressRead_X, writeEn_X, clock, reset, weightMemInput_X, weightMemOutput_X);
    weightRAM  #(HIDDEN_SZ, HIDDEN_SZ, BITWIDTH)       WRAM_Y (colAddressWrite_Y, colAddressRead_Y, writeEn_Y, clock, reset, weightMemInput_Y, weightMemOutput_Y);
    
endmodule
