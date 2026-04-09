library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity debayering_filter is
    generic (
        N : integer := 4 -- Παραμετρικό N, προεπιλογή 4 για το testbench [cite: 109]
    );
    port (
        clk             : in  std_logic; -- Το σήμα ρολογιού [cite: 58]
        rst_n           : in  std_logic; -- Ασύγχρονο σήμα μηδενισμού (active low) [cite: 59, 60]
        new_image       : in  std_logic; -- Ένδειξη νέας εικόνας 
        valid_in        : in  std_logic; -- Έγκυρο pixel εισόδου [cite: 62]
        pixel           : in  std_logic_vector(7 downto 0); -- Σήμα εισόδου 8-bit [cite: 61]
        
        valid_out       : out std_logic; -- Έγκυρη έξοδος R, G, B [cite: 69]
        image_finished  : out std_logic; -- Ένδειξη τέλους εικόνας [cite: 73]
        R               : out std_logic_vector(7 downto 0); -- Κόκκινη συνιστώσα [cite: 66, 68]
        G               : out std_logic_vector(7 downto 0); -- Πράσινη συνιστώσα [cite: 66, 68]
        B               : out std_logic_vector(7 downto 0)  -- Μπλε συνιστώσα [cite: 66, 68]
    );
end entity;

architecture structural of debayering_filter is

    -- ==========================================
    -- ΔΗΛΩΣΗ ΤΩΝ COMPONENTS
    -- ==========================================
    component control_unit
        generic ( N : integer );
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

    component processor
        port (
            clk         : in  std_logic;
            rst_n       : in  std_logic;
            data_in     : in  std_logic_vector(71 downto 0);
            state1      : in  std_logic_vector(3 downto 0);
            state2      : in  std_logic_vector(1 downto 0);
            red_out     : out std_logic_vector(7 downto 0);
            green_out   : out std_logic_vector(7 downto 0);
            blue_out    : out std_logic_vector(7 downto 0)
        );
    end component;

    -- ==========================================
    -- ΕΣΩΤΕΡΙΚΑ ΣΗΜΑΤΑ (Διασυνδέσεις)
    -- ==========================================
    signal s_wr_en      : std_logic_vector(2 downto 0);
    signal s_rd_en      : std_logic_vector(2 downto 0);
    signal s_state1     : std_logic_vector(3 downto 0);
    signal s_state2     : std_logic_vector(1 downto 0);
    signal s_window_72  : std_logic_vector(71 downto 0);

begin

    -- Ενσωμάτωση Control Unit
    CU_inst : control_unit
        generic map ( N => N )
        port map (
            clk             => clk,
            rst_n           => rst_n,
            new_image       => new_image,
            valid_in        => valid_in,
            wr_en           => s_wr_en,
            rd_en           => s_rd_en,
            state1          => s_state1,
            state2          => s_state2,
            valid_out       => valid_out,
            image_finished  => image_finished
        );

    -- Ενσωμάτωση Serial-to-Parallel Converter [cite: 82]
    CONV_inst : converter
        port map (
            clk         => clk,
            rstn        => rst_n, -- Συνδέουμε το rst_n στο rstn του converter
            wr_en       => s_wr_en,
            rd_en       => s_rd_en,
            data_in     => pixel,
            data_out    => s_window_72
        );

    -- Ενσωμάτωση Processor (Υπολογισμός Μέσων Όρων)
    PROC_inst : processor
        port map (
            clk         => clk,
            rst_n       => rst_n,
            data_in     => s_window_72,
            state1      => s_state1,
            state2      => s_state2,
            red_out     => R,
            green_out   => G,
            blue_out    => B
        );

end architecture;
