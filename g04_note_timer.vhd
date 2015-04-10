library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	   
entity g04_note_timer is
port ( clk, reset : in std_logic;
	   note_duration : in std_logic_vector(2 downto 0);
	   triplet : in std_logic;
	   tempo_enable : in std_logic;
	   TRIGGER : out std_logic);
end g04_note_timer;

architecture implementation of g04_note_timer is
signal tempo_pulses : unsigned(8 downto 0);
signal count : unsigned (8 downto 0);
signal triplet_and_note_duration : std_logic_vector(3 downto 0);
begin
	triplet_and_note_duration <= triplet&note_duration;
	with triplet_and_note_duration select tempo_pulses <=
		"000000011" when "0000",
		"000000110" when "0001",
		"000001100" when "0010",
		"000011000" when "0011",
		"000110000" when "0100",
		"001100000" when "0101",
		"011000000" when "0110",
		"110000000" when "0111",
		"000000010" when "1000",
		"000000100" when "1001",
		"000001000" when "1010",
		"000010000" when "1011",
		"000100000" when "1100",
		"001000000" when "1101",
		"010000000" when "1110",
		"100000000" when "1111";
	counter : process (clk, tempo_pulses, reset, tempo_enable)
	begin
		if (reset = '0') then
			count <= "000000000";
			TRIGGER <= '1';
		elsif (clk = '1' and clk'event) then
			if (tempo_enable = '1') then
				count <= count + 1;
			end if;
			if (count = 1) then
				TRIGGER <= '0';
			end if;
			if (count = tempo_pulses-1) then
				TRIGGER <= '1';
				count <= "000000000";
			end if;
		end if;
	end process;		
		
	

end implementation;

