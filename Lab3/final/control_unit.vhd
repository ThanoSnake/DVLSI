library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity control_unit is
    port (
        i_clk       : in  std_logic;
        i_rst       : in  std_logic;	
        i_valid_in  : in  std_logic;
        o_rom_addr  : out std_logic_vector(2 downto 0);
        o_ram_addr  : out std_logic_vector(2 downto 0);
        o_mac_init  : out std_logic;
        o_valid_out : out std_logic;
        o_running   : out std_logic
    );       	
end entity control_unit;

architecture Behavioral of control_unit is

    signal counter      : std_logic_vector(2 downto 0) := (others => '0');
    signal running      : std_logic := '0';

begin 
    
    process(i_clk, i_rst) 
    begin
        if i_rst = '1' then 
            counter     <= (others => '0');
            running     <= '0';
            o_valid_out <= '0';
            o_mac_init  <= '0';
        elsif rising_edge(i_clk) then
            
            if running = '1' then  --fir is running
                if counter = "111" then 
                    o_valid_out <= '1';
                    running     <= '0';
                else 
                    counter <= counter + 1;
                    o_mac_init <= '0';
                end if;
            elsif i_valid_in = '1' then --user gave refreshed input
                counter     <= "001";
                running     <= '1';
                o_valid_out <= '0'; --only refreshed input can change validout
                o_mac_init  <= '1';
            end if;

        end if;
    end process;

    o_rom_addr <= counter;
    o_ram_addr <= counter;
    o_running  <= running; --To control MAC

end architecture;