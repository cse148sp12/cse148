module bypass_unit
(
    input i_DEC_Is_Branch,
    input i_DEC_Is_Jump,
    input i_DEC_Stall,
    output o_DEC_Is_Branch,
    output o_DEC_Is_Jump
);

assign o_DEC_Is_Branch = i_DEC_Stall ? 1'bx : i_DEC_Is_Branch;
assign o_DEC_Is_Jump = i_DEC_Stall ? 1'bx : i_DEC_Is_Jump;

endmodule
