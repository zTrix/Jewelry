library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity mainbox is port
	(
		clock	: in std_logic;
		startGame: in std_logic;
		pauseGame	 : in std_logic;
		button  : in std_logic_vector(3 downto 0);
		timer	: in std_logic;
		rx, ry  : in std_logic_vector(8 downto 0); --use relative coordinate
		r,g,b	: out std_logic;
		score	: out integer range 0 to 1000
	);
end mainbox;

architecture behav of mainbox is

type fallState is array (0 to 2) of std_logic_vector(2 downto 0); -- type of falling blocks
type rowType   is array (0 to 7) of std_logic_vector(2 downto 0);
type bRowType is array (0 to 7) of std_logic;
type tableType is array (0 to 14) of rowType;        -- table (row)(column)
type bTableType is array (0 to 14) of bRowType;      -- row column

signal fall_block: fallState;    -- top to bottom    [0] is bottom
signal table : tableType;        -- row column

SIGNAL count_timer : STD_LOGIC_VECTOR(7 DOWNTO 0);

signal link_r, link_g, link_b : std_logic;
signal curType: std_logic_vector(2 downto 0);
signal link_x, link_y : std_logic_vector(4 downto 0);

signal posRow, posCol, lastRow, lastCol : integer;
signal touchBottom, press: std_logic;

signal fallromData: std_logic_vector(8 downto 0);
signal fallromAddr: std_logic_vector(7 downto 0);
signal changing: std_logic;            -- indicate changing block from fallrom.mif
signal dead: std_logic;				   -- game state : dead
signal cutting: std_logic;		   	   -- cutting the block
signal cutAni: std_logic;
signal link_score : integer range 0 to 1000;

component showblock
	port
	(
		clk  :  in std_logic;
		blkTp:	in std_logic_vector(2 downto 0);
		x,y	 :  in std_logic_vector(4 downto 0);   --use relative coordinate
		r,g,b:	out std_logic
	);
end component;

component fallrom
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
	);
end component;


begin

-- curType <= "000";
-- link_x <= "00000";
-- link_y <= "00000";


fallrom_inst : fallrom PORT MAP (
		address	 => fallromAddr,
		clock	 => clock,
		q	 => fallromData
	);

showblock_inst: component showblock
	port map(clock, curType, link_x, link_y, 
			 r, g, b);

-----------------------------------------------------------------------
use_showBlock: process (clock, timer)
begin
if rising_edge(clock) then
	link_x <= rx(4 downto 0);
	link_y <= ry(4 downto 0);
	
	curType <= table(1+conv_integer(ry(8 downto 5)))(1+conv_integer(rx(7 downto 5)));
end if;
end process;
------------------------------------------------------------------------


----------------------------------------------------------update fall block
updateFallBlock: process(timer, count_timer, touchBottom)
variable rotate:std_logic := '0';
variable tmpBlk:std_logic_vector(2 downto 0) := "000";
begin
	if (startGame = '0') then
--		fallRomAddr <= (others => '0');
		fallRomAddr <= count_timer;
		fall_block(0) <= fallRomData(2 downto 0);
		fall_block(1) <= fallRomData(5 downto 3);
		fall_block(2) <= fallRomData(8 downto 6);
		changing <= '0';
		rotate := '0';
	else 
		if rising_edge(timer) then
			if touchBottom = '1' and dead = '0' then
				if changing = '0' then
					changing <= '1';
					fallRomAddr <= fallRomAddr + 1;
					fall_block(0) <= fallRomData(2 downto 0);
					fall_block(1) <= fallRomData(5 downto 3);
					fall_block(2) <= fallRomData(8 downto 6);
				end if;
			else
				changing <= '0';
				if (button(3) = '0')then
					if (rotate = '0') then
						rotate := '1';
						tmpBlk := fall_block(0);
						fall_block(0) <= fall_block(1);
						fall_block(1) <= fall_block(2);
						fall_block(2) <= tmpBlk;
					end if;
				else 
					rotate := '0';
				end if;
			end if;
		end if;
	end if;
end process;
----------------------------------------------------------update fall block

-------------------------------------------------update count_timer-----
times : PROCESS(timer, button)
BEGIN
    IF rising_edge(timer) THEN
		if pauseGame = '1' and cutting = '0' then
          IF count_timer = "1111111" THEN
             count_timer <= (others=>'0');
          ELSE
             count_timer <= count_timer + 1;       
          END IF;
        end if;
    END IF;
