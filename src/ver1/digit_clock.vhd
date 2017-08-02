library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity digit_clock is
	port (
		base_clk_i: in std_logic;
		key_a: in std_logic;
		key_b: in std_logic;
		led_clk_i: in std_logic;
		led_a: out std_logic;
		led_b: out std_logic;
		led_c: out std_logic;
		led_d: out std_logic;
		led_e: out std_logic;
		led_f: out std_logic;
		led_g: out std_logic;
		debug_o: out std_logic;
		lednr_o: out std_logic_vector(7 downto 0)
	);
end entity;

architecture arch_digit_clock of digit_clock is
	type digit_cntr_type is array(0 to 7) of std_logic_vector(3 downto 0);
	signal digit_cntr: digit_cntr_type;
	signal clk: std_logic;
	signal led_cntr: std_logic_vector(2 downto 0);
	signal clk10ms: std_logic;
	signal c: std_logic_vector(3 downto 0);
begin

	process(base_clk_i)
	begin
		if (base_clk_i = '1' and base_clk_i'event) then
			clk10ms <= '0';
			if (conv_integer(c) = 8) then
				c <= (others => '0');
				clk10ms <= '1';
			else
				c <= c + 1;
			end if;
		end if;
	end process;

	clk <= clk10ms when key_a = '1' else led_clk_i;
	debug_o <= clk10ms;

	clock_logic: process(clk, digit_cntr)
		variable continue: std_logic;
	begin
		if (clk = '1' and clk'event) then
			continue := '1';
			for k in digit_cntr'range loop
				if (continue = '1') then
					case k is
						when 0 | 1 | 2 | 4 => -- 10 ms, 100 ms, 1 s, 1 min
							if (key_a = '0' and (k = 1 or k = 0)) then null;
							elsif (key_b = '0' and (k = 1 or k = 0)) then null;
							elsif (conv_integer(digit_cntr(k)) < 9) then
								digit_cntr(k) <= digit_cntr(k) + 1;
								continue := '0';
							else
								digit_cntr(k) <= (others => '0');
							end if;
						when 3 | 5 => -- 10 s, 10 min
							if (conv_integer(digit_cntr(k)) < 5) then
								digit_cntr(k) <= digit_cntr(k) + 1;
								continue := '0';
							else
								digit_cntr(k) <= (others => '0');
							end if;
						when 6 => -- 1 h
							if (digit_cntr(k+1) < 2) then
								if (conv_integer(digit_cntr(k)) < 9) then
									digit_cntr(k) <= digit_cntr(k) + 1;
									continue := '0';
								else
									digit_cntr(k) <= (others => '0');
								end if;
							else
								if (conv_integer(digit_cntr(k)) < 3) then
									digit_cntr(k) <= digit_cntr(k) + 1;
									continue := '0';
								else
									digit_cntr(k) <= (others => '0');
								end if;
							end if;
						when 7 => -- 10 h
							if (conv_integer(digit_cntr(k)) < 2) then
								digit_cntr(k) <= digit_cntr(k) + 1;
							else
								digit_cntr(k) <= (others => '0');
							end if;
						when others => continue := '0';
					end case;
				end if;
			end loop;
		end if;
	end process clock_logic;

	process(led_clk_i, led_cntr)
	begin
		if (led_clk_i = '1' and led_clk_i'event) then
			led_cntr <= led_cntr + 1;
		end if;
	end process;

	output_logic: process(digit_cntr, led_cntr)
		variable led_nr: integer range 0 to 7;
		variable digit_val: integer range 0 to 9;
		variable nr: std_logic_vector(lednr_o'range);
	begin
		--
		led_nr := conv_integer(led_cntr);
		nr := (others => '0');
		nr(led_nr) := '1';
		lednr_o <= nr;
		--
		digit_val := conv_integer(digit_cntr(led_nr));
		case digit_val is
			when 0 =>
				led_a <= '0';
				led_b <= '0';
				led_c <= '0';
				led_d <= '0';
				led_e <= '0';
				led_f <= '0';
				led_g <= '1';
			when 1 =>
				led_a <= '1';
				led_b <= '0';
				led_c <= '0';
				led_d <= '1';
				led_e <= '1';
				led_f <= '1';
				led_g <= '1';
			when 2 =>
				led_a <= '0';
				led_b <= '0';
				led_c <= '1';
				led_d <= '0';
				led_e <= '0';
				led_f <= '1';
				led_g <= '0';
			when 3 =>
				led_a <= '0';
				led_b <= '0';
				led_c <= '0';
				led_d <= '0';
				led_e <= '1';
				led_f <= '1';
				led_g <= '0';
			when 4 =>
				led_a <= '1';
				led_b <= '0';
				led_c <= '0';
				led_d <= '1';
				led_e <= '1';
				led_f <= '0';
				led_g <= '0';
			when 5 =>
				led_a <= '0';
				led_b <= '1';
				led_c <= '0';
				led_d <= '0';
				led_e <= '1';
				led_f <= '0';
				led_g <= '0';
			when 6 =>
				led_a <= '0';
				led_b <= '1';
				led_c <= '0';
				led_d <= '0';
				led_e <= '0';
				led_f <= '0';
				led_g <= '0';
			when 7 =>
				led_a <= '0';
				led_b <= '0';
				led_c <= '0';
				led_d <= '1';
				led_e <= '1';
				led_f <= '1';
				led_g <= '1';
			when 8 =>
				led_a <= '0';
				led_b <= '0';
				led_c <= '0';
				led_d <= '0';
				led_e <= '0';
				led_f <= '0';
				led_g <= '0';
			when 9 =>
				led_a <= '0';
				led_b <= '0';
				led_c <= '0';
				led_d <= '0';
				led_e <= '1';
				led_f <= '0';
				led_g <= '0';
		end case;
	end process output_logic;

end architecture arch_digit_clock;