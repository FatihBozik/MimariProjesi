library ieee;
use ieee.numeric_std.all;
use work.Constants.all;
use ieee.std_logic_1164.all;


package Functions is

function T(a: in std_logic_vector; b: in std_logic_vector ) return std_logic_vector;
	
function Andi(a: in std_logic_vector; b: in std_logic_vector ) return std_logic_vector;
	
end package Functions;



package body Functions is

function Topla(a: in std_logic_vector; b: in std_logic_vector ) return std_logic_vector is 
begin
	return std_logic_vector(unsigned(a) + unsigned(b));
end Topla;

function f_And(a: in std_logic_vector; b: in std_logic_vector ) return std_logic_vector is 
begin
	return (a and b);
end f_And;



end package body Functions;

