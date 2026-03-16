library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Η είσοδος περνάει από 9 registers (καθυστέρησης) για να φθάσει στην έξοδο
-- T_latency: Από ακμή ανάγνωσης input έως ακμή εμφάνισης output
-- Τ_latency = 9*CLOCK_PERIOD.

entity sync_RCM4_tb is
end entity;

architecture tb of sync_RCM4_tb is

    component sync_RCM4 is
        port (
            clk     : in  std_logic;
            i_rst   : in  std_logic;
            i_A     : in  std_logic_vector(4-1 downto 0);
            i_B     : in  std_logic_vector(4-1 downto 0);
            o_P     : out std_logic_vector(4+4-1 downto 0)
        );
    end component;

    signal clk     : std_logic;
    signal i_rst   : std_logic;
    signal i_A     : std_logic_vector(4-1 downto 0);
    signal i_B     : std_logic_vector(4-1 downto 0);
    signal o_P     : std_logic_vector(4+4-1 downto 0);

    constant CLOCK_PERIOD : time := 10 ns;

begin 

    DUT: sync_RCM4
        port map (
            clk     => clk,
            i_rst   => i_rst,
            i_A     => i_A,
            i_B     => i_B,
            o_P     => o_P
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

        i_rst   <= '1';
        i_A     <= (others => '0');
        i_B     <= (others => '0');
        wait for (2*CLOCK_PERIOD);
        i_rst <= '0';

        i_B <= "0001";
        for i in 0 to 15 loop
            i_A <= std_logic_vector(to_unsigned(i,4));
            wait for (1*CLOCK_PERIOD);
        end loop;

        wait for (9*CLOCK_PERIOD);

        i_rst <= '1';
        wait for (2*CLOCK_PERIOD);
        i_rst <= '0';
        
        i_B <= "0010";
        for i in 0 to 15 loop
            i_A <= std_logic_vector(to_unsigned(i,4));
            wait for (1*CLOCK_PERIOD);
        end loop;

        wait for (9*CLOCK_PERIOD);

        i_rst <= '1';
        wait for (1*CLOCK_PERIOD);
        i_rst <= '0';
        
        i_B <= "0011";
        for i in 0 to 15 loop
            i_A <= std_logic_vector(to_unsigned(i,4));
            wait for (1*CLOCK_PERIOD);
        end loop;

        wait;
    
    end process;

end architecture;
        
