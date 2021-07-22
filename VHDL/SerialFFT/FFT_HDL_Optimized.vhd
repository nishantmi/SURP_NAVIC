
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY FFT_HDL_Optimized IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        enb                               :   IN    std_logic;
        dataIn_re                         :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        dataIn_im                         :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        validIn                           :   IN    std_logic;
        syncReset                         :   IN    std_logic;
        dataOut_re                        :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        dataOut_im                        :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        startOut                          :   OUT   std_logic;
        endOut                            :   OUT   std_logic;
        validOut                          :   OUT   std_logic;
        ready                             :   OUT   std_logic
        );
END FFT_HDL_Optimized;


ARCHITECTURE rtl OF FFT_HDL_Optimized IS

  -- Component Declarations
  COMPONENT TWDLROM
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb                             :   IN    std_logic;
          dMemOutDly_vld                  :   IN    std_logic;
          stage                           :   IN    std_logic_vector(3 DOWNTO 0);  -- ufix4
          initIC                          :   IN    std_logic;
          syncReset                       :   IN    std_logic;
          twdl_re                         :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En30
          twdl_im                         :   OUT   std_logic_vector(31 DOWNTO 0)  -- sfix32_En30
          );
  END COMPONENT;

  COMPONENT MINRESRX2FFT_MEMORY
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb                             :   IN    std_logic;
          dMemIn1_re                      :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          dMemIn1_im                      :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          dMemIn2_re                      :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          dMemIn2_im                      :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          wrEnb1                          :   IN    std_logic;
          wrEnb2                          :   IN    std_logic;
          wrEnb3                          :   IN    std_logic;
          rdEnb1                          :   IN    std_logic;
          rdEnb2                          :   IN    std_logic;
          rdEnb3                          :   IN    std_logic;
          stage                           :   IN    std_logic_vector(3 DOWNTO 0);  -- ufix4
          initIC                          :   IN    std_logic;
          unLoadPhase                     :   IN    std_logic;
          syncReset                       :   IN    std_logic;
          dMemOut1_re                     :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          dMemOut1_im                     :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          dMemOut2_re                     :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          dMemOut2_im                     :   OUT   std_logic_vector(31 DOWNTO 0)  -- sfix32_En16
          );
  END COMPONENT;

  COMPONENT MINRESRX2FFT_BTFSEL
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb                             :   IN    std_logic;
          din_1_re                        :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          din_1_im                        :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          validIn                         :   IN    std_logic;
          rdy                             :   IN    std_logic;
          dMemOut1_re                     :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          dMemOut1_im                     :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          dMemOut2_re                     :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          dMemOut2_im                     :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          dMemOut_vld                     :   IN    std_logic;
          stage                           :   IN    std_logic_vector(3 DOWNTO 0);  -- ufix4
          initIC                          :   IN    std_logic;
          syncReset                       :   IN    std_logic;
          btfIn1_re                       :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          btfIn1_im                       :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          btfIn2_re                       :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          btfIn2_im                       :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          btfIn_vld                       :   OUT   std_logic
          );
  END COMPONENT;

  COMPONENT MINRESRX2_BUTTERFLY
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb                             :   IN    std_logic;
          btfIn1_re                       :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          btfIn1_im                       :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          btfIn2_re                       :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          btfIn2_im                       :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          btfIn_vld                       :   IN    std_logic;
          twdl_re                         :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En30
          twdl_im                         :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En30
          syncReset                       :   IN    std_logic;
          btfOut1_re                      :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          btfOut1_im                      :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          btfOut2_re                      :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          btfOut2_im                      :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          btfOut_vld                      :   OUT   std_logic
          );
  END COMPONENT;

  COMPONENT MINRESRX2FFT_MEMSEL
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb                             :   IN    std_logic;
          btfOut1_re                      :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          btfOut1_im                      :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          btfOut2_re                      :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          btfOut2_im                      :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          btfOut_vld                      :   IN    std_logic;
          stage                           :   IN    std_logic_vector(3 DOWNTO 0);  -- ufix4
          initIC                          :   IN    std_logic;
          syncReset                       :   IN    std_logic;
          stgOut1_re                      :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          stgOut1_im                      :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          stgOut2_re                      :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          stgOut2_im                      :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          stgOut_vld                      :   OUT   std_logic
          );
  END COMPONENT;

  COMPONENT MINRESRX2FFT_CTRL
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb                             :   IN    std_logic;
          din_1_re                        :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          din_1_im                        :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          validIn                         :   IN    std_logic;
          stgOut1_re                      :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          stgOut1_im                      :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          stgOut2_re                      :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          stgOut2_im                      :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          stgOut_vld                      :   IN    std_logic;
          syncReset                       :   IN    std_logic;
          dMemIn1_re                      :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          dMemIn1_im                      :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          dMemIn2_re                      :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          dMemIn2_im                      :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          wrEnb1                          :   OUT   std_logic;
          wrEnb2                          :   OUT   std_logic;
          wrEnb3                          :   OUT   std_logic;
          rdEnb1                          :   OUT   std_logic;
          rdEnb2                          :   OUT   std_logic;
          rdEnb3                          :   OUT   std_logic;
          dMemOut_vld                     :   OUT   std_logic;
          vldOut                          :   OUT   std_logic;
          stage                           :   OUT   std_logic_vector(3 DOWNTO 0);  -- ufix4
          rdy                             :   OUT   std_logic;
          initIC                          :   OUT   std_logic;
          unLoadPhase                     :   OUT   std_logic
          );
  END COMPONENT;

  COMPONENT MINRESRX2FFT_OUTMux
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb                             :   IN    std_logic;
          rdEnb1                          :   IN    std_logic;
          rdEnb2                          :   IN    std_logic;
          rdEnb3                          :   IN    std_logic;
          dMemOut1_re                     :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          dMemOut1_im                     :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          dMemOut2_re                     :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          dMemOut2_im                     :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          vldOut                          :   IN    std_logic;
          syncReset                       :   IN    std_logic;
          dOut_re                         :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          dOut_im                         :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          dout_vld                        :   OUT   std_logic
          );
  END COMPONENT;

  -- Component Configuration Statements
  FOR ALL : TWDLROM
    USE ENTITY work.TWDLROM(rtl);

  FOR ALL : MINRESRX2FFT_MEMORY
    USE ENTITY work.MINRESRX2FFT_MEMORY(rtl);

  FOR ALL : MINRESRX2FFT_BTFSEL
    USE ENTITY work.MINRESRX2FFT_BTFSEL(rtl);

  FOR ALL : MINRESRX2_BUTTERFLY
    USE ENTITY work.MINRESRX2_BUTTERFLY(rtl);

  FOR ALL : MINRESRX2FFT_MEMSEL
    USE ENTITY work.MINRESRX2FFT_MEMSEL(rtl);

  FOR ALL : MINRESRX2FFT_CTRL
    USE ENTITY work.MINRESRX2FFT_CTRL(rtl);

  FOR ALL : MINRESRX2FFT_OUTMux
    USE ENTITY work.MINRESRX2FFT_OUTMux(rtl);

  -- Functions
  -- HDLCODER_TO_STDLOGIC 
  FUNCTION hdlcoder_to_stdlogic(arg: boolean) RETURN std_logic IS
  BEGIN
    IF arg THEN
      RETURN '1';
    ELSE
      RETURN '0';
    END IF;
  END FUNCTION;


  -- Signals
  SIGNAL dMemOut_vld                      : std_logic;
  SIGNAL dMemOutDly_vld                   : std_logic;
  SIGNAL stage                            : std_logic_vector(3 DOWNTO 0);  -- ufix4
  SIGNAL initIC                           : std_logic;
  SIGNAL twdl_re                          : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL twdl_im                          : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL dMemIn1_re                       : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL dMemIn1_im                       : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL dMemIn2_re                       : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL dMemIn2_im                       : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL wrEnb1                           : std_logic;
  SIGNAL wrEnb2                           : std_logic;
  SIGNAL wrEnb3                           : std_logic;
  SIGNAL rdEnb1                           : std_logic;
  SIGNAL rdEnb2                           : std_logic;
  SIGNAL rdEnb3                           : std_logic;
  SIGNAL unLoadPhase                      : std_logic;
  SIGNAL dMemOut1_re                      : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL dMemOut1_im                      : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL dMemOut2_re                      : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL dMemOut2_im                      : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL rdy                              : std_logic;
  SIGNAL btfIn1_re                        : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL btfIn1_im                        : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL btfIn2_re                        : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL btfIn2_im                        : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL btfIn_vld                        : std_logic;
  SIGNAL btfOut1_re                       : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL btfOut1_im                       : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL btfOut2_re                       : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL btfOut2_im                       : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL btfOut_vld                       : std_logic;
  SIGNAL stgOut1_re                       : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL stgOut1_im                       : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL stgOut2_re                       : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL stgOut2_im                       : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL stgOut_vld                       : std_logic;
  SIGNAL vldOut                           : std_logic;
  SIGNAL dOut_re                          : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL dOut_im                          : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL dout_vld                         : std_logic;
  SIGNAL startOutput_sampleCnt            : unsigned(14 DOWNTO 0);  -- ufix15
  SIGNAL startOutput_sampleCnt_next       : unsigned(14 DOWNTO 0);  -- ufix15
  SIGNAL startOutS                        : std_logic;
  SIGNAL endOutput_sampleCnt              : unsigned(14 DOWNTO 0);  -- ufix15
  SIGNAL endOutput_endOut_reg             : std_logic;
  SIGNAL endOutput_sampleCnt_next         : unsigned(14 DOWNTO 0);  -- ufix15
  SIGNAL endOutput_endOut_reg_next        : std_logic;
  SIGNAL endOutS                          : std_logic;