END PROCESS times;
------------------------------------------------------------------------

------------------------------------------------------------------------
Vertical_position : PROCESS(timer)
BEGIN
	if startGame = '0' then
		posRow <= 0;
		touchBottom <= '1';
		dead <= '0';
	else
		IF rising_edge(timer) THEN
			if (count_timer = "1111111") or (button(2) = '0' and count_timer(3 downto 0) = "1111") then
				if cutting = '1' then
					posRow <= 0;
				else
					if ((posRow < 13) and (table(posRow + 1)(posCol) = "000")) then
						posRow <= posRow + 1;
						touchBottom <= '0';
					else 
						touchBottom <= '1';
						if(table(0)(1) /= "000" or 
						   table(0)(2) /= "000" or 
						   table(0)(3) /= "000" or
						   table(0)(4) /= "000" or
						   table(1)(4) /= "000" or
						   table(0)(5) /= "000" or
						   table(0)(6) /= "000") then
							dead <= '1';
						else 
							posRow <= 0;
						end if;
					end if;
				end if;
			end if;
		end if;
    end if;
END PROCESS Vertical_position;
------------------------------------------------------------------------

------------------------------------------------------------------------
Horizontal_position : PROCESS(timer, button)
BEGIN
	if startGame = '0' then
		posCol <= 4;
		press <= '0';
	else
		if touchBottom = '1' then
			posCol <= 4;
		else 
			if rising_edge(timer) then
				IF button(1) = '0' THEN
					if (posCol > 1) and press = '0' then
						if table(posRow)(posCol - 1) = "000" then
							press <= '1';
							posCol <= posCol - 1;
						end if;
					end if;
				elsif button(0) = '0' then
					if (posCol < 6) and press = '0' then
						if table(posRow)(posCol + 1) = "000" then
							press <= '1';
							posCol <= posCol + 1;
						end if;
					end if;
				else
					press <= '0';
				END IF;
			end if;
		end if;      
    end if;
END PROCESS Horizontal_position;

