--------------------------------------------------------------------------------------------------------------------------------------------------
-- Autor: Iago Agrella Fancio 					
-- 							
-- Data de comeÃ§o: 10/08/17 
-- Historico de RevisÃ£o   Data        	Autor 	       Comentarios
-- 			              15/08/17 		Iago Fancio 	 Criado
--------------------------------------------------------------------------------------------------------------------------------------------------
-- Purpose: 
-- Esta entidade/arquitetura funciona como um registrador de um bit
--------------------------------------------------------------------------------------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY reg1 IS
	PORT ( 
		registrado : IN STD_LOGIC;	-- numero que sera registrado
		registrado_enable : IN STD_LOGIC; -- enabler do registrador
		clock : IN STD_LOGIC; -- clock do registrador
		reset : IN STD_LOGIC; -- reset do registrador
		registro : OUT STD_LOGIC); -- saida de valor igual ao registrado
END reg1;

ARCHITECTURE reg1_arch OF reg1 IS
	BEGIN
	 --------------------------------------------
    -- registra:
    -- O process registra a entrada na subida do clock
    --------------------------------------------
	registra: PROCESS (clock,reset)
	BEGIN
	IF(reset = '1')THEN
		registro <= '0';
	ELSIF (rising_edge(clock)) THEN
		IF registrado_enable = '1' THEN
			registro <= registrado;
		END IF;
	END IF;
	
	END PROCESS;

END reg1_arch;