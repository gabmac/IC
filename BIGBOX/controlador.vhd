--------------------------------------------------------------------------------------------------------------------------------------------------
-- Author: Gabriel Bonani Machado					
-- 							
-- Begin Date: 23/08/2017 
-- Revision History 	Date 		Author 		Comments
-- 					07/11/2017	Gabriel 		Criado
--------------------------------------------------------------------------------------------------------------------------------------------------
-- Purpose: 
-- criar um controlador que passara os valores analisados para cada 
-- componente de forma ordenada e que seja assincrono
--------------------------------------------------------------------------------------------------------------------------------------------------
		
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity controlador is
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
end entity;

Architecture controlador_arch of controlador is

	
	Signal fim,finalizador: std_logic; --sinal que indica se alguem esta pedindo
	Signal position: integer := 0; -- posica no barramento aonde sera colocado a informacao

	begin


----------------------------------------------------------------
---obtem o or entre os request para saber se tem um release
---------------------------------------------------------------
	
obter_release: process(request,release,finalizador,flag,fim)
	variable temp,finaliza: std_logic;
	begin
		temp := '0';
		G1 : for i in 0 to z-1 loop
		  temp := temp or request(i);
		  finaliza := finaliza and request(i);
	  end loop G1;
	release <= temp;
	ledr <= finaliza and flag;
	finaliza := '1';
end process;


----------------------------------------------------------------
---obtem qual trabalhador esta livre
---------------------------------------------------------------
	obter_livre:process (request,position,reset)

		variable a: integer := 0;
	begin  
	G2 : for i in z-1 downto 0 loop
			if(request(i) = '1') then
				a := i;
			end if;
		end loop;
		if(reset = '1') then
      position <= 0;
    else
		  position <= a;
		end if;
	end process;
-------------------------------------------------------------------
--coloca o valor no grant
-------------------------------------------------------------------
	
	coloca: process(release,position, reset)
	begin
		if(reset = '1' or flag = '1') then
			aviso <=(OTHERS => '0');
			grant <=(OTHERS => '0');
		else
			if(release = '1') then
				grant(((position+1)*n)-1 downto position*n)<=valor; -- coloca o dado no barramento certo
				aviso <=(OTHERS => '0');
				aviso(position)<='1';
			else
				aviso(position)<='0';
			end if;
		end if;
	end process;
	


	
END controlador_arch;