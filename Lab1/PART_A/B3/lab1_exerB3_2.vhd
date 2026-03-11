library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity count3_2 is
    port( 
        clk,resetn,count_en : in std_logic;
        modulo              : in std_logic_vector(2 downto 0);
        sum                 : out std_logic_vector(2 downto 0);
        cout                : out std_logic
    );
end;

architecture rtl_limit of count3_2 is
    signal count : std_logic_vector(2 downto 0);
begin
    process(clk, resetn)
    begin
        if resetn='0' then
        -- Ασύγχρονος μηδενισμός
            count <= (others=>'0');
        elsif clk'event and clk='1' then
            if count_en = '1' then
            -- Μέτρηση μόνο αν count_en=’1’
                if count<modulo then
                -- Αυξάνουμε το μετρητή μόνο αν
                -- δεν είναι modulo
                    count <= count+1;
                else
            -- Αλλιώς τον μηδενίζουμε
                    count<=(others=>'0');
                end if;
            end if;
        end if;
    end process;
    sum<= count;
    cout <= '1' when count>=modulo and count_en='1' else '0';
end rtl_limit;