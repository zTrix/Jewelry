library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity timer is
       port
       (
        Clock                   : in std_logic;
        timer                  : out std_logic
        );
end timer;

architecture behav of timer is
    
signal  Counter : std_logic_vector(25 downto 0);

begin
process(Clock)
begin
	if clock'event and clock = '1' then
		counter <= counter + 1;
	end if;	
	timer <= counter(19);
end process;


end behav;


