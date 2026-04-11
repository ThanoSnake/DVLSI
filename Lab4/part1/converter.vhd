library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity converter is
    port (
        clk         : in  std_logic;
        rstn        : in  std_logic;
        wr_en       : in  std_logic_vector(2 downto 0);
        rd_en       : in  std_logic_vector(2 downto 0);
        shift_enable: in  std_logic;
        data_in     : in  std_logic_vector(7 downto 0);
        data_out    : out std_logic_vector(71 downto 0)
    );
end entity;

architecture arc of converter is

    type my_array is array (0 to 2) of std_logic_vector(7 downto 0);
    type my_array_regs is array (0 to 2) of std_logic_vector(23 downto 0);

    signal s_dout_bus   : my_array;
    signal s_din_bus    : my_array;
    signal s_regs_block : my_array_regs;
    signal s_rst_high   : std_logic;

    COMPONENT fifo_generator_0
        PORT (
            clk     : IN STD_LOGIC;
            srst    : IN STD_LOGIC;
            din     : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            wr_en   : IN STD_LOGIC;
            rd_en   : IN STD_LOGIC;
            dout    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            full    : OUT STD_LOGIC;
            empty   : OUT STD_LOGIC 
        );
    END COMPONENT;

begin

    s_rst_high <= not rstn;

    FIFO_GEN: for i in 0 to 2 generate
        FIFO_inst: fifo_generator_0
            port map (
                clk     => clk,
                srst    => s_rst_high,
                din     => s_din_bus(i),
                wr_en   => wr_en(i),
                rd_en   => rd_en(i),
                dout    => s_dout_bus(i),
                full    => open,
                empty   => open
            );
    end generate FIFO_GEN;

    s_din_bus(0) <= data_in;
    s_din_bus(1 to 2) <= s_dout_bus(0 to 1);

    process(clk, rstn)
    begin

        if rstn = '0' then
            s_regs_block(0) <= (others => '0');
            s_regs_block(1) <= (others => '0');
            s_regs_block(2) <= (others => '0');
        elsif rising_edge(clk) then
            --shifting
            if shift_enable = '1' then 
                s_regs_block(0)(7 downto 0) <= s_dout_bus(0);
                s_regs_block(0)(15 downto 8) <= s_dout_bus(1);
                s_regs_block(0)(23 downto 16) <= s_dout_bus(2);

                s_regs_block(1 to 2) <= s_regs_block(0 to 1);
            end if;
        end if;

    end process;
    
    PACK_DATA_GEN: for i in 0 to 2 generate
        data_out(24*i+23 downto 24*i) <= s_regs_block(i); --data out
    end generate PACK_DATA_GEN;

end architecture;