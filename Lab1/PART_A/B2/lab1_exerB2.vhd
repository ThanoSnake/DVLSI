library IEEE;
use IEEE.std_logic_1164.all;

entity shift_reg is

    port (

        clk,rst,si,en,pl,mode:      in std_logic;
        din:                        in std_logic_vector(3 downto 0);
        so:                         out std_logic);

end shift_reg;


architecture rtl of shift_reg is
    signal dff  : std_logic_vector(3 downto 0);
    signal temp : std_logic := '0';
begin
    edge: process (clk,rst)
    begin

        if rst='0' then
            dff<=(others=>'0');

        elsif clk'event and clk='1' then
            if pl='1' then
                dff<=din;

            elsif en='1' then
                case mode is
                    when '0' =>
                        temp <= dff(0);
                        dff <= si & dff(3 downto 1);
                    when '1' =>
                        dff <= dff(2 downto 0) & si;
                        temp <= dff(3);
                    when others =>
                        dff <= "0000";
                        temp <= '0'; 
                end case;
            end if;
        end if;
    end process;
    so <= temp;
    --so <= dff(0) when mode='0' else dff(3);
end rtl;