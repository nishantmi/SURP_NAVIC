
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.CRFFT_pkg.ALL;

ENTITY MINRESRX2FFT_MEMORY IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        enb                               :   IN    std_logic;
        dMemIn1_re                        :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        dMemIn1_im                        :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        dMemIn2_re                        :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        dMemIn2_im                        :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        wrEnb1                            :   IN    std_logic;
        wrEnb2                            :   IN    std_logic;
        wrEnb3                            :   IN    std_logic;
        rdEnb1                            :   IN    std_logic;
        rdEnb2                            :   IN    std_logic;
        rdEnb3                            :   IN    std_logic;
        stage                             :   IN    std_logic_vector(3 DOWNTO 0);  -- ufix4
        initIC                            :   IN    std_logic;
        unLoadPhase                       :   IN    std_logic;
        syncReset                         :   IN    std_logic;
        dMemOut1_re                       :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        dMemOut1_im                       :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        dMemOut2_re                       :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        dMemOut2_im                       :   OUT   std_logic_vector(31 DOWNTO 0)  -- sfix32_En16
        );
END MINRESRX2FFT_MEMORY;


ARCHITECTURE rtl OF MINRESRX2FFT_MEMORY IS

  -- Component Declarations
  COMPONENT SimpleDualPortRAM_generic
    GENERIC( AddrWidth                    : integer;
             DataWidth                    : integer
             );
    PORT( clk                             :   IN    std_logic;
          enb                             :   IN    std_logic;
          wr_din                          :   IN    std_logic_vector(DataWidth - 1 DOWNTO 0);  -- generic width
          wr_addr                         :   IN    std_logic_vector(AddrWidth - 1 DOWNTO 0);  -- generic width
          wr_en                           :   IN    std_logic;
          rd_addr                         :   IN    std_logic_vector(AddrWidth - 1 DOWNTO 0);  -- generic width
          rd_dout                         :   OUT   std_logic_vector(DataWidth - 1 DOWNTO 0)  -- generic width
          );
  END COMPONENT;

  -- Component Configuration Statements
  FOR ALL : SimpleDualPortRAM_generic
    USE ENTITY work.SimpleDualPortRAM_generic(rtl);

  -- Signals
  SIGNAL dMemIn1_re_signed                : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL intdelay_reg                     : vector_of_signed32(0 TO 1);  -- sfix32 [2]
  SIGNAL intdelay_reg_next                : vector_of_signed32(0 TO 1);  -- sfix32_En16 [2]
  SIGNAL wrData01Dly_re                   : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL stage_unsigned                   : unsigned(3 DOWNTO 0);  -- ufix4
  SIGNAL dMemIn2_re_signed                : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL intdelay_reg_1                   : vector_of_signed32(0 TO 1);  -- sfix32 [2]
  SIGNAL intdelay_reg_next_1              : vector_of_signed32(0 TO 1);  -- sfix32_En16 [2]
  SIGNAL wrData10Dly_re                   : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL dMemIn2_im_signed                : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL intdelay_reg_2                   : vector_of_signed32(0 TO 1);  -- sfix32 [2]
  SIGNAL intdelay_reg_next_2              : vector_of_signed32(0 TO 1);  -- sfix32_En16 [2]
  SIGNAL wrData10Dly_im                   : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL intdelay_reg_3                   : vector_of_signed32(0 TO 1);  -- sfix32 [2]
  SIGNAL intdelay_reg_next_3              : vector_of_signed32(0 TO 1);  -- sfix32_En16 [2]
  SIGNAL wrData11Dly_re                   : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL intdelay_reg_4                   : vector_of_signed32(0 TO 1);  -- sfix32 [2]
  SIGNAL intdelay_reg_next_4              : vector_of_signed32(0 TO 1);  -- sfix32_En16 [2]
  SIGNAL wrData11Dly_im                   : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL rdAddr10                         : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL wrAddr10                         : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL wrEnb11                          : std_logic;
  SIGNAL rdData11_im                      : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL rdData11_im_signed               : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL rdData11_re                      : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL rdData11_re_signed               : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL wrEnb10                          : std_logic;
  SIGNAL rdData10_im                      : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL rdData10_im_signed               : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL rdAddr10_tmp                     : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL addrBit10_14                     : std_logic;
  SIGNAL addrBit10_13                     : std_logic;
  SIGNAL addrBit10_12                     : std_logic;
  SIGNAL addrBit10_11                     : std_logic;
  SIGNAL addrBit10_10                     : std_logic;
  SIGNAL addrBit10_9                      : std_logic;
  SIGNAL addrBit10_8                      : std_logic;
  SIGNAL addrBit10_7                      : std_logic;
  SIGNAL addrBit10_6                      : std_logic;
  SIGNAL addrBit10_5                      : std_logic;
  SIGNAL addrBit10_4                      : std_logic;
  SIGNAL addrBit10_3                      : std_logic;
  SIGNAL addrBit10_2                      : std_logic;
  SIGNAL addrBit10_1                      : std_logic;
  SIGNAL rdAddr10_bitRev                  : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL rdData10_re                      : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL rdData10_re_signed               : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL minResRX2FFTMEMCtrl_cnt1         : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL minResRX2FFTMEMCtrl_cnt2         : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL minResRX2FFTMEMCtrl_cnt1LSB      : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL minResRX2FFTMEMCtrl_cnt2MSB      : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL minResRX2FFTMEMCtrl_IC           : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL minResRX2FFTMEMCtrl_initCnt      : std_logic;
  SIGNAL minResRX2FFTMEMCtrl_rdEnb2Dly    : std_logic;
  SIGNAL minResRX2FFTMEMCtrl_rdEnb3Dly    : std_logic;
  SIGNAL minResRX2FFTMEMCtrl_wrAddrReg23  : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL minResRX2FFTMEMCtrl_wrAddrReg1   : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL minResRX2FFTMEMCtrl_rdAddrReg1   : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL minResRX2FFTMEMCtrl_rdAddrReg23  : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL minResRX2FFTMEMCtrl_wrEnb01Reg   : std_logic;
  SIGNAL minResRX2FFTMEMCtrl_wrEnb10Reg   : std_logic;
  SIGNAL minResRX2FFTMEMCtrl_wrEnb11Reg   : std_logic;
  SIGNAL minResRX2FFTMEMCtrl_wrAddr1Dly   : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL minResRX2FFTMEMCtrl_wrAddr2Dly   : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL minResRX2FFTMEMCtrl_wrEnb1Dly    : std_logic;
  SIGNAL minResRX2FFTMEMCtrl_wrEnb2Dly    : std_logic;
  SIGNAL minResRX2FFTMEMCtrl_wrEnb3Dly    : std_logic;
  SIGNAL minResRX2FFTMEMCtrl_cnt1_next    : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL minResRX2FFTMEMCtrl_cnt2_next    : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL minResRX2FFTMEMCtrl_cnt1LSB_next : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL minResRX2FFTMEMCtrl_cnt2MSB_next : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL minResRX2FFTMEMCtrl_IC_next      : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL minResRX2FFTMEMCtrl_initCnt_next : std_logic;
  SIGNAL minResRX2FFTMEMCtrl_rdEnb2Dly_next : std_logic;
  SIGNAL minResRX2FFTMEMCtrl_rdEnb3Dly_next : std_logic;
  SIGNAL minResRX2FFTMEMCtrl_wrAddrReg23_next : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL minResRX2FFTMEMCtrl_wrAddrReg1_next : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL minResRX2FFTMEMCtrl_rdAddrReg1_next : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL minResRX2FFTMEMCtrl_rdAddrReg23_next : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL minResRX2FFTMEMCtrl_wrEnb01Reg_next : std_logic;
  SIGNAL minResRX2FFTMEMCtrl_wrEnb10Reg_next : std_logic;
  SIGNAL minResRX2FFTMEMCtrl_wrEnb11Reg_next : std_logic;
  SIGNAL minResRX2FFTMEMCtrl_wrAddr1Dly_next : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL minResRX2FFTMEMCtrl_wrAddr2Dly_next : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL minResRX2FFTMEMCtrl_wrEnb1Dly_next : std_logic;
  SIGNAL minResRX2FFTMEMCtrl_wrEnb2Dly_next : std_logic;
  SIGNAL minResRX2FFTMEMCtrl_wrEnb3Dly_next : std_logic;
  SIGNAL wrEnb01                          : std_logic;
  SIGNAL wrAddr01                         : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL rdAddr01_tmp                     : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL dMemOut2_re_tmp                  : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL dMemOut2_im_tmp                  : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL addrBit01_1                      : std_logic;
  SIGNAL addrBit01_2                      : std_logic;
  SIGNAL addrBit01_3                      : std_logic;
  SIGNAL addrBit01_4                      : std_logic;
  SIGNAL addrBit01_5                      : std_logic;
  SIGNAL addrBit01_6                      : std_logic;
  SIGNAL addrBit01_7                      : std_logic;
  SIGNAL addrBit01_8                      : std_logic;
  SIGNAL addrBit01_9                      : std_logic;
  SIGNAL addrBit01_10                     : std_logic;
  SIGNAL addrBit01_11                     : std_logic;
  SIGNAL addrBit01_12                     : std_logic;
  SIGNAL addrBit01_13                     : std_logic;
  SIGNAL addrBit01_14                     : std_logic;
  SIGNAL rdAddr01_bitRev                  : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL rdAddr01                         : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL dMemOut1_re_tmp                  : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL dMemIn1_im_signed                : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL intdelay_reg_5                   : vector_of_signed32(0 TO 1);  -- sfix32 [2]
  SIGNAL intdelay_reg_next_5              : vector_of_signed32(0 TO 1);  -- sfix32_En16 [2]
  SIGNAL wrData01Dly_im                   : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL dMemOut1_im_tmp                  : std_logic_vector(31 DOWNTO 0);  -- ufix32

