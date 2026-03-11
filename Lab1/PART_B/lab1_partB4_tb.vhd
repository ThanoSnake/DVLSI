library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bcd_fa_tb is
end entity; 

architecture tb of bcd_fa_tb is 

    component bcd_fa
        port (
            a,b     : in std_logic_vector(3 downto 0);
            cin     : in std_logic;
            sum     : out std_logic_vector(3 downto 0);
            cout    : out std_logic
        );
    end component;

    signal s_a, s_b         : std_logic_vector(3 downto 0) := (others => '0');
    signal s_cin            : std_logic := '0';
    signal s_cout           : std_logic;
    signal s_sum            : std_logic_vector(3 downto 0);

    constant TIME_DELAY : time := 10 ns;

begin 

    DUT : bcd_fa
        port map (
            a       => s_a,
            b       => s_b,
            cin     => s_cin,
            sum     => s_sum,
            cout    => s_cout
        );


    STIMULUS : process

    begin
        s_a <= std_logic_vector(to_unsigned(2,4));
        s_b <= std_logic_vector(to_unsigned(4,4));
        wait for (1*TIME_DELAY);

        s_a <= std_logic_vector(to_unsigned(4,4));
        s_b <= std_logic_vector(to_unsigned(5,4));
        wait for (1*TIME_DELAY);

        s_a <= std_logic_vector(to_unsigned(7,4));
        s_b <= std_logic_vector(to_unsigned(6,4));
        wait for (1*TIME_DELAY);

        s_a     <= std_logic_vector(to_unsigned(9,4));
        s_b     <= std_logic_vector(to_unsigned(9,4));
        wait for (1*TIME_DELAY);

        s_a     <= std_logic_vector(to_unsigned(1,4));
        s_b     <= std_logic_vector(to_unsigned(1,4));
        s_cin   <= '1';
        wait for (1*TIME_DELAY);
    --    for i in 0 to 9 loop
    --        for j in 0 to 9 loop
    --            for k in 0 to 1 loop
    --                s_a <= std_logic_vector(to_unsigned(i, 4));
    --                s_b <= std_logic_vector(to_unsigned(j, 4));
    --                if k = 1 then
    --                    s_cin <= '1';
    --                else
    --                    s_cin <= '0';
    --                end if;
    --                wait for (1*TIME_DELAY);
    --            end loop;
    --        end loop;
    --    end loop;
            
        wait;
    end process;
end tb;
            