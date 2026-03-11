library IEEE;
use IEEE.std_logic_1164.all;

entity shift_reg_alt is

    port (

        clk,rst,si,en,pl,mode:      in std_logic;
        din:                        in std_logic_vector(3 downto 0);
        so:                         out std_logic);

end shift_reg_alt;


architecture rtl of shift_reg_alt is
    signal dff  : std_logic_vector(3 downto 0);
    signal temp : std_logic;
begin
    edge: process (clk,rst)
    begin

        if rst='0' then
            dff<=(others=>'0');

        elsif clk'event and clk='1' then
            if pl='1' then
                dff<=din;

            elsif en='1' then
                if mode = '0' then 
                    temp <= dff(0);
                    dff <= si & dff(3 downto 1);
                elsif mode = '1' then 
                    temp <= dff(3);
                    dff <= dff(2 downto 0) & si;
                else 
                    temp <= '0';
                    dff <= "0000";
                end if;
            end if;
        end if;
    end process;
    so <= temp;
end rtl;