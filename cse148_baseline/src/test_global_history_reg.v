/*=============================================================================
 * File:    test_global_history_reg.v
 * Author:  Kevin Huynh
 * 
 * Version  Date        Comment
 * ----------------------------------------------------------------------------
 *   1.2    05/24/12    Changed testbench from clocked to edge-triggered.
 *   1.1    05/03/12    Automated testbench.
 *   1.0    04/30/12    Initial design.
 *
 * Description:
 *   Simulation level module that tests the GHR for logical correctness. This 
 *   module tests the functionality of the GHR's asynchronous reset; insertion
 *   of the branch prediction bit into the GHR when a branch instruction 
 *   reaches the DEC stage; and updating the GHR when a branch is resolved
 *   (in the EX stage).
 =============================================================================*/
`timescale 1ns/1ps
module test_global_history_reg();

localparam BPRED_WIDTH = 9;
localparam HI = 1'b1;
localparam LO = 1'b0;
localparam TRUE = 1'b1;
localparam FALSE = 1'b0;
localparam TAKEN = 1'b1;
localparam NOT_TAKEN = 1'b0;

reg Reset_n;

reg ALU_o_Branch_Valid;   // instruction at EX stage is a branch
reg DEC_o_Is_Branch;      // instruction at DEC stage is a branch
reg BP_i_Prediction;      // branch prediction given by counter table
reg ALU_o_Branch_Outcome; // branch resolution

wire [BPRED_WIDTH-1:0] BP_o_Global_History;    // GHR output

integer errors;

// UUT - Unit Under Test
global_history_reg #(.BPRED_WIDTH(BPRED_WIDTH)) UUT
(
	.i_Reset_n(Reset_n),
	
	.i_ALU_Branch_Valid(ALU_o_Branch_Valid),        // instruction at EX stage is a branch
	.i_DEC_Is_Branch(DEC_o_Is_Branch),              // instruction at DEC stage is a branch
	.i_Prediction(BP_i_Prediction),                 // branch prediction given by counter table
	.i_ALU_Branch_Outcome(ALU_o_Branch_Outcome),    // branch resolution
	
	.o_Global_History(BP_o_Global_History)          // GHR output
);			

/*=============
 * TEST BENCH
 =============*/
initial  
begin
    $display("=========================================");
    $display(" BEGIN BP - COUNTER TABLE TEST           ");
    $display("=========================================");
    
    errors <= 0;

    /*===============
     * TEST 1: RESET
     ================*/
    #1
	Reset_n <= LO;                      // reset
    ALU_o_Branch_Valid <= FALSE;
    DEC_o_Is_Branch <= FALSE;
    BP_i_Prediction <= 1'bx;
    ALU_o_Branch_Outcome <= 1'bx;
    
    #1
    $display("");
    $display("-----------------------------------------");
    $display(" TEST 1: RESET                           ");
    $display("-----------------------------------------");
    $display("BP_o_Global_History[0]");
    $display("\texpected: 1");
    $display("\tactual:   %d", BP_o_Global_History[0]);
    
    if (BP_o_Global_History[0] == TAKEN)
        $display("result: passed.");
    else
    begin
        $display("result: FAILED. BP_o_Global_History[0] does not match expected value.");
        errors <= errors + 1;
    end
	
	/*==========================================
     * TEST 2: BRANCH PREDICTION BIT INSERTION
     ==========================================*/
    #1
    Reset_n <= HI;                      // disable reset
    ALU_o_Branch_Valid <= FALSE;        // no branch in EX stage
    DEC_o_Is_Branch <= TRUE;            // branch in DEC stage
    BP_i_Prediction <= NOT_TAKEN;       // predict not taken
    ALU_o_Branch_Outcome <= 1'bx;       // ignore branch resolution
    
    #1
    $display("");
    $display("-----------------------------------------");
    $display(" TEST 2: BRANCH PREDICTION BIT INSERTION ");
    $display("-----------------------------------------");
    $display("BP_o_Global_History[0]");
    $display("\texpected: 0");
    $display("\tactual:   %d", BP_o_Global_History[0]);
    
    if (BP_o_Global_History[0] == NOT_TAKEN)
        $display("result: passed.");
    else
    begin
        $display("result: FAILED. BP_o_Global_History[0] does not match expected value.");
        errors <= errors + 1;
    end
    
    DEC_o_Is_Branch <= FALSE;           // pull low for next test

	/*===================================
     * TEST 3: BRANCH RESOLUTION UPDATE
     ===================================*/
    #1
    ALU_o_Branch_Valid <= TRUE;         // branch in EX stage
    DEC_o_Is_Branch <= FALSE;           // no branch in DEC stage
    BP_i_Prediction <= 1'bx;            // ignore prediction
    ALU_o_Branch_Outcome <= TAKEN;      // taken
    
    #1
    $display("");
    $display("-----------------------------------------");
    $display(" TEST 3: BRANCH RESOLUTION UPDATE        ");
    $display("-----------------------------------------");
    $display("BP_o_Global_History[0]");
    $display("\texpected: 1");
    $display("\tactual:   %d", BP_o_Global_History[0]);
    
    if (BP_o_Global_History[0] == TAKEN)
        $display("result: passed.");
    else
    begin
        $display("result: FAILED. BP_o_Global_History[0] does not match expected value.");
        errors <= errors + 1;
    end
    
    DEC_o_Is_Branch <= FALSE;           // pull low for next test
        
    /*=================
     * END TEST BENCH
     =================*/
    #1
    $display("");
    $display("=========================================");
    $display(" END BP - GLOBAL HISTORY REGISTER TEST   ");
    $display(" errors: %d", errors);
    $display("=========================================");

    $stop;
end 

endmodule
