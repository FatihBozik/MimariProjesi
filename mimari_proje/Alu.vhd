--*******----\
-- <ALU.VHD> --
--*******----/

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Constants.all;


entity Alu is
       port( a, b : in std_logic_vector(width-1 downto 0); 
  			 result : out std_logic_vector(width-1 downto 0);
  			 opcode, funcode : in std_logic_vector(5 downto 0)
  		   );
end Alu;




architecture Behavioral of Alu is
begin
	
process(a, b, opcode, funcode)
begin
	
	if(opcode = "000000") then
		
		case funcode is
			when "100000" => --ADD funcode=0x20
				result <= std_logic_vector(unsigned(a) + unsigned(b));
		
			when "10 0100" => --AND funcode=0x24
				result <= a and b;
				
		    
				
			when "100111" => --NOR funcode=0x27
				result <= a nor b;
			
			
			
			when others =>
				--assdcsx;
	    end case;
		
    end if;
	
end process;

end Behavioral;