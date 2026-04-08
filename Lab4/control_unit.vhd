library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity control_unit is
    generic (
        N : integer := 16;
    )
    port (
        clk         : in  std_logic;
        rst_n       : in  std_logic;
        new_image   : in  std_logic;
        valid_in    : in  std_logic
    );
end entity;

architecture arc of control_unit is

    signal counter : integer;
    signal i       : integer;
    signal j       : integer;

begin

    process(clk, rst_n)
    begin
        if rst_n = '0' then

        elsif rising_edge(clk) then
            if new_image = '1' and valid_in = '1' then
                counter <= 0;
            elsif valid_in = '1' then
                counter <= counter + 1;
            end if;
        end if;
    end process;

    i <= counter/N+1;
    j <= counter%N+1;
