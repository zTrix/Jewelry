Library IEEE;
use IEEE.STD_Logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity jewelry is
  port(reset		 : in std_logic;
       startGame	 : in std_logic;
       pauseGame	 : in std_logic;
       clock         : in std_logic;
       button		 : in std_logic_vector(3 downto 0);
       R, G, B, H, V : out std_logic);
end entity;

architecture show of jewelry is

signal link_r, link_g, link_b : std_logic;
signal link_r_logo, link_g_logo, link_b_logo : std_logic;
signal doubleClock : std_logic;

component vgacon is
    port(reset_n		:in std_logic;
        clk             :in std_logic;
        rin, gin, bin   :in std_logic;
        row, column : out std_logic_vector(10 downto 0);
        hs,vs			:out STD_LOGIC;
		r,g,b			:out STD_LOGIC);
end component;

component logo
	port
	(
		clk  :  in std_logic;
		x,y	 :  in std_logic_vector(10 downto 0);   --coordinate
		r,g,b:	out std_logic
	);
end component;

component game
	PORT(clock : IN STD_LOGIC;
		startGame: in std_logic;
		pauseGame	 : in std_logic;
         button : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        -- timer : IN STD_LOGIC;
         x,y : IN STD_LOGIC_VECTOR(10 downto 0);
         red, green, blue : OUT std_logic
	);
end component;

component doubleclk
	PORT
	(
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC
	);
end component;

signal row, column : std_logic_vector(10 downto 0);
signal red, green, blue : std_logic;
signal rom_data    : std_logic_vector(7 downto 0);
signal bdata	   : std_logic;

begin

  VGA : component vgacon
    port map ( reset, clock,
               red, green, blue,
               row, column,
               H, V,
               R, G, B);
	
logo_inst : logo
	port map
	(
		clk => clock,
		x=>column,
		y=>row,
		r=>link_r_logo,
		g=>link_g_logo,
		b=>link_b_logo
	);
	
game_inst     : game
	port map(doubleClock, startGame, pauseGame, button, column, row, link_r, link_g, link_b);
	
	
doubleclk_inst : doubleclk PORT MAP (
		
		inclk0	 => clock,
		c0	 => doubleclock
		
	);

	
 
 RGB : process(reset, clock, row, column)
 begin
 if rising_edge(clock) then
	if startGame = '1' then
		red <= link_r;
		green <= link_g;
		blue <= link_b;
	else
		red <= link_r_logo;
		green <= link_g_logo;
		blue <= link_b_logo;
	end if;
    
end if;
end process;

end architecture;