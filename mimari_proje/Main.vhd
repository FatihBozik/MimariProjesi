--*******-----\
-- <MAIN.VHD> --
--*******-----/

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Constants.all;
use work.Alu.all;

--StatusRegister = [v, c, n, z]

entity Main is
   
   port( 
		 InstructionRegister : in std_logic_vector(width-1 downto 0);
		 --StatusRegister : in std_logic_vector(3 downto 0); 
		 programCounter: inout std_logic_vector(width-1 downto 0)
	   );
end Main;

architecture Behavioral of Main is
	-- Register file
	shared variable reg : register_array;
	
	-- R type
	shared variable rd : std_logic_vector(4 downto 0);
	shared variable sa : std_logic_vector(4 downto 0);
	
	-- R type ve I type
	shared variable funcode : std_logic_vector(5 downto 0); 
	shared variable rs : std_logic_vector(4 downto 0);      
	shared variable rt : std_logic_vector(4 downto 0);
	
	-- R type, I type, J type
	shared variable opcode : std_logic_vector(5 downto 0);

begin
process(InstructionRegister, programCounter)
begin
	opcode := InstructionRegister(31 downto 26);
	
	if opcode = "000000" then --R-type komut
		rs := InstructionRegister(25 downto 21);
		rt := InstructionRegister(20 downto 16);
		rd := InstructionRegister(15 downto 11);
		sa := InstructionRegister(10 downto 6);
		funcode := InstructionRegister(5 downto 0);
		
	    case funcode is
		    when "100000" => -- ADD funcode=0x20
				reg(to_integer(unsigned(rd))) := function_Add(reg(to_integer(unsigned(rs))), reg(to_integer(unsigned(rt))));
				programCounter <= std_logic_vector(unsigned(programCounter) + 4);
				
		    when "100010" => -- SUB funcode=0x22
				reg(to_integer(unsigned(rd))) := function_Sub(reg(to_integer(unsigned(rs))), reg(to_integer(unsigned(rt))));
				programCounter <= std_logic_vector(unsigned(programCounter) + 4);
				
			when "100100" => -- AND funcode=0x24
				reg(to_integer(unsigned(rd))) := function_And(reg(to_integer(unsigned(rs))), reg(to_integer(unsigned(rt))));
				programCounter <= std_logic_vector(unsigned(programCounter) + 4);
				
			when "100101" => -- OR funcode=0x25	
				reg(to_integer(unsigned(rd))) := function_Or(reg(to_integer(unsigned(rs))), reg(to_integer(unsigned(rt))));
				programCounter <= std_logic_vector(unsigned(programCounter) + 4);
				
			when "100111" => -- NOR funcode=0x27
			    reg(to_integer(unsigned(rd))) := function_Nor(reg(to_integer(unsigned(rs))), reg(to_integer(unsigned(rt))));
				programCounter <= std_logic_vector(unsigned(programCounter) + 4);
			
			when others =>
			
		end case;
	else	
		
		
	end if;
		
	
	
end process;
end Behavioral;





--library IEEE;
--use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
--use work.Constants.all;
--
--
--entity Main is
--	   port( a, b : in std_logic_vector(width-1 downto 0);
--	   	    	result : out std_logic_vector(width-1 downto 0); 
--		     IR: 
--  			 
--  			 pc : inout std_logic_vector(width-1 downto 0);
--  			 v, c, n, z : inout bit;
--  			 opcode, funcode : in std_logic_vector(5 downto 0)
--  		   );
--end Main;
--
--
--architecture Behavioral of Main is
--begin
--	
--process(a, b, opcode, funcode, pc)
--begin
--	
--	if(opcode = "000000") then	-- R-type fonksiyonlar  
--		case funcode is
--			when "100000" => -- ADD funcode=0x20
--				result <= std_logic_vector(unsigned(a) + unsigned(b));
--				pc <= std_logic_vector(unsigned(pc) + 4);
--				
--			when "100010" => -- SUB funcode=0x22
--				result <= std_logic_vector(unsigned(a) - unsigned(b));
--				pc <= std_logic_vector(unsigned(pc) + 4);
--				
--			when "100100" => -- AND funcode=0x24
--				result <= a and b;
--				pc <= std_logic_vector(unsigned(pc) + 4);
--				
--			when "100101" => -- OR funcode=0x25	
--				result <= a or b;
--				pc <= std_logic_vector(unsigned(pc) + 4);
--				
--			when "100111" => -- NOR funcode=0x27
--				result <= a nor b;
--				pc <= std_logic_vector(unsigned(pc) + 4);
--		end case;
--	else	
--		
--		
--	end if;
--	 
--
--	
--	
--end process;
--
--end Behavioral;