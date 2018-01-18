library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

ENTITY MultiBox IS
	GENERIC( n: NATURAL := 38; -- se queremos contar 2^k temos que colocar n = k+1
				z: NATURAL := 7; -- numero de trabalhadores por controlador
				g: NATURAL := 32; -- numero de trabalhadores
				l: NATURAL := 5); -- g=2^l BigBoxes dentro da MultiBox
				
	PORT (
		key: IN STD_LOGIC_VECTOR(1 DOWNTO 0); 
		clock_50: IN STD_LOGIC;
		sw: IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		ledg: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		
------------------------------------- sinais para debug -------------------------------------------------------		
		hex0: out STD_LOGIC_VECTOR(0 TO 6); -- hex sao usados para contagem
		hex1: out STD_LOGIC_VECTOR(0 TO 6);
		hex2: out STD_LOGIC_VECTOR(0 TO 6);
		hex3: out STD_LOGIC_VECTOR(0 TO 6);
		hex4: out STD_LOGIC_VECTOR(0 TO 3)
--		hex5: out STD_LOGIC_VECTOR(0 TO 6); -- hex sao usados para contagem
--		hex6: out STD_LOGIC_VECTOR(0 TO 6);
--		hex7: out STD_LOGIC_VECTOR(0 TO 6)
------------------------------------- sinais para debug -------------------------------------------------------

	);
END MultiBox;

ARCHITECTURE MultiBox_arch of MultiBox is

	COMPONENT bigbox IS
		GENERIC( n: NATURAL := 38; -- se queremos contar 2^k temos que colocar n = k+1
					z: NATURAL := 8); -- numero de trabalhadores por controlador
		PORT (
			reset : IN STD_LOGIC; -- reseta a contagem
			clock : IN STD_LOGIC; -- clock do sistema, "vem da multibox" -Bonani, Gabriel
			inicial : IN STD_LOGIC_VECTOR (n-1 DOWNTO 0);	-- valor de inicio da contagem
			final : IN STD_LOGIC_VECTOR (n-1 DOWNTO 0); -- valor final da contagem
			fim : OUT STD_LOGIC; -- inica o termino da contagem e dos processos
			sinal_contador_controlador: BUFFER STD_LOGIC_VECTOR(n-1 DOWNTO 0)
		);
	END COMPONENT ;

	
	SIGNAL reset: STD_LOGIC;
	SIGNAL clock: STD_LOGIC; -- clock do sistema
	SIGNAL fim: STD_LOGIC_VECTOR(g-1 downto 0);
	SIGNAL inicial: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
	SIGNAL final: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
	SIGNAL intermedio: STD_LOGIC_VECTOR(n*(g-1)-1 DOWNTO 0);
	SIGNAL incremento: STD_LOGIC_VECTOR(n-1-l DOWNTO 0);
	
	
	SIGNAL sinal_contador_controlador_i: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
	
	BEGIN
		
		clock <= clock_50 and sw(0);
		reset <= not key (1);
--		ledg(7) <= fim(0) and fim(1) and fim(2) and fim(3);
		
-------------------------------------------------------------------
--cria o vetor de 
-------------------------------------------------------------------
	
	coloca: process(fim)
		variable led: std_LOGIC;
	begin
				led := '1';
    			L2: for i in 0 to g-1 loop
					led := fim(i) and led;
				end loop L2;
				ledg(7) <= led;
	end process;
		
		-- geracao do valor inicial
		inicial(n-1) <= '1';
		inicial(n-2 downto 1) <= (OTHERS => '0');
		inicial(0) <= '1';
		-- geracao do valor final
		final <=(OTHERS => '1');
		-- geracao do numero incrementador
		incremento(n-l-1) <= '1';
		incremento(n-l-2 DOWNTO 0) <= (OTHERS => '0');
		
		
