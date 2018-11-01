library std;
library ieee;
use ieee.std_logic_1164.all;
library ieee;
use ieee.numeric_std.all; 
library std;
use std.standard.all;


entity Controller is
  port (
    -- Instruction Register write
    inst_write: out std_logic;

    -- Program counter write / select
    pc_write: out std_logic;
    pc_in_select: out std_logic_vector(1 downto 0);

    -- Select the two ALU inputs / op_code
    alu1_select: out std_logic_vector(1 downto 0);
    alu2_select: out std_logic_vector(1 downto 0);

    -- Select the correct inputs to memory
    addr_select: out std_logic_vector(1 downto 0);
	MEMWRITE: out std_logic;
	
	t1_sel: out std_logic_vector(1 downto 0);
    t2_sel: out std_logic_vector(1 downto 0);
    t3_sel: out std_logic;

    -- Choices for Register file
    a1_sel: out std_logic;
    a2_sel: out std_logic;
    rf_d3_sel: out std_logic_vector(1 downto 0);
    regwrite_select: out std_logic_vector(1 downto 0);
    reg_write: out std_logic;
    t1_write, t2_write,t3_write, ar_write, PC_en, rd, alu_op_sel,mem_d_sel : out std_logic;

    -- Control signals which decide whether or not to set carry flag
    carry_en, zero_en: out std_logic;
	
	pego: in std_logic;
    CARRY, ZERO: in std_logic;
    ir_out: in std_logic_vector(15 downto 0);


    -- clock and reset pins, if reset is high, external memory signals
    -- active.
    clk, reset: in std_logic;
	 ns : out std_logic_vector(4 downto 0)
  );
end entity;

architecture Struct of Controller is
  type FsmState is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11,S12, S13, S14, S15, S16);
  signal state: FsmState;
  signal op_code: std_logic_vector(3 downto 0) := ir_out(15 downto 12);
  signal op_diff: std_logic_vector(1 downto 0) := ir_out(1 downto 0);
  signal nstate : FsmState;
begin

  op_code(3 downto 0) <= ir_out(15 downto 12);
  op_diff(1 downto 0) <= ir_out(1 downto 0);
  -- Next state process
    
  process(clk, reset, state, op_code, op_diff, CARRY, ZERO, pego, ir_out)
