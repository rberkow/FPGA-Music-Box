-- entity name: g04_7_segment_decoder
--
-- Copyright (C) 2015 Ruth Berkow, Yarden Arane
-- Version 1.0
-- Author: Ruth Berkow; ruth.berkow@mail.mcgill.ca
--		   Yarden Arane; yarden.arane@mail.mcgill.ca
-- Date: February 09, 2015
library ieee; -- allows use of the std_logic_vector type
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library lpm; -- allows use of the Altera library modules
use lpm.lpm_components.all;

entity g04_7_segment_decoder is
port ( code : in std_logic_vector(3 downto 0);
 RippleBlank_In : in std_logic;
 RippleBlank_Out : out std_logic;
segments : out std_logic_vector(6 downto 0));
end g04_7_segment_decoder;

architecture implementation of g04_7_segment_decoder is
signal out_segments : std_logic_vector(7 downto 0); 
begin
with code & RippleBlank_In select out_segments <=
	"11111111" when "00001",
	"00000010" when "00000",
	"10011110" when "00010",
	"10011110" when "00011",
	"00100100" when "00100",
	"00100100" when "00101",
	"00001100" when "00110",
	"00001100" when "00111",
	"10011000" when "01000",
	"10011000" when "01001",
	"01001000" when "01010",
	"01001000" when "01011",
	"01000000" when "01100",
	"01000000" when "01101",
	"00011110" when "01110",
	"00011110" when "01111",
	"00000000" when "10000",
	"00000000" when "10001",
	"00001000" when "10010",
	"00001000" when "10011",
	"00010000" when "10100",
	"00010000" when "10101",
	"11000000" when "10110",
	"11000000" when "10111",
	"01100010" when "11000",
	"01100010" when "11001",
	"10000100" when "11010",
	"10000100" when "11011",
	"01100000" when "11100",
	"01100000" when "11101",
	"01110000" when "11110",
	"01110000" when "11111";

segments <= out_segments(7 downto 1);
RippleBlank_Out <= out_segments(0);

end implementation;
