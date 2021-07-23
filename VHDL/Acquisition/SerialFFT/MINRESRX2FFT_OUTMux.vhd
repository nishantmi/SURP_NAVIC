
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY MINRESRX2FFT_OUTMux IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        enb                               :   IN    std_logic;
        rdEnb1                            :   IN    std_logic;
        rdEnb2                            :   IN    std_logic;
        rdEnb3                            :   IN    std_logic;
        dMemOut1_re                       :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        dMemOut1_im                       :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        dMemOut2_re                       :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        dMemOut2_im                       :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        vldOut                            :   IN    std_logic;
        syncReset                         :   IN    std_logic;
        dOut_re                           :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        dOut_im                           :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        dout_vld                          :   OUT   std_logic
        );
END MINRESRX2FFT_OUTMux;


ARCHITECTURE rtl OF MINRESRX2FFT_OUTMux IS

  -- Signals
  SIGNAL dMemOut1_re_signed               : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL dMemOut1_im_signed               : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL dMemOut2_re_signed               : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL dMemOut2_im_signed               : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL minResRX2FFTOutMux_doutReg_re    : signed(31 DOWNTO 0);  -- sfix32
  SIGNAL minResRX2FFTOutMux_doutReg_im    : signed(31 DOWNTO 0);  -- sfix32
  SIGNAL minResRX2FFTOutMux_doutReg_vld   : std_logic;
  SIGNAL minResRX2FFTOutMux_rdEnb1Dly     : std_logic;
  SIGNAL minResRX2FFTOutMux_rdEnb2Dly     : std_logic;
  SIGNAL minResRX2FFTOutMux_rdEnb3Dly     : std_logic;
  SIGNAL minResRX2FFTOutMux_doutReg_re_next : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL minResRX2FFTOutMux_doutReg_im_next : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL minResRX2FFTOutMux_doutReg_vld_next : std_logic;
  SIGNAL minResRX2FFTOutMux_rdEnb1Dly_next : std_logic;
  SIGNAL minResRX2FFTOutMux_rdEnb2Dly_next : std_logic;
  SIGNAL minResRX2FFTOutMux_rdEnb3Dly_next : std_logic;
  SIGNAL dOut_re_tmp                      : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL dOut_im_tmp                      : signed(31 DOWNTO 0);  -- sfix32_En16

BEGIN
  dMemOut1_re_signed <= signed(dMemOut1_re);

  dMemOut1_im_signed <= signed(dMemOut1_im);

  dMemOut2_re_signed <= signed(dMemOut2_re);

  dMemOut2_im_signed <= signed(dMemOut2_im);

  -- minResRX2FFTOutMux
  minResRX2FFTOutMux_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      minResRX2FFTOutMux_doutReg_re <= to_signed(0, 32);
      minResRX2FFTOutMux_doutReg_im <= to_signed(0, 32);
      minResRX2FFTOutMux_doutReg_vld <= '0';
      minResRX2FFTOutMux_rdEnb1Dly <= '0';
      minResRX2FFTOutMux_rdEnb2Dly <= '0';
      minResRX2FFTOutMux_rdEnb3Dly <= '0';
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        IF syncReset = '1' THEN
          minResRX2FFTOutMux_doutReg_re <= to_signed(0, 32);
          minResRX2FFTOutMux_doutReg_im <= to_signed(0, 32);
          minResRX2FFTOutMux_doutReg_vld <= '0';
          minResRX2FFTOutMux_rdEnb1Dly <= '0';
          minResRX2FFTOutMux_rdEnb2Dly <= '0';
          minResRX2FFTOutMux_rdEnb3Dly <= '0';
        ELSE 
          minResRX2FFTOutMux_doutReg_re <= minResRX2FFTOutMux_doutReg_re_next;
          minResRX2FFTOutMux_doutReg_im <= minResRX2FFTOutMux_doutReg_im_next;
          minResRX2FFTOutMux_doutReg_vld <= minResRX2FFTOutMux_doutReg_vld_next;
          minResRX2FFTOutMux_rdEnb1Dly <= minResRX2FFTOutMux_rdEnb1Dly_next;
          minResRX2FFTOutMux_rdEnb2Dly <= minResRX2FFTOutMux_rdEnb2Dly_next;
          minResRX2FFTOutMux_rdEnb3Dly <= minResRX2FFTOutMux_rdEnb3Dly_next;
        END IF;
      END IF;
    END IF;
  END PROCESS minResRX2FFTOutMux_process;

  minResRX2FFTOutMux_output : PROCESS (dMemOut1_im_signed, dMemOut1_re_signed, dMemOut2_im_signed, dMemOut2_re_signed,
       minResRX2FFTOutMux_doutReg_im, minResRX2FFTOutMux_doutReg_re,
       minResRX2FFTOutMux_doutReg_vld, minResRX2FFTOutMux_rdEnb1Dly,
       minResRX2FFTOutMux_rdEnb2Dly, minResRX2FFTOutMux_rdEnb3Dly, rdEnb1,
       rdEnb2, rdEnb3, vldOut)
  BEGIN
    minResRX2FFTOutMux_doutReg_re_next <= minResRX2FFTOutMux_doutReg_re;
    minResRX2FFTOutMux_doutReg_im_next <= minResRX2FFTOutMux_doutReg_im;
    minResRX2FFTOutMux_doutReg_vld_next <= minResRX2FFTOutMux_doutReg_vld;
    IF vldOut = '1' THEN 
      minResRX2FFTOutMux_doutReg_vld_next <= '1';
      IF (minResRX2FFTOutMux_rdEnb2Dly OR minResRX2FFTOutMux_rdEnb3Dly) = '1' THEN 
        minResRX2FFTOutMux_doutReg_re_next <= dMemOut2_re_signed;
        minResRX2FFTOutMux_doutReg_im_next <= dMemOut2_im_signed;
      ELSIF minResRX2FFTOutMux_rdEnb1Dly = '1' THEN 
        minResRX2FFTOutMux_doutReg_re_next <= dMemOut1_re_signed;
        minResRX2FFTOutMux_doutReg_im_next <= dMemOut1_im_signed;
      ELSE 
        minResRX2FFTOutMux_doutReg_vld_next <= '0';
      END IF;
    ELSE 
      minResRX2FFTOutMux_doutReg_vld_next <= '0';
    END IF;
    minResRX2FFTOutMux_rdEnb1Dly_next <= rdEnb1;
    minResRX2FFTOutMux_rdEnb2Dly_next <= rdEnb2;
    minResRX2FFTOutMux_rdEnb3Dly_next <= rdEnb3;
    dOut_re_tmp <= minResRX2FFTOutMux_doutReg_re;
    dOut_im_tmp <= minResRX2FFTOutMux_doutReg_im;
    dout_vld <= minResRX2FFTOutMux_doutReg_vld;
  END PROCESS minResRX2FFTOutMux_output;


  dOut_re <= std_logic_vector(dOut_re_tmp);

  dOut_im <= std_logic_vector(dOut_im_tmp);

END rtl;

