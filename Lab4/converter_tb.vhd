library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity converter_tb is
-- Ένα testbench δεν έχει ποτέ ports
end entity;

architecture sim of converter_tb is

    -- 1. Δήλωση του component που θα δοκιμάσουμε
    component converter
        port (
            clk         : in  std_logic;
            rstn        : in  std_logic;
            wr_en       : in  std_logic_vector(2 downto 0);
            rd_en       : in  std_logic_vector(2 downto 0);
            data_in     : in  std_logic_vector(7 downto 0);
            data_out    : out std_logic_vector(71 downto 0)
        );
    end component;

    -- 2. Εσωτερικά σήματα για τη σύνδεση με το DUT (Device Under Test)
    signal s_clk      : std_logic := '0';
    signal s_rstn     : std_logic := '0';
    signal s_wr_en    : std_logic_vector(2 downto 0) := (others => '0');
    signal s_rd_en    : std_logic_vector(2 downto 0) := (others => '0');
    signal s_data_in  : std_logic_vector(7 downto 0) := (others => '0');
    signal s_data_out : std_logic_vector(71 downto 0);

    -- Σταθερά για την περίοδο του ρολογιού
    constant CLK_PERIOD : time := 10 ns;

begin

    -- 3. Ενσωμάτωση του DUT
    DUT: converter
        port map (
            clk      => s_clk,
            rstn     => s_rstn,
            wr_en    => s_wr_en,
            rd_en    => s_rd_en,
            data_in  => s_data_in,
            data_out => s_data_out
        );

    -- 4. Δημιουργία Ρολογιού
    clk_process: process
    begin
        s_clk <= '0';
        wait for CLK_PERIOD / 2;
        s_clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- 5. Κύρια Διαδικασία (Stimulus)
    stimulus_process: process
    begin
        -- ΑΡΧΙΚΟΠΟΙΗΣΗ & RESET
        s_rstn    <= '0'; -- Ενεργό χαμηλό (active low) reset
        s_wr_en   <= "000";
        s_rd_en   <= "000";
        s_data_in <= (others => '0');
        
        wait for 5 * CLK_PERIOD;
        s_rstn <= '1'; -- Απελευθέρωση του reset
        
        -- ΣΗΜΑΝΤΙΚΟ: Περιμένουμε αρκετούς κύκλους για το safety circuitry των Xilinx FIFOs
        wait for 20 * CLK_PERIOD;

        -- ΒΗΜΑ 1: Γράφουμε το '1' στην 1η FIFO (wr_en(0))
        s_data_in <= std_logic_vector(to_unsigned(1, 8)); -- Βάζουμε την τιμή 1
        s_wr_en(0) <= '1'; -- Ενεργοποιούμε την εγγραφή ΜΟΝΟ για την πρώτη FIFO
        wait for CLK_PERIOD;
        s_wr_en(0) <= '0';
        --s_wr_en(1) <= '1';
        s_rd_en(0) <= '1';
        wait for CLK_PERIOD;
        s_wr_en(1) <= '1';
        s_rd_en(0) <= '0';
        wait for CLK_PERIOD;
        s_rd_en(1) <= '1';
        --s_data_in <= (others => '0'); -- Καθαρίζουμε την είσοδο

        -- Αφήνουμε λίγο χρόνο για να καταχωρηθεί στη FIFO (για να μη διαβάσουμε άδεια FIFO)
        --wait for 1 * CLK_PERIOD;

        -- ΒΗΜΑ 2: Διαβάζουμε το '1' από την 1η FIFO (rd_en(0))
        --s_rd_en(0) <= '1';
        --wait for CLK_PERIOD;
        --s_rd_en(0) <= '0';

        -- ΒΗΜΑ 3: Παρακολούθηση της μεταφοράς (Shifting)
        -- Αφήνουμε την προσομοίωση να τρέξει μερικούς κύκλους για να δούμε 
        -- το '1' να ταξιδεύει μέσα στους shift registers (s_regs_block).
        wait for 10 * CLK_PERIOD;

        wait;
    end process;

end architecture;