/*=============================================================================
 * File:    global_history_reg.v
 * Author:  Ben Fiola
 *          Kevin Huynh
 *
 * Version  Date        Comment
 * ----------------------------------------------------------------------------
 *   1.2    05/03/12    Fixed GHR update bug when shifting.
 *   1.1    04/30/12    Added & cleaned-up comments. Re-implemented GHR as a
 *                      left-shift shift register.
 *   1.0    04/26/12    Initial design.
 *
 * Description:
 *   The global history register (GHR) stores the last n branch predictions.
 *   When a branch enters the DEC pipeline stage, the GHR shifts the branch 
 *   prediction in. When the branch is resolved one cycle later in the EX 
 *   stage, the GHR is updated with the actual branch outcome. Writes are 
 *   synchronous while reads are asynchronous (in write first read later 
 *   fashion0 to circumvent branch hazards when executing sequential branch
 *   instructions.
 =============================================================================*/
module global_history_reg #(parameter BPRED_WIDTH)
(
	input i_Clk,
	input i_Reset,
	
	input i_ALU_Branch_Valid,   // instruction at EX stage is a branch
	input i_DEC_Is_Branch,      // instruction at DEC stage is a branch
	input i_Prediction,         // branch prediction given by counter table
	input i_ALU_Branch_Outcome, // branch resolution
	
	output [BPRED_WIDTH-1:0] o_Global_History   // GHR output
);

    /*===========
     * INTERNAL 
     ===========*/
	reg [BPRED_WIDTH-1:0] Global_History;       // internal GHR
    
    /*========================
     * HARDWIRED ASSIGNMENTS
     ========================*/
    assign o_Global_History = Global_History;   // async readout

    /*====================
     * SYNCHRONOUS LOGIC
     ====================*/
	always@(posedge i_Clk or negedge i_Reset)
	begin
        // async active-lo reset
		if(! i_Reset)
		begin	
            // assume taken as default
			Global_History <= {BPRED_WIDTH{1'b1}};
		end
		else
		begin
            // if a branch is in DEC stage
			if(i_DEC_Is_Branch)
			begin	
                // shift in prediction bit from counter table
				Global_History <= Global_History << 1;
				Global_History[0] <= i_Prediction;
                
                // update GHR with branch resolution
                if(i_ALU_Branch_Valid)
                    Global_History[1] <= i_ALU_Branch_Outcome;    
			end
            // if a branch is in EX stage
			if(i_ALU_Branch_Valid)
			begin
                // update GHR with branch resolution
				Global_History[0] <= i_ALU_Branch_Outcome;
			end
		end	
	end
endmodule
			
	


	