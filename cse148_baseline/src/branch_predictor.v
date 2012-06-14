/*=============================================================================
 * File:    branch_predictor.v
 * Author:  Kevin Huynh
 *
 * Version  Date        Comment
 * ----------------------------------------------------------------------------
 *   1.0    05/24/12    Initial design.
 *
 * Description:
 *   The branch predictor predicts whether a branch shall be taken or not 
 *   taken during the DECODE stage. This helps eliminate any pipeline bubbles 
 *   and reduce branch mispredicts by employing a dynamic prediction method 
 *   (g-share). The module itself simply instantiates the two components of a
 *   typical g-share predictor: 1) the global history register (GHR) and 
 *   2) the table of 2-bit predictors (counter table); it contains no other
 *   logic.
 =============================================================================*/
module branch_predictor #(parameter BPRED_WIDTH)
(
    input i_Reset_n,
    input i_ALU_Branch_Valid,                       // branch instruction is currently at the EX stage
    input i_DEC_Is_Branch,                          // branch instruction is currently at the DEC stage
    input [BPRED_WIDTH-1:0] i_Resolution_Index,     // index of counter to be updated by branch resolutions
    input i_ALU_Branch_Outcome,                     // branch resolution
    input [BPRED_WIDTH-1:0] i_PC,                   // lower address bits of the PC

    output [BPRED_WIDTH-1:0] o_Resolution_Index,    // index of counter that shall be updated by branch resolutions
    output o_Prediction                             // branch prediction
);

/*===========
 * INTERNAL
 ===========*/
wire BP_i_Prediction;                               // feedback signal to update GHR with branch resolution
wire [BPRED_WIDTH-1:0] BP_i_Index;                  // counter index for branch predictions
wire [BPRED_WIDTH-1:0] BP_o_Global_History;         // GHR output

/*========================
 * HARDWIRED ASSIGNMENTS
 ========================*/
assign BP_i_Index = BP_o_Global_History ^ i_PC;
assign o_Resolution_Index = BP_i_Index;
assign o_Prediction = BP_i_Prediction;

/*====================
 * INTERNAL HARDWARE
 ====================*/
global_history_reg #(.BPRED_WIDTH(BPRED_WIDTH))
    GHR
    (
        .i_Reset_n(i_Reset_n),
        .i_ALU_Branch_Valid(i_ALU_Branch_Valid),
        .i_DEC_Is_Branch(i_DEC_Is_Branch),
        .i_Prediction(BP_i_Prediction),
        .i_ALU_Branch_Outcome(i_ALU_Branch_Outcome),
        .o_Global_History(BP_o_Global_History)
    );
    
counter_table #(.BPRED_WIDTH(BPRED_WIDTH))
    COUNT_TABLE
    (
        .i_Reset_n(i_Reset_n),
        .i_ALU_Branch_Valid(i_ALU_Branch_Valid),
        .i_Resolution_Index(i_Resolution_Index),
        .i_ALU_Branch_Outcome(i_ALU_Branch_Outcome),
        .i_Index(BP_i_Index),
        .o_Prediction(BP_i_Prediction)
    );

endmodule
