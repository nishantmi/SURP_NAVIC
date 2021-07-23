
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.CRFFT_pkg.ALL;

ENTITY MINRESRX2_BUTTERFLY IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        enb                               :   IN    std_logic;
        btfIn1_re                         :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        btfIn1_im                         :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        btfIn2_re                         :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        btfIn2_im                         :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        btfIn_vld                         :   IN    std_logic;
        twdl_re                           :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En30
        twdl_im                           :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En30
        syncReset                         :   IN    std_logic;
        btfOut1_re                        :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        btfOut1_im                        :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        btfOut2_re                        :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        btfOut2_im                        :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        btfOut_vld                        :   OUT   std_logic
        );
END MINRESRX2_BUTTERFLY;


ARCHITECTURE rtl OF MINRESRX2_BUTTERFLY IS

  -- Component Declarations
  COMPONENT Complex4Multiply
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb                             :   IN    std_logic;
          btfIn2_re                       :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          btfIn2_im                       :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          din2Dly_vld                     :   IN    std_logic;
          twdl_re                         :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En30
          twdl_im                         :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En30
          syncReset                       :   IN    std_logic;
          dinXTwdl_re                     :   OUT   std_logic_vector(64 DOWNTO 0);  -- sfix65_En46
          dinXTwdl_im                     :   OUT   std_logic_vector(64 DOWNTO 0);  -- sfix65_En46
          dinXTwdl_vld                    :   OUT   std_logic
          );
  END COMPONENT;

  -- Component Configuration Statements
  FOR ALL : Complex4Multiply
    USE ENTITY work.Complex4Multiply(rtl);

  -- Signals
  SIGNAL btfIn2_re_signed                 : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL btfIn2_im_signed                 : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL intdelay_reg                     : vector_of_signed32(0 TO 1);  -- sfix32 [2]
  SIGNAL intdelay_reg_next                : vector_of_signed32(0 TO 1);  -- sfix32_En16 [2]
  SIGNAL din2Dly_re                       : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL intdelay_reg_1                   : vector_of_signed32(0 TO 1);  -- sfix32 [2]
  SIGNAL intdelay_reg_next_1              : vector_of_signed32(0 TO 1);  -- sfix32_En16 [2]
  SIGNAL din2Dly_im                       : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL dinXTwdl_re                      : std_logic_vector(64 DOWNTO 0);  -- ufix65
  SIGNAL dinXTwdl_im                      : std_logic_vector(64 DOWNTO 0);  -- ufix65
  SIGNAL dinXTwdl_vld                     : std_logic;
  SIGNAL dinXTwdl_re_signed               : signed(64 DOWNTO 0);  -- sfix65_En46
  SIGNAL dinXTwdl_im_signed               : signed(64 DOWNTO 0);  -- sfix65_En46
  SIGNAL btfIn1_re_signed                 : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL intdelay_reg_2                   : vector_of_signed32(0 TO 7);  -- sfix32 [8]
  SIGNAL intdelay_reg_next_2              : vector_of_signed32(0 TO 7);  -- sfix32_En16 [8]
  SIGNAL din1Dly_re                       : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL btfIn1_im_signed                 : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL intdelay_reg_3                   : vector_of_signed32(0 TO 7);  -- sfix32 [8]
  SIGNAL intdelay_reg_next_3              : vector_of_signed32(0 TO 7);  -- sfix32_En16 [8]
  SIGNAL din1Dly_im                       : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL intdelay_reg_4                   : std_logic_vector(0 TO 7);  -- ufix1 [8]
  SIGNAL intdelay_reg_next_4              : std_logic_vector(0 TO 7);  -- ufix1 [8]
  SIGNAL din1Dly_vld                      : std_logic;
  SIGNAL minResRX2FFTButterfly_add1_re    : signed(65 DOWNTO 0);  -- sfix66
  SIGNAL minResRX2FFTButterfly_add1_im    : signed(65 DOWNTO 0);  -- sfix66
  SIGNAL minResRX2FFTButterfly_sub1_re    : signed(65 DOWNTO 0);  -- sfix66
  SIGNAL minResRX2FFTButterfly_sub1_im    : signed(65 DOWNTO 0);  -- sfix66
  SIGNAL minResRX2FFTButterfly_vld_reg    : std_logic;
  SIGNAL minResRX2FFTButterfly_add1_cast_re : signed(65 DOWNTO 0);  -- sfix66
  SIGNAL minResRX2FFTButterfly_add1_cast_im : signed(65 DOWNTO 0);  -- sfix66
  SIGNAL minResRX2FFTButterfly_sub1_cast_re : signed(65 DOWNTO 0);  -- sfix66
  SIGNAL minResRX2FFTButterfly_sub1_cast_im : signed(65 DOWNTO 0);  -- sfix66
  SIGNAL minResRX2FFTButterfly_add1_re_next : signed(65 DOWNTO 0);  -- sfix66_En46
  SIGNAL minResRX2FFTButterfly_add1_im_next : signed(65 DOWNTO 0);  -- sfix66_En46
  SIGNAL minResRX2FFTButterfly_sub1_re_next : signed(65 DOWNTO 0);  -- sfix66_En46
  SIGNAL minResRX2FFTButterfly_sub1_im_next : signed(65 DOWNTO 0);  -- sfix66_En46
  SIGNAL minResRX2FFTButterfly_add1_cast_re_next : signed(65 DOWNTO 0);  -- sfix66_En46
  SIGNAL minResRX2FFTButterfly_add1_cast_im_next : signed(65 DOWNTO 0);  -- sfix66_En46
  SIGNAL minResRX2FFTButterfly_sub1_cast_re_next : signed(65 DOWNTO 0);  -- sfix66_En46
  SIGNAL minResRX2FFTButterfly_sub1_cast_im_next : signed(65 DOWNTO 0);  -- sfix66_En46
  SIGNAL minResRX2FFTButterfly_add_cast   : signed(65 DOWNTO 0);  -- sfix66_En46
  SIGNAL minResRX2FFTButterfly_add_cast_1 : signed(65 DOWNTO 0);  -- sfix66_En46
  SIGNAL minResRX2FFTButterfly_add_cast_2 : signed(65 DOWNTO 0);  -- sfix66_En46
  SIGNAL minResRX2FFTButterfly_add_cast_3 : signed(65 DOWNTO 0);  -- sfix66_En46
  SIGNAL minResRX2FFTButterfly_sub_cast   : signed(65 DOWNTO 0);  -- sfix66_En46
  SIGNAL minResRX2FFTButterfly_sub_cast_1 : signed(65 DOWNTO 0);  -- sfix66_En46
  SIGNAL minResRX2FFTButterfly_sub_cast_2 : signed(65 DOWNTO 0);  -- sfix66_En46
  SIGNAL minResRX2FFTButterfly_sub_cast_3 : signed(65 DOWNTO 0);  -- sfix66_En46
  SIGNAL btfOut1FP_re                     : signed(65 DOWNTO 0);  -- sfix66_En46
  SIGNAL btfOut1FP_im                     : signed(65 DOWNTO 0);  -- sfix66_En46
  SIGNAL btfOut2FP_re                     : signed(65 DOWNTO 0);  -- sfix66_En46
  SIGNAL btfOut2FP_im                     : signed(65 DOWNTO 0);  -- sfix66_En46
  SIGNAL btfOut1_re_tmp                   : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL btfOut1_im_tmp                   : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL btfOut2_re_tmp                   : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL btfOut2_im_tmp                   : signed(31 DOWNTO 0);  -- sfix32_En16

