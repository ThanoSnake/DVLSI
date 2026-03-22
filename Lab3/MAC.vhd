library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity mac is
    port (
        i_clk       : in  std_logic;
        i_rst       : in  std_logic;
        i_mac_init  : in  std_logic;						
        i_rom_out   : in  std_logic_vector(7 downto 0);			
        i_ram_out   : in  std_logic_vector(7 downto 0);
        o_y         : out std_logic_vector(18 downto 0)
    );       	
end entity mac;

architecture Behavioral of mac is
    signal a : std_logic_vector(18 downto 0) := (others => '0');

begin 

    process(i_clk, i_rst)
    begin
        if i_rst = '1' then 
            a <= (others => '0');
        elsif rising_edge(i_clk) then 
            if i_mac_init = '1' then
                a <= "000" & (i_rom_out * i_ram_out);
            else 
                a <= a + ("000" & (i_rom_out * i_ram_out));
            end if;
        end if;
    end process;

    o_y <= a;

end architecture;

