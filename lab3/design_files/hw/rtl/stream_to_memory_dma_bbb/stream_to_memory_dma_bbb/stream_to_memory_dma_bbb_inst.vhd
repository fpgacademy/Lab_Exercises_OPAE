	component stream_to_memory_dma_bbb is
		port (
			clk_clk                        : in  std_logic                      := 'X';             -- clk
			reset_reset                    : in  std_logic                      := 'X';             -- reset
			csr_waitrequest                : out std_logic;                                         -- waitrequest
			csr_readdata                   : out std_logic_vector(63 downto 0);                     -- readdata
			csr_readdatavalid              : out std_logic;                                         -- readdatavalid
			csr_burstcount                 : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- burstcount
			csr_writedata                  : in  std_logic_vector(63 downto 0)  := (others => 'X'); -- writedata
			csr_address                    : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- address
			csr_write                      : in  std_logic                      := 'X';             -- write
			csr_read                       : in  std_logic                      := 'X';             -- read
			csr_byteenable                 : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- byteenable
			csr_debugaccess                : in  std_logic                      := 'X';             -- debugaccess
			host_write_address             : out std_logic_vector(47 downto 0);                     -- address
			host_write_writedata           : out std_logic_vector(511 downto 0);                    -- writedata
			host_write_byteenable          : out std_logic_vector(63 downto 0);                     -- byteenable
			host_write_burstcount          : out std_logic_vector(2 downto 0);                      -- burstcount
			host_write_write               : out std_logic;                                         -- write
			host_write_response            : in  std_logic_vector(1 downto 0)   := (others => 'X'); -- response
			host_write_writeresponsevalid  : in  std_logic                      := 'X';             -- writeresponsevalid
			host_write_waitrequest         : in  std_logic                      := 'X';             -- waitrequest
			descriptor_fetch_address       : out std_logic_vector(47 downto 0);                     -- address
			descriptor_fetch_burstcount    : out std_logic_vector(2 downto 0);                      -- burstcount
			descriptor_fetch_byteenable    : out std_logic_vector(63 downto 0);                     -- byteenable
			descriptor_fetch_read          : out std_logic;                                         -- read
			descriptor_fetch_readdata      : in  std_logic_vector(511 downto 0) := (others => 'X'); -- readdata
			descriptor_fetch_readdatavalid : in  std_logic                      := 'X';             -- readdatavalid
			descriptor_fetch_waitrequest   : in  std_logic                      := 'X';             -- waitrequest
			descriptor_store_address       : out std_logic_vector(47 downto 0);                     -- address
			descriptor_store_burstcount    : out std_logic_vector(2 downto 0);                      -- burstcount
			descriptor_store_byteenable    : out std_logic_vector(63 downto 0);                     -- byteenable
			descriptor_store_waitrequest   : in  std_logic                      := 'X';             -- waitrequest
			descriptor_store_write         : out std_logic;                                         -- write
			descriptor_store_writedata     : out std_logic_vector(511 downto 0);                    -- writedata
			mem_write_waitrequest          : in  std_logic                      := 'X';             -- waitrequest
			mem_write_readdata             : in  std_logic_vector(511 downto 0) := (others => 'X'); -- readdata
			mem_write_readdatavalid        : in  std_logic                      := 'X';             -- readdatavalid
			mem_write_burstcount           : out std_logic_vector(2 downto 0);                      -- burstcount
			mem_write_writedata            : out std_logic_vector(511 downto 0);                    -- writedata
			mem_write_address              : out std_logic_vector(47 downto 0);                     -- address
			mem_write_write                : out std_logic;                                         -- write
			mem_write_read                 : out std_logic;                                         -- read
			mem_write_byteenable           : out std_logic_vector(63 downto 0);                     -- byteenable
			mem_write_debugaccess          : out std_logic;                                         -- debugaccess
			s2m_st_sink_data               : in  std_logic_vector(511 downto 0) := (others => 'X'); -- data
			s2m_st_sink_valid              : in  std_logic                      := 'X';             -- valid
			s2m_st_sink_ready              : out std_logic;                                         -- ready
			s2m_st_sink_startofpacket      : in  std_logic                      := 'X';             -- startofpacket
			s2m_st_sink_endofpacket        : in  std_logic                      := 'X';             -- endofpacket
			s2m_st_sink_empty              : in  std_logic_vector(5 downto 0)   := (others => 'X')  -- empty
		);
	end component stream_to_memory_dma_bbb;

	u0 : component stream_to_memory_dma_bbb
		port map (
			clk_clk                        => CONNECTED_TO_clk_clk,                        --              clk.clk
			reset_reset                    => CONNECTED_TO_reset_reset,                    --            reset.reset
			csr_waitrequest                => CONNECTED_TO_csr_waitrequest,                --              csr.waitrequest
			csr_readdata                   => CONNECTED_TO_csr_readdata,                   --                 .readdata
			csr_readdatavalid              => CONNECTED_TO_csr_readdatavalid,              --                 .readdatavalid
			csr_burstcount                 => CONNECTED_TO_csr_burstcount,                 --                 .burstcount
			csr_writedata                  => CONNECTED_TO_csr_writedata,                  --                 .writedata
			csr_address                    => CONNECTED_TO_csr_address,                    --                 .address
			csr_write                      => CONNECTED_TO_csr_write,                      --                 .write
			csr_read                       => CONNECTED_TO_csr_read,                       --                 .read
			csr_byteenable                 => CONNECTED_TO_csr_byteenable,                 --                 .byteenable
			csr_debugaccess                => CONNECTED_TO_csr_debugaccess,                --                 .debugaccess
			host_write_address             => CONNECTED_TO_host_write_address,             --       host_write.address
			host_write_writedata           => CONNECTED_TO_host_write_writedata,           --                 .writedata
			host_write_byteenable          => CONNECTED_TO_host_write_byteenable,          --                 .byteenable
			host_write_burstcount          => CONNECTED_TO_host_write_burstcount,          --                 .burstcount
			host_write_write               => CONNECTED_TO_host_write_write,               --                 .write
			host_write_response            => CONNECTED_TO_host_write_response,            --                 .response
			host_write_writeresponsevalid  => CONNECTED_TO_host_write_writeresponsevalid,  --                 .writeresponsevalid
			host_write_waitrequest         => CONNECTED_TO_host_write_waitrequest,         --                 .waitrequest
			descriptor_fetch_address       => CONNECTED_TO_descriptor_fetch_address,       -- descriptor_fetch.address
			descriptor_fetch_burstcount    => CONNECTED_TO_descriptor_fetch_burstcount,    --                 .burstcount
			descriptor_fetch_byteenable    => CONNECTED_TO_descriptor_fetch_byteenable,    --                 .byteenable
			descriptor_fetch_read          => CONNECTED_TO_descriptor_fetch_read,          --                 .read
			descriptor_fetch_readdata      => CONNECTED_TO_descriptor_fetch_readdata,      --                 .readdata
			descriptor_fetch_readdatavalid => CONNECTED_TO_descriptor_fetch_readdatavalid, --                 .readdatavalid
			descriptor_fetch_waitrequest   => CONNECTED_TO_descriptor_fetch_waitrequest,   --                 .waitrequest
			descriptor_store_address       => CONNECTED_TO_descriptor_store_address,       -- descriptor_store.address
			descriptor_store_burstcount    => CONNECTED_TO_descriptor_store_burstcount,    --                 .burstcount
			descriptor_store_byteenable    => CONNECTED_TO_descriptor_store_byteenable,    --                 .byteenable
			descriptor_store_waitrequest   => CONNECTED_TO_descriptor_store_waitrequest,   --                 .waitrequest
			descriptor_store_write         => CONNECTED_TO_descriptor_store_write,         --                 .write
			descriptor_store_writedata     => CONNECTED_TO_descriptor_store_writedata,     --                 .writedata
			mem_write_waitrequest          => CONNECTED_TO_mem_write_waitrequest,          --        mem_write.waitrequest
			mem_write_readdata             => CONNECTED_TO_mem_write_readdata,             --                 .readdata
			mem_write_readdatavalid        => CONNECTED_TO_mem_write_readdatavalid,        --                 .readdatavalid
			mem_write_burstcount           => CONNECTED_TO_mem_write_burstcount,           --                 .burstcount
			mem_write_writedata            => CONNECTED_TO_mem_write_writedata,            --                 .writedata
			mem_write_address              => CONNECTED_TO_mem_write_address,              --                 .address
			mem_write_write                => CONNECTED_TO_mem_write_write,                --                 .write
			mem_write_read                 => CONNECTED_TO_mem_write_read,                 --                 .read
			mem_write_byteenable           => CONNECTED_TO_mem_write_byteenable,           --                 .byteenable
			mem_write_debugaccess          => CONNECTED_TO_mem_write_debugaccess,          --                 .debugaccess
			s2m_st_sink_data               => CONNECTED_TO_s2m_st_sink_data,               --      s2m_st_sink.data
			s2m_st_sink_valid              => CONNECTED_TO_s2m_st_sink_valid,              --                 .valid
			s2m_st_sink_ready              => CONNECTED_TO_s2m_st_sink_ready,              --                 .ready
			s2m_st_sink_startofpacket      => CONNECTED_TO_s2m_st_sink_startofpacket,      --                 .startofpacket
			s2m_st_sink_endofpacket        => CONNECTED_TO_s2m_st_sink_endofpacket,        --                 .endofpacket
			s2m_st_sink_empty              => CONNECTED_TO_s2m_st_sink_empty               --                 .empty
		);

