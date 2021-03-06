library ieee;
use ieee.std_logic_1164.all;
	
entity g04_integration is
	port( clk, reset : in std_logic;
		note_duration : in std_logic_vector(2 downto 0);
	    triplet : in std_logic;
	    bpm : in std_logic_vector(7 downto 0);
	    beat: out std_logic;
	    segment_display : out std_logic_vector(27 downto 0);
	    tempo_enable : out std_logic;
		TRIGGER : out std_logic);
end g04_integration;

architecture implementation of g04_integration is

component g04_note_timer
	port ( clk, reset : in std_logic;
	   note_duration : in std_logic_vector(2 downto 0);
	   triplet : in std_logic;
	   tempo_enable : in std_logic;
	   TRIGGER : out std_logic);
end component;

component g04_tempo
	port ( bpm : in std_logic_vector(7 downto 0);
		   clk, reset : in std_logic;
		   beat: out std_logic;
		   count2 : out std_logic_vector(4 downto 0);
		   tempo_enable : out std_logic;
		   segment_display : out std_logic_vector(27 downto 0));
end component;

signal tempo_enable_intermediate : std_logic;
signal dummy_count2 : std_logic_vector(4 downto 0);
signal inter_trigger : std_logic;

begin
	
	tempo : g04_tempo
	port map (bpm, clk, reset, beat, dummy_count2, tempo_enable_intermediate, segment_display);
	
	note_timer : g04_note_timer
	port map (clk, reset, note_duration, not triplet, tempo_enable_intermediate, inter_trigger);
	
	TRIGGER <= inter_trigger;
	tempo_enable <= tempo_enable_intermediate;
	
end implementation;
