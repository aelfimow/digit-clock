library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity digit_clock3 is
	port (
		base_clk_i: in std_logic;
		led_clk_i: in std_logic;
		key_a: in std_logic;
		key_b: in std_logic;
		led_a: out std_logic;
		led_b: out std_logic;
		led_c: out std_logic;
		led_d: out std_logic;
		led_e: out std_logic;
		led_f: out std_logic;
		led_g: out std_logic;
		lednr_o: out std_logic_vector(0 to 7);
		dp_o: out std_logic
	);
end entity digit_clock3;

architecture arch_digit_clock of digit_clock3 is
	-- clock counters
	signal c1sec, c1min: integer range 0 to 9;
	signal c10sec, c10min: integer range 0 to 5;
	signal c1hour: integer range 0 to 9;
	signal c10hour: integer range 0 to 2;
	-- internal clock
	signal clk: std_logic;
	-- counter for multiplexer
	signal part_cntr: integer range 0 to 5;
	-- counter fpr generating 1 Hz
	signal cntr_1Hz: integer range 0 to 899;
	signal cntr_XHz: integer range 0 to 63;
	signal clk_1Hz: std_logic;
	signal clk_XHz: std_logic;
	signal min_or_sec: integer range 0 to 3;
begin

	generate_1Hz: process(base_clk_i, cntr_1Hz, cntr_XHz)
	begin
		if base_clk_i = '1' and base_clk_i'event then
			if cntr_1Hz = cntr_1Hz'high then cntr_1Hz <= 0; else cntr_1Hz <= cntr_1Hz + 1; end if;
			if cntr_XHz = cntr_XHz'high then cntr_XHz <= 0; else cntr_XHz <= cntr_XHz + 1; end if;
		end if;
	end process generate_1Hz;

	process(key_a)
	begin
		if key_a = '0' and key_a'event then
			if min_or_sec = min_or_sec'high then
				min_or_sec <= 0;
			else
				min_or_sec <= min_or_sec + 1;
			end if;
		end if;
	end process;

	clk_XHz <= '0' when cntr_XHz = cntr_XHz'high else '1';
	clk_1Hz <= '0' when cntr_1Hz = cntr_1Hz'high else '1';
	clk <= clk_1Hz when key_a = '1' and key_b = '1' else clk_XHz;

	clock_logic: process(clk, c1sec, c10sec, c1min, c10min, c1hour, c10hour)
		variable continue: std_logic;
	begin
		if (clk = '1' and clk'event) then
			continue := '1';
			for j in part_cntr'range loop
				if (continue = '1') then
					continue := '0';
					case j is
						when 0 =>
							c1sec <= c1sec + 1;
							if key_a = '0' and min_or_sec = 1 then
								continue := '1';
							elsif key_b = '0' or c1sec = 9 then
								c1sec <= 0;
								continue := '1';
							end if;
						when 1 =>
							c10sec <= c10sec + 1;
							if key_a = '0' and min_or_sec = 1 then
								continue := '1';
							elsif key_b = '0' or c10sec = 5 then
								c10sec <= 0;
								continue := '1';
							end if;
						when 2 =>
							c1min <= c1min + 1;
							if key_a = '0' and min_or_sec = 0 then null;
							elsif key_b = '0' or c1min = 9 then
								c1min <= 0;
								continue := '1';
							end if;
						when 3 =>
							c10min <= c10min + 1;
							if key_a = '0' and min_or_sec = 0 then null;
							elsif key_b = '0' or c10min = 5 then
								c10min <= 0;
								continue := '1';
							end if;
						when 4 =>
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
						when 5 =>
							c10hour <= c10hour + 1;
							if c10hour = 2 then c10hour <= 0; end if;
						when others => null;
					end case;
				end if;
			end loop;
		end if;
	end process clock_logic;

	multiplexer_cntr: process(base_clk_i, part_cntr)
	begin
		if (base_clk_i = '1' and base_clk_i'event) then
			if part_cntr = part_cntr'high then part_cntr <= 0; else part_cntr <= part_cntr + 1; end if;
		end if;
	end process multiplexer_cntr;

	output_logic: process(part_cntr, c1sec, c10sec, c1min, c10min, c1hour, c10hour, key_a, key_b)
		variable val: integer range 0 to 9;
	begin
		lednr_o <= (others => '0');
		lednr_o(part_cntr) <= '1';
		case part_cntr is
			when 0 =>
				val := c1sec;
				dp_o <= '0';
			when 1 =>
				val := c10sec;
				dp_o <= '1';
			when 2 =>
				val := c1min;
				dp_o <= '0';
			when 3 =>
				val := c10min;
				dp_o <= '1';
			when 4 =>
				val := c1hour;
				dp_o <= '0';
			when 5 =>
				val := c10hour;
				dp_o <= '1';
		end case;
		led_a <= '1';
		led_b <= '1';
		led_c <= '1';
		led_d <= '1';
		led_e <= '1';
		led_f <= '1';
		led_g <= '1';
		case val is
			when 0 =>
				led_a <= '0';
				led_b <= '0';
				led_c <= '0';
				led_d <= '0';
				led_e <= '0';
				led_f <= '0';
			when 1 =>
				led_b <= '0';
				led_c <= '0';
			when 2 =>
				led_a <= '0';
				led_b <= '0';
				led_d <= '0';
				led_e <= '0';
				led_g <= '0';
			when 3 =>
				led_a <= '0';
				led_b <= '0';
				led_c <= '0';
				led_d <= '0';
				led_g <= '0';
			when 4 =>
				led_b <= '0';
				led_c <= '0';
				led_f <= '0';
				led_g <= '0';
			when 5 =>
				led_a <= '0';
				led_c <= '0';
				led_d <= '0';
				led_f <= '0';
				led_g <= '0';
			when 6 =>
				led_a <= '0';
				led_c <= '0';
				led_d <= '0';
				led_e <= '0';
				led_f <= '0';
				led_g <= '0';
			when 7 =>
				led_a <= '0';
				led_b <= '0';
				led_c <= '0';
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
				led_f <= '0';
				led_g <= '0';
		end case;
	end process output_logic;


end architecture arch_digit_clock;