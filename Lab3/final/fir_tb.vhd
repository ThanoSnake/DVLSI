library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity fir_tb is
end entity fir_tb;

architecture Behavioral of fir_tb is

    component fir
        port (
            i_clk       : in  std_logic;
            i_rst       : in  std_logic;
            i_valid_in  : in  std_logic;
            i_x         : in  std_logic_vector(7 downto 0);
            o_valid_out : out std_logic;
            o_y         : out std_logic_vector(18 downto 0)
        );
    end component;

    signal clk          : std_logic := '0';
    signal rst          : std_logic := '0';
    signal valid_in     : std_logic := '0';
    signal x_in         : std_logic_vector(7 downto 0) := (others => '0');
    signal valid_out    : std_logic;
    signal y_out        : std_logic_vector(18 downto 0);

    constant CLK_PERIOD : time := 10 ns;

    type input_array is array (0 to 16) of integer;
    constant x_values : input_array := (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 0, 0, 0, 0, 0, 0, 0);

begin

    DUT: fir
        port map (
            i_clk       => clk,
            i_rst       => rst,
            i_valid_in  => valid_in,
            i_x         => x_in,
            o_valid_out => valid_out,
            o_y         => y_out
        );

    process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    process
    begin		

        wait for (10 * CLK_PERIOD);

        -- 1. Reset System
        rst <= '1';
        wait for (2 * CLK_PERIOD);
        valid_in <= '0';
        rst <= '0';
        wait for (2 * CLK_PERIOD);

        for i in 0 to 16 loop
            x_in <= std_logic_vector(to_unsigned(x_values(i), 8));
            valid_in <= '1';
            
            wait for CLK_PERIOD;
            
            valid_in <= '0';
            
            wait for (7 * CLK_PERIOD);
        end loop;

        wait for (1 * CLK_PERIOD);

        rst <= '1';
        wait for (2 * CLK_PERIOD);
        rst <= '0';

        x_in <= std_logic_vector(to_unsigned(1, 8));
        valid_in <= '1'; 
        wait for CLK_PERIOD;
        valid_in <= '0';
        wait for (3 * CLK_PERIOD);
        

        x_in <= std_logic_vector(to_unsigned(2, 8));
        valid_in <= '1'; 
        wait for CLK_PERIOD;
        valid_in <= '0';
        wait for (9 * CLK_PERIOD);

        x_in <= std_logic_vector(to_unsigned(3, 8));
        valid_in <= '1'; 
        wait for CLK_PERIOD;
        valid_in <= '0';
        wait for (8 * CLK_PERIOD);

        for i in 0 to 6 loop
            x_in <= std_logic_vector(to_unsigned(0, 8));
            valid_in <= '1';
            
            wait for CLK_PERIOD;
            
            valid_in <= '0';
            
            wait for (7 * CLK_PERIOD);
        end loop;

        wait for (10 * CLK_PERIOD);
        
        wait;
    end process;


end architecture;