updateTable: process(timer, button)
variable flag, tmpCut:std_logic := '0';
variable counter: std_logic_vector(3 downto 0);
variable cutCnter: std_logic_vector(5 downto 0);
variable typeCnter: std_logic_vector(2 downto 0);
variable tmpTable: bTableType;
variable tmpStart, tmpEnd:integer:=0;
variable deltaScore : integer;
begin
	flag := '0';
	if startGame = '0' then
		table <= (others=>(others=>(others=>'0')));
		lastCol <= 4;
		lastRow <= 0;
		counter := "0000";
		cutting <= '0';
		score <= 0;
		link_score <= 0;
	else 
		if rising_edge(timer) then
			if dead = '0' then
				if touchBottom = '0' then
					cutting <= '0';
					cutCnter := "000000";
					cutAni <= '0';
					for i in 0 to 2 loop
						if (lastRow >= i) then
							table(lastRow - i)(lastCol) <= "000";
						end if;
					end loop;
					
					for i in 0 to 2 loop
						if (posRow >= i) then
							table(posRow-i)(posCol) <= fall_block(i);
						end if;
					end loop;
				else
					if cutAni = '0' then
					
						tmpTable := (others => (others => '0'));
						-------first find all the blocks that should be cut----------------------
						
							-- horizental cut----------------------------------------------------
						for i in 1 to 14 loop
							tmpStart := 1;
							tmpEnd   := 1;
							for j in 2 to 7 loop
								if table(i)(j) /= "000" and table(i)(j) = table(i)(j-1) then
									tmpEnd := j;
								else
									if tmpEnd - tmpStart >= 2 then
										for k in 1 to 6 loop
											if k <= tmpEnd and k >= tmpStart then
												tmpTable(i)(k) := '1';
											end if;
										end loop;
									end if;
									tmpEnd := j;
									tmpStart := j;
								end if;
							end loop;
						end loop;
						
							--vetical cut----------------------------------------------------------
						for i in 1 to 6 loop
							tmpStart := 1;
							tmpEnd   := 1;
							for j in 2 to 14 loop
								if (table(j)(i) /= "000" and table(j)(i) = table(j-1)(i)) then
									tmpEnd := j;
								else
									if tmpEnd - tmpStart >= 2 then
										for k in 0 to tmpEnd loop
											if k >= tmpStart then
												tmpTable(k)(i) := '1';
											end if;
										end loop;
									end if;
									tmpEnd := j;
									tmpStart := j;
								end if;
							end loop;
						end loop;
						
							-- diagonal cut----------------------------------------------------
								-- '\' shape
						for k in -10 to 3 loop
							if k <= 0 then
								tmpStart := 1 - k;
								tmpEnd   := 1 - k;
								for trow in 1 to 14 loop
									if trow >= 2-k then
										if trow + k > 7 then
											exit;
										end if;
										if table(trow)(trow+k) /= "000" and table(trow)(trow+k) = table(trow-1)(trow+k-1) then
											tmpEnd := trow;
										else
											if tmpEnd - tmpStart >= 2 then
												for ttt in 1 to tmpEnd loop
													if ttt >= tmpStart and ttt + k>= 0 then
														tmpTable(ttt)(ttt+k) := '1';
													end if;
												end loop;
											end if;
											tmpStart := trow;
											tmpEnd   := trow;
										end if;
									end if;
								end loop;
							else
								tmpStart := 1;
								tmpEnd   := 1;
								for trow in 2 to 14 loop
									if trow + k > 7 then
										exit;
									end if;
									if table(trow)(trow+k) /= "000" and table(trow)(trow+k) = table(trow-1)(trow+k-1) then
										tmpEnd := trow;
									else
										if tmpEnd - tmpStart >= 2 then
											for ttt in 1 to 13 loop
												if ttt >= tmpStart and ttt <= tmpEnd then
													tmpTable(ttt)(ttt+k) := '1';
												end if;
											end loop;
										end if;
										tmpEnd := trow;
										tmpStart := trow;
									end if;
								end loop;
							end if;
						end loop;
								
								-- '/' shape
						for k in 4 to 17 loop
							tmpStart := 1;
							tmpEnd   := 1;
							for trow in 1 to 14 loop
								if k - trow >= 0 and k - trow <= 6 then
									if table(trow)(k-trow) /= "000" and table(trow)(k-trow) = table(trow-1)(k-trow+1) then
										tmpEnd := trow;
									else
										if tmpEnd - tmpStart >= 2 then
											for ttt in 1 to 13 loop
												if ttt >= tmpStart and ttt <= tmpEnd and k-ttt <= 7 then
													tmpTable(ttt)(k-ttt) := '1';
												end if;
											end loop;
										end if;
										tmpEnd := trow;
										tmpStart := trow;
									end if;
								end if;
							end loop;
						end loop;				
					
					end if;	
					-------then cut these blocks----------------------------------------------------
					
					
					
					tmpCut := '0';
					deltaScore := 0;
					for i in 13 downto 1 loop
						for j in 6 downto 1 loop
							if tmpTable(i)(j) = '1' then
								deltaScore := deltaScore + 1;
								if cutCnter = "111111" then
									table(i)(j) <= "000";
								else
									if cutCnter(2 downto 0) = "000" then
										table(i)(j) <= typeCnter + 1;
									end if;
								end if;
								tmpCut := '1';
							end if;
						end loop;
					end loop;

					
					if tmpCut = '1' then
						cutting <= '1';
						
						if cutCnter = "111111" then
							cutAni <= '0';
							link_score <= deltaScore + link_score;
						else
							cutAni <= '1';
						end if;
						
						cutCnter := cutCnter + 1;
						if typeCnter = "100" then
							typeCnter := "000";
						else
							typeCnter := typeCnter + 1;
						end if;
					else
						cutting <= '0';
					end if;
					
					score <= link_score;
					
					-------at last adjust the table such that no empty spaces in middle------------
					
					if cutAni = '0' then
						for i in 1 to 6 loop
							for j in 13 downto 1 loop
								if (table(j)(i) = "000") then
									for k in j downto 1 loop
										table(k)(i) <= table(k-1)(i);
									end loop;
								end if;
							end loop;
						end loop;
					
					end if;
					
				end if;   -- touchBottom
				
				
				
				lastRow <= posRow;
				lastCol <= posCol;
			else                ---------------- dead animation
				counter := counter + 1;
				if counter = "1111" then
					for i in 13 downto 1 loop
						if flag = '1' then 
							exit;
						end if;
						for j in 6 downto 1 loop
							if table(i)(j) /= "110" then
								flag := '1';
								table(i)(j) <= "110";
								exit;
							end if;
						end loop;
					end loop;
				end if;  -- counter
			end if;    -- dead
		end if;    -- rising_edge
	end if; -- startGame
end process;
	
end behav;
