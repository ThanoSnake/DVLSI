library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity full_adder_tb is
end entity; 

architecture tb of full_adder_tb is 

    component full_adder
        port (
            a,b,cin : in std_logic;
            s,cout  : out std_logic
        );
    end component;

    signal s_a, s_b, s_cin  : std_logic := '0';
    signal s_s, s_cout      : std_logic;
    --signal input_vector     : std_logic_vector(2 downto 0);

    constant TIME_DELAY : time := 10 ns;

begin 

    DUT : full_adder
        port map (
            a       => s_a,
            b       => s_b,
            cin     => s_cin,
            s       => s_s,
            cout    => s_cout
        );


    STIMULUS : process
        variable input_vector : std_logic_vector(2 downto 0);
    begin
        for i in 0 to 7 loop
            input_vector := std_logic_vector(to_unsigned(i, 3));
            --wait for 5 ns;

            s_a     <= input_vector(2);
            s_b     <= input_vector(1);
            s_cin   <= input_vector(0);
            wait for (1*TIME_DELAY);
            
        end loop;
            
        wait;
    end process;
end tb;
            