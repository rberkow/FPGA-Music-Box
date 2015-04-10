library ieee;
library lpm;
use lpm.lpm_components.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity g04_FSM_Controller is 
	port (clk : in std_logic;
		  reset: in std_logic;
		  INIT: in std_logic;
		  pause: in std_logic;
		  stop: in std_logic;
		  song: in std_logic;
		  tempo: in std_logic_vector(5 downto 0);
		  repeat: in std_logic;
		  transpose: in unsigned(0 downto 0);
		  start: in std_logic;
		  note_number: out std_logic_vector(3 downto 0);
		  octave: out std_logic_vector(2 downto 0);
		  duration: out std_logic_vector(2 downto 0);
		  volume: out std_logic_vector(3 downto 0);
		  beat: out std_logic;
		  AUD_MCLK: out std_logic;
		  AUD_BCLK: out std_logic;
		  AUD_DACDAT: out std_logic;
		  AUD_DACLRCK: out std_logic;
		  I2C_SDAT: out std_logic;
		  I2C_SCLK: out std_logic;
		  FL_ADDR: out std_logic_vector(21 downto 0);
		  FL_DQ: inout std_logic_vector(7 downto 0);
		  FL_CE_N: out std_logic;
		  FL_OE_N: out std_logic;
		  FL_WE_N: out std_logic;
		  FL_RST_N: out std_logic;
		  segments: out std_logic_vector(27 downto 0);
		  trigger_real : out std_logic;
		  trigger_follow : out std_logic;
		  increment_address : out std_logic);
end g04_FSM_Controller;

architecture a of g04_FSM_Controller is
signal state: integer range 0 to 2;
signal address: unsigned(7 downto 0);
signal trigger: std_logic;
signal end_of_song: std_logic;
signal raw_note_data: std_logic_vector(15 downto 0);
signal song_1_data: std_logic_vector(15 downto 0);
signal song_2_data: std_logic_vector(15 downto 0);
signal triplet: std_logic;
signal shifted: std_logic;
signal address_incremented: std_logic;
signal parsed_duration: std_logic_vector(2 downto 0);
signal parsed_triplet: std_logic;
signal bpm: std_logic_vector(7 downto 0);
signal dead_segments: std_logic_vector(27 downto 0);
signal dead_segments1: std_logic_vector(6 downto 0);
signal dead_segments2: std_logic_vector(6 downto 0);
signal dead_segments3: std_logic_vector(6 downto 0);
signal dead_segments4: std_logic_vector(6 downto 0);
signal dead_tempo_enable: std_logic;
signal dead_rb_out: std_logic;
signal dead_rb_out2: std_logic;
signal dead_rb_out3: std_logic;
signal state_vector : std_logic_vector(1 downto 0);
signal play_sound : std_logic;
signal immediate_restart : std_logic;
signal transposed_octave : std_logic_vector(2 downto 0);

