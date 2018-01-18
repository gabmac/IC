LIBRARY ieee;
USE ieee.std_logic_1164.all;
ENTITY seg IS
 PORT (  SW : IN std_logic_vector (3 DOWNTO 0) ;
 HEX0 : OUT std_logic_vector (0 TO 6)  ) ;
END seg;

Architecture Disp of seg IS
	BEGIN
		HEX0(0) <= (NOT(SW(3)) AND NOT(SW(2)) AND NOT(SW(1)) AND SW(0) ) OR (NOT (SW(3)) AND SW(2) AND NOT(SW(1)) AND NOT (SW(0))) OR (SW(3) AND NOT (SW(2)) AND SW(1) AND SW(0)) OR (SW(3) AND SW(2) AND NOT (SW(1)) AND SW(0));
		
		HEX0(1) <= (SW(2) AND SW(1) AND NOT (SW(0))) OR (SW(3) AND SW(1) AND SW(0)) OR (SW(3) AND SW(2) AND NOT SW(0)) OR (NOT(SW(3)) AND SW(2) AND NOT(SW(1)) AND SW(0)) ;
		
		HEX0(2) <= (SW(3) AND SW(2) AND NOT (SW(0))) OR (SW(3) AND SW(2) AND SW(1)) OR (NOT (SW(3)) AND NOT SW(2) AND SW(1) AND NOT (SW(0))); 

		HEX0(3) <= (SW(2) AND SW(1) AND SW(0)) OR (NOT (SW(3)) AND NOT (SW(2)) AND NOT (SW(1)) AND SW(0)) OR (NOT(SW(3)) AND SW(2) AND NOT SW(1) AND NOT (SW(0))) OR (SW(3) AND NOT (SW(2)) AND SW(1) AND NOT SW(0));
			
		HEX0(4) <= (NOT(SW(3)) AND SW(0)) OR (NOT (SW(2)) AND NOT (SW(1)) AND SW(0)) OR (NOT (SW(3)) AND SW(2) AND NOT (SW(1)));
		
		HEX0(5) <= (NOT (SW(3)) AND NOT (SW(2)) AND SW(0)) OR (NOT (SW(3)) AND SW(1) AND SW(0)) OR (NOT (SW(3)) AND NOT (SW(2)) AND SW(1)) OR (SW(3) AND SW(2) AND NOT (SW(1)) AND SW(0));
		
		HEX0(6) <= (NOT (SW(3)) AND NOT (SW(2)) AND NOT (SW(1))) OR (NOT(SW(3)) AND SW(2) AND SW(1) AND SW(0)) OR (SW(3) AND SW(2) AND NOT (SW(1)) AND NOT (SW(0)));
END Architecture;