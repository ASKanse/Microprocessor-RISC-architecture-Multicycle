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
	 alu_op_sel: in std_logic;
    MEMWRITE: in std_logic;
	 mem_d_sel: in std_logic;
    --memreg_write: in std_logic;

  t1_sel: in std_logic_vector(1 downto 0);
  t2_sel: in std_logic_vector(1 downto 0);
  t3_sel: in std_logic;
    -- Choices for Register file
    a1_sel: in std_logic;
    a2_sel: in std_logic;
    rf_d3_sel: in std_logic_vector(2 downto 0);
    regwrite_select: in std_logic_vector(1 downto 0);
    reg_write: in std_logic;
    t1_write, t2_write,t3_write, ar_write, PC_en, rd : in std_logic;

    carry_en, zero_en: in std_logic;
  
    pego: out std_logic;
    CARRY, ZERO: out std_logic;
   ir_out: OUT std_logic_vector(15 downto 0) ;   --:= (others => '0');
    
    clk, reset: in std_logic);

end entity;

architecture behave_dp of Datapath is
  -- Constants

  signal CONST_0: std_logic_vector(15 downto 0) := (others => '0');
  signal CONST_1: std_logic_vector(15 downto 0) := (0 => '1', others => '0');
  signal CONST_32: std_logic_vector(15 downto 0) := (5 => '1', others => '0');
  signal CARRY_v, ZERO_v: std_logic_vector(0 downto 0);
  

  -- Memory signals
  signal ADDRESS_in: std_logic_vector(15 downto 0);
  signal MEMDATA_in: std_logic_vector(15 downto 0);
  signal MEM_out: std_logic_vector(15 downto 0);


  -- Register File signals
  signal PC_in: std_logic_vector(15 downto 0);
  signal PC_out: std_logic_vector(15 downto 0);
  signal D1: std_logic_vector(15 downto 0);
  signal D2: std_logic_vector(15 downto 0);
  signal A1: std_logic_vector(2 downto 0);
  signal A2: std_logic_vector(2 downto 0);
  signal A3: std_logic_vector(2 downto 0);
  signal D3: std_logic_vector(15 downto 0);                      

  --Sign Extender signals
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
  signal ALU_carry: std_logic_vector(0 downto 0);
  signal ALU_zero: std_logic_vector(0 downto 0);
  signal ALU_opcode: std_logic_vector(3 downto 0);


  -- Flag Register
  signal CARRY_in: std_logic_vector(0 downto 0);
  signal ZERO_in: std_logic_vector(0 downto 0);
 
  
 
  signal AR_out: std_logic_vector(2 downto 0);
  signal DATA_T1: std_logic_vector(15 downto 0);
  signal DATA_T2: std_logic_vector(15 downto 0);
  signal DATA_T3: std_logic_vector(7 downto 0);
  signal pein: std_logic_vector(7 downto 0);
  signal modpein: std_logic_vector(7 downto 0);
  signal peout: std_logic_vector(2 downto 0);
  signal ls7_out: std_logic_vector(15 downto 0);
  signal INSTRUCTION: std_logic_vector(15 downto 0) ;
  signal r7pc: std_logic_vector(15 downto 0) ;
  

------------------------------------------------------------------------------------------------------------
-- end of defining signals
-----------------------------------------------------------------------------------------------------------

component ALU2 is
   port(alu_in_1, alu_in_2: in std_logic_vector(15 downto 0);
        op_in: in std_logic_vector(3 downto 0);
        alu_out: out std_logic_vector(15 downto 0);
        carry: out std_logic;
        zero: out std_logic);
end component;

component memory is 
	port ( wr,rd,clk : in std_logic; 
			Add_in, D_in: in std_logic_vector(15 downto 0);
			Y_out: out std_logic_vector(15 downto 0)); 
end component; 

component dreg is
  generic (data_width:integer:= 16);
  port (Din: in std_logic_vector(data_width-1 downto 0);
        Dout: out std_logic_vector(data_width-1 downto 0);
        clk, enable: in std_logic);
end component;

component ls7 is 
	port( ls7_in : in std_logic_vector(15 downto 0);
		  ls7_out: out std_logic_vector(15 downto 0));
end component;

component pr_encoder is
	port( pein : in std_logic_vector (7 downto 0);
		  peout: out std_logic_vector(2 downto 0);
		  modpein: out std_logic_vector (7 downto 0);
		  pego: out std_logic);
end component;

component rf is 
	port( A1,A2,A3 : in std_logic_vector(2 downto 0);
		  D3, D_PC: in std_logic_vector(15 downto 0);
		  
		clk,rf_wr, pc_r7, reset: in std_logic ; -- No separate control for PC required; simply drive 111 to A_
		D1, D2, R7_PC: out std_logic_vector(15 downto 0));
