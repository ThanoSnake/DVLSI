library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity count3_1 is
    port( 
        clk,resetn,count_en,mode : in std_logic;
        sum : out std_logic_vector(2 downto 0);
        cout : out std_logic);
    end;

architecture rtl_nolimit of count3_1 is
    signal count: std_logic_vector(2 downto 0);
begin
    process(clk, resetn)
    begin
        if resetn='0' then
        -- Κώδικας για την περίπτωση του reset (ενεργό χαμηλά)
            count <= (others=>'0');
        elsif clk'event and clk='1' then
            -- Μέτρηση μόνο αν count_en = 1
            if count_en='1' then
                case mode is
                    when '1' => 
                        count <= count+1;
                    when '0' =>
                        count <= count-1;
                    when others =>
                        count <= "000";
                end case;
            end if;
        end if;
    end process;
    -- Ανάθεση τιμών στα σήματα εξόδου
    sum <= count;
    cout <= '1' when (count = "111" and mode = '1' and count_en = '1') or 
                     (count = "000" and mode = '0' and count_en = '1') 
                     else '0';
end rtl_nolimit;