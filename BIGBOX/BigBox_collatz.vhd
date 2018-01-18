library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

ENTITY bigbox IS
	GENERIC( n: NATURAL := 38; -- se queremos contar 2^k temos que colocar n = k+1
				z: NATURAL := 9); -- numero de trabalhadores por controlador
	PORT (
		 reset : IN STD_LOGIC; -- reseta a contagem
		 clock : IN STD_LOGIC; -- clock do sistema, "vem da multibox" -Bonani, Gabriel
		 inicial : IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);	-- valor de inicio da contagem
		 final : IN STD_LOGIC_VECTOR (n-1 DOWNTO 0); -- valor final da contagem
		 fim : OUT STD_LOGIC; -- inica o termino da contagem e dos processos
		
------------------------------------------- sinais para debug -------------------------------------------
--		key:IN STD_LOGIC_VECTOR(1 DOWNTO 0); 
--		clock_50: IN STD_LOGIC;
--		sw: IN STD_LOGIC_VECTOR(0 DOWNTO 0);
--		ledg: OUT STD_LOGIC_VECTOR(7 DOWNTO 0); 
		sinal_contador_controlador: BUFFER STD_LOGIC_VECTOR(n-1 DOWNTO 0) -- sinal que liga o contador ao controlador
--		hex0: out STD_LOGIC_VECTOR(0 TO 6); -- hex sao usados para contagem
--		hex1: out STD_LOGIC_VECTOR(0 TO 6);
--		hex2: out STD_LOGIC_VECTOR(0 TO 6);
--		hex3: out STD_LOGIC_VECTOR(0 TO 6);
--		hex4: out STD_LOGIC_VECTOR(0 TO 6)
------------------------------------- sinais para debug -------------------------------------------------------
	);
END bigbox ;

ARCHITECTURE BigBox_collatz_arch OF bigbox IS
	
	COMPONENT contador is -- contador dos valores a serem processados
		generic (
			n : natural := 16
		);
		port (
			clock ,reset_n, incr_pc : in std_logic;
			flag : buffer std_logic;
			final : in STD_LOGIC_VECTOR(n-1 downto 0);
			inicial : in STD_LOGIC_VECTOR(n-1 downto 0);
			count : out STD_LOGIC_VECTOR(n-1 downto 0)
		); 
	end COMPONENT;
	
	COMPONENT controlador is -- distribuidor dos numeros contados nos trabalhadores
	generic (
		n : natural := 4; ---tamanho do barramento
		z : natural := 2 ---- quantidade dos trabalhadores
	);
		
	port (
		valor: in std_logic_vector(n-1 downto 0);
		request: in std_logic_vector(z-1 downto 0); -- barramento de pedidos
		flag, reset: in std_logic;
		grant: out std_logic_vector(n*z-1 downto 0); --- barramento de dados
		aviso: out std_logic_vector (z-1 downto 0);
		ledr: out std_logic;
		release: buffer std_logic
		); 
	end COMPONENT;
	
	COMPONENT auxiliar_contador IS -- "se pa nem usa" -Fancio, Iago
	GENERIC (n : natural := 16);
	PORT (
		count : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0); -- numero que deve ser passado para o modulo
		alimento : OUT STD_LOGIC_VECTOR(2*n+1 DOWNTO 0) -- numero que deve entrar no modulo
		); 
	END COMPONENT;
	
	COMPONENT collatz212 IS -- modulo do trabalhador
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
	END COMPONENT;
	
	Component seg IS -- mostrador de 7 seg "se pa nem usa" -Fancio, Iago "esse não usa mesmo" -Bonani, Gabriel "kkkkkkk" - Ambos
    PORT ( 
	     SW : IN std_logic_vector (3 DOWNTO 0) ;
	     HEX0 : OUT std_logic_vector (0 TO 6)  
    );
	END Component;
	
------------------------------------- sinais para debug -------------------------------------------------------
--	SIGNAL reset : STD_LOGIC;
--	SIGNAL clock : STD_LOGIC; -- clock do sistema
--	SIGNAL fim : STD_LOGIC;
--	SIGNAL inicial: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
--	SIGNAL final: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
------------------------------------- sinais para debug -------------------------------------------------------	

	SIGNAL flag_i : STD_LOGIC; -- sinal de termino dos numeros contados	
	SIGNAL relese_i : STD_LOGIC; -- sinal que indica que um ou mais trabalhadores estão parados
	SIGNAL run_c : STD_LOGIC_VECTOR(z-1 DOWNTO 0); -- sinal que liga os trabalhadores
	SIGNAL done_i: STD_LOGIC_VECTOR(z-1 DOWNTO 0); -- sinal que indica termino dos trabalhadores
	SIGNAL incr_pc_i : STD_LOGIC_VECTOR(z-1 DOWNTO 0);	-- sinal de enable da contagem
	SIGNAL overflow_i : STD_LOGIC_VECTOR(z-1 DOWNTO 0); -- sinal que indica se houve overflow em algum sistema
