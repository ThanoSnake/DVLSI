library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity control_unit is
    generic (
        N : integer := 16
    );
    port (
        clk             : in  std_logic;
        rst_n           : in  std_logic;
        new_image       : in  std_logic;
        valid_in        : in  std_logic;
        wr_en           : out std_logic_vector(2 downto 0);
        rd_en           : out std_logic_vector(2 downto 0);
        state1          : out std_logic_vector(3 downto 0);
        state2          : out std_logic_vector(1 downto 0);
        valid_out       : out std_logic;
        image_finished  : out std_logic
    );
end entity;

architecture arc of control_unit is

    signal running : std_logic;
    signal counter : integer := 0;
    signal i       : integer := 0;
    signal j       : integer := 0;

begin

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            running <= '0';
            counter <= 0;
            i <= 0;
            j <= 0;
        elsif rising_edge(clk) then
            if new_image = '1' and valid_in = '1' then --new image
                counter <= 1;
                running <= '1';
            elsif running = '1' then
                if counter = N*N+2*N+4 then --whole process finished
                    running <= '0';
                    counter <= 0;
                elsif (counter <= N*N-1 and valid_in = '1') or counter > N*N-1 then --raise counter
                    counter <= counter + 1;
                    if counter = 2*N+2 then --first valid 3x3 kernel
                        i <= 0; 
                        j <= 0;
                    elsif counter > 2*N+2 then --move kernel
                        if j = N-1 then --last column
                            i <= i + 1;
                            j <= 0;
                        else
                            j <= j + 1;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    --wr_en(0) <= valid_in;
    wr_en(0) <= '0';
    
    rd_en(0) <= '1' when (counter >= N) else '0';
    wr_en(1) <= '1' when (counter > N) else '0';

    rd_en(1) <= '1' when (counter >= 2*N) else '0';
    wr_en(2) <= '1' when (counter > 2*N) else '0';

    rd_en(2) <= '1' when (counter >= 3*N) else '0';

    --Boundary Decoder
    state1(3) <= '1' when i=0   else '0'; --Top
    state1(2) <= '1' when j=0   else '0'; --Left
    state1(1) <= '1' when i=N-1 else '0'; --Bottom
    state1(0) <= '1' when j=N-1 else '0'; --Right

    --Color Decoder
    state2(1) <= '1' when (i mod 2)=0 else '0'; 
    state2(0) <= '1' when (j mod 2)=0 else '0';

    valid_out       <= '1' when (counter >= 2*N+4 and counter <= N*N+2*N+4) else '0';
    image_finished  <= '1' when counter = N*N+2*N+3 else '0';
    
    --G1 "11"
    --B  "10"
    --R  "01"
    --G2 "00"
end architecture;
