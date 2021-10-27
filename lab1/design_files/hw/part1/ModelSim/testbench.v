`timescale 1ns / 1ps

module testbench ( );
    // declare design under test (DUT) inputs
    reg reset, clock, W;
    reg [15:0] A;    // address
    reg [7:0] D;    // data
    // declare DUT outputs
    wire [7:0] Q;

    // instantiate the DUT
    application U1 (reset, clock, W, A, D, Q);

    // define a 100 MHz clock waveform
    always
        #5 clock <= ~clock;
    
    // assign inputs at various times
    initial 
    begin
        clock <= 1'b0;
        reset <= 1'b1;
        W <= 1'b0; A <= 2'bXX;
        #10  reset <= 1'b0;
             // initialize the polynomial
             A <= 16'h0010; D <= 221; W <= 1'b1;
        #10  // initialize the seed
             A <= 16'h0012; D <= 1'b1;
        #10  // set the control register for continuous mode
             A <= 16'h0014; D <= 2'b10;
        #10  W <= 1'b0;
        #90  // set the control register for stopped mode
             D <= 0; W <= 1'b1;
        #20  // re-initialize the seed
             A <= 16'h0012; D <= 1;
        #10  // set the control register for step mode
             A <= 16'h0014; D <= 8'b01;
        #20  D <= 8'b00;   // stop
        #10  D <= 8'b01;   // step
        #20  D <= 8'b00;   // stop
        #10  D <= 8'b01;   // step
        #20  D <= 8'b00;   // stop
        #10  D <= 8'b01;   // step
        #20  D <= 8'b00;   // stop
        #10  D <= 8'b01;   // step
        #20  D <= 8'b00;   // stop
        #10  D <= 8'b01;   // step
        #20  D <= 8'b00;   // stop
    end // initial
endmodule
