
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity TwosComplement is
port (
  input: in std_logic_vector(15 downto 0);
  output: out std_logic_vector(15 downto 0)
);
end entity TwosComplement;
architecture Behave of TwosComplement is
begin
output <= std_logic_vector(unsigned(not input) + 1);
end Behave;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity ALU2 is
   port(alu_in_1, alu_in_2: in std_logic_vector(15 downto 0);
        op_in: in std_logic_vector(3 downto 0);
        alu_out: out std_logic_vector(15 downto 0);
        carry: out std_logic;
        zero: out std_logic);
end entity;


architecture Struct of ALU2 is
  signal alu_out_read : std_logic_vector(16 downto 0);
  signal extended_1: std_logic_vector(16 downto 0);
  signal extended_2: std_logic_vector(16 downto 0);
begin

   alu_out <= alu_out_read(15 downto 0);
	extended_1(15 downto 0) <= alu_in_1;
	extended_2(15 downto 0) <= alu_in_2;
   zero <= '1' when alu_out_read(15 downto 0) = "0000000000000000" else '0';
	
	process(op_in,alu_out_read,alu_in_1, alu_in_2,extended_1, extended_2)
   begin
	if(alu_in_1(15) = '0') then 
		extended_1(16) <= '0';
	else 
		extended_1(16) <= '1';
	end if;
	
	if(alu_in_2(15) = '0') then 
		extended_2(16) <= '0';
	else 
		extended_2(16) <= '1';
	end if;
	
	if(op_in(3 downto 0) = "0000") then
      alu_out_read <= std_logic_vector(unsigned(extended_1) + unsigned(extended_2));
   elsif(op_in(3 downto 0) = "0010") then
      alu_out_read <= extended_1 nand extended_2;
	else
		alu_out_read <= std_logic_vector(unsigned(extended_1) - unsigned(extended_2));
   end if;
	
	if(op_in(3 downto 0) = "0000"and alu_out_read(16) = '1') then
		carry <= '1';
	elsif(op_in(3 downto 0) = "0000"and alu_out_read(16) = '0') then
		carry <= '0';
	end if;
	end process;

end Struct;