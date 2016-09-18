----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
----------------------------------------------------------------------------
package image_proc_package is
	constant C_KERNEL_SIZE : positive := 3;
	type kernel_array is array (0 to C_KERNEL_SIZE-1, 0 to C_KERNEL_SIZE-1) of integer range -2 to 2;
	constant kernel_x : kernel_array := ( (-1, 0, 1), (-2, 0, 2), (-1, 0, 1) );
	constant kernel_y : kernel_array := ( (-1, -2, -1), (0, 0, 0), (1, 2, 1) );

	constant C_WORD_SIZE : positive := 8;
	constant C_ADDRESS_SIZE : positive := 20;
	constant C_WIDTH_MAX : positive := 1024;
	constant C_HEIGHT_MAX : positive := 1024;
end package;
----------------------------------------------------------------------------

