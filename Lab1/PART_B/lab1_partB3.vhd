library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity pa4 is 
    port (
        a       : in std_logic_vector(3 downto 0);
        b       : in std_logic_vector(3 downto 0);
        cin     : in std_logic;
        sum     : out std_logic_vector(3 downto 0);
        cout    : out std_logic
    );
end pa4;

architecture structural_arch of pa4 is

    component full_adder is 
        port (
            a,b,cin     : in std_logic;
            s,cout      : out std_logic
        );
    end component;

    signal c_vector : std_logic_vector(2 downto 0);

begin

    fa1 : full_adder 
        port map (
            a       => a(0),
            b       => b(0),
            cin     => cin,
            s       => sum(0),
            cout    => c_vector(0)
        );
    
    fa2 : full_adder 
        port map (
            a       => a(1),
            b       => b(1),
            cin     => c_vector(0),
            s       => sum(1),
            cout    => c_vector(1)
        );
    

    fa3 : full_adder 
        port map (
            a       => a(2),
            b       => b(2),
            cin     => c_vector(1),
            s       => sum(2),
            cout    => c_vector(2)
        );    

    fa4 : full_adder 
        port map (
            a       => a(3),
            b       => b(3),
            cin     => c_vector(2),
            s       => sum(3),
            cout    => cout
        );
  
end structural_arch;