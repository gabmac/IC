------------------------------------------------------------------------------------------------------------------------------------
-- Purpose: 
-- criar um contador que implemente valores impares com 8 bits
--------------------------------------------------------------------------------------------------------------------------------------------------
		
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity contador is
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
end entity;

architecture contador_arch of contador is
	
	
	begin
	
--------------------------------------------
-- ProcessName:processo
-- o process a seguir soma inicializa o 
-- valor com 1 e soma em 2 a cada ciclo
--------------------------------------------
	
	processo: PROCESS(clock, reset_n, incr_pc) 
		variable value : std_logic_vector(n-1 downto 0):=(OTHERS => '0'); --inicializa com o primeiro numero da sequencia
		begin
			
		if (reset_n = '1') then --reseta o valor
			value := inicial;
		elsif (rising_edge(clock)) then 
			if(flag = '1') then -- caso tenha chego no numero maixmo para a contagem
				value (n-1 DOWNTO 0) := (OTHERS => '0');
			elsif (incr_pc = '1') then  -- a cada subida de clock e somado 2 no valor se o enable de contagem estiver ativo
				value := value + 2;
			end if;
		end if;
		
		if (value >= inicial and value <= final) then -- liga a flag de terminop quando atinge o range maximo
			flag <= '0';
		else
			flag <= '1';
		end if;
	
	count <= value;
	
	end process;
	
	
	
end contador_arch;