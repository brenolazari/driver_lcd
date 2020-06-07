library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity driver_lcd is
generic (
    FSM_INITIAL_STATE : std_logic_vector(1 downto 0) := "00";
    FSM_LOOP_STATE    : std_logic_vector(1 downto 0) := "01"
);
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
-- A taxa de escrita dos sinais relativos as interfaces do display de LCD deverão ser de 1k bps (no max)
-- O sinal de reset global (reset) deverá ser síncrono a borda de subida do master clock (clock).
-- O sinal de reset deverá reconfigurar o display considerando os comandos #1 : x"38", #2 : x"0F", #3 : x"06", #4 : x"01"
-- O sinal de reset também deverá apagar os dados salvos em todos os endereços do banco de registradores.
-- As definições de projeto não previstas nesta especificação devem ser tratadas e resolvidas pelos grupos de trabalho.

architecture driver_lcd_arch of driver_lcd is

    -- fsm varre oo banco de registrador e escreve no lcd
        -- primeiro estado deve configurar o display
        -- se ligar de ir setando a poriscoa do cursor (pular linha por ex) do lcd
    signal fsm    : std_logic_vector(1 downto 0) := FSM_INITIAL_STATE;
    signal s_rs   : std_logic := '0';
    signal s_en   : std_logic := '0';
    signal s_data : std_logic_vector(7 downto 0) := "00000000";

    procedure send_command_to_lcd(signal rs   : in integer;
                                  signal en   : in integer;
                                  signal data : in std_logic_vector(7 downto 0)) is
    begin
        -- TODO: protocolo que ta no pdf do sor
    end procedure;

begin

    -- TODO: Implementar/Instanciar banco de registradores

    process (clock, rst)
    begin
        if rst = '1' then
            fsm <= FSM_INITIAL_STATE;
        elsif clock'event and clock = '1' then
            case fsm is
                when FSM_INITIAL_STATE =>

                    -- TODO: limpar registradores

                    s_data <= "00000001"; -- limpa display
                    s_rs   <= '0';
                    s_en   <= '0';
                    send_command_to_lcd(s_rs, s_en, s_data);

                    s_data <= "00111000"; -- config basica
                    s_rs   <= '0';
                    s_en   <= '0';
                    send_command_to_lcd(s_rs, s_en, s_data);

                    s_data <= "00001111"; -- config cursor
                    s_rs   <= '0';
                    s_en   <= '0';
                    send_command_to_lcd(s_rs, s_en, s_data);

                    s_data <= "00000110"; -- config cursor
                    s_rs   <= '0';
                    s_en   <= '0';
                    send_command_to_lcd(s_rs, s_en, s_data);

                    -- ?? dps da config inicial, vai p loop que fica varrendo o registrador e printando no LCD
                    fsm <= FSM_LOOP_STATE;

                when FSM_LOOP_STATE =>
                    -- varrer reg e printar no LCD

                    -- if enable = '1' then -- TODO: Talvez validar addr e enable tbm

                    -- end if;
            end case;
        end if;
    end process;
end driver_lcd_arch;
