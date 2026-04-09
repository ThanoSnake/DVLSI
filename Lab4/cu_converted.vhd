library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity image_processor_top is
    generic (
        N : integer := 16 -- Μέγεθος εικόνας (N x N)
    );
    port (
        clk             : in  std_logic;
        rst_n           : in  std_logic;
        new_image       : in  std_logic;
        valid_in        : in  std_logic;
        data_in         : in  std_logic_vector(7 downto 0);
        
        -- Έξοδοι από το Control Unit
        state1          : out std_logic_vector(3 downto 0);
        state2          : out std_logic_vector(1 downto 0);
        valid_out       : out std_logic;
        image_finished  : out std_logic;
        
        -- Έξοδος από τον Converter
        data_out        : out std_logic_vector(71 downto 0)
    );
end entity;

architecture rtl of image_processor_top is

    -- Εσωτερικά σήματα για τη σύνδεση των δύο modules
    signal s_wr_en : std_logic_vector(2 downto 0);
    signal s_rd_en : std_logic_vector(2 downto 0);

    -- Δήλωση του Control Unit Component
    component control_unit is
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

    -- Δήλωση του Converter Component
    component converter is
        port (
            clk         : in  std_logic;
            rstn        : in  std_logic;
            wr_en       : in  std_logic_vector(2 downto 0);
            rd_en       : in  std_logic_vector(2 downto 0);
            data_in     : in  std_logic_vector(7 downto 0);
            data_out    : out std_logic_vector(71 downto 0)
        );
    end component;

begin

    -- Instantiation του Control Unit
    CU_INST : control_unit
        generic map (
            N => N
        )
        port map (
            clk            => clk,
            rst_n          => rst_n,
            new_image      => new_image,
            valid_in       => valid_in,
            wr_en          => s_wr_en, -- Σύνδεση στο εσωτερικό σήμα
            rd_en          => s_rd_en, -- Σύνδεση στο εσωτερικό σήμα
            state1         => state1,
            state2         => state2,
            valid_out      => valid_out,
            image_finished => image_finished
        );

    -- Instantiation του Converter
    CONV_INST : converter
        port map (
            clk      => clk,
            rstn     => rst_n,
            wr_en    => s_wr_en, -- Λήψη εντολών από το CU
            rd_en    => s_rd_en, -- Λήψη εντολών από το CU
            data_in  => data_in,
            data_out => data_out
        );

end architecture;
