/*=============================================================================
 * File:    test_counter_table.v
 * Author:  Kevin Huynh
 * 
 * Version  Date        Comment
 * ----------------------------------------------------------------------------
 *   1.1    05/08/12    Changed testbench from clocked to edge-triggered.
 *   1.0    05/03/12    Initial design.
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
integer errors;

// UUT - Unit Under Test
counter_table #(.BPRED_WIDTH(BPRED_WIDTH)) UUT
(
    .i_Enable(BP_i_Enable),
	.i_Reset(Reset_n),
    
	// inputs
	.i_Index(BP_i_Index),
	.i_ALU_Branch_Outcome(ALU_o_Branch_Outcome),
    
	// outputs
	.o_Prediction(BP_o_Prediction)
);			

/*=============
 * TEST BENCH
 =============*/
initial  
begin
    $display("===============================");
    $display(" BEGIN BP - COUNTER TABLE TEST ");
    $display("===============================");
    
    errors <= 0;

    /*================
     * TEST 1: RESET
     ================*/
    #1
    BP_i_Enable <= LO;
	Reset_n <= LO;
    BP_i_Index <= 0;
    ALU_o_Branch_Outcome <= 0;
    
    #1
    $display("");
    $display("-------------------------------");
    $display(" TEST 1: RESET                 ");
    $display("-------------------------------");
    $display("BP_o_Prediction");
    $display("\texpected: 1");
    $display("\tactual:   %d", BP_o_Prediction);
    
    if (BP_o_Prediction == TAKEN)
        $display("result: passed.");
    else
    begin
        $display("result: FAILED. BP_o_Prediction does not match expected value.");
        errors <= errors + 1;
    end
	
	/*=================
     * TEST 2: ENABLE
     =================*/
    #1
    BP_i_Enable <= LO;                           // disable table
    Reset_n <= HI;                               // disable reset
    BP_i_Index <= 0;                             // select counter 0
    ALU_o_Branch_Outcome <= 0;                   // move state to weakly not taken
    
    #1
    $display("");
    $display("-------------------------------");
    $display(" TEST 2: ENABLE                ");
    $display("-------------------------------");
    $display("BP_o_Prediction");
    $display("\texpected: 1");
    $display("\tactual:   %d", BP_o_Prediction);
    
    if (BP_o_Prediction == TAKEN)
        $display("result: passed.");
    else
    begin
        $display("result: FAILED. BP_o_Prediction does not match expected value.");
        errors <= errors + 1;
    end

	/*===================================
     * TEST 3A: STATE TRANSITIONS
     ===================================*/
    
    #1
    BP_i_Enable <= HI;                          // enable
    BP_i_Index <= 0;                            // select counter 0
    ALU_o_Branch_Outcome <= 0;                  // move state to weakly not taken
    
    #1
    $display("");
    $display("-------------------------------");
    $display(" TEST 3A: STATE TRANSITIONS    ");
    $display("-------------------------------");
    $display("BP_o_Prediction");
    $display("\texpected: 0");
    $display("\tactual:   %d", BP_o_Prediction);
    
    if (BP_o_Prediction == NOT_TAKEN)
        $display("result: passed.");
    else
    begin
        $display("result: FAILED. BP_o_Prediction does not match expected value.");
        errors <= errors + 1;
    end
    
    BP_i_Enable <= LO;                          // pull enable lo for next use
    
    /*===================================
     * TEST 3B: STATE TRANSITIONS
     ===================================*/
    
    #1
    BP_i_Enable <= HI;                          // enable
    BP_i_Index <= 0;                            // select counter 0
    ALU_o_Branch_Outcome <= 0;                  // move state to strongly not taken
    
    #1
    $display("");
    $display("-------------------------------");
    $display(" TEST 3B: STATE TRANSITIONS    ");
    $display("-------------------------------");
    $display("BP_o_Prediction");
    $display("\texpected: 0");
    $display("\tactual:   %d", BP_o_Prediction);
    
    if (BP_o_Prediction == NOT_TAKEN)
        $display("result: passed.");
    else
    begin
        $display("result: FAILED. BP_o_Prediction does not match expected value.");
        errors <= errors + 1;
    end
    
    BP_i_Enable <= LO;                          // pull enable lo for next use
    
    /*===================================
     * TEST 3C: STATE TRANSITIONS
     ===================================*/
    
    #1
    BP_i_Enable <= HI;                          // enable
    BP_i_Index <= 0;                            // select counter 0
    ALU_o_Branch_Outcome <= 0;                  // saturate state strongly not taken
    
    #1
    $display("");
    $display("-------------------------------");
    $display(" TEST 3C: STATE TRANSITIONS    ");
    $display("-------------------------------");
    $display("BP_o_Prediction");
    $display("\texpected: 0");
    $display("\tactual:   %d", BP_o_Prediction);
    
    if (BP_o_Prediction == NOT_TAKEN)
        $display("result: passed.");
    else
    begin
        $display("result: FAILED. BP_o_Prediction does not match expected value.");
        errors <= errors + 1;
    end
    
    BP_i_Enable <= LO;                          // pull enable lo for next use
    
    /*===================================
     * TEST 3D: STATE TRANSITIONS
     ===================================*/
    
    #1
    BP_i_Enable <= HI;                          // enable
    BP_i_Index <= 0;                            // select counter 0
    ALU_o_Branch_Outcome <= 1;                  // move state to weakly not taken
    
    #1
    $display("");
    $display("-------------------------------");
    $display(" TEST 3D: STATE TRANSITIONS    ");
    $display("-------------------------------");
    $display("BP_o_Prediction");
    $display("\texpected: 0");
    $display("\tactual:   %d", BP_o_Prediction);
    
    if (BP_o_Prediction == NOT_TAKEN)
        $display("result: passed.");
    else
    begin
        $display("result: FAILED. BP_o_Prediction does not match expected value.");
        errors <= errors + 1;
    end
    
    BP_i_Enable <= LO;                          // pull enable lo for next use
    
    /*===================================
     * TEST 3E: STATE TRANSITIONS
     ===================================*/
    
    #1
    BP_i_Enable <= HI;                          // enable
    BP_i_Index <= 0;                            // select counter 0
    ALU_o_Branch_Outcome <= 1;                  // move state to weakly taken
    
    #1
    $display("");
    $display("-------------------------------");
    $display(" TEST 3E: STATE TRANSITIONS    ");
    $display("-------------------------------");
    $display("BP_o_Prediction");
    $display("\texpected: 1");
    $display("\tactual:   %d", BP_o_Prediction);
    
    if (BP_o_Prediction == TAKEN)
        $display("result: passed.");
    else
    begin
        $display("result: FAILED. BP_o_Prediction does not match expected value.");
        errors <= errors + 1;
    end
    
    BP_i_Enable <= LO;                          // pull enable lo for next use
    
    /*===================================
     * TEST 3F: STATE TRANSITIONS
     ===================================*/
    
    #1
    BP_i_Enable <= HI;                          // enable
    BP_i_Index <= 0;                            // select counter 0
    ALU_o_Branch_Outcome <= 1;                  // move state to strongly taken
    
    #1
    $display("");
    $display("-------------------------------");
    $display(" TEST 3F: STATE TRANSITIONS    ");
    $display("-------------------------------");
    $display("BP_o_Prediction");
    $display("\texpected: 1");
    $display("\tactual:   %d", BP_o_Prediction);
    
    if (BP_o_Prediction == TAKEN)
        $display("result: passed.");
    else
    begin
        $display("result: FAILED. BP_o_Prediction does not match expected value.");
        errors <= errors + 1;
    end
    
    BP_i_Enable <= LO;                          // pull enable lo for next use
    
    /*===================================
     * TEST 3G: STATE TRANSITIONS
     ===================================*/
    
    #1
    BP_i_Enable <= HI;                          // enable
    BP_i_Index <= 0;                            // select counter 0
    ALU_o_Branch_Outcome <= 1;                  // saturate state strongly taken
    
    #1
    $display("");
    $display("-------------------------------");
    $display(" TEST 3G: STATE TRANSITIONS    ");
    $display("-------------------------------");
    $display("BP_o_Prediction");
    $display("\texpected: 1");
    $display("\tactual:   %d", BP_o_Prediction);
    
    if (BP_o_Prediction == TAKEN)
        $display("result: passed.");
    else
    begin
        $display("result: FAILED. BP_o_Prediction does not match expected value.");
        errors <= errors + 1;
    end
    
    BP_i_Enable <= LO;                          // pull enable lo for next use
    
    /*===================================
     * TEST 3H: STATE TRANSITIONS
     ===================================*/
    
    #1
    BP_i_Enable <= HI;                           // enable
    BP_i_Index <= 0;                             // select counter 0
    ALU_o_Branch_Outcome <= 0;                   // move state to weakly taken
    
    #1
    $display("");
    $display("-------------------------------");
    $display(" TEST 3H: STATE TRANSITIONS    ");
    $display("-------------------------------");
    $display("BP_o_Prediction");
    $display("\texpected: 1");
    $display("\tactual:   %d", BP_o_Prediction);
    
    if (BP_o_Prediction == TAKEN)
        $display("result: passed.");
    else
    begin
        $display("result: FAILED. BP_o_Prediction does not match expected value.");
        errors <= errors + 1;
    end
    
    BP_i_Enable <= LO;                          // pull enable lo for next use
    
    /*=================
     * END TEST BENCH
     =================*/
    #1
    $display("");
    $display("=========================================");
    $display(" END BP - COUNTER TABLE TEST             ");
    $display(" errors: %d", errors);
    $display("=========================================");

    $stop;
    
/*=================
 * END TEST BENCH
 =================*/
 
end 
endmodule
