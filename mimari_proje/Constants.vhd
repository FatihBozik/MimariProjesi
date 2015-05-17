--***************----\
-- <CONSTANTS.VHD> -- 
--***************----/

library ieee;
use ieee.std_logic_1164.all;
package Constants is

--global
subtype register_s is std_logic_vector(31 downto 0);
type register_array is array (0 to 31) of register_s;
constant width : natural := 32;	
constant regfile_depth : positive := 32;
constant regfile_adrsize : positive := 5; 
constant one : std_logic_vector(31 downto 0) := X"00000001";
constant zero : std_logic_vector(31 downto 0) := X"00000000";

end Constants;
