library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity bcd_pa4_tb is
end bcd_pa4_tb;

architecture tb of bcd_pa4_tb is

    component bcd_pa4
        port (
            a, b : in  std_logic_vector(15 downto 0);
            cin  : in  std_logic;
            sum  : out std_logic_vector(15 downto 0);
            cout : out std_logic
        );
    end component;

    signal s_a    : std_logic_vector(15 downto 0) := (others => '0');
    signal s_b    : std_logic_vector(15 downto 0) := (others => '0');
    signal s_cin  : std_logic := '0';
    signal s_sum  : std_logic_vector(15 downto 0);
    signal s_cout : std_logic;

    constant TIME_DELAY : time := 20 ns;

begin

    DUT: bcd_pa4
        port map (
            a    => s_a,
            b    => s_b,
            cin  => s_cin,
            sum  => s_sum,
            cout => s_cout
        );

    STIMULUS: process
    begin
        
        s_a <= x"1234"; s_b <= x"5678"; s_cin <= '0';
        wait for (1*TIME_DELAY);

        s_a <= x"0009"; s_b <= x"0001"; s_cin <= '0';
        wait for (1*TIME_DELAY);

        s_a <= x"9999"; s_b <= x"0001"; s_cin <= '0';
        wait for (1*TIME_DELAY);

        s_a <= x"9999"; s_b <= x"9999"; s_cin <= '1';
        wait for (1*TIME_DELAY);

        s_a <= x"9998"; s_b <= x"0001"; s_cin <= '1';
        wait for (1*TIME_DELAY);

        s_a <= x"4567"; s_b <= x"2835"; s_cin <= '0';
        wait for (1*TIME_DELAY);

        wait; 
    end process;

end tb;