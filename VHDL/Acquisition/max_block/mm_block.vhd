-- -------------------------------------------------------------
-- 
-- File Name: hdlsrc\mm_block\mm_block.vhd
-- Created: 2021-07-01 03:28:53
-- 
-- Generated by MATLAB 9.8 and HDL Coder 3.16
-- 
-- 
-- -------------------------------------------------------------
-- Rate and Clocking Details
-- -------------------------------------------------------------
-- Model base rate: 6.10963e-08
-- Target subsystem base rate: 6.10963e-08
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: mm_block
-- Source Path: mm_block
-- Hierarchy Level: 0
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.mm_block_pkg.ALL;

ENTITY mm_block IS
  PORT( Input                             :   IN    vector_of_std_logic_vector32(0 TO 20);  -- sfix32_En16 [21]
        Outport                           :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        Outport1                          :   OUT   std_logic_vector(31 DOWNTO 0)  -- uint32
        );
END mm_block;


ARCHITECTURE rtl OF mm_block IS

  -- Component Declarations
  COMPONENT Maximum
    PORT( in0                             :   IN    vector_of_std_logic_vector32(0 TO 20);  -- sfix32_En16 [21]
          out0                            :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          out1                            :   OUT   std_logic_vector(31 DOWNTO 0)  -- uint32
          );
  END COMPONENT;

  -- Component Configuration Statements
  FOR ALL : Maximum
    USE ENTITY work.Maximum(rtl);

  -- Signals
  SIGNAL Maximum_out1                     : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL Maximum_out2                     : std_logic_vector(31 DOWNTO 0);  -- ufix32

BEGIN
  u_mm_block_Maximum : Maximum
    PORT MAP( in0 => Input,  -- sfix32_En16 [21]
              out0 => Maximum_out1,  -- sfix32_En16
              out1 => Maximum_out2  -- uint32
              );

  Outport <= Maximum_out1;

  Outport1 <= Maximum_out2;

END rtl;

