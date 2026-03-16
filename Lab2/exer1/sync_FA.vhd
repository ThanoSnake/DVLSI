library IEEE;
use IEEE.std_logic_1164.all;

-- check for reset
entity sync_FA is
    port (
        i_rst               : in  std_logic;
        clk                 : in  std_logic;
        i_A, i_B, i_cin     : in  std_logic;
        o_sum, o_cout       : out std_logic
    );
end entity;

architecture arc_sync_FA of sync_FA is
begin
    
    process(clk,i_rst)
    begin
        if i_rst = '1' then
            o_sum   <= '0';
            o_cout  <= '0';
        elsif rising_edge(clk) then
            o_sum   <= i_A xor i_B xor i_cin;
            o_cout  <= (i_A and i_B) or (i_A and i_cin) or (i_B and i_cin);
        end if;
    end process;

end architecture;