--	SIGNAL sinal_contador_controlador: STD_LOGIC_VECTOR(n-1 DOWNTO 0); -- sinal que liga o contador ao controlador
	SIGNAL grant_i : STD_LOGIC_VECTOR(n*z-1 DOWNTO 0); -- sinal interno do grant, sinal que carrega os valores a serem processados
	SIGNAL sinal_aux_collatz: STD_LOGIC_VECTOR((2*(n+1)*z)-1 DOWNTO 0); -- sinal que liga os auxiliares aos trabalhadores, os numeros são ampliados para evitarem problemas de overflow
	
	
	
	BEGIN
	
------------------------------------- sinais para debug -------------------------------------------------------
--		clock <= clock_50 and sw(0);
--		reset <= not key (1);
--		ledg(7) <= fim;
--		-- geracao do valor inicial
--		inicial(n-1) <= '1';
--		inicial(n-2 downto 1) <= (OTHERS => '0');
--		inicial(0) <= '1';
--		-- geracao do valor final
--		final <=(OTHERS => '1');
------------------------------------- sinais para debug -------------------------------------------------------		
		
		-- contador do sistema que passa os numeros a serem processados para o controlador
		contador_i: contador
			generic map (n => n)
			port map(
				clock => clock, 
				reset_n => reset,
				incr_pc => relese_i, -- sinal que libera o incremento do numero
				flag => flag_i, -- sinal que indica o termino dos numeros
				final => final, -- numero final a ser contado
				inicial => inicial, -- numero inicial da contagem
				count => sinal_contador_controlador(n-1 DOWNTO 0) -- numero atual da contagem que vai para o controlador
			);
		
		-- o controlador distribui os numeros do contador para os trabalhadores
		contrl:  controlador
			generic map(
				n => n, ---tamanho do barramento
				z => z ---- quantidade dos trabalhadores
				)
			port map(
				valor => sinal_contador_controlador (n-1 downto 0),
				request => done_i(z-1 downto 0), -- barramento de pedidos
				flag => flag_i, -- sinal de termino dos numeros a serem processados
				reset => reset,
				grant => grant_i(n*z-1 downto 0), --- barramento de dados
				aviso => run_c(z-1 downto 0), -- sinal que liga os trabalhadores que receberam o numero
				ledr => fim, -- sinal de termino de execução de todos os numeros
				release => relese_i -- sinal que indica que ha um trabalhador parado e libera o incremento do numero contado
				);

	-- geração generica de trabalhadores e seus respectivos auxiliares
	gen_aux_collatz:
		FOR i IN 0 TO z-1 GENERATE
		
		-- componente que adapta o nuemro contado para um barramento de processamento adequado
		auxiliar_de_contador : auxiliar_contador
			GENERIC MAP(n => n)
			PORT MAP(
				count => grant_i((n*(i+1)-1) DOWNTO n*i), -- numero passado pelo controlador
				alimento => sinal_aux_collatz((2*(n+1)*(i+1)-1) DOWNTO (2*(n+1)*i)) -- numero adaptado
			);

			modulo_collatz: collatz212
			GENERIC MAP(n => 2*n+2)
			PORT MAP(
				alimentacao => sinal_aux_collatz((2*(n+1)*(i+1)-1) DOWNTO (2*(n+1)*i)), -- numero a ser processado
				run => run_c(i), -- sinal que liga op trabalhador
				reset => reset, 
				clock => clock,
				done => done_i(i), -- sinal de termino de execucao
				overflow => overflow_i(i) -- sinal que indica extouro de campo caso o numero cresca demais enquanto processado
			--	dado_i => sinal_dos_hex ((2*(n+1)*(i+1)-1) DOWNTO (2*(n+1)*i)) -- sinal de auxilio para debug
			);
			
	END GENERATE gen_aux_collatz;

--------------------------------------- sinais para debug -------------------------------------------------------
--		hex0 <= not sinal_contador_controlador(6 downto 0); -- numero contado
--		hex1 <= not sinal_contador_controlador(13 downto 7);
--		hex2 <= not sinal_contador_controlador(20 downto 14);
--		hex3 <= not sinal_contador_controlador(27 downto 21);
--		hex4 <= not sinal_contador_controlador(34 downto 28);
--		ledg(2 downto 0) <= sinal_contador_controlador(37 downto 35);
--------------------------------------- sinais para debug -------------------------------------------------------		
END BigBox_collatz_arch;