

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

ENTITY auxiliar_contador IS
	GENERIC (n : natural := 16);
	PORT (
		count : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0); -- numero que deve ser passado para o modulo
		alimento : OUT STD_LOGIC_VECTOR(2*n+1 DOWNTO 0) -- numero que deve entrar no modulo
	); 
END auxiliar_contador;

ARCHITECTURE auxiliar_contador_arch OF auxiliar_contador IS

	BEGIN 
	
	
	alimento(2*n+1 DOWNTO n) <= (OTHERS => '0');
	alimento(n-1 DOWNTO 0) <= count;

END auxiliar_contador_arch;
	
