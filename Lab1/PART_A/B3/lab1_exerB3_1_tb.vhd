library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rtl1_tb is
end entity; 

architecture tb of rtl1_tb is
    ---------------------------------------------------------------
    -- COMPONENT
    ----------------------------------------------------------------
    component count3_1 is

        port (

            clk,resetn,count_en : in std_logic;
            mode                : in std_logic; --COMMENT OUT IF B3_2
            --modulo              : in std_logic_vector(2 downto 0); --COMMENT OUT IF B3_1
            sum                 : out std_logic_vector(2 downto 0);
            cout                : out std_logic 
        );

    end component;

    ---------------------------------------------------------------
    -- SIGNALS 
    ---------------------------------------------------------------
    signal s_clk,s_resetn,s_count_en            : std_logic := '0';
    signal s_mode                               : std_logic := '0';  --COMMENT OUT IF B3_2
    --signal s_modulo                             : std_logic_vector(2 downto 0) := (others => '0');  --COMMENT OUT IF B3_1
    signal s_sum                                : std_logic_vector(2 downto 0); 
    signal s_cout                               : std_logic;

    ---------------------------------------------------------------
    -- CONSTANTS
    ---------------------------------------------------------------
    constant CLOCK_PERIOD : time := 10 ns;

begin 

    DUT : count3_1
        port map (
            clk         => s_clk,
            resetn      => s_resetn,
            count_en    => s_count_en,
            mode        => s_mode,
            --modulo      => s_modulo,  --COMMENT OUT IF B3_2
            sum         => s_sum,
            cout        => s_cout
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
        s_count_en <= '0'; 
        --s_modulo <= (others => '0');
        wait for (1*CLOCK_PERIOD);

        --CHECK RESET 
        s_resetn <= '0';
        wait for (1*CLOCK_PERIOD);
        s_resetn <= '1';

        ----------------
        --CHECK B3_1--
        ----------------

        --CHECK COUNT UP
        s_count_en <= '1';
        s_mode <= '1';
        wait for (9*CLOCK_PERIOD);

        --CHECK COUNT DOWN
        s_mode   <= '0';
        wait for (9*CLOCK_PERIOD);

        s_count_en <= '0';

        ----------------
        --CHECK B3_2--
        ----------------
        --s_modulo <= "101";
        --s_count_en <= '1';
        --wait for (10*CLOCK_PERIOD);

        --s_count_en <= '0';
        wait;
    end process;

end architecture;