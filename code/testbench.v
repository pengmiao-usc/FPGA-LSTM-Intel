`timescale 1ns / 1ps

module testbench();
    
    parameter RAW_INPUT_BIT = 1;
    parameter RAW_INPUT_SIZE = 1;
	parameter INPUT_SZ  = 8;
	parameter HIDDEN_SZ = 128;
	parameter OUTPUT_SZ = 1;
	parameter QN = 6;
    parameter QM = 11;
	parameter DSP48_PER_ROW_G = 2;
	parameter DSP48_PER_ROW_M = 2;
	parameter FINAL_OUT_SIZE=16;
	
	
    parameter EM_IN  = 2;
    parameter EM_DIM  = 8;
    // Dependent Parameters
    parameter BITWIDTH         = QN + QM + 1;
    parameter INPUT_BITWIDTH   = BITWIDTH*INPUT_SZ;
    parameter OUTPUT_BITWIDTH  = BITWIDTH*OUTPUT_SZ;
    parameter LAYER_BITWIDTH   = BITWIDTH*HIDDEN_SZ;
	parameter ADDR_BITWIDTH    = $ln(HIDDEN_SZ)/$ln(2);
	parameter ADDR_BITWIDTH_X  = $ln(INPUT_SZ)/$ln(2);
    parameter HALF_CLOCK       = 1.667;//2.5;
    parameter FULL_CLOCK       = 2*HALF_CLOCK;
    parameter MAX_SAMPLES      = 48;
    parameter TRAIN_SAMPLES    = 10000;

	reg clock;
	reg reset;
    reg                       newSample;
    wire   			          dataReady;
    //reg raw_input;
    reg  [RAW_INPUT_BIT-1:0] inputVec;
    wire [FINAL_OUT_SIZE*BITWIDTH-1:0] outputVec;
    reg [OUTPUT_BITWIDTH-1:0] test;
    reg   [BITWIDTH-1:0] temp;
    // File descriptors for the error/output dumps
    integer fid, fid_error_dump, retVal;
    integer fid_x, fid_Wz, fid_Wi, fid_Wf, fid_Wo, fid_Rz, fid_Ri, fid_Rf, fid_Ro, fid_bz, fid_bi, fid_bf, fid_bo,fid_Em,fid_Dw,fid_Db;
    integer i=0,j=0,k=0,l=0,m=0;
    real    quantError=0;
    reg dense_enable=0;
    wire data_result_Ready;
    
    // Clock generation
    always begin
        #(HALF_CLOCK) clock = ~clock;
        #(HALF_CLOCK) clock = ~clock;
    end
    
    /*
    module network  #(parameter RAW_INPUT_BIT = 1,
                  parameter RAW_INPUT_SZ = 1,
                  parameter INPUT_SZ   =  8,
                  parameter HIDDEN_SZ  = 64,
                  parameter OUTPUT_SZ  =  1,//NUM_OUTPUT_SYMBOLS = 2,
                  parameter QN        =  6,
                  parameter QM        = 11,
                  parameter DSP48_PER_ROW_G = 1,
                  parameter DSP48_PER_ROW_M = 4,
                  parameter EM_IN  = 2,
                  parameter EM_DIM  = 8)
                 (inputVec,
        //          trainingFlag,
                  clock,
                  reset,
                  newSample,
                  data_lstm_Ready,
                  outputVec,
                  dense_enable,
                  data_result_Ready);
                  */
    
    // DUT Instantiation
    network              #(RAW_INPUT_BIT, RAW_INPUT_SIZE, INPUT_SZ, HIDDEN_SZ, OUTPUT_SZ, QN, QM, DSP48_PER_ROW_G, DSP48_PER_ROW_M,EM_IN,EM_DIM) 
	PREFETCHER    (inputVec, clock, reset, newSample, dataReady, outputVec,dense_enable,data_result_Ready);
    
    // Keeping track of the simulation time
    real time_start, time_end;

	initial begin/*
		fid_x = $fopen("/home/pengmiao/vivado/RNN_ON_FPGA/my_test/network_after_emb/data/Input_X.dat", "r");
		fid_Wz = $fopen("/home/pengmiao/vivado/RNN_ON_FPGA/my_test/network_after_emb/data/weight_W_z_fpb.dat", "r");
		fid_Wi = $fopen("/home/pengmiao/vivado/RNN_ON_FPGA/my_test/network_after_emb/data/weight_W_i_fpb.dat", "r");
		fid_Wf = $fopen("/home/pengmiao/vivado/RNN_ON_FPGA/my_test/network_after_emb/data/weight_W_f_fpb.dat", "r");
		fid_Wo = $fopen("/home/pengmiao/vivado/RNN_ON_FPGA/my_test/network_after_emb/data/weight_W_o_fpb.dat", "r");
		fid_Rz = $fopen("/home/pengmiao/vivado/RNN_ON_FPGA/my_test/network_after_emb/data/weight_R_z_fpb.dat", "r");
		fid_Ri = $fopen("/home/pengmiao/vivado/RNN_ON_FPGA/my_test/network_after_emb/data/weight_R_i_fpb.dat", "r");
		fid_Rf = $fopen("/home/pengmiao/vivado/RNN_ON_FPGA/my_test/network_after_emb/data/weight_R_f_fpb.dat", "r");
		fid_Ro = $fopen("/home/pengmiao/vivado/RNN_ON_FPGA/my_test/network_after_emb/data/weight_R_o_fpb.dat", "r");
		fid_bz = $fopen("/home/pengmiao/vivado/RNN_ON_FPGA/my_test/network_after_emb/data/weight_b_z_fpb.dat", "r");
		fid_bi = $fopen("/home/pengmiao/vivado/RNN_ON_FPGA/my_test/network_after_emb/data/weight_b_i_fpb.dat", "r");
		fid_bf = $fopen("/home/pengmiao/vivado/RNN_ON_FPGA/my_test/network_after_emb/data/weight_b_f_fpb.dat", "r");
		fid_bo = $fopen("/home/pengmiao/vivado/RNN_ON_FPGA/my_test/network_after_emb/data/weight_b_o_fpb.dat", "r");
		fid    = $fopen("/home/pengmiao/vivado/RNN_ON_FPGA/my_test/network_after_emb/data/output.bin", "w");
	*/
	/*
	    fid_x = $fopen("/home/pengmiao/Project/MEMSYS/my_ChampSim_Py/0501/Input_X_single.dat", "r");
		fid_Wz = $fopen("/home/pengmiao/vivado/RNN_ON_FPGA/my_test/network_after_emb/goldenIn_Wz.bin", "r");
		fid_Wi = $fopen("/home/pengmiao/vivado/RNN_ON_FPGA/my_test/network_after_emb/goldenIn_Wi.bin", "r");
		fid_Wf = $fopen("/home/pengmiao/vivado/RNN_ON_FPGA/my_test/network_after_emb/goldenIn_Wf.bin", "r");
		fid_Wo = $fopen("/home/pengmiao/vivado/RNN_ON_FPGA/my_test/network_after_emb/goldenIn_Wo.bin", "r");
		fid_Rz = $fopen("/home/pengmiao/vivado/RNN_ON_FPGA/my_test/network_after_emb/goldenIn_Rz.bin", "r");
		fid_Ri = $fopen("/home/pengmiao/vivado/RNN_ON_FPGA/my_test/network_after_emb/goldenIn_Ri.bin", "r");
		fid_Rf = $fopen("/home/pengmiao/vivado/RNN_ON_FPGA/my_test/network_after_emb/goldenIn_Rf.bin", "r");
		fid_Ro = $fopen("/home/pengmiao/vivado/RNN_ON_FPGA/my_test/network_after_emb/goldenIn_Ro.bin", "r");
		fid_bz = $fopen("/home/pengmiao/vivado/RNN_ON_FPGA/my_test/network_after_emb/goldenIn_bz.bin", "r");
		fid_bi = $fopen("/home/pengmiao/vivado/RNN_ON_FPGA/my_test/network_after_emb/goldenIn_bi.bin", "r");
		fid_bf = $fopen("/home/pengmiao/vivado/RNN_ON_FPGA/my_test/network_after_emb/goldenIn_bf.bin", "r");
		fid_bo = $fopen("/home/pengmiao/vivado/RNN_ON_FPGA/my_test/network_after_emb/goldenIn_bo.bin", "r");
		fid_Em = $fopen("/home/pengmiao/vivado/RNN_ON_FPGA/my_test/network_after_emb/goldenIn_Em.bin", "r");
	    fid_Dw = $fopen("/home/pengmiao/Project/MEMSYS/my_ChampSim_Py/0501/weight_dense_w_fpb.dat", "r");
		fid_Db = $fopen("/home/pengmiao/Project/MEMSYS/my_ChampSim_Py/0501/weight_dense_b_fpb.dat", "r");
		fid    = $fopen("/home/pengmiao/vivado/RNN_ON_FPGA/my_test/network_after_emb/output.bin", "w");
		*/
		
		// only absolute path works.
		fid_x = $fopen("/home/pengmiao/vivado/599_project/my_lstm_try6_final/data/Input_X_single.dat", "r");
		fid_Wz = $fopen("/home/pengmiao/vivado/599_project/my_lstm_try6_final/data/goldenIn_Wz.bin", "r");
		fid_Wi = $fopen("/home/pengmiao/vivado/599_project/my_lstm_try6_final/data/data/goldenIn_Wi.bin", "r");
		fid_Wf = $fopen("/home/pengmiao/vivado/599_project/my_lstm_try6_final/data/data/goldenIn_Wf.bin", "r");
		fid_Wo = $fopen("/home/pengmiao/vivado/599_project/my_lstm_try6_final/data/data/goldenIn_Wo.bin", "r");
		fid_Rz = $fopen("/home/pengmiao/vivado/599_project/my_lstm_try6_final/data/data/goldenIn_Rz.bin", "r");
		fid_Ri = $fopen("/home/pengmiao/vivado/599_project/my_lstm_try6_final/data/data/goldenIn_Ri.bin", "r");
		fid_Rf = $fopen("/home/pengmiao/vivado/599_project/my_lstm_try6_final/data/data/goldenIn_Rf.bin", "r");
		fid_Ro = $fopen("/home/pengmiao/vivado/599_project/my_lstm_try6_final/data/data/goldenIn_Ro.bin", "r");
		fid_bz = $fopen("/home/pengmiao/vivado/599_project/my_lstm_try6_final/data/data/goldenIn_bz.bin", "r");
		fid_bi = $fopen("/home/pengmiao/vivado/599_project/my_lstm_try6_final/data/data/goldenIn_bi.bin", "r");
		fid_bf = $fopen("/home/pengmiao/vivado/599_project/my_lstm_try6_final/data/data/goldenIn_bf.bin", "r");
		fid_bo = $fopen("/home/pengmiao/vivado/599_project/my_lstm_try6_final/data/data/goldenIn_bo.bin", "r");
		fid_Em = $fopen("/home/pengmiao/vivado/599_project/my_lstm_try6_final/data/data/goldenIn_Em.bin", "r");
	    fid_Dw = $fopen("/home/pengmiao/vivado/599_project/my_lstm_try6_final/data/data/weight_dense_w_fpb.dat", "r");
		fid_Db = $fopen("/home/pengmiao/vivado/599_project/my_lstm_try6_final/data/data/weight_dense_b_fpb.dat", "r");
		fid    = $fopen("/home/pengmiao/vivado/599_project/my_lstm_try6_final/data/data/output.bin", "w");
		/*
		fid_Em = $fopen("/home/pengmiao/vivado/RNN_ON_FPGA/my_test/network_after_emb/goldenIn_Em.bin", "r");
		for(i = 0; i < EM_IN; i = i + 1) begin
            for(j = 0; j < EM_DIM; j = j + 1) begin
                retVal = $fscanf(fid_Em, "%b\n", PREFETCHER.EMBEDDING_LAYER.WRAM_Em.RAM_matrix[i][j*BITWIDTH +: BITWIDTH]);
            end
        end
		
		*/

		for(i = 0; i < EM_IN; i = i + 1) begin
            for(j = 0; j < EM_DIM; j = j + 1) begin
                retVal = $fscanf(fid_Em, "%b\n", PREFETCHER.EMBEDDING_LAYER.WRAM_Em.RAM_matrix[i][j*BITWIDTH +: BITWIDTH]);
            end
        end
        /*
        for(i = 0; i < FINAL_OUT_SIZE; i = i + 1) begin//32*16 reverse to 16*32 for data fetch
            for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
                retVal = $fscanf(fid_Dw, "%b\n", PREFETCHER.DENSE_LAYER.WRAM_DENSE_W.RAM_matrix[i][j*BITWIDTH +: BITWIDTH]);
            end
        end
        */
        for(i = 0; i < FINAL_OUT_SIZE*HIDDEN_SZ; i = i + 1) begin//32*16 reverse to 16*32 for data fetch
          //  for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
                retVal = $fscanf(fid_Dw, "%b\n", PREFETCHER.W_DENSE_W[i*BITWIDTH +: BITWIDTH]);
         //   end
        end
        
        for(i = 0; i < FINAL_OUT_SIZE; i = i + 1) begin
			retVal = $fscanf(fid_Db, "%18b\n",PREFETCHER.W_DENSE_B[i*BITWIDTH +: BITWIDTH]);
	    end



		
		// -------------------------------- Loading the weight memory ------------------------------- //
		
		
		for(i = 0; i < INPUT_SZ; i = i + 1) begin
            for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
                retVal = $fscanf(fid_Wz, "%b\n", PREFETCHER.LSTM_LAYER.WRAM_Z_X.RAM_matrix[i][j*BITWIDTH +: BITWIDTH]);
            end
        end
        
        for(i = 0; i < HIDDEN_SZ; i = i + 1) begin
            for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
                retVal = $fscanf(fid_Rz, "%b\n", PREFETCHER.LSTM_LAYER.WRAM_Z_Y.RAM_matrix[i][j*BITWIDTH +: BITWIDTH]);
            end
        end
        
        for(i = 0; i < INPUT_SZ; i = i + 1) begin
            for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
                retVal = $fscanf(fid_Wi, "%b\n", PREFETCHER.LSTM_LAYER.WRAM_I_X.RAM_matrix[i][j*BITWIDTH +: BITWIDTH]);
            end
        end
        
        for(i = 0; i < HIDDEN_SZ; i = i + 1) begin
            for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
                retVal = $fscanf(fid_Ri, "%b\n", PREFETCHER.LSTM_LAYER.WRAM_I_Y.RAM_matrix[i][j*BITWIDTH +: BITWIDTH]);
            end
        end
        
        for(i = 0; i < INPUT_SZ; i = i + 1) begin
            for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
                retVal = $fscanf(fid_Wf, "%b\n", PREFETCHER.LSTM_LAYER.WRAM_F_X.RAM_matrix[i][j*BITWIDTH +: BITWIDTH]);
            end
        end
        
        for(i = 0; i < HIDDEN_SZ; i = i + 1) begin
            for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
                retVal = $fscanf(fid_Rf, "%b\n", PREFETCHER.LSTM_LAYER.WRAM_F_Y.RAM_matrix[i][j*BITWIDTH +: BITWIDTH]);
            end
        end
        
        for(i = 0; i < INPUT_SZ; i = i + 1) begin
            for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
                retVal = $fscanf(fid_Wo, "%b\n", PREFETCHER.LSTM_LAYER.WRAM_O_X.RAM_matrix[i][j*BITWIDTH +: BITWIDTH]);
            end
        end
        
        for(i = 0; i < HIDDEN_SZ; i = i + 1) begin
            for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
                retVal = $fscanf(fid_Ro, "%b\n", PREFETCHER.LSTM_LAYER.WRAM_O_Y.RAM_matrix[i][j*BITWIDTH +: BITWIDTH]);
            end
        end
        
        for(i = 0; i < HIDDEN_SZ; i = i + 1) begin
			retVal = $fscanf(fid_bz, "%18b\n",temp);
			PREFETCHER.LSTM_LAYER.bZ[i*BITWIDTH +: BITWIDTH] = temp;
			
			retVal = $fscanf(fid_bi, "%18b\n",temp);
			PREFETCHER.LSTM_LAYER.bI[i*BITWIDTH +: BITWIDTH] = temp;
			
			retVal = $fscanf(fid_bf, "%18b\n",temp);
			PREFETCHER.LSTM_LAYER.bF[i*BITWIDTH +: BITWIDTH] = temp;
			
			retVal = $fscanf(fid_bo, "%18b\n",temp);
			PREFETCHER.LSTM_LAYER.bO[i*BITWIDTH +: BITWIDTH] = temp;
        end
		
	end
	
    // Running the simulation
    initial begin
        time_start = $realtime;
		clock = 0;
		newSample = 0;
		
		// Applying the initial reset
		reset     = 1'b1;
		#(2*FULL_CLOCK);
		reset     = 1'b0;

		// ----------------------------------------------------------------------------------------- //

        $display("Simulation started at %f", time_start);

		for(k=0; k < TRAIN_SAMPLES; k = k + 1) begin
			
			// Applying the initial reset
			reset     = 1'b1;
			#(2*FULL_CLOCK);
			reset     = 1'b0;
			
			if(k % 100 == 0) begin
				$display("Input Sample %d", k);
			end
			
			for(i=0; i < MAX_SAMPLES; i = i + 1) begin
				
				// ---------- Applying a new input signal ---------- //
				
				@(posedge clock);
				retVal = $fscanf(fid_x,  "%b\n", temp);
				inputVec[RAW_INPUT_BIT-1 : 0]  = temp;
				$display("Read: %b", inputVec);
				/*
				for(m=0; m< INPUT_SZ; m = m + 1)begin
				    retVal = $fscanf(fid_x,  "%b\n", temp);
				    inputVec[m*BITWIDTH +: BITWIDTH]  = temp;
				end
				$display("Read: %b and %b", inputVec[17:0], inputVec[35:18]);
				$display("Read_last: %b and %b", inputVec[18*10-1:18*9], inputVec[18*9-1:18*8]);
				//inputVec=34876125;
				*/
				newSample = 1'b1;
				#(FULL_CLOCK);
				newSample = 1'b0;
				
				// ------------------------------------------------- //
				
				// Waiting for the result
				@(posedge dataReady);
				
				#(2*FULL_CLOCK);
				
				for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
					//$display("Neuron[%0d]: %b", j, outputVec[j*BITWIDTH +: BITWIDTH]);
					$fwrite(fid, "%d\n", outputVec[j*BITWIDTH +: BITWIDTH]);
				end
				
				if(i==(MAX_SAMPLES-2))
				    dense_enable=1;
			end
			#(6*FULL_CLOCK);
			dense_enable=0;
			PREFETCHER.DENSE_LAYER.dense_enable_innter=0;
       end
        //$display("Average Quantization Error: %f", quantError/(MAX_SAMPLES*HIDDEN_SZ));
 
        $stop; 
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
            
    
       