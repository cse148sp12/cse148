/*=============================================================================
 * File:    counter_table.v
 * Author:  Ben Fiola
 *          Kevin Huynh
 *
 * Version  Date        Comment
 * ----------------------------------------------------------------------------
 *   1.1    05/01/12    Added & cleaned-up comments. Changed implementation to
 *                      4-state FSM.
 *   1.0    04/26/12    Initial design.
 *
 * Description:
 *   The counter table is a 2^n size table of 2-bit predictors, indexed by the
 *   n lower order bits of the branch address XOR'd with the GHR (n bits 
 *   wide).
 =============================================================================*/
module counter_table #(parameter BPRED_WIDTH)
(
	input i_Clk,
    input i_Enable,                     // enables state change
	input i_Reset,
	
	input [BPRED_WIDTH-1:0] i_Index,    // index to select counter
	input i_ALU_Branch_Outcome,         // branch resolution
	
	output o_Prediction                 // branch prediction
);

/*============
 * VARIABLES
 ============*/
localparam STRONGLY_NOT_TAKEN = 2'b00;
localparam WEAKLY_NOT_TAKEN   = 2'b01;
localparam WEAKLY_TAKEN       = 2'b10;
localparam STRONGLY_TAKEN     = 2'b11;

localparam TABLE_SIZE = 1 << BPRED_WIDTH;   // 2^BPRED_WIDTH rows

integer i;  // loop iterator

/*===========
 * INTERNAL
 ===========*/
reg [1:0] counter_table [TABLE_SIZE-1:0];   // internal counter table

/*========================
 * HARDWIRED ASSIGNMENTS
 ========================*/
assign o_Prediction = counter_table[i_Index][1];

/*======================
 * COMBINATORIAL LOGIC
 ======================*/
always@(posedge i_Clk or negedge i_Reset)
begin
    // active-lo reset
    if (!i_Reset)
        // set all counters to weakly taken
        for (i = 0; i < TABLE_SIZE; i = i + 1)
            counter_table[i] <= WEAKLY_TAKEN;
    // update counter table
    else if (i_Enable)
    begin
        // 2-bit predictor state machine
        case (counter_table[i_Index])
            STRONGLY_NOT_TAKEN: counter_table[i_Index] <= i_ALU_Branch_Outcome ? WEAKLY_NOT_TAKEN : STRONGLY_NOT_TAKEN;
            WEAKLY_NOT_TAKEN:   counter_table[i_Index] <= i_ALU_Branch_Outcome ? WEAKLY_TAKEN     : STRONGLY_NOT_TAKEN;
            WEAKLY_TAKEN:       counter_table[i_Index] <= i_ALU_Branch_Outcome ? STRONGLY_TAKEN   : WEAKLY_NOT_TAKEN;
            STRONGLY_TAKEN:     counter_table[i_Index] <= i_ALU_Branch_Outcome ? STRONGLY_TAKEN   : WEAKLY_TAKEN;
            default:
                ;   // do nothing
        endcase
    end
end
endmodule
