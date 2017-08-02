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
		lednr_o: out std_logic_vector(7 downto 0);
		dp_o: out std_logic;
		middle_points_o: out std_logic
		
	);
end entity digit_clock;

architecture arch_digit_clock of digit_clock is
	signal c10ms: integer range 0 to 9;
	signal c100ms: integer range 0 to 9;
	signal c1sec: integer range 0 to 9;
	signal c10sec: integer range 0 to 5;
	signal c1min: integer range 0 to 9;
	signal c10min: integer range 0 to 5;
	signal c1hour: integer range 0 to 9;
	signal c10hour: integer range 0 to 2;
	signal clk: std_logic;
	signal clk10ms: std_logic;
	signal part_cntr: integer range 0 to 7;
	signal c: integer range 0 to 8;
	signal flag: std_logic;
begin

	generate_100Hz: process(base_clk_i, c)
	begin
		if (base_clk_i = '1' and base_clk_i'event) then
			clk10ms <= '0';
			if (c = 8) then
				c <= 0;
				clk10ms <= '1';
			else
				c <= c + 1;
			end if;
		end if;
	end process generate_100Hz;

	clk <= clk10ms when key_a = '1' else base_clk_i;
	debug_o <= clk10ms;

	clock_logic: process(clk, c10ms, c100ms, c1sec, c10sec, c1min, c10min, c1hour, c10hour)
		variable continue: std_logic;
	begin
		if (clk = '1' and clk'event) then
			continue := '1';
			for j in 0 to 7 loop
				if (continue = '1') then
					continue := '0';
					case j is
						when 0 =>
							c10ms <= c10ms + 1;
							if key_a = '0' or key_b = '0' or c10ms = 9 then
								c10ms <= 0;
								continue := '1';
							end if;
						when 1 =>
							c100ms <= c100ms + 1;
							if key_a = '0' or key_b = '0' or c100ms = 9 then
								c100ms <= 0;
								continue := '1';
							end if;
						when 2 =>
							c1sec <= c1sec + 1;
							if key_b = '0' or c1sec = 9 then
								c1sec <= 0;
								continue := '1';
							end if;
						when 3 =>
							c10sec <= c10sec + 1;
							if key_b = '0' or c10sec = 5 then
								c10sec <= 0;
								continue := '1';
							end if;
						when 4 =>
							c1min <= c1min + 1;
							if c1min = 9 then
								c1min <= 0;
								continue := '1';
							end if;
						when 5 =>
							c10min <= c10min + 1;
							if c10min = 5 then
								c10min <= 0;
								continue := '1';
							end if;
						when 6 =>
							c1hour <= c1hour + 1;
							if c10hour /= 2 then
								if c1hour = 9 then
									c1hour <= 0;
									continue := '1';
								end if;
							else
								if c1hour = 3 then
									c1hour <= 0;
									continue := '1';
								end if;
							end if;
						when 7 =>
							c10hour <= c10hour + 1;
							if c10hour = 2 then c10hour <= 0; end if;
					end case;
				end if;
			end loop;
		end if;
	end process clock_logic;

	multiplexer_cntr: process(led_clk_i, part_cntr)
	begin
		if (led_clk_i = '1' and led_clk_i'event) then
			if part_cntr = 7 then
				part_cntr <= 0;
			else
				part_cntr <= part_cntr + 1;
			end if;
		end if;
	end process multiplexer_cntr;

	output_logic: process(part_cntr, c10ms, c100ms, c1sec, c10sec, c1min, c10min, c1hour, c10hour)
		variable val: integer range 0 to 9;
	begin
		lednr_o <= (others => '0');
		lednr_o(part_cntr) <= '1';
		middle_points_o <= '0';
		case part_cntr is
			when 0 =>
				val := c10ms;
				dp_o <= '0';
			when 1 =>
				val := c100ms;
				dp_o <= '1';
			when 2 =>
				val := c1sec;
				dp_o <= '0';
			when 3 =>
				val := c10sec;
				dp_o <= '1';
			when 4 =>
				val := c1min;
				dp_o <= '0';
			when 5 =>
				val := c10min;
				dp_o <= '1';
			when 6 =>
				val := c1hour;
				dp_o <= '0';
			when 7 =>
				val := c10hour;
				dp_o <= '1';
		end case;
		led_a <= '0';
		led_b <= '0';
		led_c <= '0';
		led_d <= '0';
		led_e <= '0';
		led_f <= '0';
		led_g <= '0';
		case val is
			when 0 =>
				led_g <= '1';
			when 1 =>
				led_a <= '1';
				led_d <= '1';
				led_e <= '1';
				led_f <= '1';
				led_g <= '1';
			when 2 =>
				led_c <= '1';
				led_f <= '1';
			when 3 =>
				led_e <= '1';
				led_f <= '1';
			when 4 =>
				led_a <= '1';
				led_d <= '1';
				led_e <= '1';
			when 5 =>
				led_b <= '1';
				led_e <= '1';
			when 6 =>
				led_b <= '1';
			when 7 =>
				led_d <= '1';
				led_e <= '1';
				led_f <= '1';
				led_g <= '1';
			when 8 => null;
			when 9 =>
				led_e <= '1';
			when others => null;
		end case;
	end process output_logic;

end architecture arch_digit_clock;