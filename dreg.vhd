library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;
library ieee;
use ieee.numeric_std.all; 

entity dreg is
  generic (data_width:integer:= 16);
  port (Din: in std_logic_vector(data_width-1 downto 0);
        Dout: out std_logic_vector(data_width-1 downto 0);
        clk, enable,reset: in std_logic);
end entity;
architecture Behave of dreg is
signal Const_0 : std_logic_vector( 15 downto 0);
begin
COnst_0 <= "0000000000000000";
  process(clk,reset)
  begin
  if(reset = '1') then
		Dout <= COnst_0(data_width-1 downto 0);
  else
    if(clk'event and (clk  = '1')) then
      if(enable = '1') then
        Dout <= Din;
      end if;
    end if;
	end if;
  end process;
end Behave;