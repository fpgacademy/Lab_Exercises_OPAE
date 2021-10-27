`timescale 1ns / 1ps

module testbench ( );
    // declare design under test (DUT) inputs
    reg reset, clk, ctrl;
    reg [63:0] ctrl_data;
    reg ctrl_address;

    reg [15:0] readdata;
    reg readdatavalid, waitrequest;
    wire [47:0] address;
    wire read, write;
    wire [15:0] writedata;
    

    // instantiate the DUT
    image_transform U1(clk, reset, ctrl, ctrl_data, ctrl_address, readdata, readdatavalid, waitrequest, address, read, write, writedata);


    // define a 100 MHz clock waveform
    always
        #5 clk <= ~clk;
    
    // assign inputs at various times
    initial 
    begin
        clk <= 1'b0;
        reset <= 1'b1;
        ctrl <= 1'b0; ctrl_data <= '0; ctrl_address <= '0;

        readdata <= '0;
        readdatavalid <= 1'b0; waitrequest  <= 1'b0;

        #10 reset <= 1'b0;
        #10 ctrl <= 1'b1; ctrl_data <= 64'h0000_0010_0008_0002;
        #10 ctrl <= 1'b0;

        #70 waitrequest <= 1'b1;
        #30 waitrequest <= 1'b0;

        #80 waitrequest <= 1'b1;
        #40 waitrequest <= 1'b0;
    end // initial

    reg request;
    always @(posedge clk) begin
        if(reset == 1'b1) begin
            readdatavalid <= 1'b0;
            request <= 1'b0;
        end
        else if(read == 1'b1) begin
            readdata[7:0] <= address[7:0];
            readdata[15:8] <= address[7:0] + 1'b1;
            if(!waitrequest)
                readdatavalid <= 1'b1;
            else begin
                request <= 1'b1;
                readdatavalid <= 1'b0;
            end
        end
        else if (request)
            if(!waitrequest) begin
                readdatavalid <= 1'b1;
                request <= 1'b0;
            end
            else
                readdatavalid <= 1'b1;
        else
            readdatavalid <= 1'b0;
    end

endmodule