BEGIN
  u_MinResRX2FFT_TWDLROM : TWDLROM
    PORT MAP( clk => clk,
              reset => reset,
              enb => enb,
              dMemOutDly_vld => dMemOutDly_vld,
              stage => stage,  -- ufix4
              initIC => initIC,
              syncReset => syncReset,
              twdl_re => twdl_re,  -- sfix32_En30
              twdl_im => twdl_im  -- sfix32_En30
              );

  u_MinResRX2FFT_MEMORY : MINRESRX2FFT_MEMORY
    PORT MAP( clk => clk,
              reset => reset,
              enb => enb,
              dMemIn1_re => dMemIn1_re,  -- sfix32_En16
              dMemIn1_im => dMemIn1_im,  -- sfix32_En16
              dMemIn2_re => dMemIn2_re,  -- sfix32_En16
              dMemIn2_im => dMemIn2_im,  -- sfix32_En16
              wrEnb1 => wrEnb1,
              wrEnb2 => wrEnb2,
              wrEnb3 => wrEnb3,
              rdEnb1 => rdEnb1,
              rdEnb2 => rdEnb2,
              rdEnb3 => rdEnb3,
              stage => stage,  -- ufix4
              initIC => initIC,
              unLoadPhase => unLoadPhase,
              syncReset => syncReset,
              dMemOut1_re => dMemOut1_re,  -- sfix32_En16
              dMemOut1_im => dMemOut1_im,  -- sfix32_En16
              dMemOut2_re => dMemOut2_re,  -- sfix32_En16
              dMemOut2_im => dMemOut2_im  -- sfix32_En16
              );

  u_MinResRX2FFT_BTFSEL : MINRESRX2FFT_BTFSEL
    PORT MAP( clk => clk,
              reset => reset,
              enb => enb,
              din_1_re => dataIn_re,  -- sfix32_En16
              din_1_im => dataIn_im,  -- sfix32_En16
              validIn => validIn,
              rdy => rdy,
              dMemOut1_re => dMemOut1_re,  -- sfix32_En16
              dMemOut1_im => dMemOut1_im,  -- sfix32_En16
              dMemOut2_re => dMemOut2_re,  -- sfix32_En16
              dMemOut2_im => dMemOut2_im,  -- sfix32_En16
              dMemOut_vld => dMemOut_vld,
              stage => stage,  -- ufix4
              initIC => initIC,
              syncReset => syncReset,
              btfIn1_re => btfIn1_re,  -- sfix32_En16
              btfIn1_im => btfIn1_im,  -- sfix32_En16
              btfIn2_re => btfIn2_re,  -- sfix32_En16
              btfIn2_im => btfIn2_im,  -- sfix32_En16
              btfIn_vld => btfIn_vld
              );

  u_MinResRX2FFT_BUTTERFLY : MINRESRX2_BUTTERFLY
    PORT MAP( clk => clk,
              reset => reset,
              enb => enb,
              btfIn1_re => btfIn1_re,  -- sfix32_En16
              btfIn1_im => btfIn1_im,  -- sfix32_En16
              btfIn2_re => btfIn2_re,  -- sfix32_En16
              btfIn2_im => btfIn2_im,  -- sfix32_En16
              btfIn_vld => btfIn_vld,
              twdl_re => twdl_re,  -- sfix32_En30
              twdl_im => twdl_im,  -- sfix32_En30
              syncReset => syncReset,
              btfOut1_re => btfOut1_re,  -- sfix32_En16
              btfOut1_im => btfOut1_im,  -- sfix32_En16
              btfOut2_re => btfOut2_re,  -- sfix32_En16
              btfOut2_im => btfOut2_im,  -- sfix32_En16
              btfOut_vld => btfOut_vld
              );

  u_MinResRX2FFT_MEMSEL : MINRESRX2FFT_MEMSEL
    PORT MAP( clk => clk,
              reset => reset,
              enb => enb,
              btfOut1_re => btfOut1_re,  -- sfix32_En16
              btfOut1_im => btfOut1_im,  -- sfix32_En16
              btfOut2_re => btfOut2_re,  -- sfix32_En16
              btfOut2_im => btfOut2_im,  -- sfix32_En16
              btfOut_vld => btfOut_vld,
              stage => stage,  -- ufix4
              initIC => initIC,
              syncReset => syncReset,
              stgOut1_re => stgOut1_re,  -- sfix32_En16
              stgOut1_im => stgOut1_im,  -- sfix32_En16
              stgOut2_re => stgOut2_re,  -- sfix32_En16
              stgOut2_im => stgOut2_im,  -- sfix32_En16
              stgOut_vld => stgOut_vld
              );

  u_MinResRX2FFT_CTRL : MINRESRX2FFT_CTRL
    PORT MAP( clk => clk,
              reset => reset,
              enb => enb,
              din_1_re => dataIn_re,  -- sfix32_En16
              din_1_im => dataIn_im,  -- sfix32_En16
              validIn => validIn,
              stgOut1_re => stgOut1_re,  -- sfix32_En16
              stgOut1_im => stgOut1_im,  -- sfix32_En16
              stgOut2_re => stgOut2_re,  -- sfix32_En16
              stgOut2_im => stgOut2_im,  -- sfix32_En16
              stgOut_vld => stgOut_vld,
              syncReset => syncReset,
              dMemIn1_re => dMemIn1_re,  -- sfix32_En16
              dMemIn1_im => dMemIn1_im,  -- sfix32_En16
              dMemIn2_re => dMemIn2_re,  -- sfix32_En16
              dMemIn2_im => dMemIn2_im,  -- sfix32_En16
              wrEnb1 => wrEnb1,
              wrEnb2 => wrEnb2,
              wrEnb3 => wrEnb3,
              rdEnb1 => rdEnb1,
              rdEnb2 => rdEnb2,
              rdEnb3 => rdEnb3,
              dMemOut_vld => dMemOut_vld,
              vldOut => vldOut,
              stage => stage,  -- ufix4
              rdy => rdy,
              initIC => initIC,
              unLoadPhase => unLoadPhase
              );

  u_MinResRX2FFT_OUTMUX : MINRESRX2FFT_OUTMux
    PORT MAP( clk => clk,
              reset => reset,
              enb => enb,
              rdEnb1 => rdEnb1,
              rdEnb2 => rdEnb2,
              rdEnb3 => rdEnb3,
              dMemOut1_re => dMemOut1_re,  -- sfix32_En16
              dMemOut1_im => dMemOut1_im,  -- sfix32_En16
              dMemOut2_re => dMemOut2_re,  -- sfix32_En16
              dMemOut2_im => dMemOut2_im,  -- sfix32_En16
              vldOut => vldOut,
              syncReset => syncReset,
              dOut_re => dOut_re,  -- sfix32_En16
              dOut_im => dOut_im,  -- sfix32_En16
              dout_vld => dout_vld
              );

  intdelay_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      dMemOutDly_vld <= '0';
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        IF syncReset = '1' THEN
          dMemOutDly_vld <= '0';
        ELSE 
          dMemOutDly_vld <= dMemOut_vld;
        END IF;
      END IF;
    END IF;
  END PROCESS intdelay_process;


  -- startOutput
  startOutput_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      startOutput_sampleCnt <= to_unsigned(16#0000#, 15);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        IF syncReset = '1' THEN
          startOutput_sampleCnt <= to_unsigned(16#0000#, 15);
        ELSE 
          startOutput_sampleCnt <= startOutput_sampleCnt_next;
        END IF;
      END IF;
    END IF;
  END PROCESS startOutput_process;

  startOutput_output : PROCESS (dout_vld, startOutput_sampleCnt)
  BEGIN
    startOutput_sampleCnt_next <= startOutput_sampleCnt;
    startOutS <= hdlcoder_to_stdlogic(startOutput_sampleCnt = to_unsigned(16#0000#, 15)) AND dout_vld;
    IF dout_vld = '1' THEN 
      startOutput_sampleCnt_next <= startOutput_sampleCnt + to_unsigned(16#0001#, 15);
    END IF;
  END PROCESS startOutput_output;


  startOut <= startOutS;

  -- endOutput
  endOutput_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      endOutput_sampleCnt <= to_unsigned(16#0000#, 15);
      endOutput_endOut_reg <= '0';
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        IF syncReset = '1' THEN
          endOutput_sampleCnt <= to_unsigned(16#0000#, 15);
          endOutput_endOut_reg <= '0';
        ELSE 
          endOutput_sampleCnt <= endOutput_sampleCnt_next;
          endOutput_endOut_reg <= endOutput_endOut_reg_next;
        END IF;
      END IF;
    END IF;
  END PROCESS endOutput_process;

  endOutput_output : PROCESS (dout_vld, endOutput_endOut_reg, endOutput_sampleCnt)
  BEGIN
    endOutput_sampleCnt_next <= endOutput_sampleCnt;
    endOutput_endOut_reg_next <= endOutput_endOut_reg;
    endOutS <= endOutput_endOut_reg;
    endOutput_endOut_reg_next <= hdlcoder_to_stdlogic(endOutput_sampleCnt = to_unsigned(16#7FFE#, 15)) AND dout_vld;
    IF dout_vld = '1' THEN 
      endOutput_sampleCnt_next <= endOutput_sampleCnt + to_unsigned(16#0001#, 15);
    END IF;
  END PROCESS endOutput_output;


  endOut <= endOutS;

  validOut <= dout_vld;

  ready <= rdy;

  dataOut_re <= dOut_re;

  dataOut_im <= dOut_im;

END rtl;

