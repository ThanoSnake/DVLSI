library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity mlab_ram is
	 generic (
		data_width : integer :=8  				--- width of data (bits)
	 );
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        we          : in  std_logic;						--- memory write enable
		en          : in  std_logic;				--- operation enable
        addr        : in  std_logic_vector(2 downto 0);			-- memory address
        di          : in  std_logic_vector(data_width-1 downto 0);		-- input data
        do          : out std_logic_vector(data_width-1 downto 0));		-- output data
end mlab_ram;

architecture Behavioral of mlab_ram is

    type ram_type is array (7 downto 0) of std_logic_vector (data_width-1 downto 0);
    signal RAM : ram_type := (others => (others => '0'));
    signal flag : std_logic;
	 
begin


    process (clk, rst)
    begin
        if rst = '1' then 
            RAM <= (others => (others => '0'));
            flag <= '1';
            do <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                if we = '1' and flag = '1' then				
                    for i in 6 downto 0 loop
                        RAM(i+1) <= RAM(i);
                    end loop;

                    flag <= '0';
 
                    RAM(0) <= di;
                    do <= di;

                else						
                    do <= RAM(conv_integer(addr));
                    if addr = "111" then 
                        flag <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;


end Behavioral;