-------------------------------------------------------------------
--cria o vetor de numero intermediarios
-------------------------------------------------------------------
	
	coloca1: process(inicial,incremento)
	variable freddymercury: std_LOGIC_VECTOR((n*(g-1))-1 downto 0);
	begin
	  freddymercury(n-1 downto 0) := inicial + incremento;
    			L1: for i in 1 to g-2 loop
				freddymercury((i+1)*(n)-1 downto n*i) := freddymercury((i)*(n)-1 downto n*(i-1)) + incremento;
				intermedio <= freddymercury;
			end loop L1;
			
	end process;
		-- primeira caixa
		bigbox0: bigbox
		GENERIC MAP(n => n, 			-- se queremos contar 2^k temos que colocar n = k+1
						z => z) -- numero de trabalhadores por controlador
		PORT MAP(
			reset => reset, -- reseta a contagem
			clock => clock, -- clock do sistema, "vem da multibox" -Bonani, Gabriel
			inicial => inicial,	-- valor de inicio da contagem
			final => intermedio(n-1 downto 0)-1, -- valor final da contagem
			fim => fim(0), -- inica o termino da contagem e dos processos
			sinal_contador_controlador => sinal_contador_controlador_i
		);
		-- geração generica de BigBoxes e seus respectivos auxiliares
		gen_aux_bigbox:
			FOR i IN 1 TO g-2 GENERATE

				modulo_bigbox: bigbox
				GENERIC MAP( n => n, -- se queremos contar 2^k temos que colocar n = k+1
								 z => z) -- numero de trabalhadores por controlador
				PORT MAP(
					reset => reset, -- reseta a contagem
					clock => clock, -- clock do sistema, "vem da multibox" -Bonani, Gabriel
					inicial => intermedio(i*n-1 downto n*(i-1)),	-- valor de inicio da contagem "10100011110101110000101000111101"
					final => intermedio((i+1)*n-1 downto n*i)-1,	-- valor final da contagem "10100011110101110000101000111101"
					fim => fim(i) -- inica o termino da contagem e dos processos
				);
				
		END GENERATE gen_aux_bigbox;
		-- ultima caixa "lest bóqs" -Bonani, Machado
		bigbox3: bigbox
			GENERIC MAP(n => n, 			-- se queremos contar 2^k temos que colocar n = k+1
							z => z) -- numero de trabalhadores por controlador
			PORT MAP(
				reset => reset, -- reseta a contagem
				clock => clock, -- clock do sistema, "vem da multibox" -Bonani, Gabriel
				inicial => intermedio((g-1)*n-1 downto (g-2)*n),	-- valor de inicio da contagem
				final => final, -- valor final da contagem
				fim => fim(g-1), -- inica o termino da contagem e dos processos
				sinal_contador_controlador => sinal_contador_controlador_i
			);
			
--		bigbox0: bigbox
--		GENERIC MAP(n => n, 			-- se queremos contar 2^k temos que colocar n = k+1
--						z => z) -- numero de trabalhadores por controlador
--		PORT MAP(
--			reset => reset, -- reseta a contagem
--			clock => clock, -- clock do sistema, "vem da multibox" -Bonani, Gabriel
--			inicial => inicial,	-- valor de inicio da contagem
--			final => intermedio(n-1 downto 0)-1, -- valor final da contagem
--			fim => fim(0), -- inica o termino da contagem e dos processos
--			sinal_contador_controlador => sinal_contador_controlador_i
--		);
--		
--		bigbox1: bigbox
--		GENERIC MAP(n => n, 			-- se queremos contar 2^k temos que colocar n = k+1
--						z => z) -- numero de trabalhadores por controlador
--		PORT MAP(
--			reset => reset, -- reseta a contagem
--			clock => clock, -- clock do sistema, "vem da multibox" -Bonani, Gabriel
--			inicial => intermedio(n-1 downto 0),	-- valor de inicio da contagem
--			final => intermedio(2*n-1 downto n)-1, -- valor final da contagem
--			fim => fim(1), -- inica o termino da contagem e dos processos
--			sinal_contador_controlador => sinal_contador_controlador_i
--		);
--	
--			bigbox2: bigbox
--		GENERIC MAP(n => n, 			-- se queremos contar 2^k temos que colocar n = k+1
--						z => z) -- numero de trabalhadores por controlador
--		PORT MAP(
--			reset => reset, -- reseta a contagem
--			clock => clock, -- clock do sistema, "vem da multibox" -Bonani, Gabriel
--			inicial => intermedio(2*n-1 downto n),	-- valor de inicio da contagem
--			final => intermedio(3*n-1 downto 2*n)-1, -- valor final da contagem
--			fim => fim(2), -- inica o termino da contagem e dos processos
--			sinal_contador_controlador => sinal_contador_controlador_i
--		);
--		
--		bigbox3: bigbox
--		GENERIC MAP(n => n, 			-- se queremos contar 2^k temos que colocar n = k+1
--						z => z) -- numero de trabalhadores por controlador
--		PORT MAP(
--			reset => reset, -- reseta a contagem
--			clock => clock, -- clock do sistema, "vem da multibox" -Bonani, Gabriel
--			inicial => intermedio(3*n-1 downto 2*n),	-- valor de inicio da contagem
--			final => final, -- valor final da contagem
--			fim => fim(3), -- inica o termino da contagem e dos processos
--			sinal_contador_controlador => sinal_contador_controlador_i
--		);
--------------------------------------- sinais para debug -------------------------------------------------------
		hex0(0) <= not fim(0);
		hex0(1) <= not fim(1);
		hex0(2) <= not fim(2);
		hex0(3) <= not fim(3);
		hex0(4) <= not fim(4);
		hex0(5) <= not fim(5);
		hex0(6) <= not fim(6);
		hex1 <= not fim(13 downto 7);
		hex2 <= not fim(20 downto 14);
		hex3 <= not fim (27 downto 21);
		hex4(0 to 3) <= not fim (31 downto 28);
