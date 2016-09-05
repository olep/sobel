-- filename: sobel.vhd
-- date: 26.08.2016

----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use sobel_package.all;
----------------------------------------------------------------------------
entity sobel is
	port (
		-- Clock and reset
		clk : in std_logic;
		rst : in std_logic; 
		
		-- RAM interface
		we : out std_logic_vector; 
		address : out std_logic_vector(C_ADDRESS_SIZE-1 downto 0);
		data : inout std_logic_vector(C_WORD_SIZE-1 downto 0);

		-- Sobel control block interface
		en : std_logic_vector
	);
end entity;
----------------------------------------------------------------------------
architecture rtl of sobel is
begin

end architecture;
----------------------------------------------------------------------------

