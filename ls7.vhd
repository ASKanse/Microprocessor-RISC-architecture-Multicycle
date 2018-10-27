library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;


entity ls7 is 
	port( ls7_in : in std_logic_vector(15 downto 0);
		  ls7_out: out std_logic_vector(15 downto 0));
end entity;

architecture behave_ls7 of ls7 is 

begin 
 ls7_out(15 downto 7) <= ls7_in(8 downto 0); 
 ls7_out(6) <= '0'; 
 ls7_out(5) <= '0'; 
 ls7_out(4) <= '0'; 
 ls7_out(3) <= '0'; 
 ls7_out(2) <= '0'; 
 ls7_out(1) <= '0';
 ls7_out(0) <= '0'; 
end behave_ls7; 