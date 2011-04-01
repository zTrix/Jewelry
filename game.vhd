LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY game IS
    PORT(clock : IN STD_LOGIC;
         startGame: in std_logic;
         pauseGame	 : in std_logic;
         button : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        -- timer : IN STD_LOGIC;
         x,y : IN STD_LOGIC_VECTOR(10 downto 0);
         red, green, blue : OUT std_logic);
END game;

ARCHITECTURE a of game IS
--SIGNAL rom_address: std_logic_vector(8 DOWNTO 0);
signal gametimer	:std_logic;
signal mainbox_x, mainbox_y: std_logic_vector(8 downto 0);
signal mainbox_r, mainbox_g, mainbox_b: std_logic;

signal charromAddr : std_logic_vector(10 downto 0);
signal charromData : std_logic_vector(31 downto 0);
signal score  	   : integer range 0 to 1000;

type titleType is array(0 to 6) of std_logic_vector(11 downto 0);
constant title : titleType := (X"2e0", x"3c0", x"440", x"3c0", x"3e0", x"420", x"460");
constant scoreText : titleType := (x"360", x"3a0", x"400", x"420", x"3c0", x"0e0", x"000");

type numType is array(0 to 4) of integer;

component charrom
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;

component timer
	port(
		clock                   : in std_logic;
		timer                  : out std_logic
	);
end component;

component mainbox
	port(
		clock	: in std_logic;
		startGame: in std_logic;
		pauseGame	 : in std_logic;
		button  : in std_logic_vector(3 downto 0);
		timer	: in std_logic;
		rx, ry  : in std_logic_vector(8 downto 0); --use relative coordinate
		r,g,b	: out std_logic;
		score	: out integer range 0 to 1000
	);
end component;
 
begin 
 
timer_inst: component timer
	port map(clock, gametimer);
	
mainbox_inst: component mainbox
	port map(clock, startGame, pauseGame, button, gametimer, mainbox_x, mainbox_y, mainbox_r, mainbox_g, mainbox_b, score);
	
charrom_inst : charrom 
	PORT MAP (
		address	 => charromAddr,
		clock	 => clock,
		q	 => charromData
	);
 
output: PROCESS(clock)
variable tmpx, tmpy: std_logic_vector(10 downto 0);
variable num : numType;
BEGIN
if rising_edge(clock) then
	if y < 100 then
		if (x >= 288 and x < 512 and y >= 64 and y < 96) then -- show title
			red <= '0';
			green <= '0';
		
			charromAddr <= "00000000000" + y(4 downto 0) + conv_integer(title(conv_integer(x(10 downto 5)) - 9));
			if (charromData(conv_integer(not x(4 downto 0))) = '1') then
				blue <= '1';
			else 
				blue <= '0';
			end if;
		else
			red <= '0';
			green <= '0';
			blue <= '0';
		end if;
--		if x < 100 and button(0) = '1' then
--			red <= '1';
--			green <= '0';
--			blue <= '0';
--		elsif x < 200 and button(1) = '1' then
--			red <= '0';
--			green <= '1';
--			blue <= '0';
--		elsif x < 300 and button(2) = '1' then
--			red <= '0';
--			green <= '0';
--			blue <= '1';
--		elsif x < 400 and button(3) = '1' then
--			red <= '1';
--			green <= '1';
--			blue <= '0';
--		elsif x < 500 then
--			red <= '1';
--			green <= '0';
--			blue <= '1';
--		elsif x < 600 then
--			red <= '0';
--			green <= '1';
--			blue <= '1';
--		elsif x < 700 then
--			red <= '1';
--			green <= '1';
--			blue <= '1';
--		else 
--			red <= '0';
--			green <= '0';
--			blue <= '0';
--		end if;
	else

		--	if (x >= 128 and x < 352 and y >= 128 and y < 576) then
		if (x >= 216 and x < 440 and y >= 128 and y < 576) then
		--	if (x < 144 or x >= 336 or y < 144 or y >= 560) then
			if (x < 232 or x >= 424 or y < 144 or y >= 560) then
				--red <= gametimer;
				red <= '0';
				green <= '1';
				blue <= '1';
			else 
			--	tmpx := (x - 144);
				tmpx := (x - 232);
				tmpy := (y - 144);
				mainbox_x <= tmpx(8 downto 0);
				mainbox_y <= tmpy(8 downto 0);
				red <= mainbox_r;
				green <= mainbox_g;
				blue <= mainbox_b;
			end if;
		elsif (x >= 512 and x < 704 and y >=192 and y < 224) then -- show score title
			blue <= '0';
			green <= '0';
			
			charromAddr <= "00000000000" + y(4 downto 0) + conv_integer(scoreText(conv_integer(x(10 downto 5)) - 16));
			if (charromData(conv_integer(not x(4 downto 0))) = '1') then
				red  <= '1';
			else 
				red <= '0';
			end if;
			
		elsif (x >= 512 and x < 672 and y >= 256 and y < 288) then -- show score num 17 18 19
			blue <= '0';
			
			num(0) := score / 100;
			num(1) := (score / 10) mod 10;
			num(2) := score mod 10;
			num(3) := 0;
			num(4) := 0;
			
			charromAddr <= y(4 downto 0) + "00101000000" + num(conv_integer((x(10 downto 5)) - 16)) * 32;
			if (charromData(conv_integer(not x(4 downto 0))) = '1') then
				red  <= '1';
				green <= '1';
			else 
				red <= '0';
				green <= '0';
			end if;
		else	
			red <= '0';
			green <= '0';
			blue <= '0';
		end if;
	
	end if;
end if;
END PROCESS;

END a;

