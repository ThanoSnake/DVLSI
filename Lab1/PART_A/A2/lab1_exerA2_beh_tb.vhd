library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decoder3_to_8_beh_tb is
end entity; 

architecture tb of decoder3_to_8_beh_tb is
    ---------------------------------------------------------------
    -- COMPONENT
    ----------------------------------------------------------------
    component decoder3_to_8_beh is 
        port (
            enc : in  std_logic_vector(2 downto 0);
            dec : out std_logic_vector(7 downto 0)
        );
    end component;

    ---------------------------------------------------------------
    -- SIGNALS 
    ---------------------------------------------------------------
    signal s_enc : std_logic_vector(2 downto 0) := (others => '0'); 
    signal s_dec : std_logic_vector(7 downto 0);

    ---------------------------------------------------------------
    -- CONSTANTS
    ---------------------------------------------------------------
    constant TIME_DELAY : time := 20 ns;

begin 

    DUT : decoder3_to_8_beh
        port map (
            enc => s_enc,
            dec => s_dec
        );


    STIMULUS : process
    begin
     
        -- INITIALIZE SIGNALS
        s_enc <= (others => '0');
        wait for (1*TIME_DELAY);

        for i in 0 to 7 loop
            s_enc <= std_logic_vector(to_unsigned(i, 3)); 
            wait for (1*TIME_DELAY);
        end loop;

        s_enc <= (others => '0');
        wait for (1 * TIME_DELAY);

        wait;

    end process;

end architecture;