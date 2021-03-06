-- RGH1.2 Code for X360ACE/DGX, Trinity/Corona Version
-- 15432, GliGli, Octal450

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- main module

entity post_proc is
	Port (
		callback : in STD_LOGIC;
		POST : in STD_LOGIC;
		CLK : in STD_LOGIC;
		to_slow : out STD_LOGIC := '0';
		DBG : out STD_LOGIC := '0';
		RST : inout STD_LOGIC := 'Z'
	);
end post_proc;

architecture arch of post_proc is

constant R_LEN : integer := 12;
constant R_STA : integer := 1821950; -- 20 - 80 works for me on various chips and boards, crystal varies slightly per chip, adjust value as needed
constant T_BUF : integer := 10417;
constant T_END : integer := R_STA + R_LEN + T_BUF;

constant post_rgh : integer := 11;
constant post_max : integer := 15;
signal cnt : integer range 0 to T_END := 0;
signal post_cnt : integer range 0 to post_max := 0;
signal timeout : STD_LOGIC := '0';

begin

-- post counter
process (POST) is
begin
	if (POST'event) then
		if (RST = '0') then
			post_cnt <= 0;
		else
			if (post_cnt < post_max) then
				post_cnt <= post_cnt + 1;
			end if;
		end if;
	end if;
	
	DBG <= POST;
end process;

-- timing counter + reset
process (CLK) is
begin
	if (rising_edge(CLK)) then -- 50 MHz
		if (post_cnt >= post_rgh) then
			if (cnt < T_END) then
				cnt <= cnt + 1;
				timeout <= '0';
			else
				timeout <= '1';
			end if;
		else
			cnt <= 0;
			timeout <= '0';
		end if;
		
		if (cnt >= R_STA and cnt < R_STA + R_LEN and callback = '1') then
			RST <= '0';
		else
			RST <= 'Z';
		end if;
	end if;
end process;

-- slowdown
process (post_cnt, timeout) is
begin
	if (post_cnt >= post_rgh - 1 and timeout = '0') then
		to_slow <= '1';
	else
		to_slow <= '0';
	end if;
end process;

end arch;
