module WRAM (
		input  wire [287:0] data,    //    data.datain
		output wire [287:0] q,       //       q.dataout
		input  wire [3:0]   address, // address.address
		input  wire         wren,    //    wren.wren
		input  wire         clock    //   clock.clk
	);
endmodule

