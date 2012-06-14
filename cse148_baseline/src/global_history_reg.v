/*=============================================================================
 * File:    global_history_reg.v
 * Author:  Ben Fiola
 *          Kevin Huynh
 *
 * Version  Date        Comment
 * ----------------------------------------------------------------------------
 *   1.3    05/23/12    Changed implementation from clocked to edge-triggered.
 *   1.2    05/03/12    Fixed GHR update bug when shifting.
 *   1.1    04/30/12    Added & cleaned-up comments. Re-implemented GHR as a
 *                      left-shift shift register.
 *   1.0    04/26/12    Initial design.
 *
 * Description:
 *   The global history register (GHR) stores the last n branch predictions.
 *   When a branch enters the DEC pipeline stage, the GHR shifts the branch 
 *   prediction in. When the branch is resolved one cycle later in the EX 
 *   stage, the GHR is updated with the actual branch outcome. 
 =============================================================================*/
module global_history_reg #(parameter BPRED_WIDTH)
(
	input i_Reset_n,
	
	input i_ALU_Branch_Valid,   // instruction at EX stage is a branch
	input i_DEC_Is_Branch,      // instruction at DEC stage is a branch
	input i_Prediction,         // branch prediction given by counter table
	input i_ALU_Branch_Outcome, // branch resolution
	
	output [BPRED_WIDTH-1:0] o_Global_History   // GHR output
);

/*===========
 * INTERNAL
 ===========*/
 reg [BPRED_WIDTH-1:0] Global_History;

/*========================
 * HARDWIRED ASSIGNMENTS
 ========================*/
 assign o_Global_History = Global_History;

/*=======================
 * EDGE-TRIGGERED LOGIC
 =======================*/
always@(posedge i_DEC_Is_Branch or posedge i_ALU_Branch_Valid or negedge i_Reset_n)
begin
    // async active-lo reset
    if (!i_Reset_n)
    begin	
        // assume taken as default
        Global_History <= {BPRED_WIDTH{1'b1}};
    end
    else
    begin
        // if branch is in DEC stage
        if (i_DEC_Is_Branch)
            // shift GHR to the left [to store speculative bit]
            Global_History <= Global_History << 1;
    
        // if branch is resolved, update GHR; else predict next branch outcome
        Global_History[0] <= i_ALU_Branch_Valid ? i_ALU_Branch_Outcome : i_Prediction;
    end	
end

endmodule
			
	


	