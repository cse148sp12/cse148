/*=============================================================================
 * File:    test_global_history_reg.v
 * Author:  Kevin Huynh
 * 
 * Version  Date        Comment
 * ----------------------------------------------------------------------------
 *   1.1    05/03/12    Automated test bench.
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
reg BP_i_Prediction;      // branch prediction given by counter table
reg ALU_o_Branch_Outcome; // branch resolution

wire [BPRED_WIDTH-1:0] BP_o_Global_History;    // GHR output

integer k;
integer errors;

// UUT - Unit Under Test
global_history_reg #(.BPRED_WIDTH(BPRED_WIDTH)) UUT
(
    .i_Clk(clk),
	.i_Reset(Reset_n),
    
	// inputs
	.i_ALU_Branch_Valid(ALU_o_Branch_Valid),
	.i_DEC_Is_Branch(DEC_o_Is_Branch),
	.i_Prediction(BP_i_Prediction),
	.i_ALU_Branch_Outcome(ALU_o_Branch_Outcome),
    
	// outputs
	.o_Global_History(BP_o_Global_History)
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
    $display("=========================================");
    $display(" BEGIN BP - COUNTER TABLE TEST           ");
    $display("=========================================");
    
    errors <= 0;

    /*===============
     * TEST 1: RESET
     ================*/
	Reset_n = LO;                                   // reset
    
	@(posedge clk)
    begin
        Reset_n <= HI;                               // enable
    
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
    end
    
    for (k = 0; k < 2; k = k + 1) @(posedge clk);   // idle 2 cycles
	
	/*==========================================
     * TEST 2: BRANCH PREDICTION BIT INSERTION
     ==========================================*/
    @(posedge clk)
    begin
        ALU_o_Branch_Valid <= FALSE;                 // no branch in EX stage
        DEC_o_Is_Branch <= TRUE;                     // branch in DEC stage
        BP_i_Prediction <= NOT_TAKEN;                // predict not taken
        ALU_o_Branch_Outcome <= 1'bx;                // ignore branch resolution
    end
    
    // "pass" branch instruction through pipeline
	@(posedge clk)
    begin
        ALU_o_Branch_Valid <= FALSE;                 
        DEC_o_Is_Branch <= FALSE;                 
    
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
    end
    
    for (k = 0; k < 2; k = k + 1) @(posedge clk);   // idle 2 cycles

	/*===================================
     * TEST 3: BRANCH RESOLUTION UPDATE
     ===================================*/
    @(posedge clk)
    begin
        ALU_o_Branch_Valid <= TRUE;                  // branch in EX stage
        DEC_o_Is_Branch <= FALSE;                    // no branch in DEC stage
        BP_i_Prediction <= 1'bx;                     // ignore prediction
        ALU_o_Branch_Outcome <= TAKEN;               // taken
    end
    
    // "pass" branch instruction through pipeline
	@(posedge clk)
    begin
        ALU_o_Branch_Valid <= FALSE;                 
        DEC_o_Is_Branch <= FALSE;                 
    
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
    end
    
    for (k = 0; k < 2; k = k + 1) @(posedge clk);   // idle 2 cycles
    
    /*=================================
     * TEST 4: TWO BRANCHES IN FLIGHT
     =================================*/
    @(posedge clk)
    begin
        ALU_o_Branch_Valid <= FALSE;                 // no branch in EX stage
        DEC_o_Is_Branch <= TRUE;                     // branch in DEC stage
        BP_i_Prediction <= NOT_TAKEN;                // predict not taken
        ALU_o_Branch_Outcome <= 1'bx;                // ignore branch resolution
    end
    
    // "pass" branch instruction through pipeline
	@(posedge clk)
    begin
        ALU_o_Branch_Valid <= FALSE;                 
        DEC_o_Is_Branch <= FALSE;                 
    end
    
    @(posedge clk)
    begin
        ALU_o_Branch_Valid <= TRUE;                  // branch in EX stage
        DEC_o_Is_Branch <= TRUE;                     // branch in DEC stage
        BP_i_Prediction <= TAKEN;                    // predict not taken
        ALU_o_Branch_Outcome <= TAKEN;               // taken
    end
    
    // "pass" branch instruction through pipeline
	@(posedge clk)
    begin
        ALU_o_Branch_Valid <= FALSE;                 
        DEC_o_Is_Branch <= FALSE;                 
    
        $display("");
        $display("-----------------------------------------");
        $display(" TEST 4: TWO BRANCHES IN FLIGHT          ");
        $display("-----------------------------------------");
        $display("BP_o_Global_History[0]");
        $display("\texpected: 1");
        $display("\tactual:   %d", BP_o_Global_History[0]);
        $display("BP_o_Global_History[1]");
        $display("\texpected: 1");
        $display("\tactual:   %d", BP_o_Global_History[1]);
        
        if (BP_o_Global_History[0] != TAKEN)
        begin
            $display("result: FAILED. BP_o_Global_History[0] does not match expected value.");
            errors <= errors + 1;
        end
        if (BP_o_Global_History[1] != TAKEN)
        begin
            $display("result: FAILED. BP_o_Global_History[1] does not match expected value.");
            errors <= errors + 1;
        end
        if (BP_o_Global_History[0] == TAKEN && BP_o_Global_History[1] == TAKEN)
            $display("result: passed.");
    end      
        
    for (k = 0; k < 2; k = k + 1) @(posedge clk);   // idle 2 cycles
        
    /*=================
     * END TEST BENCH
     =================*/
    $display("");
    $display("=========================================");
    $display(" END BP - GLOBAL HISTORY REGISTER TEST   ");
    $display(" errors: %d", errors);
    $display("=========================================");

    $stop;
end 

endmodule
