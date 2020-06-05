library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity driver_lcd is
port (

	reset    : in std_logic;                     -- Entrada de referencia do relogio
	clock    : in std_logic;                     -- Sinal de reset de global do bloco
	data     : in std_logic_vector(7 downto 0);	 -- Entrada de dados
	addr     : in std_logic_vector(4 downto 0);  -- Entrada de endereços
	enable   : in std_logic;                     -- Entrada de habilitação de escrita de dados
    lcd_data : out std_logic_vector(7 downto 0); -- Barramento de dados do display de LCD
    lcd_en   : out std_logic;                    -- Sinal de enable do display de LCD
    lcd_rs   : out std_logic                     -- Sinal de controle de dado do display de LCD
  );
end driver_lcd;

--                   ---------------------------------------
--                   |                                     |
-------clock-------> |                                     |
-------reset-------> |      BANCO                          |------lcd_data--->
-------data--------> |        DE               FSM         |------lcd_rs----->
-------addr--------> |   REGISTRADORES                     |------lcd_en----->
-------enable------> |                                     |
--                   |                          driver_lcd |
--                   ---------------------------------------

-- OBS:
-- clock master (clock) 100Mhz; sinais sincrono a borda de subida
-- Os bits mais significativos dos barramentos de dados e endereço deverão ser considerados o bit da esquerda.
-- O processo de escrita no driver deverá ser síncrono ao clock master considerando o dado, endereço e o sinal de habilitação
-- O driver de circuito possuirá um banco de registradores relativos aos caracteres que deverão ser escritos no display de LCD.
-- O endereço “00000” será relativo a primeira posição da linha superior. O endereço “11111” será relativo a última posição da linha inferior do display de LCD.
-- A taxa de escrita dos sinais relativos as interfaces do display de LCD deverão ser de 1k bps
-- O sinal de reset global (reset) deverá ser síncrono a borda de subida do master clock (clock).
-- O sinal de reset deverá reconfigurar o display considerando os comandos #1 : x"38", #2 : x"0F", #3 : x"06", #4 : x"01"
-- O sinal de reset também deverá apagar os dados salvos em todos os endereços do banco de registradores.
-- As definições de projeto não previstas nesta especificação devem ser tratadas e resolvidas pelos grupos de trabalho.

architecture driver_lcd_arch of driver_lcd is

begin



end driver_lcd_arch;
