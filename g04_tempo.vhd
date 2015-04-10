library ieee;
library lpm;
use lpm.lpm_components.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity g04_tempo is
	port ( bpm : in std_logic_vector(7 downto 0);
		   clk, reset : in std_logic;
		   beat: out std_logic;
		   count2 : out std_logic_vector(4 downto 0);
		   tempo_enable : out std_logic;
		   segment_display : out std_logic_vector(27 downto 0));
end g04_tempo;

architecture implementation of g04_tempo is
	signal q1, freq_div_factor : std_logic_vector(21 downto 0);
	signal intermediate_enable : std_logic;
	signal q2 : std_logic_vector(4 downto 0);
	signal xx, zero1 : std_logic;
	signal bcd : std_logic_vector(11 downto 0);
	signal rb_out, zero : std_logic_vector(3 downto 0);
	component g04_bin2bcd
		port ( bpm : in std_logic_vector(7 downto 0);
			   bcd : out std_logic_vector(11 downto 0);
			   clk : in std_logic); 
	end component;
	component g04_7_segment_decoder
		port ( code : in std_logic_vector(3 downto 0);
			   RippleBlank_In : in std_logic;
			   RippleBlank_Out : out std_logic;
			   segments : out std_logic_vector(6 downto 0));
	end component;
	begin
	display0 : g04_7_segment_decoder
		port map (bcd(3 downto 0), rb_out(1), rb_out(0), segment_display(6 downto 0));
	display1 : g04_7_segment_decoder
		port map (bcd(7 downto 4), rb_out(2), rb_out(1), segment_display(13 downto 7));
	display2 : g04_7_segment_decoder
		port map (bcd(11 downto 8), rb_out(3), rb_out(2), segment_display(20 downto 14));
	display3 : g04_7_segment_decoder
		port map (zero, zero1, rb_out(3), segment_display(27 downto 21));
	
	converter : g04_bin2bcd port map (bpm, bcd, clk);
	
	zero <= "0000";
	zero1 <= '0';
	with q1 select intermediate_enable <=
		'1' when "0000000000000000000000",
		'0' when others;
	tempo_enable <= intermediate_enable;
	counter1 : lpm_counter
	GENERIC MAP (
		lpm_direction => "DOWN",
		lpm_port_updown => "PORT_UNUSED",
		lpm_type => "LPM_COUNTER",
		lpm_width => 22
	)
	port map (
		clock => clk,
		sload => intermediate_enable,
		data => freq_div_factor,
		aclr => not reset,
		q => q1);
	counter2 : lpm_counter
	GENERIC MAP (
		lpm_direction => "DOWN",
		lpm_port_updown => "PORT_UNUSED",
		lpm_type => "LPM_COUNTER",
		lpm_width => 5
	)
	port map (
		sload=> xx and intermediate_enable,
		clock => clk,
		data => "10111",
		aclr => not reset,
		cnt_en => intermediate_enable,
		q => q2);
	count2<=q2;
	with q2 select xx <=
		'1' when "00000",
		'0' when others;
	beat <= q2(4);
	
	bpm_lut : lpm_rom
	generic map (
		lpm_widthad => 8, -- sets the width of the ROM address bus
		lpm_numwords => 256, -- sets the words stored in the ROM
		lpm_outdata => "UNREGISTERED", -- no register on the output
		lpm_address_control => "REGISTERED", -- register on the input
		lpm_file => "g04_freq_lut.mif", -- the ascii file containing the ROM data
		lpm_width => 22) -- the width of the word stored in each ROM location
	port map (
		address => bpm,
		inclock => clk,
		q => freq_div_factor); 

end implementation;
