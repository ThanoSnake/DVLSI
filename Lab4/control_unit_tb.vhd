library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity control_unit_tb is
-- Το testbench δεν έχει ποτέ ports
end entity;

architecture sim of control_unit_tb is

    -- 1. Δήλωση του Component
    component control_unit
        generic (
            N : integer := 16
        );
        port (
            clk             : in  std_logic;
            rst_n           : in  std_logic;
            new_image       : in  std_logic;
            valid_in        : in  std_logic;
            wr_en           : out std_logic_vector(2 downto 0);
            rd_en           : out std_logic_vector(2 downto 0);
            state1          : out std_logic_vector(3 downto 0);
            state2          : out std_logic_vector(1 downto 0);
            valid_out       : out std_logic;
            image_finished  : out std_logic
        );
    end component;

    -- 2. Εσωτερικά Σήματα (Δίνουμε την τιμή 16 στο generic)
    constant N_tb             : integer := 16;
    signal clk_tb             : std_logic := '0';
    signal rst_n_tb           : std_logic := '0';
    signal new_image_tb       : std_logic := '0';
    signal valid_in_tb        : std_logic := '0';
    
    signal wr_en_tb           : std_logic_vector(2 downto 0);
    signal rd_en_tb           : std_logic_vector(2 downto 0);
    signal state1_tb          : std_logic_vector(3 downto 0);
    signal state2_tb          : std_logic_vector(1 downto 0);
    signal valid_out_tb       : std_logic;
    signal image_finished_tb  : std_logic;

    -- Περίοδος Ρολογιού
    constant CLK_PERIOD : time := 10 ns;

begin

    -- 3. Ενσωμάτωση (Instantiation) του UUT (Unit Under Test)
    UUT: control_unit
        generic map (
            N => N_tb
        )
        port map (
            clk             => clk_tb,
            rst_n           => rst_n_tb,
            new_image       => new_image_tb,
            valid_in        => valid_in_tb,
            wr_en           => wr_en_tb,
            rd_en           => rd_en_tb,
            state1          => state1_tb,
            state2          => state2_tb,
            valid_out       => valid_out_tb,
            image_finished  => image_finished_tb
        );

    -- 4. Δημιουργία Ρολογιού
    clk_process : process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD / 2;
        clk_tb <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- 5. Κύρια Διαδικασία Δοκιμής (Stimulus)
    stimulus : process
    begin
        -- ΑΡΧΙΚΟΠΟΙΗΣΗ & RESET
        rst_n_tb     <= '0';
        new_image_tb <= '0';
        valid_in_tb  <= '0';
        wait for 5 * CLK_PERIOD;
        
        rst_n_tb <= '1'; -- Απελευθέρωση του reset
        wait for 2 * CLK_PERIOD;
        
        -- Συγχρονισμός στην αρνητική ακμή για να αλλάζουν τα σήματα 
        -- πριν δει την αλλαγή το ρολόι (για καθαρά waveforms)
        
        -- ΕΝΑΡΞΗ ΕΙΚΟΝΑΣ
        new_image_tb <= '1';
        valid_in_tb  <= '1';
        wait for CLK_PERIOD;
        
        -- Το new_image πρέπει να είναι ψηλά μόνο για 1 κύκλο
        new_image_tb <= '0'; 
        
        -- Στέλνουμε τα υπόλοιπα pixels (Συνολικά N*N = 256 κύκλοι)
        -- Έχουμε ήδη στείλει 1, άρα στέλνουμε άλλα 255
        for k in 1 to (N_tb * N_tb - 1) loop
            wait for CLK_PERIOD;
        end loop;
        
        -- ΤΕΛΟΣ ΕΙΚΟΝΑΣ (Σταματάει το streaming)
        valid_in_tb <= '0';
        
        -- Περιμένουμε αρκετούς κύκλους για να δούμε το pipeline να "αδειάζει"
        -- και τα σήματα rd_en, wr_en να τερματίζουν ομαλά.
        wait for 40 * CLK_PERIOD;
        
        wait; -- Σταματάει την προσομοίωση
    end process;

end architecture;