LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
use ieee.std_logic_textio.all;
use std.textio.all;
 
use IEEE.std_logic_unsigned.all; -- per les sumes
use ieee.numeric_std.all; --to_signed, etc

use IEEE.math_real.all; --funcions matematiques
 
ENTITY CA_gen_tb IS
END CA_gen_tb;
 
ARCHITECTURE behavior OF CA_gen_tb IS 
 
    COMPONENT CA_gen
		port (clk : in std_logic;
			rst : in std_logic;
			enable : in std_logic;
			SAT : in integer;
			ca : out std_logic;
			epoch : out std_logic);
    END COMPONENT;
	 COMPONENT CA_NRZ
		port (clk : in std_logic;
			rst : in std_logic;
			enable : in std_logic;
			SAT : in integer;
			ca_int : out integer range -1 to 1;
			epoch : out std_logic);
    END COMPONENT;
	 
   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '1';
	signal enable: std_logic := '1';
	signal SAT : integer := 1;
 	--Outputs
   signal ca : integer;
	signal epoch : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns; --100 MHz
 
BEGIN

   -- Clock process definitions
   clk_process :process
		begin
			clk <= '1';
			wait for clk_period/2;
			clk <= '0';
			wait for clk_period/2;
   end process;
	
	--stimulus
	stim_pros:process
		begin
			wait for 5*clk_period;
			rst <= '1';
			wait for 1024*clk_period;
			SAT <= 2;
			rst <= '0';
			wait for 5*clk_period;
			rst <= '1';
			wait for 1024*clk_period;
	end process;
	
	uut: CA_NRZ
		PORT MAP (clk => clk,
          rst => rst,
			 enable => enable,
			 SAT => SAT,
          ca_int => ca,
			 epoch => epoch);

END;