----------------------------
-- Author: Nishant Mittal
-- Function: Generalts L1 C/A code for a given satellite
-- Usage:
-- Inputs: 
-- clk - clock
-- rst - reset
-- enable - enable
-- SAT - satelite no.

-- Outputs: 
-- ca - C/A code 
-- epoch - end of frame - high after 1023 chips

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CA_gen is
	port (clk : in std_logic;
			rst : in std_logic;
			enable : in std_logic;
			SAT : in integer range 1 to 32;
			ca : out std_logic;
			epoch : out std_logic);
end CA_gen;

architecture beh of CA_gen is
	signal g1, g2 : std_logic_vector(1 to 10) := (others => '1');
	signal timecount : integer := 0;
	signal flag : std_logic := '0';
	-- By default sat 1
	signal t1 : integer := 2;
	signal t2 : integer := 6;
begin
	
	-- ca_gen
	process(clk, rst)
	variable c_a : std_logic := '0';
	
	begin
		-- process
		-- activities triggered by asynchronous reset (active low)
		if rst = '0' then
			c_a := '1';
			g1 <= (others => '1');
			g2 <= (others => '1');
			timecount <= 0;	
			flag <= '0';
			
			-- changing sat only when reset
			CASE SAT IS
				WHEN 1 => 
					t1 <= 2;
					t2 <= 6;
				WHEN 2 => 
					t1 <= 3;
					t2 <= 7;
				WHEN 3 => 
					t1 <= 4;
					t2 <= 8;
				WHEN 4 => 
					t1 <= 5;
					t2 <= 9;
				WHEN 5 => 
					t1 <= 1;
					t2 <= 9;
				WHEN 6 => 
					t1 <= 2;
					t2 <= 10;
				WHEN 7 => 
					t1 <= 1;
					t2 <= 8;
				WHEN 8 => 
					t1 <= 2;
					t2 <= 9;
				WHEN 9 => 
					t1 <= 3;
					t2 <= 10;
				WHEN 10 => 
					t1 <= 2;
					t2 <= 3;
				WHEN 11 => 
					t1 <= 3;
					t2 <= 4;
				WHEN 12 => 
					t1 <= 5;
					t2 <= 6;
				WHEN 13 => 
					t1 <= 6;
					t2 <= 7;
				WHEN 14 => 
					t1 <= 7;
					t2 <= 8;
				WHEN 15 => 
					t1 <= 8;
					t2 <= 9;
				WHEN 16 => 
					t1 <= 9;
					t2 <= 10;
				WHEN 17 => 
					t1 <= 1;
					t2 <= 4;
				WHEN 18 => 
					t1 <= 2;
					t2 <= 5;
				WHEN 19 => 
					t1 <= 3;
					t2 <= 6;
				WHEN 20 => 
					t1 <= 4;
					t2 <= 7;
				WHEN 21 => 
					t1 <= 5;
					t2 <= 8;
				WHEN 22 => 
					t1 <= 6;
					t2 <= 9;
				WHEN 23 => 
					t1 <= 1;
					t2 <= 3;
				WHEN 24 => 
					t1 <= 4;
					t2 <= 6;
				WHEN 25 => 
					t1 <= 5;
					t2 <= 7;
				WHEN 26 => 
					t1 <= 6;
					t2 <= 8;
				WHEN 27 => 
					t1 <= 7;
					t2 <= 9;
				WHEN 28 => 
					t1 <= 8;
					t2 <= 10;
				WHEN 29 => 
					t1 <= 1;
					t2 <= 6;
				WHEN 30 => 
					t1 <= 2;
					t2 <= 7;
				WHEN 31 => 
					t1 <= 3;
					t2 <= 8;
				WHEN 32 => 
					t1 <= 4;
					t2 <= 9;
				WHEN OTHERS =>  
					t1 <= 2;
					t2 <= 6;
			end case;
		else
			if clk'event and clk= '1' then
				if enable = '1' then
					-- activities triggered by rising edge of clock
					g1(2 to 10) <= g1(1 to 9);
					g2(2 to 10) <= g2(1 to 9);
					g1(1) <= g1(3) xor g1(10);
					g2(1) <= g2(2) xor g2(3) xor g2(6) xor g2(8) xor g2(9) xor g2(10);
					c_a := g1(10) xor (g2(t1) xor g2(t2));					
					if timecount < 1024 then
						timecount <= timecount + 1;
						flag <= '0';
					else
						flag <= '1';
						timecount <= 0;
					end if;
				end if;
			end if;
		end if;
		
		ca <= c_a;
		epoch <= flag;

	end process;
end beh;