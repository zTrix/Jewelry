library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity showblock is
	port
	(
		clk  :  in std_logic;
		blkTp:	in std_logic_vector(2 downto 0);
		x,y	 :  in std_logic_vector(4 downto 0);   --use relative coordinate
		r,g,b:	out std_logic
	);
end showblock;

architecture behav of showblock is

signal tmpAddr: std_logic_vector(7 downto 0);
signal tmpRomData: std_logic_vector(31 downto 0);

component blockrom
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;

begin

blockrom_inst : component blockrom 
	PORT MAP (
		address	 => tmpAddr,
		clock	 => clk,
		q	 => tmpRomData
	);

output: process (clk)
begin
	if clk'event and clk = '1' then
		case blkTp is
			when "000" =>                -- empty
				tmpAddr <= "00000000" + y;
				if (tmpRomData(conv_integer(x)) = '1') then
					r <= '1';
					g <= '1';
					b <= '1';
				else 
					r <= '0';
					g <= '0';
					b <= '0';
				end if;
			when "001" =>				-- blue
				tmpAddr <= "00100000" + y;
				r <= '0';
				g <= '0';
				if (tmpRomData(conv_integer(x)) = '1') then
					b <= '1';
				else 
					b <= '0';
				end if;
			when "010" => 				-- red
				tmpAddr <= "01000000" + y;
				g <= '0';
				b <= '0';
				if (tmpRomData(conv_integer(x)) = '1') then
					r <= '1';
				else 
					r <= '0';
				end if;
			when "011" =>				-- yellow
				tmpAddr <= "01100000" + y;
				b <= '0';
				if (tmpRomData(conv_integer(x)) = '1') then
					r <= '1';
					g <= '1';
				else 
					r <= '0';
					g <= '0';
				end if;
			when "100" =>				-- green
				tmpAddr <= "10000000" + y;
				r <= '0';
				b <= '0';
				if (tmpRomData(conv_integer(x)) = '1') then
					g <= '1';
				else 
					g <= '0';
				end if;
			when "101" =>
				tmpAddr <= "10100000" + y;
				g <= '0';
				if (tmpRomData(conv_integer(x)) = '1') then
					r <= '1';
					b <= '1';
				else 
					r <= '0';
					b <= '0';
				end if;
			when "110" =>
				tmpAddr <= "11000000" + y;
				if (tmpRomData(conv_integer(x)) = '1') then
					r <= '1';
					g <= '1';
					b <= '1';
				else
					r <= '0';
					g <= '0';
					b <= '0';
				end if;
			when others =>				-- full white (for debug)
				r <= '1';
				g <= '1';
				b <= '1';
		end case;
	end if;

end process;

end behav;