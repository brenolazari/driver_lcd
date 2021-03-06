library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity driver_lcd is
generic (
    ZERO_BYTE                    : std_logic_vector(7 downto 0) := "00000000";
    BASIC_CONFIG                 : std_logic_vector(7 downto 0) := "00111000";
    CURSOR_CONTROL_CONFIG        : std_logic_vector(7 downto 0) := "00001111";
    CURSOR_MVMT_CONFIG           : std_logic_vector(7 downto 0) := "00000110";
    CLEAN_DISPLAY_CONFIG         : std_logic_vector(7 downto 0) := "00000001";
    REG_BANK_SIZE                : integer := 32;
    FSM_INITIAL_STATE            : std_logic_vector(3 downto 0) := "0000";
    FSM_SEND_CMD_STATE_ONE       : std_logic_vector(3 downto 0) := "0001";
    FSM_SEND_CMD_STATE_TWO       : std_logic_vector(3 downto 0) := "0010";
    FSM_SEND_CMD_STATE_THREE     : std_logic_vector(3 downto 0) := "0011";
    FSM_LOOP_STATE               : std_logic_vector(3 downto 0) := "0100";
    FSM_SET_POSITION_STATE_ONE   : std_logic_vector(3 downto 0) := "0101";
    FSM_SET_POSITION_STATE_TWO   : std_logic_vector(3 downto 0) := "0110";
    FSM_SET_POSITION_STATE_THREE : std_logic_vector(3 downto 0) := "0111";
    FSM_SEND_CHAR                : std_logic_vector(3 downto 0) := "1000"
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

    signal fsm         : std_logic_vector(3 downto 0) := FSM_INITIAL_STATE;
    signal address_byte: std_logic_vector(7 downto 0) := ZERO_BYTE;
    signal position    : std_logic_vector(7 downto 0) := ZERO_BYTE;

    -- CONFIGS BASICAS... DEVE RODAR NO PRIMEIRO ESTADO
    type config_instructions_array is array (0 to 3) of std_logic_vector(7 downto 0);
    signal config_instructions: config_instructions_array := (0 => BASIC_CONFIG, 1 => CURSOR_CONTROL_CONFIG, 2 => CURSOR_MVMT_CONFIG, 3 => CLEAN_DISPLAY_CONFIG);

    -- BANCO DE REGISTRADORES
    type reg_bank_array is array (0 to (REG_BANK_SIZE - 1)) of std_logic_vector(7 downto 0);
    signal reg_bank : reg_bank_array;

begin

    LCD: process (clock, reset)
    variable config_int_index  : integer := 0;
    variable reg_current_index : integer := 0;
    begin
        if reset = '1' then
            config_int_index  := 0;
            reg_current_index := 0;
            fsm <= FSM_INITIAL_STATE;
        elsif clock'event and clock = '1' and reset = '0' then
            case fsm is
                when FSM_INITIAL_STATE =>

                -- dps de configurar vai p estado de execucao que fica varrendo o banco de registrador e mandando o comando pro lcd
                if (config_int_index = 4) then
                    
                    fsm <= FSM_LOOP_STATE;
                    
                else
		    if (config_int_index = 0) then
                    	-- limpa registradores
                    	for i in 0 to (REG_BANK_SIZE - 1) loop
                        	reg_bank(i) <= ZERO_BYTE; 
                    	end loop;
		    end if ;
		                        
                    -- pega configs basicas do array
                    lcd_data <= config_instructions(config_int_index);
                    lcd_rs   <= '0';
                        
                    -- incrementa index e vai p estado de enviar comando pro lcd
                    config_int_index := config_int_index + 1;
                    fsm <= FSM_SEND_CMD_STATE_ONE;

                end if;

                when FSM_SEND_CMD_STATE_ONE =>

                    lcd_en <= '1';
                    fsm <= FSM_SEND_CMD_STATE_TWO;

                when FSM_SEND_CMD_STATE_TWO =>

                    lcd_en <= '0';
                    fsm <= FSM_SEND_CMD_STATE_THREE;
                
                -- talvez nao precise desse estado
                when FSM_SEND_CMD_STATE_THREE =>

                    fsm <= FSM_INITIAL_STATE;

                when FSM_LOOP_STATE =>

                        -- varrer reg e printar no LCD
                        for reg_index in reg_current_index to (REG_BANK_SIZE - 1) loop

                            -- se tiver char na posicao, manda pro lcd
                            if reg_bank(reg_index) /= ZERO_BYTE then

				-- seta posicao do cursor
				address_byte <= std_logic_vector(to_unsigned(reg_index, address_byte'length));
				-- 00010001 (17)
				
				-- comando para setar posicao no lcd
				position(7) <= '1';
				position(6) <= address_byte(4); -- linha
				position(5) <= '0';
				position(4) <= '0';
				position(3) <= address_byte(3); -- coluna 
				position(2) <= address_byte(2); -- coluna 
				position(1) <= address_byte(1); -- coluna 
				position(0) <= address_byte(0); -- coluna 
							                                
                                -- antes de mandar o char, seta a o posicao no lcd
                                lcd_data <= position;
                                lcd_rs <= '0';
				
				-- char a ser enviado depois de setar a posicao
				--aux_char <= reg_bank(reg_index);
				
				-- mantem o indice atual q ta varrendo o reg_bank
				--reg_current_index := reg_index;
                                fsm <= FSM_SET_POSITION_STATE_ONE;
				--exit;
                            end if;
				
			   --reg_current_index := reg_index;

                        end loop;

                        reg_current_index := 0;

		when FSM_SET_POSITION_STATE_ONE =>
			lcd_en <= '1';
                    	fsm <= FSM_SET_POSITION_STATE_TWO;
			
		when FSM_SET_POSITION_STATE_TWO =>
			lcd_en <= '0';
                    	fsm <= FSM_SET_POSITION_STATE_THREE;

		when FSM_SET_POSITION_STATE_THREE =>
			fsm <= FSM_SEND_CHAR;

		when FSM_SEND_CHAR =>
			--lcd_data <= reg_bank(reg_current_index);
			lcd_rs <= '1';

			fsm <= FSM_SEND_CMD_STATE_ONE;
                when others =>

            end case;
        end if;
    end process;

    BANK: process (clock, reset)
    begin
        if reset = '1' then
            -- fsm <= FSM_INITIAL_STATE;
        elsif clock'event and clock = '1' and reset = '0' then
		if enable = '1' then
			reg_bank(to_integer(unsigned(addr))) <= data;
		end if;  
	end if;
    end process;
end driver_lcd_arch;
