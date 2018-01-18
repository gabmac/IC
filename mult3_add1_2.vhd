--------------------------------------------------------------------------------------------------------------------------------------------------
-- Autor: Iago Agrella Fancio 					
-- 							
-- Data de começo: 10/08/17 
-- Historico de Revisão   Data        Autor         Comentarios
-- 			                    10/08/17 		 Iago Fancio 	 Criado
--									29/08/2017	Iago Fancio	 foi adicionado o sinal de overflow	
--------------------------------------------------------------------------------------------------------------------------------------------------
-- Purpose: 
-- Esta entidade/arquitetura multiplica um numero por 3 e soma 1
-- f(x) = 3x+1 
--------------------------------------------------------------------------------------------------------------------------------------------------
LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

ENTITY mult3_add1_2 IS
  GENERIC ( n: INTEGER := 16);
  PORT ( 
	 elem        : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0); -- elemento a ser multiplicado por 3 e somado 1
	 elem3_add1  : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0); -- numero apos a operação
	 overflow_elem: OUT STD_LOGIC -- sinal de overflow caso haja
  );
END mult3_add1_2;

ARCHITECTURE mult3_add1_2_arch OF mult3_add1_2 IS

	COMPONENT adder IS
    GENERIC (n : INTEGER);
    PORT ( 
      primeiro_elem : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0); -- primeiro elemento da soma
      segundo_elem  : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0); -- segundo elemento da soma
      soma_elem     : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0); -- soma dos dois elementos de entrada
      over          : OUT STD_LOGIC  -- overflow da soma caso haja
    );
	END COMPONENT;
  
	COMPONENT divide_2 IS
		GENERIC (n : INTEGER);
		PORT ( 
			elem          : IN STD_LOGIC_VECTOR (n-1 DOWNTO 0); -- numero de entrada que sera dividido por 2
			elem_dividido : OUT STD_LOGIC_VECTOR (n-1 DOWNTO 0) -- numero ja dividido por 2
		);
	END COMPONENT;
	
	signal elem_i      : STD_LOGIC_VECTOR(n-3 DOWNTO 0); -- sinal interno representativo do sinal de entrada
	signal soma        : STD_LOGIC_VECTOR(n-3 DOWNTO 0); -- soma resultante dos numeros das multiplicações de elem_i pelos bits "11"
	signal aux_elem_i  : STD_LOGIC_VECTOR(n-3 DOWNTO 0);	-- elemento auxiliar resultante da multiplicação de elem_i pelo bit menos significativo de "11"
	signal over        : STD_LOGIC; -- overflow do adder, bit mais significativo do produto
	signal aux_divide	 : STD_LOGIC_VECTOR(n-1 DOWNTO 0);
	
	BEGIN
	
    elem_i <= elem(n-3 DOWNTO 0); -- elemento que vai ser somado no adder com os  bits reduzidos para a soma
    aux_elem_i(n-4 DOWNTO 0) <= elem_i(n-3 DOWNTO 1) ; -- segundo elemento da soma é a multiplicação de elem_i pelo bit menos significativo
    aux_elem_i(n-3) <= '0'; -- zera o bit mais significativo do auxiliar
	
    soma_mult_bits: adder 
      GENERIC MAP (n => n-2)
      PORT MAP (
        primeiro_elem => aux_elem_i,
        segundo_elem => elem_i,
        soma_elem => soma,
        over => over
        ); 
        
    --------------------------------------------
    -- multi3_add1:
    -- O process multiplica o numero por 3 e soma 1
    --------------------------------------------
    multi3_add1: PROCESS(elem_i, soma, over)
      
    VARIABLE aux_elem3_add1, aux_elem3: std_LOGIC_VECTOR(n-1 downto 0);
	
    BEGIN
      -- obtenção do produto por 3
      aux_elem3(0):= elem_i(0); 
      aux_elem3(n-2 DOWNTO 1):= soma;
      aux_elem3(n-1) := over;
      -- somando 1 ao produto
      aux_elem3_add1:= aux_elem3 + '1' ;
      aux_divide <= aux_elem3_add1;
	
    END PROCESS;
	 
	 overflow_elem <= (aux_divide(n-1) OR aux_divide(n-2));
	 
	 par: divide_2
	 GENERIC MAP(n => n)
	 PORT MAP(
	   elem => aux_divide,
	   elem_dividido => elem3_add1
	 );
	 
	
END mult3_add1_2_arch;