--		ledg(2 downto 0) <= intermedio(37 downto 35);
--------------------------------------- sinais para debug -------------------------------------------------------		
		
		
-- geração generica de BigBoxes e seus respectivos auxiliares
--	gen_aux_bigbox:
--		FOR i IN 0 TO l-1 GENERATE
--
--			modulo_bigbox: bigbox
--			GENERIC MAP( n => n, -- se queremos contar 2^k temos que colocar n = k+1
--						    z => z) -- numero de trabalhadores por controlador
--			PORT MAP(
--				reset => key(1), -- reseta a contagem
--				clock => clock, -- clock do sistema, "vem da multibox" -Bonani, Gabriel
--				inicial => num_base+68719476736*i,	-- valor de inicio da contagem "10100011110101110000101000111101"
--				final => ((num_base+68719476736*(i+1))-1),	-- valor final da contagem "10100011110101110000101000111101"
--				fim => fim_i(i) -- inica o termino da contagem e dos processos
--			);
--			
--	END GENERATE gen_aux_bigbox;
--			
--			modulo_bigbox_ultimo: bigbox
--			GENERIC MAP( n => n, -- se queremos contar 2^k temos que colocar n = k+1 134690174380
--						    z => z ) -- numero de trabalhadores por controlador
--			PORT MAP(
--				reset => key(1), -- reseta a contagem
--				clock => clock, -- clock do sistema, "vem da multibox" -Bonani, Gabriel
--				inicial => "11111111111111111111111111111111101001",	-- valor de inicio da contagem "11111111111111111111111111111111101001"
--				final =>  "11111111111111111111111111111111111111",	-- valor final da contagem
--				fim => fim_i(l) -- inica o termino da contagem e dos processos
--			);
--	
--	modulo_bigbox2: bigbox
--			GENERIC MAP( n => n, -- se queremos contar 2^k temos que colocar n = k+1
--						    z => z) -- numero de trabalhadores por controlador
--			PORT MAP(
--				reset => key(1), -- reseta a contagem
--				clock => clock, -- clock do sistema, "vem da multibox" -Bonani, Gabriel
--				inicial => "11000000000000000000000000000000000001",	-- valor de inicio da contagem "10100011110101110000101000111101"
--				final =>   "11111111111111111111111111111111111111",	-- valor final da contagem "10100011110101110000101000111101"
--				fim => fim_i(1) -- inica o termino da contagem e dos processos
--			);

	----------------------------------------------------------------
---obtem qual final do processo
---------------------------------------------------------------
--		obter_fim: process(fim_i)
--			variable temp: std_logic;
--			begin
--				temp := '1';
--				H1 : for i in 0 to l-1 loop
--				  temp := temp and fim_i(i);
--				end loop H1;
--			ledg(7) <= temp;
--		end process;
--	
--		obter_comp0: process(fim_i)
--			begin
--				G0 : for i in 0 to 1 loop
--				  hex0(i) <= fim_i(i);
--				end loop G0;
--		end process;
--		
--		obter_comp1: process(fim_i)
--			begin
--				G1 : for i in 0 to 6 loop
--				  hex1(i) <= fim_i(i+7);
--				end loop G1;
--		end process;
--		
--		obter_comp2: process(fim_i)
--			begin
--				G2 : for i in 0 to 6 loop
--				  hex2(i) <= fim_i(i+14);
--				end loop G2;
--		end process;
--		
--		obter_comp3: process(fim_i)
--			begin
--				G3 : for i in 0 to 6 loop
--				  hex3(i) <= fim_i(i+21);
--				end loop G3;
--		end process;
--		
--		obter_comp4: process(fim_i)
--			begin
--				G4 : for i in 0 to 6 loop
--				  hex4(i) <= fim_i(i+28);
--				end loop G4;
--		end process;
--		
--		obter_comp5: process(fim_i)
--			begin
--				G5 : for i in 0 to 6 loop
--				  hex5(i) <= fim_i(i+35);
--				end loop G5;
--		end process;
--		
--		obter_comp6: process(fim_i)
--			begin
--				G6 : for i in 0 to 6 loop
--				  hex6(i) <= fim_i(i+42);
--				end loop G6;
--		end process;
--			
--		obter_comp7: process(fim_i)
--			begin
--				G7 : for i in 0 to 1 loop
--				  hex5(i) <= fim_i(i+49);
--				end loop G7;
--		end process;
		
END MultiBox_arch;
