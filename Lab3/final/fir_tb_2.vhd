library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_top_tb is
end entity;

architecture Behavioral of fir_top_tb is

    -- Δήλωση του Component fir (με τις διορθωμένες θύρες)
    component fir
        port (
            i_clk       : in  std_logic;
            i_rst       : in  std_logic;    
            i_valid_in  : in  std_logic;
            i_x         : in  std_logic_vector(7 downto 0);
            o_valid_out : out std_logic;
            o_y         : out std_logic_vector(18 downto 0)
        );
    end component;

    -- Σήματα διασύνδεσης
    signal clk          : std_logic := '0';
    signal rst          : std_logic := '0';
    signal valid_in     : std_logic := '0';
    signal x_in         : std_logic_vector(7 downto 0) := (others => '0');
    signal valid_out    : std_logic;
    signal y_out        : std_logic_vector(18 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    -- Σύνδεση του FIR (Device Under Test)
    DUT: fir
        port map (
            i_clk       => clk,
            i_rst       => rst,
            i_valid_in  => valid_in,
            i_x         => x_in,
            o_valid_out => valid_out,
            o_y         => y_out
        );

    -- Παραγωγή Ρολογιού
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Κύριο Σενάριο Προσομοίωσης (Stimulus)
    stim_proc: process
    begin		
        -- 1. Αρχικοποίηση Συστήματος (Reset) [cite: 15, 40-41]
        rst <= '1';
        wait for 2 * CLK_PERIOD;
        rst <= '0';
        wait for 5 * CLK_PERIOD;

        -- ΣΕΝΑΡΙΟ 1: Κανονική Είσοδος (Σύντομος Παλμός)
        -- Στέλνουμε την τιμή 10
        x_in <= std_logic_vector(to_unsigned(10, 8));
        valid_in <= '1';
        wait for CLK_PERIOD;
        valid_in <= '0';
        
        -- Περιμένουμε να δούμε το valid_out να γίνεται '1' και να μένει εκεί (Sticky) [cite: 44]
        wait for 15 * CLK_PERIOD;

        -- ΣΕΝΑΡΙΟ 2: Παρατεταμένο Valid In (Προσομοίωση Καθυστέρησης AXI/Software)
        -- Στέλνουμε την τιμή 20, αλλά το valid_in μένει στο '1' για 50 κύκλους!
        report "Starting Case 2: Prolonged Valid In (AXI delay simulation)";
        x_in <= std_logic_vector(to_unsigned(20, 8));
        valid_in <= '1'; 
        
        -- Εδώ το valid_in μένει ψηλά. Το FIR πρέπει να τρέξει ΜΟΝΟ μια φορά.
        wait for 50 * CLK_PERIOD; 
        
        valid_in <= '0'; -- Ο επεξεργαστής επιτέλους κατεβάζει το bit
        wait for 10 * CLK_PERIOD;

        -- ΣΕΝΑΡΙΟ 3: Έλεγχος Καθαρισμού Sticky Bit και Νέου Υπολογισμού
        -- Στέλνουμε την τιμή 5. Με την ακμή του valid_in, το valid_out πρέπει να μηδενιστεί 
        report "Starting Case 3: Sticky bit clear and new calculation";
        x_in <= std_logic_vector(to_unsigned(5, 8));
        valid_in <= '1';
        wait for CLK_PERIOD;
        valid_in <= '0';

        wait for 20 * CLK_PERIOD;
        
        report "Simulation Finished Successfully";
        wait;
    end process;

end architecture;