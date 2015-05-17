library ieee;
use ieee.numeric_std.all;
use work.Constants.all;
use ieee.std_logic_1164.all;

package Alu is

--function function_Name(parameter list) return type;
function function_Add(data1: in std_logic_vector; data2: in std_logic_vector) return std_logic_vector;
function function_Sub(data1: in std_logic_vector; data2: in std_logic_vector ) return std_logic_vector;	
function function_And(data1: in std_logic_vector; data2: in std_logic_vector ) return std_logic_vector;
function function_Or(data1: in std_logic_vector; data2: in std_logic_vector ) return std_logic_vector;
function function_Nor(data1: in std_logic_vector; data2: in std_logic_vector ) return std_logic_vector;
	
end package Alu;


package body Alu is

--function function_Name(parameter list) return type is 
--begin
--	 
--end function_Add;
function function_Add(data1: in std_logic_vector; data2: in std_logic_vector) return std_logic_vector is 
begin
	if std_logic_vector(signed(data1) + signed(data2)) > max_value or 
	   std_logic_vector(signed(data1) + signed(data2)) < min_value then  --overflow causes	  
		return uninitialized; 
	else
		return std_logic_vector(signed(data1) + signed(data2));
	end if;
end function_Add;

function function_Sub(data1: in std_logic_vector; data2: in std_logic_vector ) return std_logic_vector is 
begin
	return std_logic_vector(signed(data1) - signed(data2));
end function_Sub;

function function_And(data1: in std_logic_vector; data2: in std_logic_vector ) return std_logic_vector is 
begin
	return (data1 and data2);
end function_And;

function function_Or(data1: in std_logic_vector; data2: in std_logic_vector ) return std_logic_vector is 
begin
	return (data1 or data2);
end function_Or;

function function_Nor(data1: in std_logic_vector; data2: in std_logic_vector ) return std_logic_vector is 
begin
	return (data1 nor data2);
end function_Nor;

end package body Alu;

