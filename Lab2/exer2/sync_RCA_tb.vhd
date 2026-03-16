library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sync_RCA_tb is
end entity;

architecture tb of sync_RCA_tb is

    component sync_RCA4 is
        port (
            i_rst       : in  std_logic;
            clk         : in  std_logic;
            i_A, i_B    : in  std_logic_vector(4-1 downto 0);
            i_cin       : in  std_logic;
            o_sum       : out std_logic_vector(4-1 downto 0);
            o_cout      : out std_logic
        );
    end component;

    signal i_rst       : std_logic;
    signal clk         : std_logic;
    signal i_A, i_B    : std_logic_vector(4-1 downto 0);
    signal i_cin       : std_logic;
    signal o_sum       : std_logic_vector(4-1 downto 0);
    signal o_cout      : std_logic;

    constant CLOCK_PERIOD : time := 10 ns; --check this

begin

    DUT : sync_RCA4
        port map (
            i_rst   => i_rst,
            clk     => clk,
            i_A     => i_A,
            i_B     => i_B,
            i_cin   => i_cin,
            o_sum   => o_sum,
            o_cout  => o_cout
        );

    clk_process: process
    begin
        clk <= '0';
        wait for CLOCK_PERIOD/2;
        clk <= '1';
        wait for CLOCK_PERIOD/2;
    end process;

    STIMULUS: process
    begin

        i_rst <= '1';
        i_A <= (others => '0');
        i_B <= (others => '0');
        i_cin <= '0';
        wait for (1*CLOCK_PERIOD);
        i_rst <=  '0';

        i_B <= "0001";
        for i in 0 to 15 loop
            i_A <= std_logic_vector(to_unsigned(i, 4));
            wait for (1*CLOCK_PERIOD);
        end loop;

        i_rst <= '1';
        wait for (1*CLOCK_PERIOD);
        i_rst <= '0';

        i_cin <= '1';
        i_B <= (others => '0');
        for i in 0 to 15 loop
            i_A <= std_logic_vector(to_unsigned(i, 4));
            wait for (1*CLOCK_PERIOD);
        end loop;
        
        wait;
    end process;

end architecture;