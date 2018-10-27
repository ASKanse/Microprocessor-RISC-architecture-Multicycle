library std;
library ieee;
use ieee.std_logic_1164.all;
package MemoryComponent is

type MemArray is array(0 to ((2**4)-1)) of std_logic_vector(15 downto 0);

constant INIT_MEMORY : MemArray := (
  0 => "0001010010000001",
  1 => "0110010000111000",
  2 => "1111111111111111",
  3 => "1111111111111111",
  4 => "1111111111111111",
  5 => "1111111111111111",
  6 => "1111111111111111",
  7 => "1111111111111111",
  8 => "1111111111111111",
  9 => "1111111111111111",
  10 => "1111111111111111",
  11 => "1111111111111111",
  12 => "1111111111111111",
  13 => "1111111111111111",
  14 => "1111111111111111",
  15 => "1111111111111111"
);
end MemoryComponent;


library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all; 
library ieee;
use ieee.numeric_std.all; 
library work;
use work.MemoryComponent.all;


entity memory is 
	port ( wr,rd,clk : in std_logic; 
			Add_in, D_in: in std_logic_vector(15 downto 0);
			Y_out: out std_logic_vector(15 downto 0)); 
end entity; 

architecture memory_behave of memory is
	signal mem_reg: MemArray := INIT_MEMORY;
	begin	
	process(wr,rd, Add_in, D_in,clk,mem_reg)
		begin 
		if (rd = '1') then
			Y_out <= mem_reg(to_integer(unsigned(Add_in(3 downto 0))));
		elsif (rd = '0') then
			Y_out <= "1111111111111111";
		end if;
		
		if rising_edge(clk) then
			if wr = '1' then
				mem_reg(to_integer(unsigned(Add_in(3 downto 0)))) <= D_in;
			end if;
		end if;
		
	end process; 
	
	end memory_behave;