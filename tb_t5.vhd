library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
 
entity tb_driver_lcd is
end tb_driver_lcd;
 
architecture tb_driver_lcd of tb_driver_lcd is
    signal tb_data     : std_logic_vector(7 downto 0) := "00000000";
    signal tb_addr     : std_logic_vector(4 downto 0) := "00000";
    signal tb_enable   : std_logic := '0';
    signal tb_lcd_data : std_logic_vector(7 downto 0) := "00000000";
    signal tb_lcd_en   : std_logic := '0';
    signal tb_lcd_rs   : std_logic := '0';
    signal tb_clock    : std_logic := '1';
    signal tb_reset    : std_logic := '0';
begin

    LCD: entity work.driver_lcd
    port map(
    clock => tb_clock,
    reset => tb_reset,
    data => tb_data,
    addr => tb_addr,
    enable => tb_enable,
    lcd_data => tb_lcd_data,
    lcd_en => tb_lcd_en,
    lcd_rs => tb_lcd_rs
    );

    tb_clock <= not tb_clock after 10 ns;
	
    process
    begin
    	wait for 40 ns;
    	tb_reset <= '1';
        wait for 20 ns;
    	tb_reset <= '0';
    	wait for 80 ns;
    	tb_data <= "01000001"; -- A
    	tb_addr <= "10000"; -- 16
    	tb_enable <= '1';
    	wait for 20 ns;
    	tb_enable <= '0';
    	wait for 20 ns;
    	tb_data <= "01000010"; -- B
    	tb_addr <= "10011"; -- 19
    	tb_enable <= '1';
    	wait for 20 ns;
    	tb_enable <= '0';
    	wait for 20000 ns;
    end process;
 
end tb_driver_lcd;