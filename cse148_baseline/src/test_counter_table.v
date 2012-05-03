/*=============================================================================
 * File:    test_counter_table.v
 * Author:  Kevin Huynh
 * 
 * Version  Date        Comment
 * ----------------------------------------------------------------------------
 *   1.0    05/02/12    Initial design.
 *
 * Description:
 *   Simulation level module that tests the counter table for logical 
 *   correctness. This module tests the functionality of the counter table's
 *   reset, enable, and the transition of each of the four counter states.
 =============================================================================*/
`timescale 1ns/1ps
module test_counter_table();

localparam BPRED_WIDTH = 9;
localparam HI = 1'b1;
localparam LO = 1'b0;
localparam TRUE = 1'b1;
localparam FALSE = 1'b0;
localparam TAKEN = 1'b1;
localparam NOT_TAKEN = 1'b0;

reg clk;
reg BP_i_Enable;                    // enables state change
reg Reset_n;

reg [BPRED_WIDTH-1:0] BP_i_Index;   // index to select counter
reg ALU_o_Branch_Outcome;           // branch resolution

wire BP_o_Prediction;               // branch prediction

integer k;

// UUT - Unit Under Test
counter_table #(.BPRED_WIDTH(BPRED_WIDTH)) UUT
(
    .i_Clk(clk),
    .i_Enable(BP_i_Enable),
	.i_Reset(Reset_n),
    
	// inputs
	.i_Index(BP_i_Index),
	.i_ALU_Branch_Outcome(ALU_o_Branch_Outcome),
    
	// outputs
	.o_Prediction(BP_o_Prediction)
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
    $display("\n===============================");
    $display("\n BEGIN BP - COUNTER TABLE TEST ");
    $display("\n===============================");
    $display("\n");

    /*===============
     * TEST 1: RESET
     ================*/
	Reset_n = LO;                                   // reset
	for (k = 0; k < 2; k = k + 1) @(posedge clk);   // idle 2 cycles
	Reset_n = HI;                                   // enable
    
	for (k = 0; k < 2; k = k + 1) @(posedge clk);   // idle 2 cycles
    
    $display("\n-------------------------------");
    $display("\n TEST 1: RESET                 ");
    $display("\n-------------------------------");
    $display("\n");
    $display("\nBP_o_Prediction");
    $display("\n\texpected: 1");
    $display("\n\tactual:   %d", BP_o_Prediction);
    $display("\n");
    $display("\nresult: ");
    
    if (BP_o_Prediction == TAKEN)
        $display("passed.");
    else
        $display("FAILED. BP_o_Prediction does not match expected value.");
	
	/*=================
     * TEST 2: ENABLE
     =================*/
    @(posedge clk)
    begin
        BP_i_Enable = LO;                           // disable
        BP_i_Index = 0;                             // select counter 0
        ALU_o_Branch_Outcome = 0;                   // move state to weakly not taken
    end
    
    // "pass" branch instruction through pipeline
	@(posedge clk)
    begin
        BP_i_Enable = LO;                
    end
    
    $display("")
    
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
    i_Prediction = TAKEN;                           // predict not taken
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
