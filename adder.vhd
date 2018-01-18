--------------------------------------------------------------------------------------------------------------------------------------------------
-- Autor: Iago Agrella Fancio 					
-- 							
-- Data de começo: 09/08/17 
-- Historico de Revisão   Data        Autor         Comentarios
-- 			                    09/08/17 		 Iago Fancio 	 Criado
--------------------------------------------------------------------------------------------------------------------------------------------------
-- Purpose: 
-- Esta entidade/arquitetura soma dois numeros de tamanho N  
--------------------------------------------------------------------------------------------------------------------------------------------------

LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

ENTITY adder IS
  
  GENERIC (n : INTEGER);
  
  PORT ( 
    primeiro_elem : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0); -- primeiro elemento da soma
    segundo_elem  : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0); -- segundo elemento da soma
    soma_elem     : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0); -- soma dos dois elementos de entrada
    over          : OUT STD_LOGIC); -- overflow da soma caso haja
    
END ENTITY;

ARCHITECTURE adder_arch OF adder IS
  
  BEGIN

  --------------------------------------------
  -- Somador:
  -- Processo que soma os numeros primeiro_elem e segundo_elem e 
  -- retorna a soma em soma_elem
  --------------------------------------------
  adder :PROCESS(primeiro_elem, segundo_elem)
	
    VARIABLE soma, primeiro, segundo : std_logic_vector(n DOWNTO 0);
    BEGIN
	
    primeiro(n-1 DOWNTO 0) := primeiro_elem; -- associa primeiro_elem com primeiro
    primeiro(n) := '0';  -- zera o bit mais significativo de primeiro
	
    segundo(n-1 DOWNTO 0) := segundo_elem; -- associa segundo com segundo_elem
    segundo(n) := '0';  -- zera o bit mais significativo de segundo
	
    soma(n) := '0'; -- seta o bit de overflow da soma
    soma := primeiro + segundo; -- soma os valores de primeiro e segundo e guarda em soma
	
    soma_elem <= soma(n-1 DOWNTO 0);  -- coloca na saida o valor de soma
    over <= soma(n);  -- indica se houve overflow
	 
  END PROCESS;
	 
END adder_arch;

	
