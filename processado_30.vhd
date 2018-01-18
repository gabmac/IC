--------------------------------------------------------------------------------------------------------------------------------------------------
-- Autor: Iago Agrella Fancio 					
-- 							
-- Data de comeÃ§o: 15/08/17 
-- Historico de RevisÃ£o   Data       	Autor      		 Comentarios
-- 			                      15/08/17		  Iago Fancio 	 Criado
--									          16/08/17		 Iago Fancio		  Foi feito mas nao terminado a passagem de estados e seus bits de controle
--                          17/08/17    Iago Fancio   Foi terminado e testado
--									31/08/17		Iago Fancio		Foi aprimorado para um processador completamente generico
--------------------------------------------------------------------------------------------------------------------------------------------------
-- Purpose: 
-- Esta entidade/arquitetura gerencia a entrada, saida e tratamento do numero que sera aplicado a regra de Collatz
--------------------------------------------------------------------------------------------------------------------------------------------------

LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

ENTITY processador_30 IS
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
END processador_30;
	
ARCHITECTURE processador_30_arch OF processador_30 IS 
	
	COMPONENT regn IS
		GENERIC (n : INTEGER := 16);
		PORT ( 
			registrado : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);	-- numero que sera registrado
			registrado_enable : IN STD_LOGIC; -- enabler do registrador
			clock : IN STD_LOGIC; -- clock do registrador
			reset: IN STD_LOGIC;
			registro : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)); -- saida de valor igual ao registrado
	  END COMPONENT;

	COMPONENT multiplex IS
	 GENERIC (n : INTEGER :=16);
	 PORT ( 
	 	in_0,in_1 : IN STD_LOGIC_VECTOR(n-1 downto 0); -- entradas do multiplexador
	 	control : IN STD_LOGIC;	-- bits de controle do multiplexador
		saida : OUT STD_LOGIC_VECTOR(n-1 downto 0) -- saida selecionada
		);
  END COMPONENT;


	TYPE state_type IS (start_state,processing_state); -- estados possiveis sistema
	SIGNAL estado_atual, estado_futuro: state_type; -- estados do sistema
	
	SIGNAL runing : STD_LOGIC; -- sinal de controle para executar o sitema
	SIGNAL multiplex_control : STD_LOGIC; -- sinal de controle do multiplexador; escolhe entre as estradas e o registrador
	SIGNAL original_enable : STD_LOGIC; -- enable de registro do registrador com o numero original
	SIGNAL dado_enable : STD_LOGIC; -- enable de registro do registrador do dado de saida
	SIGNAL idle_i : STD_LOGIC; -- representa��o interna do sinal de saida idle
	SIGNAL dado_mux : STD_LOGIC_VECTOR(n-1 DOWNTO 0); -- sinal interno de saida do multiplexador
	SIGNAL dado_original : STD_LOGIC_VECTOR(n-1 DOWNTO 0); -- sinal interno de saida do multiplexador
	SIGNAL dado_dado : STD_LOGIC_VECTOR(n-1 DOWNTO 0); -- sinal de saida do registrado do dado; serve como um intermediario para os sinais dado e bit_0
	SIGNAL done : STD_LOGIC; -- sinal de termino de execu��o indica quando a regra de collatz acabou
	
	BEGIN
	  
	--------------------------------------------
  -- registro_ativacao:
  -- O process registra o pulso para comecar a execucao da regra
  --------------------------------------------
	registro_ativacao: PROCESS (run,reset)
	BEGIN
	
	IF (reset = '1') THEN -- resetar o sitema tambem o desliga
	  runing <= '0'; 
	ELSE runing <= run;
	END IF;
	
	END PROCESS;
	
	--------------------------------------------
  -- state_table:
  -- O process faz a associacao dos estados futuros
  -- baseado nos estados atuais e de sianais de controle
  --------------------------------------------
	
	state_table: PROCESS (estado_atual,done,runing)
		BEGIN
		
		CASE estado_atual IS
			WHEN start_state => IF(runing = '1') THEN estado_futuro <= processing_state; -- verifica se o sistema foi ligado, caso nao tenha sido se mantem na espera
				ELSE estado_futuro <= start_state; -- caso tenha sido ligado passa para a fase de registro
				END IF; 
			WHEN processing_state => IF (done = '1') THEN estado_futuro <= start_state; -- verifica se a regra de collatz acabou, caso tenha acabado vai para o estado de idle
				ELSE estado_futuro <= processing_state; -- caso nao tenha acabado volta a registrar o numero para a proxima etapa
				END IF;
		END CASE;
	
	END PROCESS;
	
	
	--------------------------------------------
  -- control_signals:
  -- O process controla quais sinais devem ser ativados 
  -- dependendo do estado atual do processador
  --------------------------------------------
	
		control_signals: PROCESS (estado_atual)
	BEGIN

	CASE estado_atual IS 
		WHEN start_state => -- caso o estado seja de start
			multiplex_control <= '1'; -- coloca o multiplexador na entrada externa
			dado_enable <= '1'; -- permite o registro no dado
			idle_i <= '1'; -- identifica idleness
			original_enable <= '1'; -- registra o numero analisado no registrador de comparacao
		WHEN processing_state => -- caso o estado seja de processamento
			multiplex_control <= '0'; -- coloca o multiplexador na realimentacao
			dado_enable <= '1'; --  o registro no dado
			idle_i <= '0'; -- nao identifrica idleness
			original_enable <= '0'; -- nega registro o numero analisado no registrador de comparacao
	END CASE;
		
	END PROCESS;
	
	--------------------------------------------
  -- state_process:
  -- O process faz a passagem de estado futuro para o estado atual
  -- tbm reseta o estado do procesador
  --------------------------------------------
		
	state_process: PROCESS (clock, reset, estado_futuro)
	BEGIN
	  
	  IF (reset = '1') THEN -- reseta o estado do sistema
	   estado_atual <= start_state;
	  ELSIF (rising_edge(clock)) THEN -- faz a pasagem dos estados
     estado_atual <= estado_futuro;
    END IF;
    
	END PROCESS;
	
	 multiplexador_entrada: multiplex
	   GENERIC MAP (n => n)
	   PORT MAP(
	     in_0 => entrada_realimentada, 
	     in_1 => entrada_externa,
	     control => multiplex_control,
	     saida => dado_mux
	   );
	  
	registrador_numero_original: regn
	    GENERIC MAP (n => n)
	    PORT MAP(
	       registrado => dado_mux,
	       registrado_enable => original_enable,
	       clock => clock,
		   reset => reset,
	       registro => dado_original
	    );
		 
		 
	done_signal: PROCESS (dado_dado, done, dado_original)
	BEGIN
	  
	  IF( dado_dado < dado_original) THEN -- verifica se o numero eh menor que o dado original
	   done <= '1';
	  ELSE done <= '0';
	  END IF;
	  
	 END PROCESS;
	
	 registrador_dado: regn
	    GENERIC MAP (n => n)
	    PORT MAP(
	       registrado => dado_mux,
	       registrado_enable => dado_enable,
	       clock => clock,
		   reset => reset,
	       registro => dado_dado
	     );
	
	  dado <= dado_dado;
	  bit_0 <= dado_dado(0);
	  idle <=idle_i;
	  
END processador_30_arch;