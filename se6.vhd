library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;


entity se6 is 
	port( se6_in : in std_logic_vector(5 downto 0);
		  se6_out: out std_logic_vector(15 downto 0));
end entity;

architecture behave_se6 of se6 is 

begin 
 se6_out(5 downto 0) <= se6_in(5 downto 0); 
 se6_out(15) <= se6_in(5); 
 se6_out(14) <= se6_in(5); 
 se6_out(13) <= se6_in(5); 
 se6_out(12) <= se6_in(5); 
 se6_out(11) <= se6_in(5); 
 se6_out(10) <= se6_in(5); 
 se6_out(9) <= se6_in(5); 
 se6_out(8) <= se6_in(5);
 se6_out(7) <= se6_in(5); 
 se6_out(6) <=se6_in(5);
end behave_se6; 