library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity processor is
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
end entity;

architecture arc of processor is

    signal mask             : std_logic_vector(71 downto 0);
    signal data_in_masked   : std_logic_vector(71 downto 0);
begin

    process(clk, rst_n)
    begin
        if rst_n = '0' then
        elsif rising_edge(clk) then
            case state1 is
                when "1100" => data_in_masked <= data_in & x"00000000FFFF00FFFF"; --Top Left
                when "1001" => data_in_masked <= data_in & x"00FFFF00FFFF000000"; --Top Right
                when "0110" => data_in_masked <= data_in & x"000000FFFF00FFFF00"; --Bottom Left
                when "0011" => data_in_masked <= data_in & x"FFFF00FFFF00000000"; --Bottom Right
                when "1000" => data_in_masked <= data_in & x"00FFFF00FFFF00FFFF"; --Top
                when "0100" => data_in_masked <= data_in & x"000000FFFFFFFFFFFF"; --Left
                when "0010" => data_in_masked <= data_in & x"FFFF00FFFF00FFFF00"; --Bottom
                when "0001" => data_in_masked <= data_in & x"FFFFFFFFFFFF000000"; --Right
                when others => data_in_masked <= data_in & (others => '1');
            end case;
        end if;
    end process;

    with state2 select
        data_out <= ( (data_in_masked(31 downto 24) + data_in_masked(31 downto 24)) >> 1 ) & data_in_masked(39 downto 32) & ( (data_in_masked(15 downto 8) + data_in_masked(61 downto 56)) >> 1 )  when "00",
        data_out <= ( (data_in_masked(15 downto 8) + data_in_masked(61 downto 56)) >> 1 ) & data_in_masked(39 downto 32) & ( (data_in_masked(31 downto 24) + data_in_masked(31 downto 24)) >> 1 )  when "11",
        data_out <= data_in_masked(39 downto 32) & ( (data_in_masked(15 downto 8) + data_in_masked(31 downto 24) + data_in_masked(47 downto 40) + data_in_masked(61 downto 56)) << 2) & ( (data_in_masked(7 downto 0) + data_in_masked(23 downto 16) + data_in_masked(55 downto 48) + data_in_masked(71 downto 64)) << 2)  when "01",
        data_out <= ( (data_in_masked(7 downto 0) + data_in_masked(23 downto 16) + data_in_masked(55 downto 48) + data_in_masked(71 downto 64)) << 2) & ( (data_in_masked(15 downto 8) + data_in_masked(31 downto 24) + data_in_masked(47 downto 40) + data_in_masked(61 downto 56)) << 2) & data_in_masked(39 downto 32)  when "10"; 
