library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mul_cell is
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
end entity;

architecture arc_mul_cell of mul_cell is

    component sync_FA is
        port (
            i_rst               : in  std_logic;
            clk                 : in  std_logic;
            i_A, i_B, i_cin     : in  std_logic;
            o_sum, o_cout       : out std_logic
        );
    end component;

    signal ab       : std_logic;
    signal a_temp   : std_logic;

begin

    sFA1: sync_FA
        port map (
            i_rst   => i_rst,
            clk     => clk,
            i_A     => ab,
            i_B     => i_s,
            i_cin   => i_c,
            o_sum   => o_s,
            o_cout  => o_c
        );

    process(clk, i_rst)
    begin
        if i_rst = '1' then
            a_temp  <= '0'; 
            o_a     <= '0';
            o_b     <= '0';
        elsif rising_edge(clk) then
            o_a     <= a_temp;            
            a_temp  <= i_a;
            o_b     <= i_b;
        end if;
    end process;

    ab  <= i_a and i_b;
end architecture; 


    
