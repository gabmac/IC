LIBRARY ieee;
USE ieee.std_logic_1164.all;
ENTITY segt IS
 PORT (  SW : IN std_logic_vector (6 DOWNTO 0) ;
 HEX : OUT std_logic_vector (0 TO 6)  ) ;
END segt;

Architecture Disp of segt IS
	BEGIN
			HEX(0) <= SW(0);
			HEX(1) <= SW(1);
			HEX(2) <= SW(2);
			HEX(3) <= SW(3);
			HEX(4) <= SW(4);
			HEX(5) <= SW(5);
			HEX(6) <= SW(6);
END Architecture;