--    variable nstate: FsmState;

  begin
    nstate <= S0;
    case state is
      when S0 =>  -- First state whenever the code is loaded
        nstate <= S1;
      
	  when S1 =>  -- Always the first state of every instruction.
        nstate <= S2;
      
	  when S2 =>  -- Common Second state of all instructions
      if op_code = "1100" then
		  nstate <= S3;
		elsif  op_code = "0000" then
  		  if op_diff = "10" and CARRY = '0' then
		    nstate <= S1;
		  elsif op_diff = "01" and ZERO = '0' then
		    nstate <= S1;
		  else
		    nstate <= S3;
		  end if;
		elsif  op_code = "0010" then
  		  if op_diff = "10" and CARRY = '0' then
		    nstate <= S1;
		  elsif op_diff = "01" and ZERO = '0' then
		    nstate <= S1;
		  else
		    nstate <= S3;
		  end if;
       elsif op_code = "0001" then
          nstate <= S5;
       elsif op_code = "0100" or op_code = "0101" then
          nstate <= S6;
       elsif op_code = "1000" then
          nstate <= S10;
       elsif op_code = "1001" then
          nstate <= S11;
       elsif op_code = "0011" then
          nstate <= S12;
       elsif op_code = "0110" then
          nstate <= S13;
       elsif op_code = "0111" then
          nstate <= S14;
       else
          nstate <= S1;
       end if;
      
	  when S3 =>  -- For ALU operations: ADD,ADC,ADZ,NDU,NDZ,NDC,BEQ
        if op_code = "1100" then
		  nstate <= S9;
		else 
		  nstate <= S4;
		end if;
      
	  when S4 =>  -- For ADZ,ADC,NDC,NDZ
        nstate <= S1;
      
	  when S5 =>  -- For ADI
        nstate <= S4;
      
	  when S6 =>  -- For LW, SW
        if op_code = "0100" then
		    nstate <= S7;
		  elsif op_code = "0101" then
		    nstate <= S8;
		  else
		    nstate <= S1;
		  end if;
      
	  when S7 =>  -- For LW
        nstate <= S4;
      
	  when S8 =>  -- For SW
        nstate <= S1;
      
	  when S9 =>  -- For BEQ
          nstate <= S1;
  
      when S10 => --For JAL
        nstate <= S1;
      
	  when S11 => -- For JLR
        nstate <= S1;
		
      when S12 => -- For LHI
        nstate <= S1;
		
      when S13 => -- For LM
        if pego = '1' then
		  nstate <= S15;
		  else 
		  nstate <= S1;
		  end if;
      
	  when S14 =>-- For SM
      if pego = '1' then
		  nstate <= S16;
		else 
		  nstate <= S1;
		end if;
      
	  when S15 => -- For LM
        nstate <= S13; 
      
	  when S16 => -- For SM
        nstate <= S14;
      
	  when others =>
        nstate <= S1;
    end case;
	 end process;
	 
   process(clk,nstate)
	begin
	if(clk'event and clk = '1') then
      if(reset = '1') then
        state <= S0;
      else
        state <= nstate;
      end if;
    end if;
	 
	 if(nstate = S0) then
		ns <= "00000";
	 elsif(nstate = S1) then
		ns <= "00001";
	 elsif(nstate = S2) then
		ns <= "00010";
	 elsif(nstate = S3) then
		ns <= "00011";
	 elsif(nstate = S4) then
		ns <= "00100";
	 elsif(nstate = S5) then
		ns <= "00101";
	 elsif(nstate = S6) then
		ns <= "00110";
	 elsif(nstate = S7) then
		ns <= "00111";
	 elsif(nstate = S8) then
		ns <= "01000";
	 elsif(nstate = S9) then
		ns <= "01001";
	 elsif(nstate = S10) then
		ns <= "01010";
	 elsif(nstate = S11) then
		ns <= "01011";
	 elsif(nstate = S12) then
		ns <= "01100";
	 elsif(nstate = S13) then
		ns <= "01101";
	 elsif(nstate = S14) then
		ns <= "01110";
	 elsif(nstate = S15) then
		ns <= "01111";
	 else
		ns <= "10000";
		end if;
	 end process;


-- Control Signal process

process(state, ZERO,CARRY, pego, reset, ir_out,op_code)
    variable n_inst_write: std_logic;
	variable n_pc_write: std_logic;
    variable n_pc_in_select: std_logic_vector(1 downto 0);
    variable n_alu1_select: std_logic_vector(1 downto 0);
    variable n_alu2_select: std_logic_vector(1 downto 0);
    variable n_addr_select: std_logic_vector(1 downto 0);
    variable n_MEMWRITE: std_logic;
    variable n_regwrite_select: std_logic_vector(1 downto 0);
    variable n_reg_write: std_logic;
    variable n_t1_write: std_logic;
    variable n_t2_write: std_logic;
	variable n_t3_write: std_logic;
	variable n_t1_sel: std_logic_vector(1 downto 0);
    variable n_t2_sel: std_logic_vector(1 downto 0);
	variable n_t3_sel: std_logic;
	variable n_a1_sel: std_logic;
	variable n_a2_sel: std_logic;
	variable n_mem_d_sel: std_logic;
    variable n_rf_d3_sel: std_logic_vector(1 downto 0);
    variable n_zero_en: std_logic;
	variable n_carry_en: std_logic;
    variable n_PC_en: std_logic;
    variable n_rd: std_logic;
    variable n_ar_write: std_logic;
	variable n_alu_op_sel: std_logic;
  begin
    n_inst_write := '0';
    n_pc_write := '0';
    n_pc_in_select := "00";
    n_alu1_select := "00";
    n_alu2_select := "00";
    n_addr_select := "00";
    n_MEMWRITE := '0';
    n_regwrite_select := "00";
    n_reg_write := '0';
    n_t1_write := '0';
    n_t2_write := '0';
	n_t3_write := '0';
	n_t1_sel := "00";
    n_t2_sel := "00";
	n_t3_sel := '0';
	n_a1_sel := '0';
	n_a2_sel := '0';
	n_mem_d_sel := '0';
    n_rf_d3_sel:= "00";
    n_zero_en := '0';
    n_carry_en := '0';
    n_PC_en := '0';
    n_rd := '0';
    n_ar_write := '0';
	n_alu_op_sel := '0';
	
	case state is
	
	when S0 =>
	n_inst_write := '0';
    n_pc_write := '0';
    n_pc_in_select := "00";
    n_alu1_select := "00";
    n_alu2_select := "00";
    n_addr_select := "00";
    n_MEMWRITE := '0';
    n_regwrite_select := "00";
    n_reg_write := '0';
    n_t1_write := '0';
    n_t2_write := '0';
	n_t3_write := '0';
	n_t1_sel := "00";
    n_t2_sel := "00";
	n_t3_sel := '0';
	n_a1_sel := '0';
	n_a2_sel := '0';
	n_mem_d_sel := '0';
    n_rf_d3_sel:= "00";
    n_zero_en := '0';
    n_carry_en := '0';
    n_PC_en := '0';
    n_rd := '0';
    n_ar_write := '0';
	n_alu_op_sel := '0';
		
	when S1 =>
	n_rd := '1';
	n_alu_op_sel := '0';
	n_PC_en := '1';
	n_inst_write := '1';
	n_pc_in_select := "11";
	n_addr_select := "00";
	n_alu1_select := "00";
    n_alu2_select := "00";
	
	n_pc_write := '0';
    n_MEMWRITE := '0';
    n_regwrite_select := "00";
    n_reg_write := '0';
    n_t1_write := '0';
    n_t2_write := '0';
	n_t3_write := '0';
	n_t1_sel := "00";
    n_t2_sel := "00";
	n_t3_sel := '0';
	n_a1_sel := '0';
	n_a2_sel := '0';
	n_mem_d_sel := '0';
    n_rf_d3_sel:= "00";
    n_zero_en := '0';
    n_carry_en := '0';
    n_ar_write := '0';
	
	when S2 =>
    n_a1_sel := '0';
	n_a2_sel := '0';
    n_t1_write := '1';
    n_t2_write := '1';
	n_t3_write := '1';	
	n_pc_write := '1';
	n_t3_sel := '1';
	n_t1_sel := "00";
    n_t2_sel := "00";
	n_reg_write := '0';
	
	n_regwrite_select := "00";
	n_inst_write := '0';
    n_pc_in_select := "00";
    n_alu1_select := "00";
    n_alu2_select := "00";
    n_addr_select := "00";
    n_MEMWRITE := '0';
	n_t3_write := '0';
	n_mem_d_sel := '0';
    n_rf_d3_sel:= "00";
    n_zero_en := '0';
    n_carry_en := '0';
    n_PC_en := '0';
    n_rd := '0';
    n_ar_write := '0';
	n_alu_op_sel := '0';
	
	when S3 =>
	n_alu_op_sel := '1';
	n_zero_en := '1';
	if(op_code = "0000") then
    n_carry_en := '1';
	else 
	 n_carry_en := '0';
	end if;
	n_alu1_select := "01";
    n_alu2_select := "01";
	n_t1_write := '1';
	n_t1_sel := "10";
	
	n_inst_write := '0';
    n_pc_write := '0';
    n_pc_in_select := "00";
    n_addr_select := "00";
    n_MEMWRITE := '0';
    n_regwrite_select := "00";
    n_reg_write := '0';
    n_t2_write := '0';
	n_t3_write := '0';
    n_t2_sel := "00";
	n_t3_sel := '0';
	n_a1_sel := '0';
	n_a2_sel := '0';
	n_mem_d_sel := '0';
    n_rf_d3_sel:= "00";
    n_PC_en := '0';
    n_rd := '0';
    n_ar_write := '0';
	
	when S4 =>
	if op_code = "0000" or op_code = "0010" then
	  n_regwrite_select := "00";
	elsif op_code = "0001" then
	  n_regwrite_select := "10";
	else
	  n_regwrite_select := "01";
	end if;
    n_rf_d3_sel:= "00";
	n_reg_write := '1';
	n_PC_en := '1';
	n_pc_in_select := "01";
	
	n_inst_write := '0';
    n_pc_write := '0';
    n_alu1_select := "00";
    n_alu2_select := "00";
    n_addr_select := "00";
    n_MEMWRITE := '0';
    n_t1_write := '0';
    n_t2_write := '0';
	n_t3_write := '0';
	n_t1_sel := "00";
    n_t2_sel := "00";
	n_t3_sel := '0';
	n_a1_sel := '0';
	n_a2_sel := '0';
	n_mem_d_sel := '0';
    n_zero_en := '0';
    n_carry_en := '0';
    n_rd := '0';
    n_ar_write := '0';
	n_alu_op_sel := '0';
	
	when S5 =>
	n_alu1_select := "01";
    n_alu2_select := "10";
	n_t1_write := '1';
	n_t1_sel := "10";
	n_zero_en := '1';
    n_carry_en := '1';
	n_alu_op_sel := '0';
	
	n_inst_write := '0';
    n_pc_write := '0';
    n_pc_in_select := "00";
    n_addr_select := "00";
    n_MEMWRITE := '0';
    n_regwrite_select := "00";
    n_reg_write := '0';
    n_t2_write := '0';
	n_t3_write := '0';
    n_t2_sel := "00";
	n_t3_sel := '0';
	n_a1_sel := '0';
	n_a2_sel := '0';
	n_mem_d_sel := '0';
    n_rf_d3_sel:= "00";
    n_PC_en := '0';
    n_rd := '0';
    n_ar_write := '0';
	
	when S6 =>
	n_alu_op_sel := '0';
	n_alu1_select := "10";
    n_alu2_select := "10";
	n_t2_write := '1';
	n_t2_sel := "10";
	n_zero_en := '1';
	
	n_inst_write := '0';
    n_pc_write := '0';
    n_pc_in_select := "00";
    n_addr_select := "00";
    n_MEMWRITE := '0';
    n_regwrite_select := "00";
    n_reg_write := '0';
    n_t1_write := '0';
	n_t3_write := '0';
	n_t1_sel := "00";
	n_t3_sel := '0';
	n_a1_sel := '0';
	n_a2_sel := '0';
    n_rf_d3_sel:= "00";
    n_carry_en := '0';
    n_PC_en := '0';
    n_rd := '0';
    n_ar_write := '0';
	 n_mem_d_sel := '0';
	
	when S7 =>
	n_rd := '1';
	n_addr_select := "11";
	n_t1_write := '1';
	n_t1_sel := "01";
	
	n_inst_write := '0';
    n_pc_write := '0';
    n_pc_in_select := "00";
    n_alu1_select := "00";
    n_alu2_select := "00";
    n_MEMWRITE := '0';
    n_regwrite_select := "00";
    n_reg_write := '0';
    n_t2_write := '0';
	n_t3_write := '0';
    n_t2_sel := "00";
	n_t3_sel := '0';
	n_a1_sel := '0';
	n_a2_sel := '0';
	n_mem_d_sel := '0';
    n_rf_d3_sel:= "00";
    n_zero_en := '0';
    n_carry_en := '0';
    n_PC_en := '0';
    n_ar_write := '0';
	n_alu_op_sel := '0';
	
	when S8 =>
	n_addr_select := "11";
	n_MEMWRITE := '1';
	n_mem_d_sel := '0';
	
	n_inst_write := '0';
    n_pc_write := '0';
    n_pc_in_select := "00";
    n_alu1_select := "00";
    n_alu2_select := "00";
    n_regwrite_select := "00";
    n_reg_write := '0';
    n_t1_write := '0';
    n_t2_write := '0';
	n_t3_write := '0';
	n_t1_sel := "00";
    n_t2_sel := "00";
	n_t3_sel := '0';
	n_a1_sel := '0';
	n_a2_sel := '0';
    n_rf_d3_sel:= "00";
	n_rd := '0';
    n_zero_en := '0';
    n_carry_en := '0';
    n_PC_en := '0';
    n_ar_write := '0';
	n_alu_op_sel := '0';
	
	when S9 =>
	n_alu_op_sel := '0';
	n_alu1_select := "00";
    n_alu2_select := "10";
	if ZERO = '1' then
	  n_PC_en := '1';
	  n_pc_in_select := "11";
	else 
	  n_t2_write := '1';
	  n_t2_sel := "10";
	end if;
	
	n_inst_write := '0';
    n_pc_write := '0';
    n_addr_select := "00";
    n_MEMWRITE := '0';
    n_regwrite_select := "00";
    n_reg_write := '0';
    n_t1_write := '0';
	n_t3_write := '0';
	n_t1_sel := "00";
	n_t3_sel := '0';
	n_a1_sel := '0';
	n_a2_sel := '0';
	n_mem_d_sel := '0';
    n_rf_d3_sel:= "00";
    n_zero_en := '0';
    n_carry_en := '0';
    n_rd := '0';
    n_ar_write := '0';
	
	when S10 =>
	n_reg_write := '1';
	n_regwrite_select := "01";
	n_rf_d3_sel:= "11";
	n_alu1_select := "00";
    n_alu2_select := "11";
	n_PC_en := '0';
	n_pc_in_select := "11";
	n_alu_op_sel := '0';
	
	n_inst_write := '0';
    n_pc_write := '0';
    n_addr_select := "00";
    n_MEMWRITE := '0';
    n_t1_write := '0';
    n_t2_write := '0';
	n_t3_write := '0';
	n_t1_sel := "00";
    n_t2_sel := "00";
	n_t3_sel := '0';
	n_a1_sel := '0';
	n_a2_sel := '0';
	n_mem_d_sel := '0';
    n_zero_en := '0';
    n_carry_en := '0';
    n_rd := '0';
    n_ar_write := '0';
	
	when S11 =>
	n_rf_d3_sel:= "11";
	n_regwrite_select := "01";
	n_a1_sel := '1';
	n_pc_in_select := "10";
	n_PC_en := '1';
	n_reg_write := '1';
	
	n_inst_write := '0';
    n_pc_write := '0';
    n_alu1_select := "00";
    n_alu2_select := "00";
    n_addr_select := "00";
    n_MEMWRITE := '0';
    n_t1_write := '0';
    n_t2_write := '0';
	n_t3_write := '0';
	n_t1_sel := "00";
    n_t2_sel := "00";
	n_t3_sel := '0';
	n_a2_sel := '0';
	n_mem_d_sel := '0';
    n_zero_en := '0';
    n_carry_en := '0';
    n_rd := '0';
    n_ar_write := '0';
	n_alu_op_sel := '0';
	
	when S12 =>
	n_rf_d3_sel:= "10";
	n_regwrite_select := "01";
	n_reg_write := '1';
	
	n_inst_write := '0';
    n_pc_write := '0';
    n_pc_in_select := "00";
    n_alu1_select := "00";
    n_alu2_select := "00";
    n_addr_select := "00";
    n_MEMWRITE := '0';
    n_t1_write := '0';
    n_t2_write := '0';
	n_t3_write := '0';
	n_t1_sel := "00";
    n_t2_sel := "00";
	n_t3_sel := '0';
	n_a1_sel := '0';
	n_a2_sel := '0';
	n_mem_d_sel := '0';
    n_zero_en := '0';
    n_carry_en := '0';
    n_PC_en := '0';
    n_rd := '0';
    n_ar_write := '0';
	n_alu_op_sel := '0';
	
	when S13 =>
	n_rd := '1';
	n_alu_op_sel := '0';
	n_PC_en := '1';
	n_t3_write := '1';
	n_pc_in_select := "01";
	n_t3_sel := '0';
	n_ar_write := '1';
	if pego = '1' then
	  n_alu1_select := "01";
      n_alu2_select := "00";
	  n_addr_select := "10";
	  n_t1_write := '1';
      n_t2_write := '1';
	  n_t1_sel := "10";
      n_t2_sel := "01";
	else
	  n_t2_write := '1';
	  n_t2_sel := "10";
	end if;  
	
	n_inst_write := '0';
    n_pc_write := '0';
    n_MEMWRITE := '0';
    n_regwrite_select := "00";
    n_reg_write := '0';
	n_a1_sel := '0';
	n_a2_sel := '0';
	n_mem_d_sel := '0';
    n_rf_d3_sel:= "00";
    n_zero_en := '0';
    n_carry_en := '0';
	
	when S14 =>
	n_PC_en := '1';
	n_pc_in_select := "01";
	n_t3_write := '1';
	n_t3_sel := '0';
	if pego = '1' then
	  n_a2_sel := '1';
	  n_t2_write := '1';
	  n_t2_sel := "00";
	else
	  n_t2_write := '1';
	  n_t2_sel := "10";
    end if;
	
	n_inst_write := '0';
    n_pc_write := '0';
    n_alu1_select := "00";
    n_alu2_select := "00";
    n_addr_select := "00";
    n_MEMWRITE := '0';
    n_regwrite_select := "00";
    n_reg_write := '0';
    n_t1_write := '0';
	n_t1_sel := "00";
	n_a1_sel := '0';
	n_mem_d_sel := '0';
    n_rf_d3_sel:= "00";
    n_zero_en := '0';
    n_carry_en := '0';
    n_rd := '0';
    n_ar_write := '0';
	n_alu_op_sel := '0';
	
	when S15 =>
	n_reg_write := '1';
	n_regwrite_select := "11";
	n_rf_d3_sel:= "01";
	
	n_inst_write := '0';
    n_pc_write := '0';
    n_pc_in_select := "00";
    n_alu1_select := "00";
    n_alu2_select := "00";
    n_addr_select := "00";
    n_MEMWRITE := '0';
    n_t1_write := '0';
    n_t2_write := '0';
	n_t3_write := '0';
	n_t1_sel := "00";
    n_t2_sel := "00";
	n_t3_sel := '0';
	n_a1_sel := '0';
	n_a2_sel := '0';
	n_mem_d_sel := '0';
    n_zero_en := '0';
    n_carry_en := '0';
    n_PC_en := '0';
    n_rd := '0';
    n_ar_write := '0';
	n_alu_op_sel := '0';
	
	when S16 => 
	n_MEMWRITE := '1';
	n_alu_op_sel := '0';
	n_alu1_select := "01";
    n_alu2_select := "00";
	n_addr_select := "10";
	n_mem_d_sel := '1';
	n_t1_write := '1';
	n_t1_sel := "10";
	
	n_inst_write := '0';
    n_pc_write := '0';
    n_pc_in_select := "00";
    n_regwrite_select := "00";
    n_reg_write := '0';
    n_t2_write := '0';
	n_t3_write := '0';
    n_t2_sel := "00";
	n_t3_sel := '0';
	n_a1_sel := '0';
	n_a2_sel := '0';
    n_rf_d3_sel:= "00";
    n_zero_en := '0';
    n_carry_en := '0';
    n_PC_en := '0';
    n_rd := '0';
    n_ar_write := '0';
	end case;
	
	if reset = '1' then
	  inst_write <= '0';
      pc_write <= '0';
      pc_in_select <= "00";
      alu1_select <= "00";
      alu2_select <= "00";
      addr_select <= "00";
      MEMWRITE <= '0';
      regwrite_select <= "00";
      reg_write <= '0';
      t1_write <= '0';
      t2_write <= '0';
	  t3_write <= '0';
	  t1_sel <= "00";
      t2_sel <= "00";
	  t3_sel <= '0';
	  a1_sel <= '0';
	  a2_sel <= '0';
	  mem_d_sel <= '0';
      rf_d3_sel<= "00";
      zero_en <= '0';
      carry_en <= '0';
      PC_en <= '1';
      rd <= '0';
      ar_write <= '0';
	  alu_op_sel <= '0';
	else
	  inst_write <= n_inst_write ;
      pc_write <= n_pc_write;
      pc_in_select <= n_pc_in_select;
      alu1_select <= n_alu1_select;
      alu2_select <= n_alu2_select;
      addr_select <= n_addr_select;
      MEMWRITE <= n_MEMWRITE;
      regwrite_select <= n_regwrite_select;
      reg_write <= n_reg_write;
      t1_write <= n_t1_write;
      t2_write <= n_t2_write;
	  t3_write <= n_t3_write;
	  t1_sel <= n_t1_sel;
      t2_sel <= n_t2_sel;
	  t3_sel <= n_t3_sel;
	  a1_sel <= n_a1_sel;
	  a2_sel <= n_a2_sel;
	  mem_d_sel <= n_mem_d_sel;
      rf_d3_sel<= n_rf_d3_sel;
      zero_en <= n_zero_en;
      carry_en <= n_carry_en;
      PC_en <= n_PC_en;
      rd <= n_rd;
      ar_write <= n_ar_write;
	  alu_op_sel <= n_alu_op_sel;
	end if;
	
end process;

end Struct;