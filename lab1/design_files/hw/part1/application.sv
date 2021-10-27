module application (reset, clock, W, A, D, Q); // A configurable LFSR.
    parameter n = 8;
    input reset, clock, W;
    input [15:0] A; // POLY_REG: 0x0010, LFSR_REG: 0x0012, CTRL_REG: 0x0014

    input [n-1:0] D;                           // input data
    output logic [n-1:0] Q;                    // LFSR output register
    logic [1:0] Ctrl;                          // control register
    logic [n-1:0] Poly;                        // polynomial register
    logic [n-1:0] Mask, Next;                  // LFSR intermediate values
    enum logic [1:0] {S0, S1, S2 } y, Y;       // FSM, state and next state
    logic z;                                   // FSM output
    
    always_ff @(posedge clock)                 // polynomial register
        if (reset)                             // synchronous reset
            Poly <= '0;
        else if (W && A == 16'h0010)           // set the polynomial
            Poly <= D;

    // define the LFSR
    // define the control register
    // define the finite state machine
endmodule