library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity fir_tb is
end entity fir_tb;

architecture Behavioral of fir_tb is

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

    signal clk          : std_logic := '0';
    signal rst          : std_logic := '0';
    signal valid_in     : std_logic := '0';
    signal x_in         : std_logic_vector(7 downto 0) := (others => '0');
    signal valid_out    : std_logic;
    signal y_out        : std_logic_vector(18 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    DUT: fir
        port map (
            i_clk       => clk,
            i_rst       => rst,
            i_valid_in  => valid_in,
            i_x         => x_in,
            o_valid_out => valid_out,
            o_y         => y_out
        );

    process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    process
    begin		

        rst <= '1';
        wait for (2*CLK_PERIOD);
        rst <= '0';
        wait for (2*CLK_PERIOD);

        -- 2. Εισαγωγή 1ου Δείγματος: x[0] = 1
        -- Αναμενόμενο y h = {8,7,6,5,4,3,2,1}: y = 8*1 = 8
        x_in <= std_logic_vector(to_unsigned(1, 8));
        valid_in <= '1';
        wait for CLK_PERIOD;
        valid_in <= '0';

        wait for (7 * CLK_PERIOD);

        
        -- Πε�?ιμένουμε μέχ�?ι να βγει η έγκυ�?η έξοδος
        --wait until valid_out = '1';
        --wait for clk_period;

        -- 3. Εισαγωγή 2ου Δείγματος: x[1] = 2
        -- Αναμενόμενο y: 8*2 + 7*1 = 16 + 7 = 23
        x_in <= std_logic_vector(to_unsigned(2, 8));
        valid_in <= '1';
        wait for clk_period;
        valid_in <= '0';

        wait for (7 *CLK_PERIOD);
        
        --wait until valid_out = '1';
        --wait for clk_period;

        -- 4. Εισαγωγή 3ου Δείγματος: x[2] = 3
        -- Αναμενόμενο y: 8*3 + 7*2 + 6*1 = 24 + 14 + 6 = 44
        x_in <= std_logic_vector(to_unsigned(3, 8));
        valid_in <= '1';
        wait for CLK_PERIOD;
        valid_in <= '0';

        wait for ( 7* CLK_PERIOD);

        --wait until valid_out = '1';
        --wait for clk_period;

        wait;
    end process;

end architecture;