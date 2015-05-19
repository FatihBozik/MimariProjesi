--*******-----\
-- <MAIN.VHD> --
--*******-----/

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Constants.all;
use work.Alu.all;

-- SR = " V      C 	   N      Z"
-- SR = SR(0)  SR(1)  SR(2)  SR(3)

entity Main is
   port( 
		 IR : in std_logic_vector(width-1 downto 0);
		 SR : inout std_logic_vector(3 downto 0)	 
	   );
end Main;

architecture Behavioral of Main is

	-- ProgramCounter
	shared variable PC : std_logic_vector(width-1 downto 0);
	shared variable REG: register_array;
	shared variable MEM: memory_array := (others=> (others=>'0'));
	
	-- R type
	shared variable rd : std_logic_vector(4 downto 0);
	shared variable sa : std_logic_vector(4 downto 0);
	
	-- R type ve I type
	shared variable funcode : std_logic_vector(5 downto 0); 
	shared variable rs : std_logic_vector(4 downto 0);      
	shared variable rt : std_logic_vector(4 downto 0);
	
	--J ytpe
	shared variable imm_address: std_logic_vector(25 downto 0);
	
	-- R type, I type, J type
	shared variable opcode : std_logic_vector(5 downto 0);
	
	-- I type
	shared variable imm_offset : std_logic_vector(15 downto 0);
