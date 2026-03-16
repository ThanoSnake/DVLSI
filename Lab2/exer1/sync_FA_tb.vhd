library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sync_FA_tb is
end entity;

architecture tb of sync_FA_tb is

    component sync_FA is
        port (
            i_rst               : in  std_logic;
            clk                 : in  std_logic;
            i_A, i_B, i_cin     : in  std_logic;
            o_sum, o_cout       : out std_logic
        );
    end component;

    signal i_rst                : std_logic;
    signal clk                  : std_logic;
    signal i_A, i_B, i_cin      : std_logic;
    signal o_sum, o_cout        : std_logic;

    constant CLOCK_PERIOD : time := 10 ns;

begin

    DUT: sync_FA
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
        variable test_vector : std_logic_vector(3-1 downto 0);
    begin
        i_rst <= '1';
        i_A   <= '0';
        i_B   <= '0';
        i_cin <= '0';
        wait for (2*CLOCK_PERIOD);
        i_rst <= '0';

        for i in 0 to 7 loop
            test_vector := std_logic_vector(to_unsigned(i,3));
            i_cin   <= test_vector(2);
            i_A     <= test_vector(1);
            i_B     <= test_vector(0);
            wait for (1*CLOCK_PERIOD);
        end loop;

        wait;
    end process;

end architecture;

         