-- buffer signals
signal volume_buff: std_logic_vector(3 downto 0);
signal beat_buff: std_logic;
signal reset_buff: std_logic;
signal clk_buff: std_logic;
signal INIT_buff: std_logic;
signal note_number_buff: std_logic_vector(3 downto 0);
signal octave_buff: std_logic_vector(2 downto 0);
signal trigger_buff: std_logic;
signal AUD_MCLK_buff: std_logic;
signal AUD_BCLK_buff: std_logic;
signal AUD_DACDAT_buff: std_logic;
signal AUD_DACLRCK_buff: std_logic;
signal I2C_SDAT_buff: std_logic;
signal I2C_SCLK_buff: std_logic;
signal FL_ADDR_buff: std_logic_vector(21 downto 0);
signal FL_DQ_buff: std_logic_vector(7 downto 0);
signal FL_CE_N_buff: std_logic;
signal FL_OE_N_buff: std_logic;
signal FL_WE_N_buff: std_logic;
signal FL_RST_N_buff: std_logic;
signal segments_buff: std_logic_vector(27 downto 0);
signal stop_buff: std_logic;
component g04_altera_display
	port (INIT: in std_logic;
		  clk_50: in std_logic;
		  rst: in std_logic;
		  note: in std_logic_vector(3 downto 0);
		  octave: in std_logic_vector(2 downto 0);
		  trigger: in std_logic;
		  volume : in std_logic_vector(3 downto 0);
		  AUD_MCLK: out std_logic;
		  AUD_BCLK: out std_logic;
		  AUD_DACDAT: out std_logic;
		  AUD_DACLRCK: out std_logic;
		  I2C_SDAT: out std_logic;
		  I2C_SCLK: out std_logic;
		  FL_ADDR: out std_logic_vector(21 downto 0);
		  FL_DQ: inout std_logic_vector(7 downto 0);
		  FL_CE_N: out std_logic;
		  FL_OE_N: out std_logic;
		  FL_WE_N: out std_logic;
		  FL_RST_N: out std_logic;
		  segment1: out std_logic_vector(6 downto 0);
		  segment2: out std_logic_vector(6 downto 0);
		  segment3: out std_logic_vector(6 downto 0);
		  segment4: out std_logic_vector(6 downto 0));
end component;
component g04_integration
	port( clk, reset : in std_logic;
		note_duration : in std_logic_vector(2 downto 0);
	    triplet : in std_logic;
	    bpm : in std_logic_vector(7 downto 0);
	    beat: out std_logic;
	    segment_display : out std_logic_vector(27 downto 0);
	    tempo_enable : out std_logic;
		TRIGGER : out std_logic);
end component;
component g04_7_segment_decoder
	port(code : in std_logic_vector(3 downto 0);
		RippleBlank_In : in std_logic;
		RippleBlank_Out : out std_logic;
		segments : out std_logic_vector(6 downto 0));
end component;

begin
trigger_buff <= trigger;
trigger_real <= trigger;
trigger_follow <= trigger_buff;
increment_address <= address_incremented;

with state select state_vector <=
	"00" when 0,
	"01" when 1,
	"10" when 2,
	"11" when others;

note_display : g04_7_segment_decoder
	port map(code => note_number_buff,
			RippleBlank_In => '0',
			RippleBlank_out => dead_rb_out,
			segments => segments(27 downto 21));
state_display : g04_7_segment_decoder
	port map(code => "00"&state_vector,
			RippleBlank_In => '0',
			RippleBlank_out => dead_rb_out2,
			segments => segments(6 downto 0));

octave_display : g04_7_segment_decoder
	port map(code => '0'&octave_buff,
			RippleBlank_In => '0',
			RippleBlank_out => dead_rb_out3,
			segments => segments(20 downto 14));
			

timing_generator : g04_integration
	port map(clk => clk_buff,
			 reset => reset_buff and not immediate_restart,
			 note_duration => parsed_duration,
			 triplet => parsed_triplet,
			 bpm => bpm,
			 beat => beat_buff,
			 segment_display => dead_segments,
			 tempo_enable => dead_tempo_enable,
			 TRIGGER => trigger);
			 

triplet <= parsed_triplet;
duration <= parsed_duration;
bpm <= tempo&"00";
-- assigning buffer signals
volume <= volume_buff;
beat <= beat_buff;
INIT_buff <= INIT;
clk_buff <= clk;
 reset_buff <= reset;
note_number <= note_number_buff;
 octave <= octave_buff;
 AUD_MCLK<= AUD_MCLK_buff;
 AUD_BCLK <= AUD_BCLK_buff;
 AUD_DACDAT <= AUD_DACDAT_buff;
 AUD_DACLRCK <= AUD_DACLRCK_buff;
 I2C_SDAT <= I2C_SDAT_buff;
 I2C_SCLK <= I2C_SCLK_buff;
 FL_ADDR <= FL_ADDR_buff;
 FL_CE_N<= FL_CE_N_buff;
 FL_OE_N <= FL_OE_N_buff;
 FL_WE_N <= FL_WE_N_buff;
 FL_RST_N <= FL_RST_N_buff;

 -- end of that bullshit
