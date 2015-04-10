LIBRARY ieee;
USE ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

LIBRARY work;

ENTITY g04_altera_display IS 
	PORT
	(
		clk_50 :  IN  STD_LOGIC;
		rst :  IN  STD_LOGIC;
		trigger :  IN  STD_LOGIC;
		INIT :  IN  STD_LOGIC;
		FL_DQ :  INOUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		note :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		octave :  IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		volume :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		FL_RST_N :  OUT  STD_LOGIC;
		FL_WE_N :  OUT  STD_LOGIC;
		FL_OE_N :  OUT  STD_LOGIC;
		FL_CE_N :  OUT  STD_LOGIC;
		AUD_MCLK :  OUT  STD_LOGIC;
		AUD_BCLK :  OUT  STD_LOGIC;
		AUD_DACDAT :  OUT  STD_LOGIC;
		AUD_DACLRCK :  OUT  STD_LOGIC;
		I2C_SDAT :  OUT  STD_LOGIC;
		I2C_SCLK :  OUT  STD_LOGIC;
		FL_ADDR :  OUT  STD_LOGIC_VECTOR(21 DOWNTO 0);
		segment1 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		segment2 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		segment3 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		segment4 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
END g04_altera_display;

ARCHITECTURE bdf_type OF g04_altera_display IS 

COMPONENT g04_flash_read_control
	PORT(clk_50 : IN STD_LOGIC;
		 rst : IN STD_LOGIC;
		 read_done : IN STD_LOGIC;
		 step : IN STD_LOGIC;
		 trigger : IN STD_LOGIC;
		 note : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 octave : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 odata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 read_start : OUT STD_LOGIC;
		 data_size_o : OUT STD_LOGIC_VECTOR(21 DOWNTO 0);
		 flash_address : OUT STD_LOGIC_VECTOR(21 DOWNTO 0);
		 sample_data : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

COMPONENT slowed_altera_up_flash_memory_up_core_standalone
GENERIC (FLASH_MEMORY_ADDRESS_WIDTH : INTEGER;
			FLASH_MEMORY_DATA_WIDTH : INTEGER
			);
	PORT(i_clock : IN STD_LOGIC;
		 i_reset_n : IN STD_LOGIC;
		 i_read : IN STD_LOGIC;
		 i_write : IN STD_LOGIC;
		 i_erase : IN STD_LOGIC;
		 FL_DQ : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 i_address : IN STD_LOGIC_VECTOR(21 DOWNTO 0);
		 i_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 o_done : OUT STD_LOGIC;
		 FL_CE_N : OUT STD_LOGIC;
		 FL_OE_N : OUT STD_LOGIC;
		 FL_WE_N : OUT STD_LOGIC;
		 FL_RST_N : OUT STD_LOGIC;
		 FL_ADDR : OUT STD_LOGIC_VECTOR(21 DOWNTO 0);
		 o_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT g04_7_segment_decoder
	PORT(RippleBlank_In : IN STD_LOGIC;
		 code : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 RippleBlank_Out : OUT STD_LOGIC;
		 segments : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
END COMPONENT;

COMPONENT g00_audio_interface
	PORT(clk : IN STD_LOGIC;
		 rst : IN STD_LOGIC;
		 INIT : IN STD_LOGIC;
		 W_EN : IN STD_LOGIC;
		 LDATA : IN SIGNED(23 DOWNTO 0);
		 RDATA : IN SIGNED(23 DOWNTO 0);
		 pulse : OUT STD_LOGIC;
		 AUD_MCLK : OUT STD_LOGIC;
		 AUD_BCLK : OUT STD_LOGIC;
		 AUD_DACDAT : OUT STD_LOGIC;
		 AUD_DACLRCK : OUT STD_LOGIC;
		 I2C_SDAT : OUT STD_LOGIC;
		 I2C_SCLK : OUT STD_LOGIC
	);
END COMPONENT;

SIGNAL	data_size_o :  STD_LOGIC_VECTOR(21 DOWNTO 0);
SIGNAL	gnd :  STD_LOGIC;
SIGNAL	sample_data :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_15 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_5 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_16 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_8 :  STD_LOGIC_VECTOR(21 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_9 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_10 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_11 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_13 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_14 :  STD_LOGIC;

SIGNAL	GDFX_TEMP_SIGNAL_0 :  STD_LOGIC_VECTOR(23 DOWNTO 0);
SIGNAL	GDFX_TEMP_SIGNAL_1 :  STD_LOGIC_VECTOR(23 DOWNTO 0);

BEGIN 
SYNTHESIZED_WIRE_16 <= '0';
SYNTHESIZED_WIRE_14 <= '1';

GDFX_TEMP_SIGNAL_0 <= (sample_data(15 DOWNTO 0) & "00000000");
GDFX_TEMP_SIGNAL_1 <= (sample_data(15 DOWNTO 0) & "00000000");


b2v_inst : g04_flash_read_control
PORT MAP(clk_50 => clk_50,
		 rst => SYNTHESIZED_WIRE_15,
		 read_done => SYNTHESIZED_WIRE_1,
		 step => SYNTHESIZED_WIRE_2,
		 trigger => SYNTHESIZED_WIRE_3,
		 note => note,
		 octave => octave,
		 odata => SYNTHESIZED_WIRE_4,
		 read_start => SYNTHESIZED_WIRE_5,
		 data_size_o => data_size_o,
		 flash_address => SYNTHESIZED_WIRE_8,
		 sample_data => sample_data);


b2v_inst1 : slowed_altera_up_flash_memory_up_core_standalone
GENERIC MAP(FLASH_MEMORY_ADDRESS_WIDTH => 22,
			FLASH_MEMORY_DATA_WIDTH => 8
			)
PORT MAP(i_clock => clk_50,
		 i_data => "00000000",
		 i_reset_n => rst,
		 i_read => SYNTHESIZED_WIRE_5,
		 i_write => SYNTHESIZED_WIRE_16,
		 i_erase => SYNTHESIZED_WIRE_16,
		 FL_DQ => FL_DQ,
		 i_address => SYNTHESIZED_WIRE_8,
		 o_done => SYNTHESIZED_WIRE_1,
		 FL_CE_N => FL_CE_N,
		 FL_OE_N => FL_OE_N,
		 FL_WE_N => FL_WE_N,
		 FL_RST_N => FL_RST_N,
		 FL_ADDR => FL_ADDR,
		 o_data => SYNTHESIZED_WIRE_4);


b2v_inst10 : g04_7_segment_decoder
PORT MAP(RippleBlank_In => SYNTHESIZED_WIRE_9,
		 code => data_size_o(11 DOWNTO 8),
		 RippleBlank_Out => SYNTHESIZED_WIRE_10,
		 segments => segment2);


b2v_inst11 : g04_7_segment_decoder
PORT MAP(RippleBlank_In => SYNTHESIZED_WIRE_10,
		 code => data_size_o(7 DOWNTO 4),
		 RippleBlank_Out => SYNTHESIZED_WIRE_11,
		 segments => segment3);


b2v_inst12 : g04_7_segment_decoder
PORT MAP(RippleBlank_In => SYNTHESIZED_WIRE_11,
		 code => data_size_o(3 DOWNTO 0),
		 segments => segment4);


SYNTHESIZED_WIRE_13 <= NOT(INIT);




SYNTHESIZED_WIRE_3 <= NOT(trigger);



SYNTHESIZED_WIRE_15 <= NOT(rst);



b2v_inst5 : g00_audio_interface
PORT MAP(clk => clk_50,
		 rst => SYNTHESIZED_WIRE_15,
		 INIT => SYNTHESIZED_WIRE_13,
		 W_EN => SYNTHESIZED_WIRE_14,
		 LDATA => resize(signed(GDFX_TEMP_SIGNAL_0) * signed(volume), 24),
		 RDATA => resize(signed(GDFX_TEMP_SIGNAL_1) * signed(volume), 24),
		 pulse => SYNTHESIZED_WIRE_2,
		 AUD_MCLK => AUD_MCLK,
		 AUD_BCLK => AUD_BCLK,
		 AUD_DACDAT => AUD_DACDAT,
		 AUD_DACLRCK => AUD_DACLRCK,
		 I2C_SDAT => I2C_SDAT,
		 I2C_SCLK => I2C_SCLK);




b2v_inst9 : g04_7_segment_decoder
PORT MAP(code => data_size_o(15 DOWNTO 12),
		 RippleBlank_Out => SYNTHESIZED_WIRE_9,
		 RippleBlank_In => gnd,
		 segments => segment1);


gnd <= '0';
END bdf_type;