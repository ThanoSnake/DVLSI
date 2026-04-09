library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity processor is
    port (
        clk         : in  std_logic;
        rst_n       : in  std_logic;
        data_in     : in  std_logic_vector(71 downto 0);
        state1      : in  std_logic_vector(3 downto 0); -- Top(3), Left(2), Bottom(1), Right(0)
        state2      : in  std_logic_vector(1 downto 0);
        red_out     : out std_logic_vector(7 downto 0);
        green_out   : out std_logic_vector(7 downto 0);
        blue_out    : out std_logic_vector(7 downto 0)
    );
end entity;

architecture arc of processor is

    --Pixels
    signal P11, P12, P13 : unsigned(7 downto 0);
    signal P21, P22, P23 : unsigned(7 downto 0);
    signal P31, P32, P33 : unsigned(7 downto 0);

    --Sums
    signal sum_cross : unsigned(9 downto 0);
    signal sum_diag  : unsigned(9 downto 0); 
    signal sum_horiz : unsigned(8 downto 0); 
    signal sum_vert  : unsigned(8 downto 0); 

begin
    
    P11 <= (others => '0') when (state1(3) = '1' or state1(2) = '1') else unsigned(data_in(71 downto 64));
    P12 <= (others => '0') when (state1(3) = '1')                    else unsigned(data_in(47 downto 40));
    P13 <= (others => '0') when (state1(3) = '1' or state1(0) = '1') else unsigned(data_in(23 downto 16));
    
    P21 <= (others => '0') when (state1(2) = '1')                    else unsigned(data_in(63 downto 56));
    P22 <= unsigned(data_in(39 downto 32)); -- Το κέντρο δεν μηδενίζεται ποτέ
    P23 <= (others => '0') when (state1(0) = '1')                    else unsigned(data_in(15 downto 8));
    
    P31 <= (others => '0') when (state1(1) = '1' or state1(2) = '1') else unsigned(data_in(55 downto 48));
    P32 <= (others => '0') when (state1(1) = '1')                    else unsigned(data_in(31 downto 24));
    P33 <= (others => '0') when (state1(1) = '1' or state1(0) = '1') else unsigned(data_in(7 downto 0));

    --Computation of sums
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            sum_cross <= (others => '0');
            sum_diag  <= (others => '0');
            sum_horiz <= (others => '0');
            sum_vert  <= (others => '0');
        elsif rising_edge(clk) then
            sum_cross <= resize(P12, 10) + resize(P21, 10) + resize(P23, 10) + resize(P32, 10);
            sum_diag  <= resize(P11, 10) + resize(P13, 10) + resize(P31, 10) + resize(P33, 10);
            sum_horiz <= resize(P21, 9)  + resize(P23, 9);
            sum_vert  <= resize(P12, 9)  + resize(P32, 9);
        end if;
    end process;

   
    with state2 select
        red_out   <= std_logic_vector(sum_horiz(8 downto 1)) when "00",
                     std_logic_vector(sum_diag(9 downto 2))  when "10", -- (B) Κέντρο Μπλε, R από διαγώνιους [cite: 40]
                     std_logic_vector(P22)                   when "01", -- (R) Κέντρο Κόκκινο
                     std_logic_vector(sum_vert(8 downto 1))  when "11", -- (G2)
                     (others => '0') when others;

    with state2 select
        green_out <= std_logic_vector(P22)                   when "00",
                     std_logic_vector(sum_cross(9 downto 2)) when "10", -- (B) Κέντρο Μπλε, G από σταυρό [cite: 40]
                     std_logic_vector(sum_cross(9 downto 2)) when "01", -- (R) Κέντρο Κόκκινο, G από σταυρό [cite: 39]
                     std_logic_vector(P22)                   when "11",
                     (others => '0') when others;

    with state2 select
        blue_out  <= std_logic_vector(sum_vert(8 downto 1))  when "00",
                     std_logic_vector(P22)                   when "10", -- (B) Κέντρο Μπλε [cite: 40]
                     std_logic_vector(sum_diag(9 downto 2))  when "01", -- (R) Κέντρο Κόκκινο, B από διαγώνιους [cite: 39]
                     std_logic_vector(sum_horiz(8 downto 1)) when "11",
                     (others => '0') when others;

end architecture;
