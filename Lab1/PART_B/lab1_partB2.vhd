library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity full_adder is 
    port (
        a,b,cin : in std_logic;
        s,cout  : out std_logic
    );
end full_adder;

architecture structural_arch of full_adder is

    component half_adder is 
        port (
            a,b     : in std_logic;
            s,c     : out std_logic
        );
    end component;

    signal s1,c1,c2 : std_logic;

begin

    ha1 : half_adder 
        port map (
            a => a,
            b => b,
            s => s1,
            c => c1
        );
    
    ha2 : half_adder
        port map (
            a => s1,
            b => cin,
            s => s,
            c => c2
        );
    
    cout <= c1 or c2;
  
end structural_arch;