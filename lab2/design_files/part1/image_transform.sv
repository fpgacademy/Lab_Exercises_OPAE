module image_transform(clk, reset, ctrl, ctrl_data, ctrl_address, readdata, readdatavalid, waitrequest, address, read, write, writedata);

    parameter NUM_BYTES = 2, n = 16;
    input clk, reset, ctrl, ctrl_address;
    input [63:0] ctrl_data;
    input [n-1:0] readdata;
    input readdatavalid, waitrequest;
    output logic [47:0] address;
    output logic read, write;
    output logic [n-1:0] writedata;

    logic transform_done;
    logic [31:0] pixel_counter;
    logic [15:0] pixel_per_row;
    logic [47:0] src_address, dst_address;
    logic [ 7:0] transform_type;
    logic [2:0] transform_state;
    logic [2:0] transform_state_next;
    // declare other signals

    always @(posedge clk) begin
        if(reset) begin
            src_address <= '0; dst_address <= '0; 
            transform_type <= '0;
        end
        else if(ctrl && ctrl_address == 0) begin    
            // read instructions
            src_address <= '0;
            dst_address[31:0] <= ctrl_data[63:32];
            pixel_per_row   <= ctrl_data[31:16];
            transform_type  <= ctrl_data[7:0];
        end
    end

    // define transform_done
    // define finite state machine
endmodule