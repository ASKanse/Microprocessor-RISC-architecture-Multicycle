library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all; 
library ieee;
use ieee.numeric_std.all; 


entity pr_encoder is
	port( pein : in std_logic_vector (7 downto 0);
		  peout: out std_logic_vector(2 downto 0);
		  modpein: out std_logic_vector (7 downto 0);
		  pego: out std_logic);
end entity;

architecture enc_behave of pr_encoder is

begin
process (pein) 
begin
   modpein <= pein;
	if(pein(7) = '1') then
		peout <= "000";
	        modpein(7) <= '0';
	elsif(pein(6) = '1') then
		peout <= "001";
	        modpein(6) <= '0';
	elsif(pein(5) = '1') then
		peout <= "010";
	        modpein(5) <= '0';
	elsif(pein(4) = '1') then
		peout <= "011";
	        modpein(4) <= '0';
	elsif(pein(3) = '1') then
		peout <= "100";
	        modpein(3) <= '0';
	elsif(pein(2) = '1') then
		peout <= "101";
           modpein(2) <= '0';  
	elsif(pein(1) = '1') then
		peout <= "110";
           modpein(1) <= '0';
	elsif(pein(0) = '1') then
		peout <= "111";
           modpein(0) <= '0';
	else
		peout <= "111";
			  
	end if; 

	if (pein = "00000000") then
		pego <= '0';
	else 
		pego <= '1';
	end if;

end process;
end architecture enc_behave;