begin
process(IR, SR)
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
				REG(to_integer(unsigned(rt))) := zero; --Reg(Rt) <- 0 kullanýlmýyor.
				REG(to_integer(unsigned(rd))) := zero; --Reg(Rd) <- 0 kullanýlmýyor.
				PC :=  REG(to_integer(unsigned(rs)));  
			
			when "001001" => -- jalr funcode=0x09 (9)
				REG(to_integer(unsigned(rt))) := zero; --Reg(Rt) <- 0 kullanýlmýyor.	
				REG(to_integer(unsigned(rd))) := std_logic_vector(unsigned(PC) + 4);
				PC := REG(to_integer(unsigned(rs)));
				
			when "010100" => -- brz funcode=0x14 (20)
				if SR(3) = '1' then --SR(3) = Z
					PC := REG(to_integer(unsigned(rs)));
				else
					PC := std_logic_vector(unsigned(PC) + 4);
				end if;
				
			when "010101" => -- brn funcode=0x15 (21)
				if SR(3) = '0' then --SR(3) = Z
					PC := REG(to_integer(unsigned(rs)));
				else
					PC := std_logic_vector(unsigned(PC) + 4);
				end if;
			
			--TODO which defaults to 31
			when "010110" => -- balrz funcode=0x16 (22)
				REG(to_integer(unsigned(rt))) := zero;   --Reg(Rt) = 0 kullanýlmýyor.
				if SR(3) = '1' then --SR(3) = Z
					REG(to_integer(unsigned(rd))) := std_logic_vector(unsigned(PC) + 4);
					PC := REG(to_integer(unsigned(rs)));
				else
					PC := std_logic_vector(unsigned(PC) + 4);
				end if;	
			
			--TODO which defaults to 31
			when "010111" => -- balrn funcode=0x17 (23)
				REG(to_integer(unsigned(rt))) := zero; --Reg(Rt) = 0 kullanýlmýyor.
				if SR(3) = '0' then --SR(3) = Z
					REG(to_integer(unsigned(rd))) := std_logic_vector(unsigned(PC) + 4);
					PC := REG(to_integer(unsigned(rs)));
				else
					PC := std_logic_vector(unsigned(PC) + 4);
				end if;	
				
			when "100000" => -- add funcode=0x20 (32)
				REG(to_integer(unsigned(rd))) := function_Add(REG(to_integer(unsigned(rs))), REG(to_integer(unsigned(rt))));
				if REG(to_integer(unsigned(rd))) = uninitialized then  --overflow causes
					SR(0) <= '1';
				end if;
				PC := std_logic_vector(unsigned(PC) + 4);
				
		    when "100010" => -- sub funcode=0x22 (34)
				REG(to_integer(unsigned(rd))) := function_Sub(REG(to_integer(unsigned(rs))), REG(to_integer(unsigned(rt))));
				if REG(to_integer(unsigned(rd))) = uninitialized then  --overflow causes
					SR(0) <= '1';
				end if;
				PC := std_logic_vector(unsigned(PC) + 4);
				
			when "100100" => -- and funcode=0x24 (36)
				REG(to_integer(unsigned(rd))) := function_And(REG(to_integer(unsigned(rs))), REG(to_integer(unsigned(rt))));
				PC := std_logic_vector(unsigned(PC) + 4);
				
			when "100101" => -- or funcode=0x25	(37)
				REG(to_integer(unsigned(rd))) := function_Or(REG(to_integer(unsigned(rs))), REG(to_integer(unsigned(rt))));
				PC := std_logic_vector(unsigned(PC) + 4);
				
			when "100111" => -- nor funcode=0x27 (39)
			    REG(to_integer(unsigned(rd))) := function_Nor(REG(to_integer(unsigned(rs))), REG(to_integer(unsigned(rt))));
				PC := std_logic_vector(unsigned(PC) + 4);
			
			when "101010" => -- slt funcode=0x2a (42)
				if REG(to_integer(unsigned(rs))) < REG(to_integer(unsigned(rt))) then
					REG(to_integer(unsigned(rd))) := one;
				else
					REG(to_integer(unsigned(rd))) := zero;
				end if;
				PC := std_logic_vector(unsigned(PC) + 4);
	
			when others =>
			
		end case;
	
	-- J-type komutlarsa	
	elsif opcode = "000010" then -- j opcode=0x02 (2)
		imm_address := IR(25 downto 0);
		PC := PC(31 downto 28) & imm_address & "00";
		
	elsif opcode = "000011"	then -- jal opcode=0x03 (3)
		imm_address := IR(25 downto 0);
		Reg(31) := std_logic_vector(unsigned(PC) + 4);
		PC := PC(31 downto 28) & imm_address & "00";
	
	elsif opcode = "011000" then -- bz opcode=0x18 (24)
		if SR(3) = '1' then 
			imm_address := IR(25 downto 0);
			PC := PC(31 downto 28) & imm_address & "00";
		else
			PC := std_logic_vector(unsigned(PC) + 4);
		end if;
	
	elsif opcode = "011001" then -- bn opcode=0x19 (25)
		if SR(3) = '0' then
			imm_address := IR(25 downto 0);
			PC := PC(31 downto 28) & imm_address & "00";
		else
			PC := std_logic_vector(unsigned(PC) + 4);
		end if;
	
	elsif opcode = "011010" then -- balz opcode=0x1A (26)
		if SR(3) = '1' then
			imm_address := IR(25 downto 0);
			Reg(31) := std_logic_vector(unsigned(PC) + 4);
			PC := PC(31 downto 28) & imm_address & "00";
		else
			PC := std_logic_vector(unsigned(PC) + 4);
		end if;
		
	elsif opcode = "011011" then -- baln opcode=0x1B (27)
		if SR(3) = '0' then
			imm_address := IR(25 downto 0);
			Reg(31) := std_logic_vector(unsigned(PC) + 4);
			PC := PC(31 downto 28) & imm_address & "00";
		else
			PC := std_logic_vector(unsigned(PC) + 4);
		end if;
		
	else -- I-type komutlarsa
		
	    rs := IR(25 downto 21);
	   	rt := IR(20 downto 16);
	   	imm_offset := IR(15 downto 0);
	   	
	   	if opcode = "000100" then -- beq opcode=0x04 (4)
			if REG(to_integer(unsigned(rs))) = REG(to_integer(unsigned(rt))) then
				PC := std_logic_vector(signed(PC) + 4 + signed(sign_extend(imm_offset & "00")));
			else
				PC := std_logic_vector(unsigned(PC) + 4);
			end if;
	    
		elsif opcode = "000101" then -- bne opcode=0x05 (5)
			if REG(to_integer(unsigned(rs))) /= REG(to_integer(unsigned(rt))) then
				PC := std_logic_vector(signed(PC) + 4 + signed(sign_extend(imm_offset & "00")));
			else
				PC := std_logic_vector(unsigned(PC) + 4);	
			end if;
	    
		elsif opcode = "001000" then -- addi opcode=0x08 (8)
			REG(to_integer(unsigned(rt))) := function_Add(REG(to_integer(unsigned(rs))), sign_extend(imm_offset));
			if REG(to_integer(unsigned(rd))) = uninitialized then  --overflow causes
					SR(0) <= '1';
			end if;
			PC := std_logic_vector(unsigned(PC) + 4);
	
		elsif opcode = "001100" then -- andi opcode=0x0c (12)
			REG(to_integer(unsigned(rt))) := function_And(REG(to_integer(unsigned(rs))), extend(imm_offset));
			PC := std_logic_vector(unsigned(PC) + 4);
	
		elsif opcode = "001101" then -- ori opcode=0x0d	(13)
			REG(to_integer(unsigned(rt))) := function_Or(REG(to_integer(unsigned(rs))), extend(imm_offset));
			PC := std_logic_vector(unsigned(PC) + 4);
			
		elsif opcode = "010010" then -- jm opcode=0x12 (18)
			PC(31 downto 24) := MEM(to_integer(signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset))));
			PC(23 downto 16) := MEM(to_integer(1 + signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset))));
			PC(15 downto 8) := MEM(to_integer(2 + signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset))));
			PC(7 downto 0) := MEM(to_integer(3 + signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset)))); 
			
		elsif opcode = "010011" then -- jalm opcode=0x13 (19)
			REG(to_integer(unsigned(rt))) := std_logic_vector(unsigned(PC) + 4);
			PC(31 downto 24) := MEM(to_integer(signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset))));
			PC(23 downto 16) := MEM(to_integer(1 + signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset))));
			PC(15 downto 8) := MEM(to_integer(2 + signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset))));
			PC(7 downto 0) := MEM(to_integer(3 + signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset)))); 
			
			
		elsif opcode = "010100" then -- bmz opcode=0x14 (20)
			if SR(3) = '1' then
				PC(31 downto 24) := MEM(to_integer(signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset))));
				PC(23 downto 16) := MEM(to_integer(1 + signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset))));
				PC(15 downto 8) := MEM(to_integer(2 + signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset))));
				PC(7 downto 0) := MEM(to_integer(3 + signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset))));
			else
				PC := std_logic_vector(unsigned(PC) + 4);
			end if;
		elsif opcode = "010101" then -- bmn opcode=0x15 (21)
			if SR(3) = '0' then
				PC(31 downto 24) := MEM(to_integer(signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset))));
				PC(23 downto 16) := MEM(to_integer(1 + signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset))));
				PC(15 downto 8) := MEM(to_integer(2 + signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset))));
				PC(7 downto 0) := MEM(to_integer(3 + signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset))));
			else
				PC := std_logic_vector(unsigned(PC) + 4);
			end if;
			
		elsif opcode = "010110" then -- balmz opcode=0x16 (22)
			if SR(3) = '1' then
				Reg(to_integer(unsigned(rt))) := std_logic_vector(unsigned(PC) + 4);
				PC(31 downto 24) := MEM(to_integer(signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset))));
				PC(23 downto 16) := MEM(to_integer(1 + signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset))));
				PC(15 downto 8) := MEM(to_integer(2 + signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset))));
				PC(7 downto 0) := MEM(to_integer(3 + signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset))));
			else
				PC := std_logic_vector(unsigned(PC) + 4);
			end if;
		
		elsif opcode = "010111" then -- balmn opcode=0x17 (23)
			if SR(3) = '0' then
				Reg(to_integer(unsigned(rt))) := std_logic_vector(unsigned(PC) + 4);
				PC(31 downto 24) := MEM(to_integer(signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset))));
				PC(23 downto 16) := MEM(to_integer(1 + signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset))));
				PC(15 downto 8) := MEM(to_integer(2 + signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset))));
				PC(7 downto 0) := MEM(to_integer(3 + signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset))));
			else
				PC := std_logic_vector(unsigned(PC) + 4);
			end if;
		
		elsif opcode = "011110" then -- jpc opcode=0x1E (30)
			PC := std_logic_vector(signed(PC) + 4 + signed(sign_extend(imm_offset & "00")));
			
		elsif opcode = "011111" then -- jalpc opcode=0x1F (31)
			REG(to_integer(unsigned(rt))) := std_logic_vector(unsigned(PC) + 4);
			PC := std_logic_vector(signed(PC) + 4 + signed(sign_extend(imm_offset & "00")));
			
		elsif opcode = "100011" then -- lw opcode=0x23 (35)
			REG(to_integer(unsigned(rt)))(31 downto 24) := MEM(to_integer(signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset))));
		    REG(to_integer(unsigned(rt)))(23 downto 16) := MEM(to_integer(1 + signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset))));
		    REG(to_integer(unsigned(rt)))(15 downto 8) := MEM(to_integer(2 + signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset))));
		    REG(to_integer(unsigned(rt)))(7 downto 0) := MEM(to_integer(3 + signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset))));
		    PC := std_logic_vector(unsigned(PC) + 4);
		     
		elsif opcode = "101011" then -- sw opcode=0x2b (43)
			MEM(to_integer(signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset)))) := REG(to_integer(unsigned(rt)))(31 downto 24);
		    MEM(to_integer(1 + signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset)))) := REG(to_integer(unsigned(rt)))(23 downto 16);
		    MEM(to_integer(2 + signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset)))) := REG(to_integer(unsigned(rt)))(15 downto 8);
		    MEM(to_integer(3 + signed(Reg(to_integer(unsigned(rs)))) + signed(sign_extend(imm_offset)))) := REG(to_integer(unsigned(rt)))(7 downto 0);
		    PC := std_logic_vector(unsigned(PC) + 4);
		    
		elsif opcode = "101100" then --beqal opcode=0x2c (44)
			if REG(to_integer(unsigned(rs))) = REG(to_integer(unsigned(rt))) then
				Reg(31) := std_logic_vector(unsigned(PC) + 4);
				PC := std_logic_vector(signed(PC) + 4 + signed(sign_extend(imm_offset & "00")));
			else
			    PC := std_logic_vector(unsigned(PC) + 4);
			end if;
		
		elsif opcode = "101101" then --bneal opcode=0x2d (45)
			if REG(to_integer(unsigned(rs))) /= REG(to_integer(unsigned(rt))) then
				Reg(31) := std_logic_vector(unsigned(PC) + 4);
				PC := std_logic_vector(signed(PC) + 4 + signed(sign_extend(imm_offset & "00")));
			else
			    PC := std_logic_vector(unsigned(PC) + 4);
			end if;		
		
	    end if;
	    
		
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