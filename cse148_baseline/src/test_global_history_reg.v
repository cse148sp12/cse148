/*=============================================================================
 * File:    test_global_history_reg.v
 * Author:  Kevin Huynh
 * 
 * Version  Date        Comment
 * ----------------------------------------------------------------------------
 *   1.0    04/30/12    Initial design.
 *
 * Description:
 *   Simulation level module that tests the GHR for logical correctness. This 
 *   module tests the functionality of the GHR's asynchronous reset; insertion
 *   of the branch prediction bit into the GHR when a branch instruction 
 *   reaches the DEC stage; updating the GHR when a branch is resolved (in the 
 *   EX stage); and simultaneously updaing the GHR when a branch is resolved 
 *   and insertion of the branch prediction bit into the GHR when another 
 *   branch instruction reaches the DEC stage.
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

reg clk;
reg Reset_n;

reg ALU_o_Branch_Valid;   // instruction at EX stage is a branch
reg DEC_o_Is_Branch;      // instruction at DEC stage is a branch
reg i_Prediction;         // branch prediction given by counter table
reg i_ALU_Branch_Outcome; // branch resolution

wire [BPRED_WIDTH-1:0] Global_History;    // GHR output

integer k;

// UUT - Unit Under Test
global_history_reg #(.BPRED_WIDTH(BPRED_WIDTH)) UUT
(
    .i_Clk(clk),
	.i_Reset(Reset_n),
    
	// inputs
	.i_ALU_Branch_Valid(ALU_o_Branch_Valid),
	.i_DEC_Is_Branch(DEC_o_Is_Branch),
	.i_Prediction(i_Prediction),
	.i_ALU_Branch_Outcome(i_ALU_Branch_Outcome),
    
	// outputs
	.o_Global_History(Global_History)
);			

/*==================
 * CLOCK GENERATOR
 ==================*/
always
begin
	#5
	clk = HI;
	#5
	clk = LO;
end

/*=============
 * TEST BENCH
 =============*/
initial  
begin
    /*===============
     * TEST 1: RESET
     ================*/
	Reset_n = LO;                                   // reset
	for (k = 0; k < 2; k = k + 1) @(posedge clk);   // idle 2 cycles
	Reset_n = HI;                                   // enable
    
	for (k = 0; k < 2; k = k + 1) @(posedge clk);   // idle 2 cycles
	
	/*==========================================
     * TEST 2: BRANCH PREDICTION BIT INSERTION
     ==========================================*/
    @(posedge clk)
    begin
        ALU_o_Branch_Valid = FALSE;                 // no branch in EX stage
        DEC_o_Is_Branch = TRUE;                     // branch in DEC stage
        i_Prediction = NOT_TAKEN;                   // predict not taken
        i_ALU_Branch_Outcome = 1'bx;                // ignore branch resolution
    end
    
    // "pass" branch instruction through pipeline
	@(posedge clk)
    begin
        ALU_o_Branch_Valid = FALSE;                 
        DEC_o_Is_Branch = FALSE;                 
    end
    
    for (k = 0; k < 2; k = k + 1) @(posedge clk);   // idle 2 cycles

	/*===================================
     * TEST 3: BRANCH RESOLUTION UPDATE
     ===================================*/
    @(posedge clk)
    begin
        ALU_o_Branch_Valid = TRUE;                  // branch in EX stage
        DEC_o_Is_Branch = FALSE;                    // no branch in DEC stage
        i_Prediction = 1'bx;                        // ignore prediction
        i_ALU_Branch_Outcome = TAKEN;               // taken
    end
    
    // "pass" branch instruction through pipeline
	@(posedge clk)
    begin
        ALU_o_Branch_Valid = FALSE;                 
        DEC_o_Is_Branch = FALSE;                 
    end
    
    for (k = 0; k < 2; k = k + 1) @(posedge clk);   // idle 2 cycles
    
    /*=================================
     * TEST 4: TWO BRANCHES IN FLIGHT
     =================================*/
    @(posedge clk)
    begin
        ALU_o_Branch_Valid = FALSE;                 // no branch in EX stage
        DEC_o_Is_Branch = TRUE;                     // branch in DEC stage
        i_Prediction = NOT_TAKEN;                   // predict not taken
        i_ALU_Branch_Outcome = 1'bx;                // ignore branch resolution
    end
    
    // "pass" branch instruction through pipeline
	@(posedge clk)
    begin
        ALU_o_Branch_Valid = FALSE;                 
        DEC_o_Is_Branch = FALSE;                 
    end
    
	ALU_o_Branch_Valid = TRUE;                      // branch in EX stage
	DEC_o_Is_Branch = TRUE;                         // branch in DEC stage
    i_Prediction = TAKEN;                       // predict not taken
    i_ALU_Branch_Outcome = TAKEN;                   // taken
    
    // "pass" branch instruction through pipeline
	@(posedge clk)
    begin
        ALU_o_Branch_Valid = FALSE;                 
        DEC_o_Is_Branch = FALSE;                 
    end
    
    for (k = 0; k < 2; k = k + 1) @(posedge clk);   // idle 2 cycles
    
    $stop;
    
/*=================
 * END TEST BENCH
 =================*/
 
end 
endmodule
