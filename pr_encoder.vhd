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
		  pego: out std_logic;
		  pe_out: out std_logic_vector(2 downto 0);
		  mod_pein: out std_logic_vector (7 downto 0)
		  );
end entity;

architecture enc_behave of pr_encoder is
signal mp : std_logic_vector (7 downto 0);
signal po : std_logic_vector(2 downto 0);
begin
process (pein) 
begin
   mp <= pein;
	if(pein(7) = '1') then
		po <= "000";
	        mp(7) <= '0';
	elsif(pein(6) = '1') then
		po <= "001";
	        mp(6) <= '0';
	elsif(pein(5) = '1') then
		po <= "010";
	        mp(5) <= '0';
	elsif(pein(4) = '1') then
		po <= "011";
	        mp(4) <= '0';
	elsif(pein(3) = '1') then
		po <= "100";
	        mp(3) <= '0';
	elsif(pein(2) = '1') then
		po <= "101";
           mp(2) <= '0';  
	elsif(pein(1) = '1') then
		po <= "110";
           mp(1) <= '0';
	elsif(pein(0) = '1') then
		po <= "111";
           mp(0) <= '0';
	else
		po <= "111";
			  
	end if; 
	
	mod_pein <= mp;
	pe_out <= po;
	modpein <= mp;
	peout <= po;
	
	if (pein = "00000000") then
		pego <= '0';
	else 
		pego <= '1';
	end if;
	

end process;
end architecture enc_behave;