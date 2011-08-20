library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity logo is
	port
	(
		clk  :  in std_logic;
		x,y	 :  in std_logic_vector(10 downto 0);   --coordinate
		r,g,b:	out std_logic
	);
end logo;

architecture behav of logo is

signal charromAddr : std_logic_vector(10 downto 0);
signal charromData : std_logic_vector(31 downto 0);

component charrom
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;

type titleType is array(0 to 13) of std_logic_vector(11 downto 0);
constant title : titleType := (X"2e0", x"3c0", x"440", x"3c0", x"3e0", x"420", x"460", x"000", x"000", x"000", x"000", x"000", x"000", x"000");
constant zwl   : titleType := (x"020", x"040", x"060", x"0e0", x"180", x"140", x"140", x"240", x"140", x"160", X"160", x"1a0", x"200", x"260");
constant lzj   : titleType := (x"080", x"0a0", x"0c0", x"0e0", x"180", x"140", x"140", x"240", x"140", x"160", X"160", x"1a0", x"220", x"260");

begin

charrom_inst : charrom 
	PORT MAP (
		address	 => charromAddr,
		clock	 => clk,
		q	 => charromData
	);

output: process(clk)
begin
if rising_edge(clk) then

	if (x >= 288 and x < 512 and y >= 128 and y < 160) then -- show title
		r <= '0';
		g <= '0';
		
		charromAddr <= "00000000000" + y(4 downto 0) + conv_integer(title(conv_integer(x(10 downto 5)) - 9));
		if (charromData(conv_integer(not x(4 downto 0))) = '1') then
			b <= '1';
		else 
			b <= '0';
		end if;
	elsif (x >= 160 and x < 608 and y >= 320 and y < 352) then -- show zwl
		r <= '0';
		b <= '0';
		
		charromAddr <= "00000000000" + y(4 downto 0) + conv_integer(zwl(conv_integer(x(10 downto 5)) - 5));
		if (charromData(conv_integer(not x(4 downto 0))) = '1') then
			g <= '1';
		else 
			g <= '0';
		end if;
	elsif (x >= 160 and x < 608 and y >= 384 and y < 416) then -- show lzj
		r <= '0';
		b <= '0';
		
		charromAddr <= "00000000000" + y(4 downto 0) + conv_integer(lzj(conv_integer(x(10 downto 5)) - 5));
		if (charromData(conv_integer(not x(4 downto 0))) = '1') then
			g <= '1';
		else 
			g <= '0';
		end if;
	else
		r <= '0';
		g <= '0';
		b <= '0';
	end if;



end if;
end process;

end behav;
