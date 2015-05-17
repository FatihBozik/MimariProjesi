--*******-----\
-- <MAIN.VHD> --
--*******-----/

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Constants.all;
use work.Alu.all;

-- SR = " V      C 	   N      Z"
-- SR = SR(0)  SR(1)  SR(2)  SR(3)

entity Main is
   
   port( 
		 IR : in std_logic_vector(width-1 downto 0);
		 SR : inout std_logic_vector(3 downto 0); 
		 PC: inout std_logic_vector(width-1 downto 0);
		 REG : inout register_array
	   );
end Main;

architecture Behavioral of Main is
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
process(IR, PC, REG, SR)
begin
	opcode := IR(31 downto 26);
	
	if opcode = "000000" then --R-type komut
		rs := IR(25 downto 21);
		rt := IR(20 downto 16);
		rd := IR(15 downto 11);
		sa := IR(10 downto 6);
		funcode := IR(5 downto 0);
		
		case funcode is
			when "001000" => -- jr funcode=0x08 (8)
				REG(to_integer(unsigned(rt))) <= zero; --Reg(Rt) <- 0 kullanýlmýyor.
				REG(to_integer(unsigned(rd))) <= zero; --Reg(Rd) <- 0 kullanýlmýyor.
				PC <=  REG(to_integer(unsigned(rs)));  
			
			when "001001" => -- jalr funcode=0x09 (9)
				
			
			--TODO which defaults to 31
			when "010110" => -- balrz funcode=0x16 (22)
				PC <= std_logic_vector(unsigned(PC) + 4);
				REG(to_integer(unsigned(rt))) <= zero;   --Reg(Rt) = 0 kullanýlmýyor.
				if SR(3) = '1' then --SR(3) = Z
					REG(to_integer(unsigned(rd))) <= PC;
					PC <= REG(to_integer(unsigned(rs)));
				end if;	
			
			--TODO which defaults to 31
			when "010111" => -- balrn funcode=0x17 (23)
				PC <= std_logic_vector(unsigned(PC) + 4);
				REG(to_integer(unsigned(rt))) <= X"00000000"; --Reg(Rt) = 0 kullanýlmýyor.
				if SR(3) = '0' then --SR(3) = Z
					REG(to_integer(unsigned(rd))) <= PC;
					PC <= REG(to_integer(unsigned(rs)));
				end if;	
				
			when "100000" => -- add funcode=0x20 (32)
				REG(to_integer(unsigned(rd))) <= function_Add(REG(to_integer(unsigned(rs))), REG(to_integer(unsigned(rt))));
				PC <= std_logic_vector(unsigned(PC) + 4);
				
		    when "100010" => -- sub funcode=0x22 (34)
				REG(to_integer(unsigned(rd))) <= function_Sub(REG(to_integer(unsigned(rs))), REG(to_integer(unsigned(rt))));
				PC <= std_logic_vector(unsigned(PC) + 4);
				
			when "100100" => -- and funcode=0x24 (36)
				REG(to_integer(unsigned(rd))) <= function_And(REG(to_integer(unsigned(rs))), REG(to_integer(unsigned(rt))));
				PC <= std_logic_vector(unsigned(PC) + 4);
				
			when "100101" => -- or funcode=0x25	(37)
				REG(to_integer(unsigned(rd))) <= function_Or(REG(to_integer(unsigned(rs))), REG(to_integer(unsigned(rt))));
				PC <= std_logic_vector(unsigned(PC) + 4);
				
			when "100111" => -- nor funcode=0x27 (39)
			    REG(to_integer(unsigned(rd))) <= function_Nor(REG(to_integer(unsigned(rs))), REG(to_integer(unsigned(rt))));
				PC <= std_logic_vector(unsigned(PC) + 4);
			
			when "101010" => -- slt funcode=0x2a (42)
				if REG(to_integer(unsigned(rs))) < REG(to_integer(unsigned(rt))) then
					REG(to_integer(unsigned(rd))) <= one;
				else
					REG(to_integer(unsigned(rd))) <= zero;
				end if;
				PC <= std_logic_vector(unsigned(PC) + 4);
	
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