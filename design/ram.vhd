-- filename: ram.vhd
-- date: 04.09.2016

-- Synchronous RAM module
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use sobel_package.all;
----------------------------------------------------------------------------
entity ram is
	port (
		-- Clock
		clk : in std_logic;
		
		-- RAM interface
		we : in std_logic; 
		address : in std_logic_vector(C_ADDRESS_SIZE-1 downto 0);
		data : inout std_logic_vector(C_WORD_SIZE-1 downto 0)
	);
end entity;
----------------------------------------------------------------------------
architecture rtl of ram is
	type memory is array (0 to C_WIDTH_MAX*C_HEIGHT_MAX) of std_logic_vector(C_WORD_SIZE-1 downto 0);
	signal myram : memory;
begin
	process (clk):
	begin
		if rising_edge(clk) then 
			if (we = '1') then
				myram(address) <= data;
			else
				data <= myram(address);
			end if;
		end if;
	end process;
end architecture;
----------------------------------------------------------------------------

