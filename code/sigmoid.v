module sigmoid  #(parameter QN = 6,
                  parameter QM = 11) 
                 (input signed  [QN+QM:0] operand,
                  input                 clock,
                  input                 reset,
                  output reg signed [QN+QM:0] result);
   
    parameter BITWIDTH = QN + QM + 1;

    // The polynomial coefficients. FORMAT: pn_ix, where n is the degree of the associated x term, and x is the corresponding interval 
    reg signed [QN+QM:0] p0_i1 = 18'b000000000110100000;
    reg signed [QN+QM:0] p1_i1 = 18'b000000000010010011;
    reg signed [QN+QM:0] p2_i1 = 18'b000000000000001101;
    reg signed [QN+QM:0] p0_i2 = 18'b000000010000000100;    
    reg signed [QN+QM:0] p1_i2 = 18'b000000001000101110;
    reg signed [QN+QM:0] p2_i2 = 18'b000000000001010011;
    reg signed [QN+QM:0] p0_i3 = 18'b000000001111111100;
    reg signed [QN+QM:0] p1_i3 = 18'b000000001000101110;
    reg signed [QN+QM:0] p2_i3 = 18'b111111111110101101;
    reg signed [QN+QM:0] p0_i4 = 18'b000000011001100000;
    reg signed [QN+QM:0] p1_i4 = 18'b000000000010010011;
    reg signed [QN+QM:0] p2_i4 = 18'b111111111111110011;

    reg signed [QN+QM:0] p2;
    reg signed [QN+QM:0] p1;
    reg signed [QN+QM:0] p0;

    // The state register
    reg state;
    reg signed [2*BITWIDTH:0] outputMAC;
    reg signed [BITWIDTH-1:0] multiplierMux;
    reg signed [BITWIDTH-1:0] adderMux;
    //reg signed [BITWIDTH-1:0] result;
    reg interval_mux_active;

	reg [2:0] STATE;
	reg [2:0] NEXT_STATE;
	parameter IDLE            = 3'd0;
	parameter INTERVAL_CHOICE = 3'd1;
	parameter COEF_CHOICE     = 3'd2;
	parameter MAC1 = 3'd3;
	parameter MAC2 = 3'd4;
	parameter END  = 3'd5;

    // Interval selector logic
    always @(*) begin
		if(reset) begin
			p2 <= 18'd0;
			p1 <= 18'd0;
			p0 <= 18'd0;
		end
		else begin
			if (operand < $signed(18'b111101000000000000)) begin
				p2 <= 18'd0;  
				p1 <= 18'd0;   
				p0 <= 18'd0;   
			end
			else if (operand < $signed(18'b111110100000000000)) begin
				p2 <= p2_i1;
				p1 <= p1_i1;
				p0 <= p0_i1;
			end
			else if (operand < $signed(18'd0)) begin
				p2 <= p2_i2;
				p1 <= p1_i2;
				p0 <= p0_i2;
			end
			else if (operand < $signed(18'b000001100000000000)) begin
				p2 <= p2_i3;
				p1 <= p1_i3;
				p0 <= p0_i3;
			end
			else if (operand < $signed(18'b000011000000000000)) begin
				p2 <= p2_i4;
				p1 <= p1_i4;
				p0 <= p0_i4;
			end
			else begin
				p2 <= 18'd0;
				p1 <= 18'd0;
				p0 <= 18'b000000100000000000;
			end
		end
    end

    // The coefficient multiplier input Muxes
    always @(posedge clock) begin
        if(reset) begin
            multiplierMux <= 18'd0;
            adderMux      <= 18'd0;
        end
        else begin
            if (state == 1'b0) begin
                multiplierMux <= p2;
                adderMux <= p1;
            end
            else begin
                multiplierMux <= result;
                adderMux <= p0;
            end
        end
    end
    
    always @(posedge clock) begin
		if(reset) begin
			outputMAC <= 37'b0;
			//resultP   <= 18'd0;
		end 
		else begin
			outputMAC <= operand*multiplierMux;
			//resultP   <= result;
		end
	end
	
	always @(*) begin
		result = (outputMAC >>> QM) + adderMux;
	end
    
    
    // --- Finite State Machine --- //
    always @(posedge clock) begin
		if(reset) begin
			STATE <= IDLE;
		end
		else begin
			STATE <= NEXT_STATE;
		end
	end
	
	always @(*) begin
		case(STATE)
		
		IDLE:
		begin
			interval_mux_active = 1;
			state =0;

		end
		
		INTERVAL_CHOICE:
		begin
			interval_mux_active = 1;
			state =0;

		end
		
		COEF_CHOICE:
		begin
			interval_mux_active = 0;
			state =0;

		end
		
		MAC1:
		begin
			interval_mux_active = 0;
			state = 1;

		end
		
		MAC2:
		begin
			interval_mux_active = 0;
			state = 1;

		end	
		
		END:
		begin
			interval_mux_active = 0;
			state = 1;

		end
		
		default:
		begin
			interval_mux_active = 0;
			state = 0;

		end
		endcase
	end
	
	always @(*) begin
		case(STATE)
		
		IDLE:
		begin
			NEXT_STATE = INTERVAL_CHOICE;
		end
		
		INTERVAL_CHOICE:
		begin
			NEXT_STATE = COEF_CHOICE;
		end
		
		COEF_CHOICE:
		begin
			NEXT_STATE = MAC1;
		end
		
		MAC1:
		begin
			NEXT_STATE = MAC2;
		end
		
		MAC2:
		begin
			NEXT_STATE = END;
		end	
		
		END:
		begin
			NEXT_STATE = IDLE;
		end
		
		default:
		begin
			NEXT_STATE = IDLE;
		end
		
		endcase
	end		
	

endmodule
