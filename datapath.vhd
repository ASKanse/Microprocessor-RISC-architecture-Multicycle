library std;
library ieee;
use ieee.std_logic_1164.all;
library work;

entity datapath is
  port (
    -- Instruction Register write
    addr_select : in std_logic_vector(1 downto 0);
    inst_write: in std_logic;
    pc_write: in std_logic;
    pc_in_select: in std_logic_vector(1 downto 0);
    alu1_select: in std_logic_vector(1 downto 0);
    alu2_select: in std_logic_vector(1 downto 0);
    MEMWRITE: in std_logic;
    --memreg_write: in std_logic;

  t1_sel: in std_logic_vector(1 downto 0);
  t2_sel: in std_logic_vector(1 downto 0);
  t3_sel: in std_logic;
    -- Choices for Register file
    a1_sel: in std_logic;
    a2_sel: in std_logic;
    rf_d3_sel: in std_logic_vector(1 downto 0);
    regwrite_select: in std_logic_vector(1 downto 0);
    reg_write: in std_logic;
    t1_write, t2_write,t3_write, ar_write, PC_en, rd : in std_logic;

    carry_en, zero_en: in std_logic;
  
    pego: out std_logic;
    CARRY, ZERO: out std_logic;
   ir_out: OUT std_logic_vector(15 downto 0) ;   --:= (others => '0');
    
    clk, reset: in std_logic;

end entity;

architecture behave_dp of Datapath is
  -- Constants
  signal CONST_0: std_logic_vector(15 downto 0) := (others => '0');
  signal CONST_1: std_logic_vector(15 downto 0) := (0 => '1', others => '0');
  signal CONST_32: std_logic_vector(15 downto 0) := (5 => '1', others => '0');

  -- Instruction Register signals
  --signal 
  signal INST_ALU: std_logic;
  --signal carry_en: std_logic;
  --signal zero_en: std_logic;

  -- Memory signals
  signal ADDRESS_in: std_logic_vector(15 downto 0);
  signal LSHIFT_ADDRESS_in: std_logic_vector(15 downto 0);
  signal MEMDATA_in: std_logic_vector(15 downto 0);
  signal MEM_out: std_logic_vector(15 downto 0);
  --signal MEMWRITE: std_logic;

  -- Memory Register (T4)
  signal MEMREG_out: std_logic_vector(15 downto 0);

  -- Register File signals
  signal PC_in: std_logic_vector(15 downto 0);
  signal PC_out: std_logic_vector(15 downto 0);
  signal DATA1: std_logic_vector(15 downto 0);
  signal DATA2: std_logic_vector(15 downto 0);
  signal READ1: std_logic_vector(2 downto 0);
  signal READ2: std_logic_vector(2 downto 0);
  signal WRITE3: std_logic_vector(2 downto 0);
  signal REGDATA_in: std_logic_vector(15 downto 0);
  signal REGLOAD_zero: std_logic;
   signal R7: std_logic_vector(15 downto 0);                      -- new signal

  -- Zero Pad / Left Shift / Sign Extender signals
  signal ZERO_PAD9: std_logic_vector(15 downto 0);
  signal SE6_out: std_logic_vector(15 downto 0);
  signal se9_out: std_logic_vector(15 downto 0);

  -- Register File Temp Registers (T1, T2)
  signal T1_out: std_logic_vector(15 downto 0);
  signal T2_out: std_logic_vector(15 downto 0);
    signal T3_out: std_logic_vector(7 downto 0);

  -- ALU signals
  signal ALU1_in: std_logic_vector(15 downto 0);
  signal ALU2_in: std_logic_vector(15 downto 0);
  signal ALU_out: std_logic_vector(15 downto 0);
  signal ALU_carry: std_logic;
  signal ALU_zero: std_logic;
  signal ALU_opcode: std_logic;

  -- ALU Register (T3)
  signal ALUREG_out: std_logic_vector(15 downto 0);

  -- Twos Complement for BEQ subtraction
  signal TwosCmp_out: std_logic_vector(15 downto 0);

  -- Flag Register
  signal CARRY_in: std_logic_vector(0 downto 0);
  signal ZERO_in: std_logic_vector(0 downto 0);
  --signal CARRY: std_logic_vector(0 downto 0);
  --signal ZERO: std_logic_vector(0 downto 0);
  signal CARRY_ENABLE: std_logic;
  signal ZERO_ENABLE: std_logic;

  -- Priority Loop Registers
  signal PL_INPUT: std_logic_vector(7 downto 0);
  signal PL_OUTPUT: std_logic_vector(2 downto 0);

  --signal rd: std_logic;
  signal PC_en: std_logic;
  signal ar_write: std_logic;
  signal t1_write: std_logic;
  signal t2_write: std_logic;
  signal t3_write: std_logic;
  signal a1_sel: std_logic_vector(1 downto 0);
  signal a2_sel: std_logic_vector(1 downto 0);
  signal AR_out: std_logic_vector(2 downto 0);
  signal DATA_T1: std_logic_vector(15 downto 0);
  signal DATA_T2: std_logic_vector(15 downto 0);
  signal DATA_T3: std_logic_vector(7 downto 0);
  signal T1_sel: std_logic_vector(1 downto 0);
  signal T2_sel: std_logic_vector(1 downto 0);
  signal T3_sel: std_logic_vector(0 downto 0);
  signal pein: std_logic_vector(7 downto 0);
  signal modpein: std_logic_vector(7 downto 0);
  signal peout: std_logic_vector(2 downto 0);
  signal pego: std_logic_vector(0 downto 0);
  signal se9_out: std_logic_vector(15 downto 0);
  signal ls7_out: std_logic_vector(15 downto 0);
  signal INSTRUCTION: std_logic_vector(15 downto 0) ; 
  
-------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- end of defining signals
-----------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
begin
  -- External mapping
  --external_ir <= INSTRUCTION;
  --external_pc_out <= PC_out;
  -- ALU Dataflow logic
  ALU1_in <= PC_out when alu1_select = "00" else
             T1_out when alu1_select = "01" else
             T2_out when alu1_select = "10" else

             --ALUREG_out when alu1_select = "010" else
             --SE6_out when alu1_select = "011" else
             --CONST_0 when alu1_select = "100" else
             --CONST_1 when alu1_select = "101" else
             CONST_32;

  
  ALU2_in <= CONST_1 when alu2_select = "00" else
             T2_out when alu2_select = "01" else
             se6_out when alu2_select = "10" else
             se9_out when alu2_select = "11" else
             --TwosCmp_out when alu2_select = "101" else
             CONST_32;

  ALU_opcode <= INSTRUCTION(15 downto 12);

  -- Memory Dataflow logic
  ADDRESS_in <= PC_out when reset = '0' and addr_select = "00" else
                --ALUREG_out when reset = '0' and addr_select = "01" else
                T1_out when reset = '0' and addr_select = "10" else
                T2_out when reset = '0' and addr_select = "11" else
                CONST_0;
                --external_addr when reset = '1' else

  MEMDATA_in <= T1_out ;--when reset = '0' ;--else external_data;
  --MEMWRITE <= mem_write;-- when reset = '0' ;--else external_mem_write;

  -- Program Counter Dataflow logic
  PC_in <= CONST_0 when pc_in_select = "00" else                                                     -- check this 1
           PC_in when pc_in_select = "01" else
           ALU_out when pc_in_select = "11" else
           DATA1 when pc_in_select = "10" else
           --T2_out when pc_in_select = "011" else
           --ALUREG_out when pc_in_select = "100"else
           CONST_32;

  -- Register File Dataflow
  READ1 <= INSTRUCTION(11 downto 9) when a1_sel = "0" else
          INSTRUCTION(8 downto 6) when a1_sel = "1" 
          else "000";

  READ2 <= INSTRUCTION(8 downto 6) when a2_sel = '0' else
           peout when a2_sel = '0' when a2_sel = '1' else
           --AR_out(2 downto 0) when a2_sel = '10' else "000" ;
           

  WRITE3 <= INSTRUCTION(5 downto 3) when regwrite_select = "00" else         --a3
            INSTRUCTION(11 downto 9) when regwrite_select = "01" else
            INSTRUCTION(8 downto 6) when regwrite_select = "10" else
            AR_out(2 downto 0) when regwrite_select = "11" else
            "000";

  DATA_T1 <= DATA1 when T1_sel = "00" else
             MEM_out when T1_sel = "01" else
             ALU_out when T1_sel = "10" else
              CONST_0;

   DATA_T2 <= DATA2 when T2_sel = "00" else
             MEM_out when T2_sel = "01" else
             ALU_out when T2_sel = "10" else
              CONST_0;

  DATA_T3 <= INSTRUCTION(7 downto 0) when T3_sel = "1" else
             modpein when T3_sel = "0" else
              CONST_0;
            

  REGDATA_in <= T1_out when rf_d3_sel = "00" else
                MEM_out when rf_d3_sel = "01" else
                --ZERO_PAD9 when r egdata_select = "10" else
                ls7_out when rf_d3_sel = "10" else
                PC_out when rf_d3_sel = "11" else
                CONST_0;

  -- Flags data flow logic
  --zero_flag <= ALU_zero;                                                                       -- change these                                                          -
  --CARRY_in(0) <= ALU_carry;
  --ZERO_in(0) <= ALU_zero ; --when zero_select = '0' else REGLOAD_zero;
  
  CARRY_ENABLE <= carry_en; -- when carry_enable_select = '1' else set_carry;
  ZERO_ENABLE <= zero_en ; --when zero_enable_select = '1' else set_zero;
  ir_out(15 downto 0) <= INSTRUCTION(15 downto 0) ; 


  -- Instruction Register and Decoder Port Maps
  IR: dreg
      generic map (data_width => 16)
      port map (
        Din => MEM_out,
        Dout => INSTRUCTION,
        Enable => inst_write,
        clk => clk
      );

   ALU: ALU2
      port map (
        alu_in_1 => ALU1_in,
        alu_in_2 => ALU2_in,
        op_in => ALU_opcode,
        alu_out => ALU_out,
        carry => ALU_carry,
        zero => ALU_zero
      );

   MEM: Memory
      port map (
        clk => clk,
        wr => MEMWRITE,
        rd => rd,
        Add_in => ADDRESS_in,
        D_in => MEMDATA_in,
        Y_out => MEM_out

      );


  -- Register File port maps
  RF: rf
      port map (
        clk => clk,
        R7_PC => PC_in,
        D_PC => PC_out,
        pc_r7 => pc_write,
        
        D1 => DATA1,
        D2 => DATA2,
        A1 => READ1,
        A2 => READ2,
        A3 => WRITE3,
        rf_wr => reg_write,
        D3 => REGDATA_in,
        --zero => REGLOAD_zero,
      );


  PC: dreg                               
      generic map (data_width => 16)
      port map (
        Din => PC_in,
        Dout => PC_out,
        Enable => PC_en,
        clk => clk
      );


  T1: dreg
      generic map (data_width => 16)
      port map (
        Din => DATA_T1,
        Dout => T1_out,
        Enable => t1_write,
        clk => clk
      );

  T2: dreg
      generic map (data_width => 16)
      port map (
        Din => DATA_T2,
        Dout => T2_out,
        Enable => t2_write,
        clk => clk
      );


  T3: dreg
      generic map (data_width => 8)
      port map (
        Din => DATA_T3,
        Dout => T3_out,
        Enable => t3_write,
        clk => clk
      );
  

  -- Memory Port Maps

  -- ALU Port Maps
  SE6: se6
      port map (
        se6 => INSTRUCTION(5 downto 0),
        se6 => SE6_out
      );

  SE9: se9
       port map (
         se9_in  => INSTRUCTION(8 downto 0),
         se9_out => se9_out
       );

  LS: ls7
      port map (
        ls7_in => se9_out,
        ls7_out => ls7_out
      );


  CR: dreg
      generic map (data_width => 1)
      port map (
        Din => ALU_carry,
        Dout => CARRY,
        Enable => carry_en,
        clk => clk
      );


  ZR: dreg
      generic map (data_width => 1)
      port map (
        Din => ALU_zero,
        Dout => ZERO,
        Enable => zero_en,
        clk => clk
      );


  PE: pr_encoder
      port map (
        pein => INSTRUCTION(7 downto 0),
        peout => peout,
       -- clock => clk,
        modpein => modpein,
        pego => pego
      );

    AR: dreg
      generic map (data_width => 3)
      port map (
        Din => peout,
        Dout => T3_out,
        Enable => ar_write,
        clk => clk
      );
  

 
end behave_dp;