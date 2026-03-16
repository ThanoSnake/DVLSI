library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sync_RCM4 is
    port (
        clk     : in  std_logic;
        i_rst   : in  std_logic;
        i_A     : in  std_logic_vector(4-1 downto 0);
        i_B     : in  std_logic_vector(4-1 downto 0);
        o_P     : out std_logic_vector(4+4-1 downto 0)
    );
end entity;

architecture arc_sync_RCM4 of sync_RCM4 is

    type a_word_array is array (0 to 4-1) of std_logic_vector(4-1 downto 0);
    signal ai, bi, si, ci : a_word_array;
    signal ao, bo, so, co : a_word_array;

    signal s_reg_p0 : std_logic_vector(9-1 downto 0);
    signal s_reg_p1 : std_logic_vector(7-1 downto 0);
    signal s_reg_p2 : std_logic_vector(5-1 downto 0);
    signal s_reg_p3 : std_logic_vector(3-1 downto 0);
    signal s_reg_p4 : std_logic_vector(2-1 downto 0);
    signal s_reg_p5 : std_logic;

    signal s_reg_a1 : std_logic;
    signal s_reg_a2 : std_logic_vector(1 downto 0);
    signal s_reg_a3 : std_logic_vector(2 downto 0);

    signal s_reg_b1 : std_logic_vector(1 downto 0);
    signal s_reg_b2 : std_logic_vector(3 downto 0);
    signal s_reg_b3 : std_logic_vector(5 downto 0);

    component mul_cell is
        port (
            clk     : in  std_logic;
            i_rst   : in  std_logic;
            i_a     : in  std_logic;
            i_b     : in  std_logic;
            i_s     : in  std_logic;
            i_c     : in  std_logic;
            o_a     : out std_logic;
            o_b     : out std_logic;
            o_s     : out std_logic;
            o_c     : out std_logic
        );
    end component;

begin

    --generation of mul cells
    gcb: for i in 0 to 4-1 generate
        gca: for j in 0 to 4-1 generate
            gc: mul_cell
                port map (
                    clk     => clk,
                    i_rst   => i_rst,
                    i_a     => ai(i)(j),
                    i_b     => bi(i)(j),
                    i_s     => si(i)(j),
                    i_c     => ci(i)(j),
                    o_a     => ao(i)(j),
                    o_b     => bo(i)(j),
                    o_s     => so(i)(j),
                    o_c     => co(i)(j)
                );
        end generate;
    end generate;

    --generation of intermediate wires
    gcaw: for i in 1 to 4-1 generate
            ai(i)   <= ao(i-1);
            si(i)   <= co(i-1)(4-1) & so(i-1)(4-1 downto 1);
    end generate;

    gcbiw:   for i in 0 to 4-1 generate
        gcbjw:  for j in 1 to 4-1 generate
                bi(i)(j) <= bo(i)(j-1);
                ci(i)(j) <= co(i)(j-1);
        end generate;
    end generate;

    --initialization of signals
    si(0) <= (others => '0');
    gbci: for i in 0 to 4-1 generate
            ci(i)(0) <= '0';
    end generate;

    process(clk,i_rst)
    begin

        if i_rst = '1' then
            s_reg_p0 <= (others => '0');
            s_reg_p1 <= (others => '0');
            s_reg_p2 <= (others => '0');
            s_reg_p3 <= (others => '0');
            s_reg_p4 <= (others => '0');
            s_reg_p5 <= '0';

            s_reg_a1 <= '0';
            s_reg_a2 <= (others => '0');
            s_reg_a3 <= (others => '0');

            s_reg_b1 <= (others => '0');
            s_reg_b2 <= (others => '0');
            s_reg_b3 <= (others => '0');
        elsif rising_edge(clk) then
            --output shift
            s_reg_p0 <= s_reg_p0(8-1 downto 0) & so(0)(0);
            s_reg_p1 <= s_reg_p1(6-1 downto 0) & so(1)(0);
            s_reg_p2 <= s_reg_p2(4-1 downto 0) & so(2)(0);
            s_reg_p3 <= s_reg_p3(2-1 downto 0) & so(3)(0);
            s_reg_p4 <= s_reg_p4(0) & so(3)(1);
            s_reg_p5 <= so(3)(2);

            --input shift
            s_reg_a1 <= i_A(1);
            s_reg_a2 <= s_reg_a2(0) & i_A(2);
            s_reg_a3 <= s_reg_a3(1 downto 0) & i_A(3);

            s_reg_b1 <= s_reg_b1(0) & i_B(1);
            s_reg_b2 <= s_reg_b2(2 downto 0) & i_B(2);
            s_reg_b3 <= s_reg_b3(4 downto 0) & i_B(3);
        end if;
    end process;

    o_P(0) <= s_reg_p0(8);
    o_P(1) <= s_reg_p1(6);
    o_P(2) <= s_reg_p2(4);
    o_P(3) <= s_reg_p3(2);
    o_P(4) <= s_reg_p4(1);
    o_P(5) <= s_reg_p5;
    o_P(6) <= so(3)(3);
    o_P(7) <= co(3)(3);

    ai(0)(0) <= i_A(0);
    ai(0)(1) <= s_reg_a1;
    ai(0)(2) <= s_reg_a2(1);
    ai(0)(3) <= s_reg_a3(2);

    bi(0)(0) <= i_B(0);
    bi(1)(0) <= s_reg_b1(1);
    bi(2)(0) <= s_reg_b2(3);
    bi(3)(0) <= s_reg_b3(5);

end architecture;