library IEEE;
use IEEE.std_logic_1164.all;

-- T_latency = (3*CLOCK_PERIOD)

entity sync_RCA4 is
    port (
        i_rst       : in  std_logic;
        clk         : in  std_logic;
        i_A, i_B    : in  std_logic_vector(4-1 downto 0);
        i_cin       : in  std_logic;
        o_sum       : out std_logic_vector(4-1 downto 0);
        o_cout      : out std_logic
    );
end entity;

architecture arc_sync_RCA4 of sync_RCA4 is

    component sync_FA is
        port (
            i_rst               : in  std_logic;
            clk                 : in  std_logic;
            i_A, i_B, i_cin     : in  std_logic;
            o_sum, o_cout       : out std_logic
        );
    end component;
    
    signal fa_cout              : std_logic_vector(3-1 downto 0);
    signal s_sum                : std_logic_vector(3-1 downto 0);
    
    signal shift_reg_fa1_sum    : std_logic_vector(3-1 downto 0);
    
    signal shift_reg_fa2_sum    : std_logic_vector(2-1 downto 0);
    signal shift_reg_fa2_A      : std_logic;
    signal shift_reg_fa2_B      : std_logic;

    signal shift_reg_fa3_sum    : std_logic;
    signal shift_reg_fa3_A      : std_logic_vector(2-1 downto 0);
    signal shift_reg_fa3_B      : std_logic_vector(2-1 downto 0);
    
    signal shift_reg_fa4_A      : std_logic_vector(3-1 downto 0);
    signal shift_reg_fa4_B      : std_logic_vector(3-1 downto 0);

begin

    fa1 : sync_FA
        port map (
            i_rst   => i_rst,
            clk     => clk,
            i_A     => i_A(0),
            i_B     => i_B(0),
            i_cin   => i_cin, 
            o_sum   => s_sum(0),
            o_cout  => fa_cout(0) 
        );

    fa2 : sync_FA
        port map (
            i_rst   => i_rst,
            clk     => clk,
            i_A     => shift_reg_fa2_A,
            i_B     => shift_reg_fa2_B,
            i_cin   => fa_cout(0), 
            o_sum   => s_sum(1),
            o_cout  => fa_cout(1)
        );

    fa3 : sync_FA
        port map (
            i_rst   => i_rst,
            clk     => clk,
            i_A     => shift_reg_fa3_A(1),
            i_B     => shift_reg_fa3_B(1),
            i_cin   => fa_cout(1), 
            o_sum   => s_sum(2),
            o_cout  => fa_cout(2)
        );
    
    fa4 : sync_FA
        port map (
            i_rst   => i_rst,
            clk     => clk,
            i_A     => shift_reg_fa4_A(2),
            i_B     => shift_reg_fa4_B(2),
            i_cin   => fa_cout(2), 
            o_sum   => o_sum(3),
            o_cout  => o_cout
        );

    process(clk,i_rst) 
    begin
        if i_rst = '1' then
            --Μηδενισμός καταχωρητών εξόδου
            shift_reg_fa1_sum <= (others => '0');
            shift_reg_fa2_sum <= (others => '0');
            shift_reg_fa3_sum <= '0';
            
            --Μηδενισμός καταχωρητών εισόδου
            shift_reg_fa2_A   <= '0';
            shift_reg_fa2_B   <= '0';
            shift_reg_fa3_A   <= (others => '0');
            shift_reg_fa3_B   <= (others => '0');
            shift_reg_fa4_A   <= (others => '0');
            shift_reg_fa4_B   <= (others => '0');
        elsif rising_edge(clk) then
            --fa1
            shift_reg_fa1_sum <= shift_reg_fa1_sum(2-1 downto 0) & s_sum(0);

            --fa2
            shift_reg_fa2_A <= i_A(1);
            shift_reg_fa2_B <= i_B(1);

            shift_reg_fa2_sum <= shift_reg_fa2_sum(0) & s_sum(1);
            
            --fa3
            shift_reg_fa3_A <= shift_reg_fa3_A(0) & i_A(2);
            shift_reg_fa3_B <= shift_reg_fa3_B(0) & i_B(2);

            shift_reg_fa3_sum <= s_sum(2);

            --fa4
            shift_reg_fa4_A <= shift_reg_fa4_A(2-1 downto 0) & i_A(3);
            shift_reg_fa4_B <= shift_reg_fa4_B(2-1 downto 0) & i_B(3);
        end if;
    end process;

    o_sum(0) <= shift_reg_fa1_sum(3-1);
    o_sum(1) <= shift_reg_fa2_sum(1);
    o_sum(2) <= shift_reg_fa3_sum;
end architecture;