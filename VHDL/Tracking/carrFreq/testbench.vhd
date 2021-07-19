----------------------------------------------------------------------------------
-- Company: 
-- Engineer:
-- 
-- Create Date: 14.07.2021 10:40:51
-- Design Name: 
-- Module Name: testbench - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;



library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;

entity Testbench is
end entity;
architecture Behave of Testbench is

  ----------------------------------------------------------------
  --  edit the following lines to set the number of i/o's of your
  --  DUT.
  ----------------------------------------------------------------
  constant number_of_inputs  : integer := 32;  -- # input bits to your design.
  constant number_of_outputs : integer := 32;  -- # output bits from your design.
  ----------------------------------------------------------------
  ----------------------------------------------------------------

  -- Note that you will have to wrap your design into the DUT
  -- as indicated in class.
--  component DUT is
--   port(input_vector: in std_logic_vector(number_of_inputs-1 downto 0);    
--       	output_vector: out std_logic_vector(number_of_outputs-1 downto 0));
--  end component;
  
  
  component VHDLGen IS
  PORT(-- carrError                         :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En30
        oldNCO                            :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        carrErrorDiff                     :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En30
        carrFreq                               :   OUT   std_logic_vector(31 DOWNTO 0)  -- sfix32_En16
        );
  END component;


  signal input_vector1  : std_logic_vector(number_of_inputs-1 downto 0);
  signal input_vector2  : std_logic_vector(number_of_inputs-1 downto 0);
  signal input_vector3  : std_logic_vector(number_of_inputs-1 downto 0);
  signal output_vector : std_logic_vector(number_of_outputs-1 downto 0);

  -- create a constrained string
  function to_string(x: string) return string is
      variable ret_val: string(1 to x'length);
      alias lx : string (1 to x'length) is x;
  begin  
      ret_val := lx;
      return(ret_val);
  end to_string;

  -- bit-vector to std-logic-vector and vice-versa
  function to_std_logic_vector(x: bit_vector) return std_logic_vector is
     alias lx: bit_vector(1 to x'length) is x;
     variable ret_val: std_logic_vector(1 to x'length);
  begin
     for I in 1 to x'length loop
        if(lx(I) = '1') then
          ret_val(I) := '1';
        else
          ret_val(I) := '0';
        end if;
     end loop; 
     return ret_val;
  end to_std_logic_vector;

  function to_bit_vector(x: std_logic_vector) return bit_vector is
     alias lx: std_logic_vector(1 to x'length) is x;
     variable ret_val: bit_vector(1 to x'length);
  begin
     for I in 1 to x'length loop
        if(lx(I) = '1') then
          ret_val(I) := '1';
        else
          ret_val(I) := '0';
        end if;
     end loop; 
     return ret_val;
  end to_bit_vector;

begin
  process 
    variable err_flag : boolean := false;
    File INFILE: text open read_mode is "TRACEFILE.txt";
    FILE OUTFILE: text  open write_mode is "outputs.txt";

    -- bit-vectors are read from the file.
    variable input_vector_var1: bit_vector (number_of_inputs-1 downto 0);
    variable input_vector_var2: bit_vector (number_of_inputs-1 downto 0);
    variable input_vector_var3: bit_vector (number_of_inputs-1 downto 0);
    variable output_vector_var: bit_vector (number_of_outputs-1 downto 0);


    -- for read/write.
    variable INPUT_LINE: Line;
    variable OUTPUT_LINE: Line;
    variable LINE_COUNT: integer := 0;

    
  begin
    while not endfile(INFILE) loop 
	  -- will read a new line every 5ns, apply input,
	  -- wait for 1 ns for circuit to settle.
	  -- read output.


          LINE_COUNT := LINE_COUNT + 1;


	  -- read input at current time.
	  readLine (INFILE, INPUT_LINE);
          read (INPUT_LINE, input_vector_var1);                     --carrError
          read (INPUT_LINE, input_vector_var2);                     --oldNCO
          read (INPUT_LINE, input_vector_var3);                     --carrErrorDiff
          read (INPUT_LINE, output_vector_var);                     --carrFreq (expected)
	
	  -- apply input.
          input_vector1 <= to_std_logic_vector(input_vector_var1);
          input_vector2 <= to_std_logic_vector(input_vector_var2);
          input_vector3 <= to_std_logic_vector(input_vector_var3);

	  -- wait for the circuit to settle 
	  wait for 10 ns;

          write(OUTPUT_LINE, output_vector_var);    --Expected output (from TRACEFILE.txt)
          write(OUTPUT_LINE, to_string(" "));
          write(OUTPUT_LINE, to_bit_vector(output_vector));               --Write DUT's output
          writeline(OUTFILE, OUTPUT_LINE);

	  -- advance time by 4 ns.
	  wait for 4 ns;
    end loop;

    wait;
  end process;

  dut_instance: VHDLGen 
     	port map(--carrError  =>   input_vector1,
        oldNCO  =>   input_vector2,
        carrErrorDiff  =>   input_vector3,
        carrFreq  =>   output_vector);

end Behave;