flash_reader : g04_altera_display
	port map(INIT => INIT_buff,
			 clk_50 => clk_buff,
			 rst => play_sound,
			 note => note_number_buff,
			 octave => octave_buff,
			 volume => volume_buff,
			 trigger => not(trigger_buff) and (stop),
			 AUD_MCLK => AUD_MCLK_buff,
			 AUD_BCLK => AUD_BCLK_buff,
			 AUD_DACDAT => AUD_DACDAT_buff,
			 AUD_DACLRCK => AUD_DACLRCK_buff,
			 I2C_SCLK => I2C_SCLK_buff,
			 I2C_SDAT => I2C_SDAT_buff,
			 FL_ADDR => FL_ADDR_buff,
			 FL_DQ => FL_DQ,
			 FL_CE_N => FL_CE_N_buff,
			 FL_OE_N => FL_OE_N_buff,
			 FL_WE_N => FL_WE_N_buff,
			 FL_RST_N => FL_RST_N_buff,
			 segment1 => dead_segments1,
			 segment2 => dead_segments2,
			 segment3 => dead_segments3,
			 segment4 => dead_segments4);
FSM : process(clk, reset, stop)
begin
	if reset = '0' then
		state <= 0;
	elsif rising_edge(clk) then
		--song selection
		if song = '0' then
			raw_note_data <= song_1_data;
		else
			raw_note_data <= song_2_data;
		end if;
		case state is
			--stop state
			when 0 =>
				play_sound <= '0';
				address <= "00000000";
				address_incremented <= '0';
											
				if start = '0' or immediate_restart = '1' then
					state <= 1;
				end if;
			--play state
			when 1 =>
				play_sound <= '1';
				if trigger = '1'  and address_incremented = '0' then
					immediate_restart <= '0';
					--parsing mif data
					note_number_buff <= raw_note_data(3 downto 0);
					octave_buff <= std_logic_vector(unsigned(raw_note_data(6 downto 4)) - transpose);
					parsed_duration <= raw_note_data(9 downto 7);
					parsed_triplet <= raw_note_data(10);
					volume_buff <= raw_note_data(14 downto 11);
					end_of_song <= raw_note_data(15);				
					
					if pause = '1' then
						state <= 2;
					end if;
					if stop = '0' then
						state <= 0;
					end if;
					address_incremented <= '1';
				end if;
				if end_of_song = '1' then
					if repeat = '1' then
						immediate_restart <= '1';
						state <= 0;
					else
						state <= 0;
					end if;
				end if;
				if trigger = '0' and address_incremented = '1' then
					address <= address + 1;
					address_incremented <= '0';
					shifted <= '0';
				end if;
			--pause state
			when 2 =>
				play_sound <= '0';
				if pause = '0' then
					state <= 1;
				end if;
		end case;
	end if;
end process;	
song_1_lut : lpm_rom
	generic map (
		lpm_widthad => 8, -- sets the width of the ROM address bus
		lpm_numwords => 256, -- sets the words stored in the ROM
		lpm_outdata => "UNREGISTERED", -- no register on the output
		lpm_address_control => "REGISTERED", -- register on the input
		lpm_file => "g00_demo_song.mif", -- the ascii file containing the ROM data
		lpm_width => 16) -- the width of the word stored in each ROM location
	port map (
		address => std_logic_vector(address),
		inclock => clk,
		q => song_1_data); 

song_2_lut : lpm_rom
	generic map (
		lpm_widthad => 8, -- sets the width of the ROM address bus
		lpm_numwords => 256, -- sets the words stored in the ROM
		lpm_outdata => "UNREGISTERED", -- no register on the output
		lpm_address_control => "REGISTERED", -- register on the input
		lpm_file => "g04_my_song.mif", -- the ascii file containing the ROM data
		lpm_width => 16) -- the width of the word stored in each ROM location
	port map (
		address => std_logic_vector(address),
		inclock => clk,
		q => song_2_data); 


end a;
