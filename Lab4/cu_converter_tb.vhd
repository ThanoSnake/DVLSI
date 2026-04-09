library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_image_processor is
-- Τα testbenches δεν έχουν ports
end entity;

architecture bhv of tb_image_processor is

    -- Παράμετροι
    constant N_VAL      : integer := 4;
    constant CLK_PERIOD : time := 10 ns;

    -- Σήματα διασύνδεσης με το DUT (Device Under Test)
    signal clk            : std_logic := '0';
    signal rst_n          : std_logic := '0';
    signal new_image      : std_logic := '0';
    signal valid_in       : std_logic := '0';
    signal data_in        : std_logic_vector(7 downto 0) := (others => '0');
    
    signal state1         : std_logic_vector(3 downto 0);
    signal state2         : std_logic_vector(1 downto 0);
    signal valid_out      : std_logic;
    signal image_finished : std_logic;
    signal data_out       : std_logic_vector(71 downto 0);

    -- Πίνακας με δεδομένα εισόδου (16 pixels για N=4)
    type pixel_array is array (0 to 15) of integer;
    constant TEST_PIXELS : pixel_array := (
        1,  2,  3,  4,
        5,  6,  7,  8,
        9, 10, 11, 12,
        13, 14, 15, 16
    );

begin

    -- Instantiation του Top-Level Module
    DUT: entity work.image_processor_top
        generic map (
            N => N_VAL
        )
        port map (
            clk            => clk,
            rst_n          => rst_n,
            new_image      => new_image,
            valid_in       => valid_in,
            data_in        => data_in,
            state1         => state1,
            state2         => state2,
            valid_out      => valid_out,
            image_finished => image_finished,
            data_out       => data_out
        );

    -- Δημιουργία Ρολογιού
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus Process
    stim_proc: process
    begin
        -- 1. Αρχικοποίηση και Reset
        rst_n <= '0';
        new_image <= '0';
        valid_in <= '0';
        data_in <= (others => '0');
        wait for CLK_PERIOD * 2;
        
        rst_n <= '1'; -- Απελευθέρωση reset
        wait for CLK_PERIOD;

        -- 2. Έναρξη Νέας Εικόνας (new_image για 1 κύκλο)
        -- Ταυτόχρονα ξεκινάμε την παροχή του 1ου pixel
        new_image <= '1';
        valid_in  <= '1';
        data_in   <= std_logic_vector(to_unsigned(TEST_PIXELS(0), 8));
        wait for CLK_PERIOD;

        -- 3. Συνέχεια παροχής pixels (valid_in παραμένει στο '1')
        new_image <= '0';
        for i in 1 to 15 loop
            data_in <= std_logic_vector(to_unsigned(TEST_PIXELS(i), 8));
            wait for CLK_PERIOD;
        end loop;

        -- 4. Τέλος εισόδου δεδομένων
        valid_in <= '0';
        data_in  <= (others => '0');

        -- Αναμονή για να δούμε την επεξεργασία (το CU συνεχίζει να μετράει)
        wait for CLK_PERIOD * 30;
        wait;
    end process;

end architecture;
