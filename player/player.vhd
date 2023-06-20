library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity player is
	port(clk: in std_logic;
		  enable: in std_logic;
		  composition: in std_logic_vector(9 downto 0);
		  sound: out std_logic
	);
end player;

architecture player_arch of player is
	signal citaj: std_logic := '0'; --postavljamo na 0 ako je sve procitano
	signal play: std_logic := '0';
	signal read_address: std_logic_vector(1 downto 0) := "00";
	signal sound_length: std_logic_vector(2 downto 0) := "000";
	signal sound_signal: std_logic := '0';
	signal sekunde, sekunde_next: integer := 0;
	signal counter50, counter50_next: integer := 0;
	signal i, i_next: integer := 9;
	
	
	component ROM is
		port(
		re_i: in std_logic;
		raddr_i: in std_logic_vector(1 downto 0);
		rdata_o: out std_logic_vector(2 downto 0)
		);
	end component;
	
	component buzzer is 
		port(
		  clk: in std_logic;
		  sound_length: in std_logic_vector(2 downto 0);
		  enable: in std_logic;
		  sound: out std_logic
		  );
	end component;
	
	component FourBit7seg is
    port(
        U : in std_logic_vector(3 downto 0);
        segments : out std_logic_vector(6 downto 0)
    );
	end component;
	
	begin
	process(clk, enable)
		begin
		if enable = '0' then
			sekunde <= 0;
			i <= 9;
		elsif rising_edge(clk) then
			counter50 <= counter50_next;
			sekunde <= sekunde_next;
			i <= i_next;
		end if;
	end process;
	
	sound <= sound_signal;
	
	counter50_next <= 0 when counter50 = 50_000_000 else
							counter50 + 1;
							
	sekunde_next <= sekunde + 1 when counter50 = 50_000_000 and sekunde < 5 else
						 0 when counter50 = 50_000_000 and sekunde = 5 else
						 sekunde;
						 
	i_next <= i - 2 when sekunde = 5 and enable = '1' and counter50 = 50_000_000 else 
				 i;
				 
	read_address <= composition(i) & composition(i-1) when citaj = '1' and counter50 = 50_000_000 else 
						 read_address;
								
	citaj <= '1' when enable = '1' and i > 0 else 
				'0';
				
	play <= '1' when sekunde <= 4 and citaj = '1' else 
			  '0';
			  
	

	
	za_ROM: ROM port map(citaj, read_address, sound_length);
	za_buzzer: buzzer port map(clk, sound_length, play, sound_signal);
		
end player_arch;