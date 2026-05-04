library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity fir is
    port (
        i_clk       : in  std_logic;
        i_rst       : in  std_logic;	
        i_valid_in  : in  std_logic;
        i_x         : in  std_logic_vector(7 downto 0);
        o_valid_out : out std_logic;
        o_y         : out std_logic_vector(18 downto 0)
    );       	
end entity fir;

architecture Behavioral of fir is

    component control_unit is
        port (
            i_clk       : in  std_logic;
            i_rst       : in  std_logic;
            i_valid_in  : in std_logic;	
            o_rom_addr  : out std_logic_vector(2 downto 0);
            o_ram_addr  : out std_logic_vector(2 downto 0);
            o_mac_init  : out std_logic;
            o_valid_out : out std_logic;
            o_running   : out std_logic
        );       	
    end component;

    component mlab_ram is
        generic (
            data_width : integer :=8  				--- width of data (bits)
        );
        port (
            clk         : in std_logic;
            rst         : in std_logic;
            we          : in std_logic;						--- memory write enable
            en          : in std_logic;				--- operation enable
            addr        : in std_logic_vector(2 downto 0);			-- memory address
            di          : in std_logic_vector(data_width-1 downto 0);		
            do          : out std_logic_vector(data_width-1 downto 0)
        );		
    end component;

    component mlab_rom is
	    generic (
		    coeff_width : integer :=8  				--- width of coefficients (bits)
	    );
        port ( 
            clk     : in  STD_LOGIC;
			en      : in  STD_LOGIC;				--- operation enable
            addr    : in  STD_LOGIC_VECTOR (2 downto 0);			-- memory address
            i_valid_in : in std_logic;
            rom_out : out  STD_LOGIC_VECTOR (coeff_width-1 downto 0) -- output data
        );	
    end component;

    
    component mac is
        port (
            i_clk       : in  std_logic;
            i_rst       : in  std_logic;
            i_en        : in  std_logic;
            i_mac_init  : in  std_logic;						
            i_rom_out   : in  std_logic_vector(7 downto 0);			
            i_ram_out   : in  std_logic_vector(7 downto 0);
            o_y         : out std_logic_vector(18 downto 0)
        );       	
    end component;

    signal s_rom_addr : std_logic_vector(2 downto 0);
    signal s_ram_addr : std_logic_vector(2 downto 0);
    signal s_mac_init : std_logic;

    signal s_ram_out : std_logic_vector(7 downto 0) := (others => '0');
    signal s_rom_out : std_logic_vector(7 downto 0) := (others => '0');

    signal s_validout_del   : std_logic := '0';
    signal s_running        : std_logic := '0';
    signal s_running_del    : std_logic := '0';
    signal s_mac_en         : std_logic := '0';
    signal s_valid_pulse    : std_logic;
    signal s_prev_state     : std_logic := '0';

begin

    cu : control_unit
        port map (
            i_clk       =>  i_clk,    
            i_rst       =>  i_rst, 
            i_valid_in  =>  s_valid_pulse,    
            o_rom_addr  =>  s_rom_addr,
            o_ram_addr  =>  s_ram_addr,
            o_mac_init  =>  s_mac_init,
            o_valid_out =>  s_validout_del,
            o_running   =>  s_running
        );

    ram : mlab_ram
        port map (
            clk         => i_clk,
            rst         => i_rst,
            we          => s_valid_pulse,					
            en          => '1',
            addr        => s_ram_addr,
            di          => i_x,
            do          => s_ram_out
        );

    rom : mlab_rom 
        port map (
            clk     => i_clk,
			en      => '1',
            addr    => s_rom_addr,
            i_valid_in => s_valid_pulse,
            rom_out => s_rom_out
        );

    mac1 : mac 
        port map (
            i_clk       => i_clk,
            i_rst       => i_rst,
            i_en        => s_mac_en,
            i_mac_init 	=> s_mac_init,			
            i_rom_out  	=> s_rom_out,	
            i_ram_out   => s_ram_out,
            o_y         => o_y
        );

    process (i_clk, i_rst)
    begin
        if i_rst = '1' then
            o_valid_out     <= '0';
            s_running_del   <= '0';
            s_prev_state    <= '0';
        elsif rising_edge(i_clk) then
            o_valid_out     <= s_validout_del; 
            s_running_del   <= s_running;   --give MAC an extra cycle to make RAM(7)*ROM(7)
            s_prev_state    <= i_valid_in;  --update previous state
        end if;
    end process;

    s_mac_en <= s_running or s_running_del; --delaying mac_enable=0 for RAM(7)*ROM(7) / MAC starts immediately 1 cycle after CU started running 
    s_valid_pulse <= '1' when (i_valid_in = '1' and s_prev_state = '0') else '0'; --rising edge detected in i_valid_in
end architecture;
