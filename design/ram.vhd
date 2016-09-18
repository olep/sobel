----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use image_proc_package.all;
----------------------------------------------------------------------------
entity ram is
	port (
		-- Clock
		fxclk			: in std_logic;
		reset_in        : in std_logic; -- reset input pin
		
		-- DDR-SDRAM
		mcb3_dram_dq    : inout std_logic_vector(15 downto 0);
		mcb3_rzq        : inout std_logic;
		mcb3_zio        : inout std_logic;
		mcb3_dram_udqs  : inout std_logic;
		mcb3_dram_dqs   : inout std_logic;
		mcb3_dram_a     : out std_logic_vector(12 downto 0);
		mcb3_dram_ba    : out std_logic_vector(1 downto 0);
		mcb3_dram_cke   : out std_logic;
		mcb3_dram_ras_n : out std_logic;
		mcb3_dram_cas_n : out std_logic;
		mcb3_dram_we_n  : out std_logic;
		mcb3_dram_dm    : out std_logic;
		mcb3_dram_udm   : out std_logic;
		mcb3_dram_ck    : out std_logic;
		mcb3_dram_ck_n  : out std_logic
		
	);
end entity;
----------------------------------------------------------------------------
architecture rtl of ram is
	
	signal clk 			 : std_logic;   -- 50 MHz system clock (for example)
	signal reset0 		 : std_logic;	-- released after dcm0 is ready
	signal reset 		 : std_logic;	-- released after MCB is ready
	signal mem_clk 		 : std_logic;   -- memory clock
	signal c3_calib_done : std_logic; 
	signal c3_rst0 		 : std_logic;
	
	component ddr_ram
	 generic(
	    C3_P0_MASK_SIZE           : integer := 4;
	    C3_P0_DATA_PORT_SIZE      : integer := 32;
	    C3_P1_MASK_SIZE           : integer := 4;
	    C3_P1_DATA_PORT_SIZE      : integer := 32;
	    C3_MEMCLK_PERIOD          : integer := 5000;
	    C3_RST_ACT_LOW            : integer := 0;
	    C3_INPUT_CLK_TYPE         : string := "SINGLE_ENDED";
	    C3_CALIB_SOFT_IP          : string := "TRUE";
	    C3_SIMULATION             : string := "FALSE";
	    DEBUG_EN                  : integer := 0;
	    C3_MEM_ADDR_ORDER         : string := "ROW_BANK_COLUMN";
	    C3_NUM_DQ_PINS            : integer := 16;
	    C3_MEM_ADDR_WIDTH         : integer := 13;
	    C3_MEM_BANKADDR_WIDTH     : integer := 2
	);
	port (
	   mcb3_dram_dq               : inout  std_logic_vector(C3_NUM_DQ_PINS-1 downto 0);
	   mcb3_dram_a                : out std_logic_vector(C3_MEM_ADDR_WIDTH-1 downto 0);
	   mcb3_dram_ba               : out std_logic_vector(C3_MEM_BANKADDR_WIDTH-1 downto 0);
	   mcb3_dram_cke              : out std_logic;
	   mcb3_dram_ras_n            : out std_logic;
	   mcb3_dram_cas_n            : out std_logic;
	   mcb3_dram_we_n             : out std_logic;
	   mcb3_dram_dm               : out std_logic;
	   mcb3_dram_udqs             : inout  std_logic;
	   mcb3_rzq                   : inout  std_logic;
	   mcb3_dram_udm              : out std_logic;
	   c3_sys_clk                 : in  std_logic;
	   c3_sys_rst_n               : in  std_logic;
	   c3_calib_done              : out std_logic;
	   c3_clk0                    : out std_logic;
	   c3_rst0                    : out std_logic;
	   mcb3_dram_dqs              : inout  std_logic;
	   mcb3_dram_ck               : out std_logic;
	   mcb3_dram_ck_n             : out std_logic;
	   c3_p0_cmd_clk              : in std_logic;
	   c3_p0_cmd_en               : in std_logic;
	   c3_p0_cmd_instr            : in std_logic_vector(2 downto 0);
	   c3_p0_cmd_bl               : in std_logic_vector(5 downto 0);
	   c3_p0_cmd_byte_addr        : in std_logic_vector(29 downto 0);
	   c3_p0_cmd_empty            : out std_logic;
	   c3_p0_cmd_full             : out std_logic;
	   c3_p0_wr_clk               : in std_logic;
	   c3_p0_wr_en                : in std_logic;
	   c3_p0_wr_mask              : in std_logic_vector(C3_P0_MASK_SIZE - 1 downto 0);
	   c3_p0_wr_data              : in std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
	   c3_p0_wr_full              : out std_logic;
	   c3_p0_wr_empty             : out std_logic;
	   c3_p0_wr_count             : out std_logic_vector(6 downto 0);
	   c3_p0_wr_underrun          : out std_logic;
	   c3_p0_wr_error             : out std_logic;
	   c3_p0_rd_clk               : in std_logic;
	   c3_p0_rd_en                : in std_logic;
	   c3_p0_rd_data              : out std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
	   c3_p0_rd_full              : out std_logic;
	   c3_p0_rd_empty             : out std_logic;
	   c3_p0_rd_count             : out std_logic_vector(6 downto 0);
	   c3_p0_rd_overflow          : out std_logic;
	   c3_p0_rd_error             : out std_logic;
	   c3_p1_cmd_clk              : in std_logic;
	   c3_p1_cmd_en               : in std_logic;
	   c3_p1_cmd_instr            : in std_logic_vector(2 downto 0);
	   c3_p1_cmd_bl               : in std_logic_vector(5 downto 0);
	   c3_p1_cmd_byte_addr        : in std_logic_vector(29 downto 0);
	   c3_p1_cmd_empty            : out std_logic;
	   c3_p1_cmd_full             : out std_logic;
	   c3_p1_wr_clk               : in std_logic;
	   c3_p1_wr_en                : in std_logic;
	   c3_p1_wr_mask              : in std_logic_vector(C3_P1_MASK_SIZE - 1 downto 0);
	   c3_p1_wr_data              : in std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
	   c3_p1_wr_full              : out std_logic;
	   c3_p1_wr_empty             : out std_logic;
	   c3_p1_wr_count             : out std_logic_vector(6 downto 0);
	   c3_p1_wr_underrun          : out std_logic;
	   c3_p1_wr_error             : out std_logic;
	   c3_p1_rd_clk               : in std_logic;
	   c3_p1_rd_en                : in std_logic;
	   c3_p1_rd_data              : out std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
	   c3_p1_rd_full              : out std_logic;
	   c3_p1_rd_empty             : out std_logic;
	   c3_p1_rd_count             : out std_logic_vector(6 downto 0);
	   c3_p1_rd_overflow          : out std_logic;
	   c3_p1_rd_error             : out std_logic;
	);
	end component;

