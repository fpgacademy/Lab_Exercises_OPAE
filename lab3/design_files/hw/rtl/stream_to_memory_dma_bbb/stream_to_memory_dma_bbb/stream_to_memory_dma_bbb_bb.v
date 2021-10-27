module stream_to_memory_dma_bbb (
		input  wire         clk_clk,                        //              clk.clk
		input  wire         reset_reset,                    //            reset.reset
		output wire         csr_waitrequest,                //              csr.waitrequest
		output wire [63:0]  csr_readdata,                   //                 .readdata
		output wire         csr_readdatavalid,              //                 .readdatavalid
		input  wire [0:0]   csr_burstcount,                 //                 .burstcount
		input  wire [63:0]  csr_writedata,                  //                 .writedata
		input  wire [7:0]   csr_address,                    //                 .address
		input  wire         csr_write,                      //                 .write
		input  wire         csr_read,                       //                 .read
		input  wire [7:0]   csr_byteenable,                 //                 .byteenable
		input  wire         csr_debugaccess,                //                 .debugaccess
		output wire [47:0]  host_write_address,             //       host_write.address
		output wire [511:0] host_write_writedata,           //                 .writedata
		output wire [63:0]  host_write_byteenable,          //                 .byteenable
		output wire [2:0]   host_write_burstcount,          //                 .burstcount
		output wire         host_write_write,               //                 .write
		input  wire [1:0]   host_write_response,            //                 .response
		input  wire         host_write_writeresponsevalid,  //                 .writeresponsevalid
		input  wire         host_write_waitrequest,         //                 .waitrequest
		output wire [47:0]  descriptor_fetch_address,       // descriptor_fetch.address
		output wire [2:0]   descriptor_fetch_burstcount,    //                 .burstcount
		output wire [63:0]  descriptor_fetch_byteenable,    //                 .byteenable
		output wire         descriptor_fetch_read,          //                 .read
		input  wire [511:0] descriptor_fetch_readdata,      //                 .readdata
		input  wire         descriptor_fetch_readdatavalid, //                 .readdatavalid
		input  wire         descriptor_fetch_waitrequest,   //                 .waitrequest
		output wire [47:0]  descriptor_store_address,       // descriptor_store.address
		output wire [2:0]   descriptor_store_burstcount,    //                 .burstcount
		output wire [63:0]  descriptor_store_byteenable,    //                 .byteenable
		input  wire         descriptor_store_waitrequest,   //                 .waitrequest
		output wire         descriptor_store_write,         //                 .write
		output wire [511:0] descriptor_store_writedata,     //                 .writedata
		input  wire         mem_write_waitrequest,          //        mem_write.waitrequest
		input  wire [511:0] mem_write_readdata,             //                 .readdata
		input  wire         mem_write_readdatavalid,        //                 .readdatavalid
		output wire [2:0]   mem_write_burstcount,           //                 .burstcount
		output wire [511:0] mem_write_writedata,            //                 .writedata
		output wire [47:0]  mem_write_address,              //                 .address
		output wire         mem_write_write,                //                 .write
		output wire         mem_write_read,                 //                 .read
		output wire [63:0]  mem_write_byteenable,           //                 .byteenable
		output wire         mem_write_debugaccess,          //                 .debugaccess
		input  wire [511:0] s2m_st_sink_data,               //      s2m_st_sink.data
		input  wire         s2m_st_sink_valid,              //                 .valid
		output wire         s2m_st_sink_ready,              //                 .ready
		input  wire         s2m_st_sink_startofpacket,      //                 .startofpacket
		input  wire         s2m_st_sink_endofpacket,        //                 .endofpacket
		input  wire [5:0]   s2m_st_sink_empty               //                 .empty
	);
endmodule

