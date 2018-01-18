--------------------------------------------------------------------------------------------------------------------------------------------------
-- Autor: Iago Agrella Fancio 					
-- 							
-- Data de comeco: 23/08/17 
-- Historico de Revisao   Data       	Autor      		 Comentarios
--                          23/08/17    Iago Fancio   CRIADO
--									31/08/17		 Iago Fancio	Aprimorado para generico
--------------------------------------------------------------------------------------------------------------------------------------------------
-- Purpose: 
-- Esta entidade/arquitetura aplica a regra de Collatz nos numeros até sua convergencia
--------------------------------------------------------------------------------------------------------------------------------------------------

LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

ENTITY collatz212 IS
	GENERIC (n : natural := 16);
	PORT (
		 alimentacao : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0); -- numero a ser tratado vindo do contador
		 run : IN STD_LOGIC; -- sinal que liga o processo
		 reset : IN STD_LOGIC; -- reinicia o sistema
		 clock : IN STD_LOGIC; -- clock do sistema
		 done: OUT STD_LOGIC; -- idleness
		 overflow: OUT STD_LOGIC; -- overflow
		 dado_i : BUFFER STD_LOGIC_VECTOR(n-1 DOWNTO 0)
	);
END ENTITY;


ARCHITECTURE collatz_212_arch OF collatz212 IS

	COMPONENT reg1 IS
	PORT ( 
		registrado : IN STD_LOGIC;	-- numero que sera registrado
		registrado_enable : IN STD_LOGIC; -- enabler do registrador
		clock : IN STD_LOGIC; -- clock do registrador
		reset : IN STD_LOGIC;
		registro : OUT STD_LOGIC); -- saida de valor igual ao registrado
	END COMPONENT;
  
	COMPONENT mult3_add1_2 IS
	  GENERIC ( n: INTEGER := 16);
	  PORT ( 
		 elem        : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0); -- elemento a ser multiplicado por 3 e somado 1
		 elem3_add1  : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0); -- numero apos a operação
		 overflow_elem: OUT STD_LOGIC -- sinal de overflow caso haja
	  );
	END COMPONENT;


  COMPONENT divide_2 IS
    GENERIC (n : INTEGER :=16);
    PORT ( 
		  elem          : IN STD_LOGIC_VECTOR (n-1 DOWNTO 0); -- numero de entrada que sera dividido por 2
		  elem_dividido : OUT STD_LOGIC_VECTOR (n-1 DOWNTO 0) -- numero ja dividido por 2
    );
  END COMPONENT;
  
  COMPONENT processador_30 IS
	GENERIC (n : INTEGER :=16);
	PORT ( 
		entrada_externa      : IN STD_LOGIC_VECTOR (n-1 DOWNTO 0); -- entrada de chaves para inicializa��o do sistema
		entrada_realimentada	: IN STD_LOGIC_VECTOR (n-1 DOWNTO 0); -- entrada de retorno apos o numero ter sido tratado
		run						: IN STD_LOGIC; -- botao push de funcionamento do sistema
		reset       : IN STD_LOGIC; -- reset do sistema
		clock       : IN STD_LOGIC; -- clock do sistema
		dado						: OUT STD_LOGIC_VECTOR (n-1 DOWNTO 0); -- dado de saida do processador 
		bit_0       : OUT STD_LOGIC; -- bit menos significativo do dado que serve como chave seletora entre par e impar
		idle						: OUT STD_LOGIC -- sinal de termino de execu��o
	);
  END COMPONENT;
  
  COMPONENT multiplex IS
	 GENERIC (n : INTEGER :=16);
	 PORT ( 
		in_0,in_1 : IN STD_LOGIC_VECTOR(n-1 downto 0); -- entradas do multiplexador
		control : IN STD_LOGIC;	-- bits de controle do multiplexador
  		saida : OUT STD_LOGIC_VECTOR(n-1 downto 0) -- saida selecionada
  		);
  END COMPONENT;

	SIGNAL realimentacao: STD_LOGIC_VECTOR(n-1 DOWNTO 0); -- sinal interno do nuemro realimentado
	SIGNAL dado_par: STD_LOGIC_VECTOR(n-1 DOWNTO 0); -- sinal de saida do tratamento par
	SIGNAL dado_impar: STD_LOGIC_VECTOR(n-1 DOWNTO 0); -- sinal de saida do tratamento impar
	SIGNAL controle_mux: STD_LOGIC; -- sinal de controle do mux
	SIGNAL serial_number: STD_LOGIC_VECTOR(3 DOWNTO 0); -- numero serial do trabalhador
	SIGNAL overflow_elem_i: STD_LOGIC; -- sinal interno de overflow
	SIGNAL overflow_elem_i2: STD_LOGIC; -- sinal interno de overflow
	SIGNAL overflow_elem_i3: STD_LOGIC; -- sinal interno de overflow

	BEGIN
	
	-- numero serial do trabalhador
	serial_number <= "0001";
	
	-- processador que recebe como entrada o numero das chaves e a realimentacao dos numeros tratados
	processador_collatz: processador_30
	  GENERIC MAP( n => n)
	  PORT MAP(
	    entrada_externa => alimentacao(n-1 DOWNTO 0),
	    entrada_realimentada => realimentacao,
	    run => run,
	    reset => reset,
	    clock => clock,
	    dado => dado_i,
	    bit_0 => controle_mux,
	    idle => done
	  );
	-- faz o tratamento par do numero
	par: divide_2
	 GENERIC MAP(n => n)
	 PORT MAP(
	   elem => dado_i,
	   elem_dividido => dado_par
	 );
	-- faz o tratamento impar do numero
	impar: mult3_add1_2
	 GENERIC MAP(n => n)
	 PORT MAP(
	   elem => dado_i,
	   elem3_add1 => dado_impar,
		overflow_elem => overflow_elem_i
	 );  
	 
	overflow_elem_i2 <= overflow_elem_i OR overflow_elem_i3; -- realimentaçao que grante que o sinal nao vai desativar
	 
	registro_overflow: reg1
	PORT MAP( 
		registrado => overflow_elem_i2,	-- caso o sinal seja ativado ele nao se desativa
		registrado_enable => '1', -- se atualiza todo clock
		clock => clock, -- clock
		reset => reset,
		registro => overflow_elem_i3 -- sinal de saida caso haja overflow
	);
	
	overflow <= overflow_elem_i2;
	
	-- coloca na realimentacao o numero apos tratamento
	mux: multiplex
     GENERIC MAP(n => n)
     PORT MAP(
       in_0 => dado_par,
       in_1 => dado_impar,
       control => controle_mux,
       saida => realimentacao
     );
  
END collatz_212_arch;