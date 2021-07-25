-- -------------------------------------------------------------
-- 
-- File Name: hdlsrc\moving_avg\moving_avg.vhd
-- Created: 2021-07-25 07:05:38
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
-- 
-- Clock Enable  Sample Time
-- -------------------------------------------------------------
-- ce_out        6.10963e-08
-- -------------------------------------------------------------
-- 
-- 
-- Output Signal                 Clock Enable  Sample Time
-- -------------------------------------------------------------
-- Outport                       ce_out        6.10963e-08
-- -------------------------------------------------------------
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: moving_avg
-- Source Path: moving_avg
-- Hierarchy Level: 0
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY moving_avg IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        clk_enable                        :   IN    std_logic;
        Inport                            :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        ce_out                            :   OUT   std_logic;
        Outport                           :   OUT   std_logic_vector(31 DOWNTO 0)  -- sfix32_En16
        );
END moving_avg;


ARCHITECTURE rtl OF moving_avg IS

  -- Signals
  SIGNAL enb                              : std_logic;
  SIGNAL Inport_signed                    : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL Delay1_out1                      : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL Delay2_out1                      : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL Delay3_out1                      : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL Add_add_temp                     : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL Add_add_temp_1                   : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL Add_out1                         : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL Add_out1_dtc                     : signed(32 DOWNTO 0);  -- sfix33_En16
  SIGNAL Constant_out1                    : signed(15 DOWNTO 0);  -- int16
  SIGNAL Divide_out1                      : signed(31 DOWNTO 0);  -- sfix32_En16

BEGIN
  Inport_signed <= signed(Inport);

  enb <= clk_enable;

  Delay1_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      Delay1_out1 <= to_signed(0, 32);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        Delay1_out1 <= Inport_signed;
      END IF;
    END IF;
  END PROCESS Delay1_process;


  Delay2_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      Delay2_out1 <= to_signed(0, 32);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        Delay2_out1 <= Delay1_out1;
      END IF;
    END IF;
  END PROCESS Delay2_process;


  Delay3_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      Delay3_out1 <= to_signed(0, 32);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        Delay3_out1 <= Delay2_out1;
      END IF;
    END IF;
  END PROCESS Delay3_process;


  Add_add_temp <= Delay3_out1 + Inport_signed;
  Add_add_temp_1 <= Add_add_temp + Delay1_out1;
  Add_out1 <= Add_add_temp_1 + Delay2_out1;

  Add_out1_dtc <= resize(Add_out1, 33);

  Constant_out1 <= to_signed(16#0004#, 16);

  Divide_output : PROCESS (Add_out1_dtc, Constant_out1)
    VARIABLE c : signed(32 DOWNTO 0);
    VARIABLE div_temp : signed(33 DOWNTO 0);
    VARIABLE cast : signed(33 DOWNTO 0);
  BEGIN
    div_temp := to_signed(0, 34);
    cast := to_signed(0, 34);
    IF Constant_out1 = to_signed(16#0000#, 16) THEN 
      IF Add_out1_dtc < to_signed(0, 33) THEN 
        c := signed'("100000000000000000000000000000000");
      ELSE 
        c := signed'("011111111111111111111111111111111");
      END IF;
    ELSE 
      cast := resize(Add_out1_dtc, 34);
      div_temp := cast / Constant_out1;
      IF (div_temp(33) = '0') AND (div_temp(32) /= '0') THEN 
        c := "011111111111111111111111111111111";
      ELSIF (div_temp(33) = '1') AND (div_temp(32) /= '1') THEN 
        c := "100000000000000000000000000000000";
      ELSE 
        c := div_temp(32 DOWNTO 0);
      END IF;
    END IF;
    IF (c(32) = '0') AND (c(31) /= '0') THEN 
      Divide_out1 <= X"7FFFFFFF";
    ELSIF (c(32) = '1') AND (c(31) /= '1') THEN 
      Divide_out1 <= X"80000000";
    ELSE 
      Divide_out1 <= c(31 DOWNTO 0);
    END IF;
  END PROCESS Divide_output;


  Outport <= std_logic_vector(Divide_out1);

  ce_out <= clk_enable;

END rtl;