BEGIN
  u_dataMEM_im_11 : SimpleDualPortRAM_generic
    GENERIC MAP( AddrWidth => 14,
                 DataWidth => 32
                 )
    PORT MAP( clk => clk,
              enb => enb,
              wr_din => std_logic_vector(wrData11Dly_im),
              wr_addr => std_logic_vector(wrAddr10),
              wr_en => wrEnb11,
              rd_addr => std_logic_vector(rdAddr10),
              rd_dout => rdData11_im
              );

  u_dataMEM_re_11 : SimpleDualPortRAM_generic
    GENERIC MAP( AddrWidth => 14,
                 DataWidth => 32
                 )
    PORT MAP( clk => clk,
              enb => enb,
              wr_din => std_logic_vector(wrData11Dly_re),
              wr_addr => std_logic_vector(wrAddr10),
              wr_en => wrEnb11,
              rd_addr => std_logic_vector(rdAddr10),
              rd_dout => rdData11_re
              );

  u_dataMEM_im_10 : SimpleDualPortRAM_generic
    GENERIC MAP( AddrWidth => 14,
                 DataWidth => 32
                 )
    PORT MAP( clk => clk,
              enb => enb,
              wr_din => std_logic_vector(wrData10Dly_im),
              wr_addr => std_logic_vector(wrAddr10),
              wr_en => wrEnb10,
              rd_addr => std_logic_vector(rdAddr10),
              rd_dout => rdData10_im
              );

  u_dataMEM_re_10 : SimpleDualPortRAM_generic
    GENERIC MAP( AddrWidth => 14,
                 DataWidth => 32
                 )
    PORT MAP( clk => clk,
              enb => enb,
              wr_din => std_logic_vector(wrData10Dly_re),
              wr_addr => std_logic_vector(wrAddr10),
              wr_en => wrEnb10,
              rd_addr => std_logic_vector(rdAddr10),
              rd_dout => rdData10_re
              );

  u_dataMEM_re_01_generic : SimpleDualPortRAM_generic
    GENERIC MAP( AddrWidth => 14,
                 DataWidth => 32
                 )
    PORT MAP( clk => clk,
              enb => enb,
              wr_din => std_logic_vector(wrData01Dly_re),
              wr_addr => std_logic_vector(wrAddr01),
              wr_en => wrEnb01,
              rd_addr => std_logic_vector(rdAddr01),
              rd_dout => dMemOut1_re_tmp
              );

  u_dataMEM_im_01 : SimpleDualPortRAM_generic
    GENERIC MAP( AddrWidth => 14,
                 DataWidth => 32
                 )
    PORT MAP( clk => clk,
              enb => enb,
              wr_din => std_logic_vector(wrData01Dly_im),
              wr_addr => std_logic_vector(wrAddr01),
              wr_en => wrEnb01,
              rd_addr => std_logic_vector(rdAddr01),
              rd_dout => dMemOut1_im_tmp
              );

  dMemIn1_re_signed <= signed(dMemIn1_re);

  intdelay_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      intdelay_reg(0) <= to_signed(0, 32);
      intdelay_reg(1) <= to_signed(0, 32);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        IF syncReset = '1' THEN
          intdelay_reg(0) <= to_signed(0, 32);
          intdelay_reg(1) <= to_signed(0, 32);
        ELSE 
          intdelay_reg(0) <= intdelay_reg_next(0);
          intdelay_reg(1) <= intdelay_reg_next(1);
        END IF;
      END IF;
    END IF;
  END PROCESS intdelay_process;

  wrData01Dly_re <= intdelay_reg(1);
  intdelay_reg_next(0) <= dMemIn1_re_signed;
  intdelay_reg_next(1) <= intdelay_reg(0);

  stage_unsigned <= unsigned(stage);

  dMemIn2_re_signed <= signed(dMemIn2_re);

  intdelay_1_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      intdelay_reg_1(0) <= to_signed(0, 32);
      intdelay_reg_1(1) <= to_signed(0, 32);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        IF syncReset = '1' THEN
          intdelay_reg_1(0) <= to_signed(0, 32);
          intdelay_reg_1(1) <= to_signed(0, 32);
        ELSE 
          intdelay_reg_1(0) <= intdelay_reg_next_1(0);
          intdelay_reg_1(1) <= intdelay_reg_next_1(1);
        END IF;
      END IF;
    END IF;
  END PROCESS intdelay_1_process;

  wrData10Dly_re <= intdelay_reg_1(1);
  intdelay_reg_next_1(0) <= dMemIn2_re_signed;
  intdelay_reg_next_1(1) <= intdelay_reg_1(0);

  dMemIn2_im_signed <= signed(dMemIn2_im);

  intdelay_2_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      intdelay_reg_2(0) <= to_signed(0, 32);
      intdelay_reg_2(1) <= to_signed(0, 32);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        IF syncReset = '1' THEN
          intdelay_reg_2(0) <= to_signed(0, 32);
          intdelay_reg_2(1) <= to_signed(0, 32);
        ELSE 
          intdelay_reg_2(0) <= intdelay_reg_next_2(0);
          intdelay_reg_2(1) <= intdelay_reg_next_2(1);
        END IF;
      END IF;
    END IF;
  END PROCESS intdelay_2_process;

  wrData10Dly_im <= intdelay_reg_2(1);
  intdelay_reg_next_2(0) <= dMemIn2_im_signed;
  intdelay_reg_next_2(1) <= intdelay_reg_2(0);

  intdelay_3_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      intdelay_reg_3(0) <= to_signed(0, 32);
      intdelay_reg_3(1) <= to_signed(0, 32);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        IF syncReset = '1' THEN
          intdelay_reg_3(0) <= to_signed(0, 32);
          intdelay_reg_3(1) <= to_signed(0, 32);
        ELSE 
          intdelay_reg_3(0) <= intdelay_reg_next_3(0);
          intdelay_reg_3(1) <= intdelay_reg_next_3(1);
        END IF;
      END IF;
    END IF;
  END PROCESS intdelay_3_process;

  wrData11Dly_re <= intdelay_reg_3(1);
  intdelay_reg_next_3(0) <= dMemIn2_re_signed;
  intdelay_reg_next_3(1) <= intdelay_reg_3(0);

  intdelay_4_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      intdelay_reg_4(0) <= to_signed(0, 32);
      intdelay_reg_4(1) <= to_signed(0, 32);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        IF syncReset = '1' THEN
          intdelay_reg_4(0) <= to_signed(0, 32);
          intdelay_reg_4(1) <= to_signed(0, 32);
        ELSE 
          intdelay_reg_4(0) <= intdelay_reg_next_4(0);
          intdelay_reg_4(1) <= intdelay_reg_next_4(1);
        END IF;
      END IF;
    END IF;
  END PROCESS intdelay_4_process;

  wrData11Dly_im <= intdelay_reg_4(1);
  intdelay_reg_next_4(0) <= dMemIn2_im_signed;
  intdelay_reg_next_4(1) <= intdelay_reg_4(0);

  rdData11_im_signed <= signed(rdData11_im);

  rdData11_re_signed <= signed(rdData11_re);

  rdData10_im_signed <= signed(rdData10_im);

  addrBit10_14 <= rdAddr10_tmp(13);

  addrBit10_13 <= rdAddr10_tmp(12);

  addrBit10_12 <= rdAddr10_tmp(11);

  addrBit10_11 <= rdAddr10_tmp(10);

  addrBit10_10 <= rdAddr10_tmp(9);

  addrBit10_9 <= rdAddr10_tmp(8);

  addrBit10_8 <= rdAddr10_tmp(7);

  addrBit10_7 <= rdAddr10_tmp(6);

  addrBit10_6 <= rdAddr10_tmp(5);

  addrBit10_5 <= rdAddr10_tmp(4);

  addrBit10_4 <= rdAddr10_tmp(3);

  addrBit10_3 <= rdAddr10_tmp(2);

  addrBit10_2 <= rdAddr10_tmp(1);

  addrBit10_1 <= rdAddr10_tmp(0);

  rdAddr10_bitRev <= unsigned'(addrBit10_1 & addrBit10_2 & addrBit10_3 & addrBit10_4 & addrBit10_5 & addrBit10_6 & addrBit10_7 & addrBit10_8 & addrBit10_9 & addrBit10_10 & addrBit10_11 & addrBit10_12 & addrBit10_13 & addrBit10_14);

  
  rdAddr10 <= rdAddr10_tmp WHEN unLoadPhase = '0' ELSE
      rdAddr10_bitRev;

  rdData10_re_signed <= signed(rdData10_re);

  -- minResRX2FFTMEMCtrl
  minResRX2FFTMEMCtrl_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      minResRX2FFTMEMCtrl_cnt1 <= to_unsigned(16#0000#, 14);
      minResRX2FFTMEMCtrl_cnt2 <= to_unsigned(16#0000#, 14);
      minResRX2FFTMEMCtrl_cnt1LSB <= to_unsigned(16#0000#, 14);
      minResRX2FFTMEMCtrl_cnt2MSB <= to_unsigned(16#0000#, 14);
      minResRX2FFTMEMCtrl_wrAddrReg23 <= to_unsigned(16#0000#, 14);
      minResRX2FFTMEMCtrl_wrAddrReg1 <= to_unsigned(16#0000#, 14);
      minResRX2FFTMEMCtrl_wrAddr1Dly <= to_unsigned(16#0000#, 14);
      minResRX2FFTMEMCtrl_wrAddr2Dly <= to_unsigned(16#0000#, 14);
      minResRX2FFTMEMCtrl_rdAddrReg23 <= to_unsigned(16#0000#, 14);
      minResRX2FFTMEMCtrl_rdAddrReg1 <= to_unsigned(16#0000#, 14);
      minResRX2FFTMEMCtrl_IC <= to_unsigned(16#0000#, 14);
      minResRX2FFTMEMCtrl_wrEnb01Reg <= '0';
      minResRX2FFTMEMCtrl_wrEnb10Reg <= '0';
      minResRX2FFTMEMCtrl_wrEnb11Reg <= '0';
      minResRX2FFTMEMCtrl_wrEnb1Dly <= '0';
      minResRX2FFTMEMCtrl_wrEnb2Dly <= '0';
      minResRX2FFTMEMCtrl_wrEnb3Dly <= '0';
      minResRX2FFTMEMCtrl_initCnt <= '0';
      minResRX2FFTMEMCtrl_rdEnb2Dly <= '0';
      minResRX2FFTMEMCtrl_rdEnb3Dly <= '0';
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        IF syncReset = '1' THEN
          minResRX2FFTMEMCtrl_cnt1 <= to_unsigned(16#0000#, 14);
          minResRX2FFTMEMCtrl_cnt2 <= to_unsigned(16#0000#, 14);
          minResRX2FFTMEMCtrl_cnt1LSB <= to_unsigned(16#0000#, 14);
          minResRX2FFTMEMCtrl_cnt2MSB <= to_unsigned(16#0000#, 14);
          minResRX2FFTMEMCtrl_wrAddrReg23 <= to_unsigned(16#0000#, 14);
          minResRX2FFTMEMCtrl_wrAddrReg1 <= to_unsigned(16#0000#, 14);
          minResRX2FFTMEMCtrl_wrAddr1Dly <= to_unsigned(16#0000#, 14);
          minResRX2FFTMEMCtrl_wrAddr2Dly <= to_unsigned(16#0000#, 14);
          minResRX2FFTMEMCtrl_rdAddrReg23 <= to_unsigned(16#0000#, 14);
          minResRX2FFTMEMCtrl_rdAddrReg1 <= to_unsigned(16#0000#, 14);
          minResRX2FFTMEMCtrl_IC <= to_unsigned(16#0000#, 14);
          minResRX2FFTMEMCtrl_wrEnb01Reg <= '0';
          minResRX2FFTMEMCtrl_wrEnb10Reg <= '0';
          minResRX2FFTMEMCtrl_wrEnb11Reg <= '0';
          minResRX2FFTMEMCtrl_wrEnb1Dly <= '0';
          minResRX2FFTMEMCtrl_wrEnb2Dly <= '0';
          minResRX2FFTMEMCtrl_wrEnb3Dly <= '0';
          minResRX2FFTMEMCtrl_initCnt <= '0';
          minResRX2FFTMEMCtrl_rdEnb2Dly <= '0';
          minResRX2FFTMEMCtrl_rdEnb3Dly <= '0';
        ELSE 
          minResRX2FFTMEMCtrl_cnt1 <= minResRX2FFTMEMCtrl_cnt1_next;
          minResRX2FFTMEMCtrl_cnt2 <= minResRX2FFTMEMCtrl_cnt2_next;
          minResRX2FFTMEMCtrl_cnt1LSB <= minResRX2FFTMEMCtrl_cnt1LSB_next;
          minResRX2FFTMEMCtrl_cnt2MSB <= minResRX2FFTMEMCtrl_cnt2MSB_next;
          minResRX2FFTMEMCtrl_IC <= minResRX2FFTMEMCtrl_IC_next;
          minResRX2FFTMEMCtrl_initCnt <= minResRX2FFTMEMCtrl_initCnt_next;
          minResRX2FFTMEMCtrl_rdEnb2Dly <= minResRX2FFTMEMCtrl_rdEnb2Dly_next;
          minResRX2FFTMEMCtrl_rdEnb3Dly <= minResRX2FFTMEMCtrl_rdEnb3Dly_next;
          minResRX2FFTMEMCtrl_wrAddrReg23 <= minResRX2FFTMEMCtrl_wrAddrReg23_next;
          minResRX2FFTMEMCtrl_wrAddrReg1 <= minResRX2FFTMEMCtrl_wrAddrReg1_next;
          minResRX2FFTMEMCtrl_rdAddrReg1 <= minResRX2FFTMEMCtrl_rdAddrReg1_next;
          minResRX2FFTMEMCtrl_rdAddrReg23 <= minResRX2FFTMEMCtrl_rdAddrReg23_next;
          minResRX2FFTMEMCtrl_wrEnb01Reg <= minResRX2FFTMEMCtrl_wrEnb01Reg_next;
          minResRX2FFTMEMCtrl_wrEnb10Reg <= minResRX2FFTMEMCtrl_wrEnb10Reg_next;
          minResRX2FFTMEMCtrl_wrEnb11Reg <= minResRX2FFTMEMCtrl_wrEnb11Reg_next;
          minResRX2FFTMEMCtrl_wrAddr1Dly <= minResRX2FFTMEMCtrl_wrAddr1Dly_next;
          minResRX2FFTMEMCtrl_wrAddr2Dly <= minResRX2FFTMEMCtrl_wrAddr2Dly_next;
          minResRX2FFTMEMCtrl_wrEnb1Dly <= minResRX2FFTMEMCtrl_wrEnb1Dly_next;
          minResRX2FFTMEMCtrl_wrEnb2Dly <= minResRX2FFTMEMCtrl_wrEnb2Dly_next;
          minResRX2FFTMEMCtrl_wrEnb3Dly <= minResRX2FFTMEMCtrl_wrEnb3Dly_next;
        END IF;
      END IF;
    END IF;
  END PROCESS minResRX2FFTMEMCtrl_process;

  minResRX2FFTMEMCtrl_output : PROCESS (initIC, minResRX2FFTMEMCtrl_IC, minResRX2FFTMEMCtrl_cnt1,
       minResRX2FFTMEMCtrl_cnt1LSB, minResRX2FFTMEMCtrl_cnt2,
       minResRX2FFTMEMCtrl_cnt2MSB, minResRX2FFTMEMCtrl_initCnt,
       minResRX2FFTMEMCtrl_rdAddrReg1, minResRX2FFTMEMCtrl_rdAddrReg23,
       minResRX2FFTMEMCtrl_rdEnb2Dly, minResRX2FFTMEMCtrl_rdEnb3Dly,
       minResRX2FFTMEMCtrl_wrAddr1Dly, minResRX2FFTMEMCtrl_wrAddr2Dly,
       minResRX2FFTMEMCtrl_wrAddrReg1, minResRX2FFTMEMCtrl_wrAddrReg23,
       minResRX2FFTMEMCtrl_wrEnb01Reg, minResRX2FFTMEMCtrl_wrEnb10Reg,
       minResRX2FFTMEMCtrl_wrEnb11Reg, minResRX2FFTMEMCtrl_wrEnb1Dly,
       minResRX2FFTMEMCtrl_wrEnb2Dly, minResRX2FFTMEMCtrl_wrEnb3Dly,
       rdData10_im_signed, rdData10_re_signed, rdData11_im_signed,
       rdData11_re_signed, rdEnb1, rdEnb2, rdEnb3, stage_unsigned, wrEnb1,
       wrEnb2, wrEnb3)
  BEGIN
    minResRX2FFTMEMCtrl_cnt1_next <= minResRX2FFTMEMCtrl_cnt1;
    minResRX2FFTMEMCtrl_cnt2_next <= minResRX2FFTMEMCtrl_cnt2;
    minResRX2FFTMEMCtrl_IC_next <= minResRX2FFTMEMCtrl_IC;
    minResRX2FFTMEMCtrl_wrAddrReg23_next <= minResRX2FFTMEMCtrl_wrAddrReg23;
    minResRX2FFTMEMCtrl_wrAddrReg1_next <= minResRX2FFTMEMCtrl_wrAddrReg1;
    minResRX2FFTMEMCtrl_rdAddrReg1_next <= minResRX2FFTMEMCtrl_rdAddrReg1;
    minResRX2FFTMEMCtrl_rdAddrReg23_next <= minResRX2FFTMEMCtrl_rdAddrReg23;
    minResRX2FFTMEMCtrl_wrAddr2Dly_next <= minResRX2FFTMEMCtrl_wrAddr1Dly;
    minResRX2FFTMEMCtrl_wrEnb01Reg_next <= minResRX2FFTMEMCtrl_wrEnb1Dly;
    minResRX2FFTMEMCtrl_wrEnb1Dly_next <= wrEnb1;
    minResRX2FFTMEMCtrl_wrEnb10Reg_next <= minResRX2FFTMEMCtrl_wrEnb2Dly;
    minResRX2FFTMEMCtrl_wrEnb2Dly_next <= wrEnb2;
    minResRX2FFTMEMCtrl_wrEnb11Reg_next <= minResRX2FFTMEMCtrl_wrEnb3Dly;
    minResRX2FFTMEMCtrl_wrEnb3Dly_next <= wrEnb3;
    IF minResRX2FFTMEMCtrl_rdEnb2Dly = '1' THEN 
      dMemOut2_re_tmp <= rdData10_re_signed;
      dMemOut2_im_tmp <= rdData10_im_signed;
    ELSIF minResRX2FFTMEMCtrl_rdEnb3Dly = '1' THEN 
      dMemOut2_re_tmp <= rdData11_re_signed;
      dMemOut2_im_tmp <= rdData11_im_signed;
    ELSE 
      dMemOut2_re_tmp <= to_signed(0, 32);
      dMemOut2_im_tmp <= to_signed(0, 32);
    END IF;
    minResRX2FFTMEMCtrl_rdEnb2Dly_next <= rdEnb2;
    minResRX2FFTMEMCtrl_rdEnb3Dly_next <= rdEnb3;
    IF rdEnb1 = '1' THEN 
      minResRX2FFTMEMCtrl_rdAddrReg1_next <= minResRX2FFTMEMCtrl_rdAddrReg1 + to_unsigned(16#0001#, 14);
    END IF;
    IF (rdEnb2 OR rdEnb3) = '1' THEN 
      minResRX2FFTMEMCtrl_rdAddrReg23_next <= minResRX2FFTMEMCtrl_rdAddrReg23 + to_unsigned(16#0001#, 14);
    END IF;
    CASE stage_unsigned IS
      WHEN "0000" =>
        minResRX2FFTMEMCtrl_wrAddrReg23_next <= minResRX2FFTMEMCtrl_cnt1LSB;
      WHEN "0001" =>
        minResRX2FFTMEMCtrl_wrAddrReg23_next <= minResRX2FFTMEMCtrl_cnt2MSB(13) & minResRX2FFTMEMCtrl_cnt1LSB(12 DOWNTO 0);
      WHEN "0010" =>
        minResRX2FFTMEMCtrl_wrAddrReg23_next <= minResRX2FFTMEMCtrl_cnt2MSB(13 DOWNTO 12) & minResRX2FFTMEMCtrl_cnt1LSB(11 DOWNTO 0);
      WHEN "0011" =>
        minResRX2FFTMEMCtrl_wrAddrReg23_next <= minResRX2FFTMEMCtrl_cnt2MSB(13 DOWNTO 11) & minResRX2FFTMEMCtrl_cnt1LSB(10 DOWNTO 0);
      WHEN "0100" =>
        minResRX2FFTMEMCtrl_wrAddrReg23_next <= minResRX2FFTMEMCtrl_cnt2MSB(13 DOWNTO 10) & minResRX2FFTMEMCtrl_cnt1LSB(9 DOWNTO 0);
      WHEN "0101" =>
        minResRX2FFTMEMCtrl_wrAddrReg23_next <= minResRX2FFTMEMCtrl_cnt2MSB(13 DOWNTO 9) & minResRX2FFTMEMCtrl_cnt1LSB(8 DOWNTO 0);
      WHEN "0110" =>
        minResRX2FFTMEMCtrl_wrAddrReg23_next <= minResRX2FFTMEMCtrl_cnt2MSB(13 DOWNTO 8) & minResRX2FFTMEMCtrl_cnt1LSB(7 DOWNTO 0);
      WHEN "0111" =>
        minResRX2FFTMEMCtrl_wrAddrReg23_next <= minResRX2FFTMEMCtrl_cnt2MSB(13 DOWNTO 7) & minResRX2FFTMEMCtrl_cnt1LSB(6 DOWNTO 0);
      WHEN "1000" =>
        minResRX2FFTMEMCtrl_wrAddrReg23_next <= minResRX2FFTMEMCtrl_cnt2MSB(13 DOWNTO 6) & minResRX2FFTMEMCtrl_cnt1LSB(5 DOWNTO 0);
      WHEN "1001" =>
        minResRX2FFTMEMCtrl_wrAddrReg23_next <= minResRX2FFTMEMCtrl_cnt2MSB(13 DOWNTO 5) & minResRX2FFTMEMCtrl_cnt1LSB(4 DOWNTO 0);
      WHEN "1010" =>
        minResRX2FFTMEMCtrl_wrAddrReg23_next <= minResRX2FFTMEMCtrl_cnt2MSB(13 DOWNTO 4) & minResRX2FFTMEMCtrl_cnt1LSB(3 DOWNTO 0);
      WHEN "1011" =>
        minResRX2FFTMEMCtrl_wrAddrReg23_next <= minResRX2FFTMEMCtrl_cnt2MSB(13 DOWNTO 3) & minResRX2FFTMEMCtrl_cnt1LSB(2 DOWNTO 0);
      WHEN "1100" =>
        minResRX2FFTMEMCtrl_wrAddrReg23_next <= minResRX2FFTMEMCtrl_cnt2MSB(13 DOWNTO 2) & minResRX2FFTMEMCtrl_cnt1LSB(1 DOWNTO 0);
      WHEN "1101" =>
        minResRX2FFTMEMCtrl_wrAddrReg23_next <= minResRX2FFTMEMCtrl_cnt2MSB(13 DOWNTO 1) & minResRX2FFTMEMCtrl_cnt1LSB(0);
      WHEN "1110" =>
        minResRX2FFTMEMCtrl_wrAddrReg23_next <= minResRX2FFTMEMCtrl_cnt2MSB;
      WHEN OTHERS => 
        minResRX2FFTMEMCtrl_wrAddrReg23_next <= to_unsigned(16#0000#, 14);
    END CASE;
    minResRX2FFTMEMCtrl_cnt1LSB_next <= minResRX2FFTMEMCtrl_cnt1;
    minResRX2FFTMEMCtrl_cnt2MSB_next <= minResRX2FFTMEMCtrl_cnt2;
    minResRX2FFTMEMCtrl_wrAddr1Dly_next <= minResRX2FFTMEMCtrl_wrAddrReg1;
    IF wrEnb1 = '1' THEN 
      minResRX2FFTMEMCtrl_wrAddrReg1_next <= minResRX2FFTMEMCtrl_wrAddrReg1 + to_unsigned(16#0001#, 14);
    END IF;
    IF minResRX2FFTMEMCtrl_initCnt = '1' THEN 
      minResRX2FFTMEMCtrl_cnt1_next <= minResRX2FFTMEMCtrl_IC;
      minResRX2FFTMEMCtrl_cnt2_next <= to_unsigned(16#0000#, 14);
    ELSIF (wrEnb2 OR wrEnb3) = '1' THEN 
      minResRX2FFTMEMCtrl_cnt1_next <= minResRX2FFTMEMCtrl_cnt1 + to_unsigned(16#0001#, 14);
      minResRX2FFTMEMCtrl_cnt2_next <= minResRX2FFTMEMCtrl_cnt2 + to_unsigned(16#0001#, 14);
    END IF;
    IF initIC = '1' THEN 
      CASE stage_unsigned IS
        WHEN "0000" =>
          minResRX2FFTMEMCtrl_IC_next <= to_unsigned(16#2000#, 14);
        WHEN OTHERS => 
          minResRX2FFTMEMCtrl_IC_next <= minResRX2FFTMEMCtrl_IC srl 1;
      END CASE;
    END IF;
    minResRX2FFTMEMCtrl_initCnt_next <= initIC;
    wrEnb01 <= minResRX2FFTMEMCtrl_wrEnb01Reg;
    wrEnb10 <= minResRX2FFTMEMCtrl_wrEnb10Reg;
    wrEnb11 <= minResRX2FFTMEMCtrl_wrEnb11Reg;
    wrAddr01 <= minResRX2FFTMEMCtrl_wrAddr2Dly;
    wrAddr10 <= minResRX2FFTMEMCtrl_wrAddrReg23;
    rdAddr01_tmp <= minResRX2FFTMEMCtrl_rdAddrReg1;
    rdAddr10_tmp <= minResRX2FFTMEMCtrl_rdAddrReg23;
  END PROCESS minResRX2FFTMEMCtrl_output;


  addrBit01_1 <= rdAddr01_tmp(0);

  addrBit01_2 <= rdAddr01_tmp(1);

  addrBit01_3 <= rdAddr01_tmp(2);

  addrBit01_4 <= rdAddr01_tmp(3);

  addrBit01_5 <= rdAddr01_tmp(4);

  addrBit01_6 <= rdAddr01_tmp(5);

  addrBit01_7 <= rdAddr01_tmp(6);

  addrBit01_8 <= rdAddr01_tmp(7);

  addrBit01_9 <= rdAddr01_tmp(8);

  addrBit01_10 <= rdAddr01_tmp(9);

  addrBit01_11 <= rdAddr01_tmp(10);

  addrBit01_12 <= rdAddr01_tmp(11);

  addrBit01_13 <= rdAddr01_tmp(12);

  addrBit01_14 <= rdAddr01_tmp(13);

  rdAddr01_bitRev <= unsigned'(addrBit01_1 & addrBit01_2 & addrBit01_3 & addrBit01_4 & addrBit01_5 & addrBit01_6 & addrBit01_7 & addrBit01_8 & addrBit01_9 & addrBit01_10 & addrBit01_11 & addrBit01_12 & addrBit01_13 & addrBit01_14);

  
  rdAddr01 <= rdAddr01_tmp WHEN unLoadPhase = '0' ELSE
      rdAddr01_bitRev;

  dMemIn1_im_signed <= signed(dMemIn1_im);

  intdelay_5_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      intdelay_reg_5(0) <= to_signed(0, 32);
      intdelay_reg_5(1) <= to_signed(0, 32);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        IF syncReset = '1' THEN
          intdelay_reg_5(0) <= to_signed(0, 32);
          intdelay_reg_5(1) <= to_signed(0, 32);
        ELSE 
          intdelay_reg_5(0) <= intdelay_reg_next_5(0);
          intdelay_reg_5(1) <= intdelay_reg_next_5(1);
        END IF;
      END IF;
    END IF;
  END PROCESS intdelay_5_process;

  wrData01Dly_im <= intdelay_reg_5(1);
  intdelay_reg_next_5(0) <= dMemIn1_im_signed;
  intdelay_reg_next_5(1) <= intdelay_reg_5(0);

  dMemOut2_re <= std_logic_vector(dMemOut2_re_tmp);

  dMemOut2_im <= std_logic_vector(dMemOut2_im_tmp);

  dMemOut1_re <= dMemOut1_re_tmp;

  dMemOut1_im <= dMemOut1_im_tmp;

END rtl;

