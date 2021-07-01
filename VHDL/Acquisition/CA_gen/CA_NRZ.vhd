library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.fixed_pkg.all;
--use ieee.float_pkg.all;
--use ieee.fixed_generic_pkg.all;

--library ieee_proposed;
--use ieee_proposed.float_pkg.all;


entity CA_NRZ is
	port (clk : in std_logic;
			rst : in std_logic;
			enable : in std_logic;
			SAT : in integer range 1 to 32;
			ca_int : out integer range -1 to 1;
			epoch : out std_logic);
end CA_NRZ;

architecture behavior of CA_NRZ is 
	
	signal ca_temp : std_logic := '1';
	signal epoch_temp : std_logic := '0';
	
	COMPONENT CA_gen
		port (clk : in std_logic;
			rst : in std_logic;
			enable : in std_logic;
			SAT : in integer range 1 to 32;
			ca : out std_logic;
			epoch : out std_logic);
    END COMPONENT;
begin	 
	
	u1: CA_gen port map (clk => clk, rst => rst, enable => enable, SAT => SAT, ca => ca_temp, epoch => epoch_temp);
	epoch <= epoch_temp;
	convert_pros: process(ca_temp)
	begin
		if ca_temp = '0' then
--			ca_float <= "1011111110000000000000000000000"; -- -1 in float 32
			ca_int <= -1;
		else 
--			ca_float <= "00111111100000000000000000000000"; -- 1 in float 32
			ca_int <= 1;
		end if;
	end process;
end;