BEGIN
  u_MUL4 : Complex4Multiply
    PORT MAP( clk => clk,
              reset => reset,
              enb => enb,
              btfIn2_re => std_logic_vector(din2Dly_re),  -- sfix32_En16
              btfIn2_im => std_logic_vector(din2Dly_im),  -- sfix32_En16
              din2Dly_vld => btfIn_vld,
              twdl_re => twdl_re,  -- sfix32_En30
              twdl_im => twdl_im,  -- sfix32_En30
              syncReset => syncReset,
              dinXTwdl_re => dinXTwdl_re,  -- sfix65_En46
              dinXTwdl_im => dinXTwdl_im,  -- sfix65_En46
              dinXTwdl_vld => dinXTwdl_vld
              );

  btfIn2_re_signed <= signed(btfIn2_re);

  btfIn2_im_signed <= signed(btfIn2_im);

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

  din2Dly_re <= intdelay_reg(1);
  intdelay_reg_next(0) <= btfIn2_re_signed;
  intdelay_reg_next(1) <= intdelay_reg(0);

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

  din2Dly_im <= intdelay_reg_1(1);
  intdelay_reg_next_1(0) <= btfIn2_im_signed;
  intdelay_reg_next_1(1) <= intdelay_reg_1(0);

  dinXTwdl_re_signed <= signed(dinXTwdl_re);

  dinXTwdl_im_signed <= signed(dinXTwdl_im);

  btfIn1_re_signed <= signed(btfIn1_re);

  intdelay_2_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      intdelay_reg_2(0) <= to_signed(0, 32);
      intdelay_reg_2(1) <= to_signed(0, 32);
      intdelay_reg_2(2) <= to_signed(0, 32);
      intdelay_reg_2(3) <= to_signed(0, 32);
      intdelay_reg_2(4) <= to_signed(0, 32);
      intdelay_reg_2(5) <= to_signed(0, 32);
      intdelay_reg_2(6) <= to_signed(0, 32);
      intdelay_reg_2(7) <= to_signed(0, 32);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        IF syncReset = '1' THEN
          intdelay_reg_2(0) <= to_signed(0, 32);
          intdelay_reg_2(1) <= to_signed(0, 32);
          intdelay_reg_2(2) <= to_signed(0, 32);
          intdelay_reg_2(3) <= to_signed(0, 32);
          intdelay_reg_2(4) <= to_signed(0, 32);
          intdelay_reg_2(5) <= to_signed(0, 32);
          intdelay_reg_2(6) <= to_signed(0, 32);
          intdelay_reg_2(7) <= to_signed(0, 32);
        ELSE 
          intdelay_reg_2(0) <= intdelay_reg_next_2(0);
          intdelay_reg_2(1) <= intdelay_reg_next_2(1);
          intdelay_reg_2(2) <= intdelay_reg_next_2(2);
          intdelay_reg_2(3) <= intdelay_reg_next_2(3);
          intdelay_reg_2(4) <= intdelay_reg_next_2(4);
          intdelay_reg_2(5) <= intdelay_reg_next_2(5);
          intdelay_reg_2(6) <= intdelay_reg_next_2(6);
          intdelay_reg_2(7) <= intdelay_reg_next_2(7);
        END IF;
      END IF;
    END IF;
  END PROCESS intdelay_2_process;

  din1Dly_re <= intdelay_reg_2(7);
  intdelay_reg_next_2(0) <= btfIn1_re_signed;
  intdelay_reg_next_2(1) <= intdelay_reg_2(0);
  intdelay_reg_next_2(2) <= intdelay_reg_2(1);
  intdelay_reg_next_2(3) <= intdelay_reg_2(2);
  intdelay_reg_next_2(4) <= intdelay_reg_2(3);
  intdelay_reg_next_2(5) <= intdelay_reg_2(4);
  intdelay_reg_next_2(6) <= intdelay_reg_2(5);
  intdelay_reg_next_2(7) <= intdelay_reg_2(6);

  btfIn1_im_signed <= signed(btfIn1_im);

  intdelay_3_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      intdelay_reg_3(0) <= to_signed(0, 32);
      intdelay_reg_3(1) <= to_signed(0, 32);
      intdelay_reg_3(2) <= to_signed(0, 32);
      intdelay_reg_3(3) <= to_signed(0, 32);
      intdelay_reg_3(4) <= to_signed(0, 32);
      intdelay_reg_3(5) <= to_signed(0, 32);
      intdelay_reg_3(6) <= to_signed(0, 32);
      intdelay_reg_3(7) <= to_signed(0, 32);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        IF syncReset = '1' THEN
          intdelay_reg_3(0) <= to_signed(0, 32);
          intdelay_reg_3(1) <= to_signed(0, 32);
          intdelay_reg_3(2) <= to_signed(0, 32);
          intdelay_reg_3(3) <= to_signed(0, 32);
          intdelay_reg_3(4) <= to_signed(0, 32);
          intdelay_reg_3(5) <= to_signed(0, 32);
          intdelay_reg_3(6) <= to_signed(0, 32);
          intdelay_reg_3(7) <= to_signed(0, 32);
        ELSE 
          intdelay_reg_3(0) <= intdelay_reg_next_3(0);
          intdelay_reg_3(1) <= intdelay_reg_next_3(1);
          intdelay_reg_3(2) <= intdelay_reg_next_3(2);
          intdelay_reg_3(3) <= intdelay_reg_next_3(3);
          intdelay_reg_3(4) <= intdelay_reg_next_3(4);
          intdelay_reg_3(5) <= intdelay_reg_next_3(5);
          intdelay_reg_3(6) <= intdelay_reg_next_3(6);
          intdelay_reg_3(7) <= intdelay_reg_next_3(7);
        END IF;
      END IF;
    END IF;
  END PROCESS intdelay_3_process;

  din1Dly_im <= intdelay_reg_3(7);
  intdelay_reg_next_3(0) <= btfIn1_im_signed;
  intdelay_reg_next_3(1) <= intdelay_reg_3(0);
  intdelay_reg_next_3(2) <= intdelay_reg_3(1);
  intdelay_reg_next_3(3) <= intdelay_reg_3(2);
  intdelay_reg_next_3(4) <= intdelay_reg_3(3);
  intdelay_reg_next_3(5) <= intdelay_reg_3(4);
  intdelay_reg_next_3(6) <= intdelay_reg_3(5);
  intdelay_reg_next_3(7) <= intdelay_reg_3(6);

  intdelay_4_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      intdelay_reg_4(0) <= '0';
      intdelay_reg_4(1) <= '0';
      intdelay_reg_4(2) <= '0';
      intdelay_reg_4(3) <= '0';
      intdelay_reg_4(4) <= '0';
      intdelay_reg_4(5) <= '0';
      intdelay_reg_4(6) <= '0';
      intdelay_reg_4(7) <= '0';
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        IF syncReset = '1' THEN
          intdelay_reg_4(0) <= '0';
          intdelay_reg_4(1) <= '0';
          intdelay_reg_4(2) <= '0';
          intdelay_reg_4(3) <= '0';
          intdelay_reg_4(4) <= '0';
          intdelay_reg_4(5) <= '0';
          intdelay_reg_4(6) <= '0';
          intdelay_reg_4(7) <= '0';
        ELSE 
          intdelay_reg_4(0) <= intdelay_reg_next_4(0);
          intdelay_reg_4(1) <= intdelay_reg_next_4(1);
          intdelay_reg_4(2) <= intdelay_reg_next_4(2);
          intdelay_reg_4(3) <= intdelay_reg_next_4(3);
          intdelay_reg_4(4) <= intdelay_reg_next_4(4);
          intdelay_reg_4(5) <= intdelay_reg_next_4(5);
          intdelay_reg_4(6) <= intdelay_reg_next_4(6);
          intdelay_reg_4(7) <= intdelay_reg_next_4(7);
        END IF;
      END IF;
    END IF;
  END PROCESS intdelay_4_process;

  din1Dly_vld <= intdelay_reg_4(7);
  intdelay_reg_next_4(0) <= btfIn_vld;
  intdelay_reg_next_4(1) <= intdelay_reg_4(0);
  intdelay_reg_next_4(2) <= intdelay_reg_4(1);
  intdelay_reg_next_4(3) <= intdelay_reg_4(2);
  intdelay_reg_next_4(4) <= intdelay_reg_4(3);
  intdelay_reg_next_4(5) <= intdelay_reg_4(4);
  intdelay_reg_next_4(6) <= intdelay_reg_4(5);
  intdelay_reg_next_4(7) <= intdelay_reg_4(6);

  -- minResRX2FFTButterfly
  minResRX2FFTButterfly_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      minResRX2FFTButterfly_add1_re <= to_signed(0, 66);
      minResRX2FFTButterfly_add1_im <= to_signed(0, 66);
      minResRX2FFTButterfly_sub1_re <= to_signed(0, 66);
      minResRX2FFTButterfly_sub1_im <= to_signed(0, 66);
      minResRX2FFTButterfly_add1_cast_re <= to_signed(0, 66);
      minResRX2FFTButterfly_add1_cast_im <= to_signed(0, 66);
      minResRX2FFTButterfly_sub1_cast_re <= to_signed(0, 66);
      minResRX2FFTButterfly_sub1_cast_im <= to_signed(0, 66);
      minResRX2FFTButterfly_vld_reg <= '0';
      btfOut_vld <= '0';
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        IF syncReset = '1' THEN
          minResRX2FFTButterfly_add1_re <= to_signed(0, 66);
          minResRX2FFTButterfly_add1_im <= to_signed(0, 66);
          minResRX2FFTButterfly_sub1_re <= to_signed(0, 66);
          minResRX2FFTButterfly_sub1_im <= to_signed(0, 66);
          minResRX2FFTButterfly_add1_cast_re <= to_signed(0, 66);
          minResRX2FFTButterfly_add1_cast_im <= to_signed(0, 66);
          minResRX2FFTButterfly_sub1_cast_re <= to_signed(0, 66);
          minResRX2FFTButterfly_sub1_cast_im <= to_signed(0, 66);
          minResRX2FFTButterfly_vld_reg <= '0';
          btfOut_vld <= '0';
        ELSE 
          minResRX2FFTButterfly_add1_re <= minResRX2FFTButterfly_add1_re_next;
          minResRX2FFTButterfly_add1_im <= minResRX2FFTButterfly_add1_im_next;
          minResRX2FFTButterfly_sub1_re <= minResRX2FFTButterfly_sub1_re_next;
          minResRX2FFTButterfly_sub1_im <= minResRX2FFTButterfly_sub1_im_next;
          minResRX2FFTButterfly_add1_cast_re <= minResRX2FFTButterfly_add1_cast_re_next;
          minResRX2FFTButterfly_add1_cast_im <= minResRX2FFTButterfly_add1_cast_im_next;
          minResRX2FFTButterfly_sub1_cast_re <= minResRX2FFTButterfly_sub1_cast_re_next;
          minResRX2FFTButterfly_sub1_cast_im <= minResRX2FFTButterfly_sub1_cast_im_next;
          btfOut_vld <= minResRX2FFTButterfly_vld_reg;
          minResRX2FFTButterfly_vld_reg <= din1Dly_vld;
        END IF;
      END IF;
    END IF;
  END PROCESS minResRX2FFTButterfly_process;

  minResRX2FFTButterfly_add1_cast_re_next <= minResRX2FFTButterfly_add1_re;
  minResRX2FFTButterfly_add1_cast_im_next <= minResRX2FFTButterfly_add1_im;
  minResRX2FFTButterfly_sub1_cast_re_next <= minResRX2FFTButterfly_sub1_re;
  minResRX2FFTButterfly_sub1_cast_im_next <= minResRX2FFTButterfly_sub1_im;
  minResRX2FFTButterfly_add_cast <= resize(din1Dly_re & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 66);
  minResRX2FFTButterfly_add_cast_1 <= resize(dinXTwdl_re_signed, 66);
  minResRX2FFTButterfly_add1_re_next <= minResRX2FFTButterfly_add_cast + minResRX2FFTButterfly_add_cast_1;
  minResRX2FFTButterfly_add_cast_2 <= resize(din1Dly_im & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 66);
  minResRX2FFTButterfly_add_cast_3 <= resize(dinXTwdl_im_signed, 66);
  minResRX2FFTButterfly_add1_im_next <= minResRX2FFTButterfly_add_cast_2 + minResRX2FFTButterfly_add_cast_3;
  minResRX2FFTButterfly_sub_cast <= resize(din1Dly_re & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 66);
  minResRX2FFTButterfly_sub_cast_1 <= resize(dinXTwdl_re_signed, 66);
  minResRX2FFTButterfly_sub1_re_next <= minResRX2FFTButterfly_sub_cast - minResRX2FFTButterfly_sub_cast_1;
  minResRX2FFTButterfly_sub_cast_2 <= resize(din1Dly_im & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 66);
  minResRX2FFTButterfly_sub_cast_3 <= resize(dinXTwdl_im_signed, 66);
  minResRX2FFTButterfly_sub1_im_next <= minResRX2FFTButterfly_sub_cast_2 - minResRX2FFTButterfly_sub_cast_3;
  btfOut1FP_re <= SHIFT_RIGHT(minResRX2FFTButterfly_add1_cast_re, 1);
  btfOut1FP_im <= SHIFT_RIGHT(minResRX2FFTButterfly_add1_cast_im, 1);
  btfOut2FP_re <= SHIFT_RIGHT(minResRX2FFTButterfly_sub1_cast_re, 1);
  btfOut2FP_im <= SHIFT_RIGHT(minResRX2FFTButterfly_sub1_cast_im, 1);

  btfOut1_re_tmp <= btfOut1FP_re(61 DOWNTO 30);

  btfOut1_re <= std_logic_vector(btfOut1_re_tmp);

  btfOut1_im_tmp <= btfOut1FP_im(61 DOWNTO 30);

  btfOut1_im <= std_logic_vector(btfOut1_im_tmp);

  btfOut2_re_tmp <= btfOut2FP_re(61 DOWNTO 30);

  btfOut2_re <= std_logic_vector(btfOut2_re_tmp);

  btfOut2_im_tmp <= btfOut2FP_im(61 DOWNTO 30);

  btfOut2_im <= std_logic_vector(btfOut2_im_tmp);

END rtl;

