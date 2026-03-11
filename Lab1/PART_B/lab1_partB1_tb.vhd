library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity half_adder_tb is
end entity; 

architecture tb of half_adder_tb is 

    component half_adder
        port (
            a,b : in std_logic;
            s,c : out std_logic
        );
    end component;

    signal s_a, s_b : std_logic := '0';
    signal s_s, s_c : std_logic;
    --signal input_vector : std_logic_vector(1 downto 0);

    constant TIME_DELAY : time := 10 ns;

begin 

    DUT : half_adder
        port map (
            a    => s_a,
            b    => s_b,
            s    => s_s,
            c    => s_c
        );


    STIMULUS : process
        variable input_vector : std_logic_vector(1 downto 0);
    begin
        for i in 0 to 3 loop
            input_vector := std_logic_vector(to_unsigned(i, 2));
            --wait for 1 ns; --necessary stall to pass the values to input vector

            s_a <= input_vector(0);
            s_b <= input_vector(1);
            wait for (1*TIME_DELAY);
        end loop;
            
        wait;
    end process;
end tb;
            