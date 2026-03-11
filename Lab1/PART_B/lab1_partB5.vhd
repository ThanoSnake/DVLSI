library IEEE;
use IEEE.std_logic_1164.all;

entity bcd_pa4 is 
    port (
        a    : in  std_logic_vector(15 downto 0); 
        b    : in  std_logic_vector(15 downto 0); 
        cin  : in  std_logic;
        sum  : out std_logic_vector(15 downto 0);
        cout : out std_logic
    );
end bcd_pa4;

architecture structural of bcd_pa4 is

    component bcd_fa is 
        port (
            a, b : in  std_logic_vector(3 downto 0);
            cin  : in  std_logic;
            sum  : out std_logic_vector(3 downto 0);
            cout : out std_logic
        );
    end component;

    
    signal c_vector : std_logic_vector(3 downto 1);

begin

    bcd_pa0: bcd_fa port map (
        a    => a(3 downto 0), 
        b    => b(3 downto 0), 
        cin  => cin, 
        sum  => sum(3 downto 0), 
        cout => c_vector(1)
    );

    bcd_pa1: bcd_fa port map (
        a    => a(7 downto 4), 
        b    => b(7 downto 4), 
        cin  => c_vector(1), 
        sum  => sum(7 downto 4), 
        cout => c_vector(2)
    );

    bcd_pa2: bcd_fa port map (
        a    => a(11 downto 8), 
        b    => b(11 downto 8), 
        cin  => c_vector(2), 
        sum  => sum(11 downto 8), 
        cout => c_vector(3)
    );

    bcd_pa3: bcd_fa port map (
        a    => a(15 downto 12), 
        b    => b(15 downto 12), 
        cin  => c_vector(3), 
        sum  => sum(15 downto 12), 
        cout => cout
    );

end structural;