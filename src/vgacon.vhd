library	ieee;
use		ieee.std_logic_1164.all;
use		ieee.std_logic_unsigned.all;
use		ieee.std_logic_arith.all;

entity vgacon is
	 port(
			reset_n:in  STD_LOGIC;
			clk:in  STD_LOGIC;
			rin, gin, bin:in STD_LOGIC;
			row, column : out std_logic_vector(10 downto 0);
			hs,vs:out STD_LOGIC;
			r,g,b:out STD_LOGIC
	  );
end vgacon;

architecture behavior of vgacon is
--replace for variable vga solution
constant H_FRONT:integer :=40;
constant H_SYNC:integer :=128;
constant H_BACK:integer :=88;
constant H_ACT:integer :=800;
constant H_BLANK:integer :=H_BACK + H_SYNC + H_FRONT;
constant H_TOTAL:integer :=H_BLANK + H_ACT;

constant V_FRONT:integer :=1;
constant V_SYNC:integer :=4;
constant V_BACK:integer :=23;
constant V_ACT:integer :=600;
constant V_BLANK:integer :=V_BACK + V_SYNC + V_FRONT;
constant V_TOTAL:integer :=V_BLANK + V_ACT;
--end replace		
	signal hs1,vs1    : std_logic;				
	signal vector_x : std_logic_vector(10 downto 0);		--X坐标
	signal vector_y : std_logic_vector(10 downto 0);		--Y坐标
begin
 -----------------------------------------------------------------------
	 process(clk,reset_n)	--行区间像素数（含消隐区）
	 begin
	  	if reset_n='0' then               --clear
	   		vector_x <= (others=>'0');
	  	elsif clk'event and clk='1' then
	   		if vector_x=H_TOTAL - 1 then
	    		vector_x <= (others=>'0');
	   		else
	    		vector_x <= vector_x + 1;
	   		end if;
	  	end if;
	 end process;

  -----------------------------------------------------------------------
	 process(clk,reset_n)	--场区间行数（含消隐区）
	 begin
	  	if reset_n='0' then
	   		vector_y <= (others=>'0');
	  	elsif clk'event and clk='1' then
	   		if vector_x=H_TOTAL - 1 then
	    		if vector_y=V_TOTAL - 1 then
	     			vector_y <= (others=>'0');
	    		else
	     			vector_y <= vector_y + 1;
	    		end if;
	   		end if;
	  	end if;
	 end process;
	 
  -----------------------------------------------------------------ouput row
  process(clk, reset_n, vector_x, vector_y)
  begin
	row <= vector_y;
	column <= vector_x;
  end process;
 
  -----------------------------------------------------------------------
	 process(clk,reset_n) --行同步信号产生（同步宽度96，前沿16）
	 begin
		  if reset_n='0' then
		   hs1 <= '1';
		  elsif clk'event and clk='1' then
		   	if vector_x>=H_ACT + H_FRONT and vector_x< H_ACT + H_FRONT + H_SYNC then
		    	hs1 <= '0';
		   	else
		    	hs1 <= '1';
		   	end if;
		  end if;
	 end process;
 
 -----------------------------------------------------------------------
	 process(clk,reset_n) --场同步信号产生（同步宽度2，前沿10）
	 begin
	  	if reset_n='0' then
	   		vs1 <= '1';
	  	elsif clk'event and clk='1' then
	   		if vector_y>=V_ACT + V_FRONT and vector_y<V_ACT + V_FRONT + V_SYNC then
	    		vs1 <= '0';
	   		else
	    		vs1 <= '1';
	   		end if;
	  	end if;
	 end process;
 -----------------------------------------------------------------------
	 process(clk,reset_n) --行同步信号输出
	 begin
	  	if reset_n='0' then
	   		hs <= '0';
	  	elsif clk'event and clk='1' then
	   		hs <=  hs1;
	  	end if;
	 end process;

 -----------------------------------------------------------------------
	 process(clk,reset_n) --场同步信号输出
	 begin
	  	if reset_n='0' then
	   		vs <= '0';
	  	elsif clk'event and clk='1' then
	   		vs <=  vs1;
	  	end if;
	 end process;
	
 -----------------------------------------------------------------------	
	process (hs1, vs1, rin, gin, bin)	--色彩输出
	begin
		if hs1 = '1' and vs1 = '1' then
			r	<= rin;
			g	<= gin;
			b	<= bin;
		else
			r	<= '0';
			g	<= '0';
			b	<= '0';
		end if;
	end process;

end behavior;
