--------------------------------------------------------------------------------------------------------------------------------------------------
-- Autor: Iago Agrella Fancio 					
-- 							
-- Data de começo: 10/08/17 
-- Historico de Revisão   Data        Autor         Comentarios
-- 			                    10/08/17 		 Iago Fancio 	 Criado
--------------------------------------------------------------------------------------------------------------------------------------------------
-- Purpose: 
-- Esta entidade/arquitetura divide o numero de entrada por 2  
--------------------------------------------------------------------------------------------------------------------------------------------------

LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

ENTITY divide_2 IS
  GENERIC (n : INTEGER);
  PORT ( 
		elem          : IN STD_LOGIC_VECTOR (n-1 DOWNTO 0); -- numero de entrada que sera dividido por 2
		elem_dividido : OUT STD_LOGIC_VECTOR (n-1 DOWNTO 0) -- numero ja dividido por 2
  );
END divide_2;

ARCHITECTURE divide_2_arch OF divide_2 IS

	begin
	  
		elem_dividido(n-2 DOWNTO 0) <= elem(n-1 DOWNTO 1); -- divide por 2 deslocando os bits para direita
    elem_dividido(n-1) <= '0'; -- zera o bit mais significativo do numero dividido
    	
END divide_2_arch;
