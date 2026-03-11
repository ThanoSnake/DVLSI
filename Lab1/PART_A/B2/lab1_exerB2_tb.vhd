library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_reg_tb is
end entity; 

architecture tb of shift_reg_tb is
    ---------------------------------------------------------------
    -- COMPONENT
    ----------------------------------------------------------------
    component shift_reg is

        port (

            clk,rst,si,en,pl,mode:      in std_logic;
            din:                        in std_logic_vector(3 downto 0);
            so:                         out std_logic);

    end component;

    ---------------------------------------------------------------
    -- SIGNALS 
    ---------------------------------------------------------------
    signal s_clk,s_rst,s_si,s_en,s_pl,s_mode    : std_logic := '0';
    signal s_din                                : std_logic_vector(3 downto 0) := (others => '0'); 
    signal s_so                                 : std_logic;

    ---------------------------------------------------------------
    -- CONSTANTS
    ---------------------------------------------------------------
    constant CLOCK_PERIOD : time := 10 ns;

begin 

    DUT : shift_reg
        port map (
            clk     => s_clk,
            rst     => s_rst,
            si      => s_si,
            en      => s_en,
            pl      => s_pl,
            mode    => s_mode,
            din     => s_din,
            so      => s_so
        );


    GEN_CLK : process
    begin
        s_clk <= '0';
        wait for (CLOCK_PERIOD / 2);
        s_clk <= '1';
        wait for (CLOCK_PERIOD / 2);
    end process;

    STIMULUS : process
    begin
     
        -- INITIALIZE SIGNALS
        s_en <= '0'; --NO SHIFTS YET
        s_din <= (others => '0');
        wait for (1*CLOCK_PERIOD);

        --CHECK RESET 
        s_rst <= '0';
        wait for (1*CLOCK_PERIOD);
        s_rst <= '1';

        --CHECK PARALLEL LOAD
        s_din <= "1010";
        s_pl <= '1';
        wait for (1*CLOCK_PERIOD);
        s_pl <= '0';

        --CHECK RIGHT SHIFT (s_en = '1', s_mode = '0')
        s_mode <= '0';
        s_en   <= '1';
        s_si   <= '1';
        wait for (4*CLOCK_PERIOD);

        --CHECK PARALLEL LOAD
        s_en <= '0';
        s_pl <= '1';
        wait for (1*CLOCK_PERIOD);
        s_pl <= '0';

        --CHECK LEFT SHIFT (s_en = '1', s_mode = '1')
        s_mode <= '1';
        s_en <= '1';
        s_si   <= '0';
        wait for (4*CLOCK_PERIOD);

        --HALT SHIFT EXPERIMENT
        s_en <= '0';
        --PARALLEL LOAD (1111)
        s_din <= "1111";
        s_pl <= '1';
        wait for (1*CLOCK_PERIOD);
        s_pl <= '0';
        wait for (4*CLOCK_PERIOD);

        wait;
    end process;

end architecture;