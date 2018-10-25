library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all; 
library ieee;
use ieee.numeric_std.all; 


entity pr_encoder is
	port( pein : in std_logic_vector (7 downto 0);
		  peout: out std_logic_vector(2 downto 0);
		  pego: out std_logic);
end entity;

architecture enc_behave of pr_encoder is

begin
process (pein) 
begin

	if(pein(0) = '1') then
		peout <= "111";
	        pein(0) <= 0;
	elsif(pein(1) = '1') then
		peout <= "110";
	        pein(1) <= 0;
	elsif(pein(2) = '1') then
		peout <= "101";
	        pein(2) <= 0;
	elsif(pein(3) = '1') then
		peout <= "100";
	        pein(3) <= 0;
	elsif(pein(4) = '1') then
		peout <= "011";
	        pein(4) <= 0;
	elsif(pein(5) = '1') then
		peout <= "010";
                pein(5) <= 0;  
	elsif(pein(6) = '1') then
		peout <= "001";
                pein(6) <= 0;
	elsif(pein(7) = '1') then
		peout <= "000";
                pein(7) <= 0;
	end if; 

	if (pein = "00000000") then
		pego <= '1';
	else 
		pego <= '0';
	end if;

end process;
end architecture enc_behave;
