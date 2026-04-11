library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity debayering_filter_tb is
end entity;

architecture sim of debayering_filter_tb is

    -- Παράμετρος N=4 για τη δοκιμή
    constant N_tb : integer := 32;

    -- Σήματα για το Top-Level Module
    signal clk_tb             : std_logic := '0';
    signal rst_n_tb           : std_logic := '0';
    signal new_image_tb       : std_logic := '0';
    signal valid_in_tb        : std_logic := '0';
    signal pixel_tb           : std_logic_vector(7 downto 0) := (others => '0');
    
    signal valid_out_tb       : std_logic;
    signal image_finished_tb  : std_logic;
    signal R_tb               : std_logic_vector(7 downto 0);
    signal G_tb               : std_logic_vector(7 downto 0);
    signal B_tb               : std_logic_vector(7 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    UUT: entity work.debayering_filter
        generic map ( N => N_tb )
        port map (
            clk             => clk_tb,
            rst_n           => rst_n_tb,
            new_image       => new_image_tb,
            valid_in        => valid_in_tb,
            pixel           => pixel_tb,
            valid_out       => valid_out_tb,
            image_finished  => image_finished_tb,
            R               => R_tb,
            G               => G_tb,
            B               => B_tb
        );

    clk_process : process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD / 2;
        clk_tb <= '1';
        wait for CLK_PERIOD / 2;
    end process;


    stimulus : process
        file input_file : text open read_mode is "pixels_file.txt"; --reading from file
        file input_file_aux : text open read_mode is "pixels_file.txt";
        variable current_row : line;
        variable pixel_val : integer;

    begin

        rst_n_tb <= '0';
        wait for 3 * CLK_PERIOD;
        rst_n_tb <= '1';
        wait for 2 * CLK_PERIOD;

        -- Starting new image
        new_image_tb <= '1';
        valid_in_tb  <= '1';

        -- Reading till file empty
        while (not endfile(input_file)) loop
            readline(input_file, current_row);
            read(current_row, pixel_val);
            pixel_tb <= std_logic_vector(to_unsigned(pixel_val, 8));

            if pixel_val = 136 then 
                valid_in_tb <= '0';
                wait for 9* CLK_PERIOD;
                valid_in_tb <= '1'; 
            end if;

            wait for CLK_PERIOD;

            new_image_tb <= '0';
        end loop;

        -- End image
        valid_in_tb <= '0';
        pixel_tb    <= (others => '0');

        -- Draining
        wait for 70 * CLK_PERIOD;


        
        --==============================================================
        -- Processing image and asychronous reset
        --==============================================================
            
        new_image_tb <= '1';
        valid_in_tb  <= '1';
        
        while (not endfile(input_file_aux)) loop
            readline(input_file_aux, current_row);
            read(current_row, pixel_val);
            pixel_tb <= std_logic_vector(to_unsigned(pixel_val, 8));

            if pixel_val = 0 then 
                rst_n_tb <= '0';
                wait for 3*CLK_PERIOD;
                rst_n_tb <= '1';
            end if;

            wait for CLK_PERIOD;

            new_image_tb <= '0';
        end loop;

        -- End image
        valid_in_tb <= '0';
        pixel_tb    <= (others => '0');


        wait;
    end process;

    -- Writing output(R, G, B) to a file
    writing : process
        file results_file : text open write_mode is "output_file.txt";
        variable out_line : line;
        variable space    : character := ' ';

    begin
        wait until rising_edge(clk_tb);

        if valid_out_tb = '1' then
            write(out_line, to_integer(unsigned(R_tb)));
            write(out_line, space);
            write(out_line, to_integer(unsigned(G_tb)));
            write(out_line, space);
            write(out_line, to_integer(unsigned(B_tb)));

            writeline(results_file, out_line);
        end if;

        if image_finished_tb = '1' then
            wait for CLK_PERIOD;
            file_close(results_file);
            wait;
        end if;
    end process;

end architecture;