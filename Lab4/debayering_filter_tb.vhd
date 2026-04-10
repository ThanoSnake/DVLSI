library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity debayering_filter_tb is
end entity;

architecture sim of debayering_filter_tb is

    -- Παράμετρος N=4 για τη δοκιμή
    constant N_tb : integer := 4;

    -- Σήματα για το Top-Level Module
    signal clk_tb             : std_logic := '0';
    signal rst_n_tb           : std_logic := '0';
    signal new_image_tb       : std_logic := '0';
    signal valid_in_tb        : std_logic := '0';
    signal pixel_tb           : std_logic_vector(7 downto 0) := (others => '0');
    
    signal valid_out_tb       : std_logic;
    signal image_finished_tb  : std_logic;
    signal R_tb               : std_logic_vector(7 downto 0);
    signal G_tb               : std_logic_vector(7 downto 0);
    signal B_tb               : std_logic_vector(7 downto 0);

    -- Περίοδος Ρολογιού 10ns (100 MHz)
    constant CLK_PERIOD : time := 10 ns;

begin

    -- UUT (Unit Under Test)
    UUT: entity work.debayering_filter
        generic map ( N => N_tb )
        port map (
            clk             => clk_tb,
            rst_n           => rst_n_tb,
            new_image       => new_image_tb,
            valid_in        => valid_in_tb,
            pixel           => pixel_tb,
            valid_out       => valid_out_tb,
            image_finished  => image_finished_tb,
            R               => R_tb,
            G               => G_tb,
            B               => B_tb
        );

    -- Γεννήτρια Ρολογιού
    clk_process : process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD / 2;
        clk_tb <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Διαδικασία Διέγερσης (Stimulus)
    stimulus : process
    begin

        wait for 100 * CLK_PERIOD;
        -- 1. Αρχικοποίηση & Reset
        rst_n_tb <= '0';
        wait for 3 * CLK_PERIOD;
        rst_n_tb <= '1';
        wait for 2 * CLK_PERIOD;

        -- 2. 1ος Κύκλος: new_image = 1, valid_in = 1, pixel = 1
        new_image_tb <= '1';
        valid_in_tb  <= '1';
        pixel_tb     <= std_logic_vector(to_unsigned(1, 8));
        wait for CLK_PERIOD;

        -- 3. Κύκλοι 2 έως 16: Το new_image πέφτει, το valid_in μένει 1 [cite: 65, 62, 63]
        new_image_tb <= '0';
        for i in 2 to (N_tb * N_tb) loop
            pixel_tb <= std_logic_vector(to_unsigned(i, 8));
            wait for CLK_PERIOD;
        end loop;

        -- 4. Τέλος Εικόνας
        valid_in_tb <= '0';
        pixel_tb    <= (others => '0');

        -- 5. Περιμένουμε να ολοκληρωθεί η επεξεργασία (να αδειάσει το Pipeline)
        wait for 20 * CLK_PERIOD;
        wait;
    end process;

end architecture;
