--------------------------------------------------------------------------------------------------------------------------------------------------
-- Autor: Iago Agrella Fancio 					
-- 							
-- Data de comeÃ§o: 10/08/17 
-- Historico de RevisÃ£o   Data        	Autor 	       Comentarios
-- 			              15/08/17 		Iago Fancio 	 Criado
--------------------------------------------------------------------------------------------------------------------------------------------------
-- Purpose: 
-- Esta entidade/arquitetura funciona como um multiplexador de 2 para 1  
--------------------------------------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


ENTITY multiplex IS
	GENERIC (n : INTEGER :=16);
	PORT ( 
		in_0,in_1 : IN STD_LOGIC_VECTOR(n-1 downto 0); -- entradas do multiplexador
		control : IN STD_LOGIC;	-- bits de controle do multiplexador
		saida : OUT STD_LOGIC_VECTOR(n-1 downto 0) -- saida selecionada
		);
END multiplex;

ARCHITECTURE multiplex_arch OF multiplex IS
	
	BEGIN
	 --------------------------------------------
    -- mux2_to1:
    -- O process seleciona atravez da chave de control qual a saida do multiplexador
    --------------------------------------------
	mux2_to1: PROCESS(control, in_0, in_1)
	
	BEGIN
	IF(control = '0') THEN
		saida <= in_0;
	ELSIF(control = '1') THEN
		saida <= in_1;
	ELSE
	 saida <= (others => '0');
	END IF;
	END PROCESS;
		
	
END multiplex_arch;