end component;

component se6 is 
	port( se6_in : in std_logic_vector(5 downto 0);
		  se6_out: out std_logic_vector(15 downto 0));
end component;

component se9 is 
	port( se9_in : in std_logic_vector(8 downto 0);
		  se9_out: out std_logic_vector(15 downto 0));
end component;


begin
  -- External mapping
  --external_ir <= INSTRUCTION;
  --external_pc_out <= PC_out;
  -- ALU Dataflow logic
  ALU1_in <= PC_out when alu1_select = "00" else
             T1_out when alu1_select = "01" else
             T2_out when alu1_select = "10" else

             
             --SE6_out when alu1_select = "011" else
             --CONST_0 when alu1_select = "100" else
             --CONST_1 when alu1_select = "101" else
             CONST_32;

  
  ALU2_in <= CONST_1 when alu2_select = "00" else
             T2_out when alu2_select = "01" else
             se6_out when alu2_select = "10" else
             se9_out when alu2_select = "11" else
             CONST_32;

  ALU_opcode <= INSTRUCTION(15 downto 12) when alu_op_sel = '1' else
                Const_0(3 downto 0);

  -- Memory Dataflow logic
  ADDRESS_in <= PC_out when reset = '0' and addr_select = "00" else
                T1_out when reset = '0' and addr_select = "10" else
                T2_out when reset = '0' and addr_select = "11" else
                CONST_0;
                --external_addr when reset = '1' else

  MEMDATA_in <= T2_out when mem_d_sel = '1' else
					 T1_out when mem_d_sel = '0';
  
  
  -- Program Counter Dataflow logic
  PC_in <= CONST_0 when pc_in_select = "00" else                                                     -- check this 1
           r7pc when pc_in_select = "01" else
           ALU_out when pc_in_select = "11" else
           D1 when pc_in_select = "10" else
           CONST_32;

  -- Register File Dataflow
  A1 <= INSTRUCTION(11 downto 9) when a1_sel = '0' else
          INSTRUCTION(8 downto 6) when a1_sel = '1' 
          else "000";

  A2 <= INSTRUCTION(8 downto 6) when a2_sel = '0' else
           peout  when a2_sel = '1';
           --AR_out(2 downto 0) when a2_sel = '10' else "000" ;
           

  A3 <= INSTRUCTION(5 downto 3) when regwrite_select = "00" else         
            INSTRUCTION(11 downto 9) when regwrite_select = "01" else
            INSTRUCTION(8 downto 6) when regwrite_select = "10" else
            AR_out(2 downto 0) when regwrite_select = "11" else
            "000";

  DATA_T1 <= D1 when T1_sel = "00" else
             MEM_out when T1_sel = "01" else
             ALU_out when T1_sel = "10" else
              CONST_0;

   DATA_T2 <= D2 when T2_sel = "00" else
             MEM_out when T2_sel = "01" else
             ALU_out when T2_sel = "10" else
              CONST_0;

  DATA_T3 <= INSTRUCTION(7 downto 0) when T3_sel = '1' else
             modpein when T3_sel = '0' else
              CONST_0(7 downto 0);
            

  D3 <=         T2_out when rf_d3_sel = "100" else
                MEM_out when rf_d3_sel = "001" else
                ls7_out when rf_d3_sel = "010" else
                PC_out when rf_d3_sel = "011" else
                T1_out when rf_d3_sel = "000"else
					 Const_0;
  

  ir_out(15 downto 0) <= INSTRUCTION(15 downto 0) ; 
  carry <= carry_v(0);
  zero <= zero_v(0);


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
        carry => ALU_carry(0),
        zero => ALU_zero(0)
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
  reg_file: rf
      port map (
        clk => clk,
        R7_PC => r7PC,
        D_PC => PC_out,
        pc_r7 => pc_write,
		  reset => reset,
        
        D1 => D1,
        D2 => D2,
        A1 => A1,
        A2 => A2,
        A3 => A3,
        rf_wr => reg_write,
        D3 => D3
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
  SE_6: se6
      port map (
        se6_in => INSTRUCTION(5 downto 0),
        se6_out => SE6_out
      );

  SE_9: se9
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
        Dout => CARRY_v,
        Enable => carry_en,
        clk => clk
      );


  ZR: dreg
      generic map (data_width => 1)
      port map (
        Din => ALU_zero,
        Dout => ZERO_v,
        Enable => zero_en,
        clk => clk
      );


  PE: pr_encoder
      port map (
        pein => T3_out,
        peout => peout,
        modpein => modpein,
        pego => pego
      );

    AR: dreg
      generic map (data_width => 3)
      port map (
        Din => peout,
        Dout => AR_out,
        Enable => ar_write,
        clk => clk
      );
  

 
end behave_dp;