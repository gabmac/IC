LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY clk_1s IS PORT (
	clk_in: IN std_logic;
	clk_out: OUT std_logic
	);
END clk_1s;

ARCHITECTURE seq OF clk_1s IS
BEGIN
PROCESS (clk_in)

VARIABLE contador: INTEGER := 0;
variable clk_out_var : std_logic := '0';
	
BEGIN
	IF(rising_edge(clk_in)) then
		contador := contador + 1;
		if( contador = 250000)then
			contador := 0;
			clk_out_var := NOT clk_out_var;
		end if;		
	END IF;
	
	clk_out <= clk_out_var;
END PROCESS;
END seq;	