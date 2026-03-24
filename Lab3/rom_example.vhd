library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;


entity mlab_rom is
	generic (
		coeff_width : integer :=8  				--- width of coefficients (bits)
	);
    Port ( 
        clk         : in  STD_LOGIC;
		en          : in  STD_LOGIC;				--- operation enable
        addr        : in  STD_LOGIC_VECTOR (2 downto 0);			-- memory address
        i_valid_in  : in  std_logic;
        rom_out     : out STD_LOGIC_VECTOR (coeff_width-1 downto 0));	-- output data
end mlab_rom;

architecture Behavioral of mlab_rom is

    type rom_type is array (7 downto 0) of std_logic_vector (coeff_width-1 downto 0);                 
    signal rom : rom_type:= ("00001000", "00000111", "00000110", "00000101", "00000100", "00000011", "00000010",
                             "00000001");      				 -- initialization of rom with user data                 

    signal rdata : std_logic_vector(coeff_width-1 downto 0) := (others => '0');
    signal flag : std_logic := '1';
begin

    rdata <= rom(conv_integer(addr));

    process (clk)
    begin
        if (clk'event and clk = '1') then
            if (en = '1') then
                if i_valid_in = '1' and flag = '1' then 
                    rom_out <= rom(0);
                    flag <= '0';
                else 
                    rom_out <= rdata;
                    if addr = "111" then 
                        flag <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;			


end Behavioral;