begin

	-- Instantiate DDR RAM block 
	u_ddr_ram : ddr_ram
    generic map (
    	C3_P0_MASK_SIZE 	  => C3_P0_MASK_SIZE,
    	C3_P0_DATA_PORT_SIZE  => C3_P0_DATA_PORT_SIZE,
    	C3_P1_MASK_SIZE 	  => C3_P1_MASK_SIZE,
    	C3_P1_DATA_PORT_SIZE  => C3_P1_DATA_PORT_SIZE,
    	C3_MEMCLK_PERIOD 	  => C3_MEMCLK_PERIOD,
    	C3_RST_ACT_LOW 		  => C3_RST_ACT_LOW,
    	C3_INPUT_CLK_TYPE 	  => C3_INPUT_CLK_TYPE,
    	C3_CALIB_SOFT_IP 	  => C3_CALIB_SOFT_IP,
    	C3_SIMULATION 		  => C3_SIMULATION,
    	DEBUG_EN 			  => DEBUG_EN,
    	C3_MEM_ADDR_ORDER 	  => C3_MEM_ADDR_ORDER,
    	C3_NUM_DQ_PINS 		  => C3_NUM_DQ_PINS,
    	C3_MEM_ADDR_WIDTH 	  => C3_MEM_ADDR_WIDTH,
    	C3_MEM_BANKADDR_WIDTH => C3_MEM_BANKADDR_WIDTH
	)
    port map (
		mcb3_dram_dq      	 =>  mcb3_dram_dq,  
		mcb3_dram_a       	 =>  mcb3_dram_a,  
		mcb3_dram_ba      	 =>  mcb3_dram_ba,
		mcb3_dram_ras_n   	 =>  mcb3_dram_ras_n,                        
		mcb3_dram_cas_n   	 =>  mcb3_dram_cas_n,                        
		mcb3_dram_we_n    	 =>  mcb3_dram_we_n,                          
		mcb3_dram_cke     	 =>  mcb3_dram_cke,                          
		mcb3_dram_ck      	 =>  mcb3_dram_ck,                          
		mcb3_dram_ck_n    	 =>  mcb3_dram_ck_n,       
		mcb3_dram_dqs     	 =>  mcb3_dram_dqs,                          
		mcb3_dram_udqs    	 =>  mcb3_dram_udqs,    -- for X16 parts           
		mcb3_dram_udm  	  	 =>  mcb3_dram_udm,     -- for X16 parts
		mcb3_dram_dm  	  	 =>  mcb3_dram_dm,
		mcb3_rzq			 =>  mcb3_rzq,
		
    	c3_sys_clk  	     =>  mem_clk,
		c3_sys_rst_n       	 =>  reset0,
		
		c3_clk0			  	 =>	 clk,
		c3_rst0			  	 =>  c3_rst0,
		c3_calib_done      	 =>  c3_calib_done,
  
		c3_p0_cmd_clk        =>  c3_p0_cmd_clk,
		c3_p0_cmd_en         =>  c3_p0_cmd_en,
		c3_p0_cmd_instr      =>  c3_p0_cmd_instr,
		c3_p0_cmd_bl         =>  c3_p0_cmd_bl,
		c3_p0_cmd_byte_addr  =>  c3_p0_cmd_byte_addr,
		c3_p0_cmd_empty      =>  c3_p0_cmd_empty,
		c3_p0_cmd_full       =>  c3_p0_cmd_full,
		c3_p0_wr_clk         =>  c3_p0_wr_clk,
		c3_p0_wr_en          =>  c3_p0_wr_en,
		c3_p0_wr_mask        =>  c3_p0_wr_mask,
		c3_p0_wr_data        =>  c3_p0_wr_data,
		c3_p0_wr_full        =>  c3_p0_wr_full,
		c3_p0_wr_empty       =>  c3_p0_wr_empty,
		c3_p0_wr_count       =>  c3_p0_wr_count,
		c3_p0_wr_underrun    =>  c3_p0_wr_underrun,
		c3_p0_wr_error       =>  c3_p0_wr_error,
		c3_p0_rd_clk         =>  c3_p0_rd_clk,
		c3_p0_rd_en          =>  c3_p0_rd_en,
		c3_p0_rd_data        =>  c3_p0_rd_data,
		c3_p0_rd_full        =>  c3_p0_rd_full,
		c3_p0_rd_empty       =>  c3_p0_rd_empty,
		c3_p0_rd_count       =>  c3_p0_rd_count,
		c3_p0_rd_overflow    =>  c3_p0_rd_overflow,
		c3_p0_rd_error       =>  c3_p0_rd_error,
		
		c3_p1_cmd_clk        =>  c3_p1_cmd_clk,
		c3_p1_cmd_en         =>  c3_p1_cmd_en,
		c3_p1_cmd_instr      =>  c3_p1_cmd_instr,
		c3_p1_cmd_bl         =>  c3_p1_cmd_bl,
		c3_p1_cmd_byte_addr  =>  c3_p1_cmd_byte_addr,
		c3_p1_cmd_empty      =>  c3_p1_cmd_empty,
		c3_p1_cmd_full       =>  c3_p1_cmd_full,
		c3_p1_wr_clk         =>  c3_p1_wr_clk,
		c3_p1_wr_en          =>  c3_p1_wr_en,
		c3_p1_wr_mask        =>  c3_p1_wr_mask,
		c3_p1_wr_data        =>  c3_p1_wr_data,
		c3_p1_wr_full        =>  c3_p1_wr_full,
		c3_p1_wr_empty       =>  c3_p1_wr_empty,
		c3_p1_wr_count       =>  c3_p1_wr_count,
		c3_p1_wr_underrun    =>  c3_p1_wr_underrun,
		c3_p1_wr_error       =>  c3_p1_wr_error,
		c3_p1_rd_clk         =>  c3_p1_rd_clk,
		c3_p1_rd_en          =>  c3_p1_rd_en,
		c3_p1_rd_data        =>  c3_p1_rd_data,
		c3_p1_rd_full        =>  c3_p1_rd_full,
		c3_p1_rd_empty       =>  c3_p1_rd_empty,
		c3_p1_rd_count       =>  c3_p1_rd_count,
		c3_p1_rd_overflow    =>  c3_p1_rd_overflow,
		c3_p1_rd_error       =>  c3_p1_rd_error
		
	);

	reset <= reset0 or (not c3_calib_done) or c3_rst0;
	reset0 <= reset_in;
	mem_clk <= fxclk;

end architecture;
----------------------------------------------------------------------------

