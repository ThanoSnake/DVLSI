library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity bcd_fa is 
    port (
        a       : in std_logic_vector(3 downto 0);
        b       : in std_logic_vector(3 downto 0);
        cin     : in std_logic;
        sum     : out std_logic_vector(3 downto 0);
        cout    : out std_logic
    );
end bcd_fa;

architecture structural_arch of bcd_fa is

    component pa4 is 
        port (
            a,b         : in std_logic_vector(3 downto 0);
            cin         : in std_logic;
            sum         : out std_logic_vector(3 downto 0);
            cout        : out std_logic
        );
    end component;

    signal sum1                     : std_logic_vector(3 downto 0);
    signal bias                     : std_logic_vector(3 downto 0);
    signal c1,useless_c,s_cout      : std_logic;

begin

    pa1 : pa4 
        port map (
            a       => a,
            b       => b,
            cin     => cin,
            sum     => sum1,
            cout    => c1
        );
    
    s_cout <= c1 or (sum1(3) and (sum1(2) or sum1(1)));
    cout <= s_cout;
    bias <= '0' & s_cout & s_cout & '0';
    --bias <= "0110" when s_cout = '1'
    --        else "0000";
    
    pa2 : pa4 
        port map (
            a       => sum1,
            b       => bias,
            cin     => '0',
            sum     => sum,
            cout    => useless_c
        );
    
  
end structural_arch;