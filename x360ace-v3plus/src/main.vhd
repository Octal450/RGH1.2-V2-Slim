-- RGH1.2 Code for X360ACE V3+, Trinity/Corona Version
-- 15432, GliGli, Octal450

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity main is
    Port ( CLK : in STD_LOGIC;
           DBG : out STD_LOGIC := '0';
           PLL : out STD_LOGIC := '0';
           POST : in STD_LOGIC;
           RST : inout STD_LOGIC := 'Z');
end main;

architecture arch of main is

constant R_LEN : integer := 6;
constant R_STA : integer := 910995; -- 995 works for me
constant T_BUF : integer := 5208;
constant T_END : integer := R_STA + R_LEN + T_BUF;

-- post proc
constant post_rgh : integer := 11;
constant post_s_max : integer := 7;
signal rgh_cnt : integer range 0 to T_END := 0;
signal post_r_cnt : integer range 0 to post_s_max := 0;
signal post_f_cnt : integer range 0 to post_s_max := 0;
signal timeout : STD_LOGIC := '0';
signal to_slow : STD_LOGIC := '0';

-- slower divider
constant div_value : integer := 1023;
signal div_counter : integer range 0 to div_value := 0;
signal div_clk : STD_LOGIC := '0';

-- slower + delayer
constant delay_val : integer := 6639; -- Trinity: 6639, Corona: 6820, Winbond Corona: 7999
signal delay_cnt : integer range 0 to delay_val := 0;
signal slow : STD_LOGIC := '0';

begin

-- post counter
process (POST) is
begin
	if (rising_edge(POST)) then
		if (RST = '0') then
			post_r_cnt <= 0;
		else
			if (post_r_cnt < post_s_max) then
				post_r_cnt <= post_r_cnt + 1;
			end if;
		end if;
    end if;
    if (falling_edge(POST)) then
		if (RST = '0') then
			post_f_cnt <= 0;
		else
			if (post_f_cnt < post_s_max) then
				post_f_cnt <= post_f_cnt + 1;
			end if;
		end if;
	end if;
	
	DBG <= not POST;
end process;

-- timing counter + reset
process (CLK) is
begin
	if (rising_edge(CLK)) then -- 25 MHz
		if (post_r_cnt + post_f_cnt >= post_rgh) then
			if (rgh_cnt < T_END) then
				rgh_cnt <= rgh_cnt + 1;
				timeout <= '0';
			else
				timeout <= '1';
			end if;
		else
			rgh_cnt <= 0;
			timeout <= '0';
		end if;
		
		if (rgh_cnt >= R_STA and rgh_cnt < R_STA + R_LEN and slow = '1') then
			RST <= '0';
		else
			RST <= 'Z';
		end if;
	end if;
end process;

-- slowdown
process (post_r_cnt, post_f_cnt, timeout) is
begin
	if (post_r_cnt + post_f_cnt >= post_rgh - 1 and timeout = '0') then
		to_slow <= '1';
	else
		to_slow <= '0';
	end if;
end process;

-- slower divider
process (CLK) is
begin
	if (rising_edge(CLK)) then -- divide further by processing only on rising edge
		if (div_counter < div_value) then
			div_counter <= div_counter + 1;
		else
			div_counter <= 0;
			div_clk <= not div_clk;
		end if;
	end if;
end process;

-- PLL slower + delayer
process (div_clk) is
begin
	if (rising_edge(div_clk)) then
		if (to_slow = '1') then
			if (delay_cnt < delay_val) then
				delay_cnt <= delay_cnt + 1;
				slow <= '0';
			else
				slow <= '1';
			end if;
		else
			slow <= '0';
			delay_cnt <= 0;
		end if;
	end if;
end process;

process (slow) is
begin
	PLL <= slow;
end process;

end arch;
