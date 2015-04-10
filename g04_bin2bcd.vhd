library ieee;
library lpm;
use lpm.lpm_components.all;
use ieee.std_logic_1164.all;

entity g04_bin2bcd is
	port ( bpm : in std_logic_vector(7 downto 0);
		   bcd : out std_logic_vector(11 downto 0);
		   clk : in std_logic); 
end g04_bin2bcd;

architecture implementation of g04_bin2bcd is
	signal out_bcd : std_logic_vector(11 downto 0);
	begin
	converter_lut : lpm_rom
	generic map (
		lpm_widthad => 8, -- sets the width of the ROM address bus
		lpm_numwords => 256, -- sets the words stored in the ROM
		lpm_outdata => "UNREGISTERED", -- no register on the output
		lpm_address_control => "REGISTERED", -- register on the input
		lpm_file => "g04_bin2bcd.mif", -- the ascii file containing the ROM data
		lpm_width => 12) -- the width of the word stored in each ROM location
	port map (
		address => bpm,
		inclock => clk,
		q => out_bcd);
	bcd <= out_bcd;
end implementation; 