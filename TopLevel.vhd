library std;
library ieee;
use ieee.std_logic_1164.all;
library work;

entity TopLevel is
  port (
    clk, reset: in std_logic;
    -- Data coming from outside
    CARRY,ZERO: out std_logic
  );
end entity TopLevel;

architecture Struct of TopLevel is
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
    rf_d3_sel: out std_logic_vector(2 downto 0);
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
    clk, reset: in std_logic

component datapath is
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
    
    clk, reset: in std_logic);

end component;

component Controller is
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
    rf_d3_sel: out std_logic_vector(2 downto 0);
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
    clk, reset: in std_logic
  );
end component;

begin

CP: Controller
    port map (
    inst_write => inst_write,
    pc_write => pc_write,
    pc_in_select => pc_in_select,
    alu1_select => alu1_select,
    alu2_select => alu2_select,
    addr_select => addr_select,
    MEMWRITE => MEMWRITE,
    t1_sel => t1_sel,
    t2_sel => t2_sel,
    t3_sel => t3_sel,
    a1_sel => a1_sel,
    a2_sel => a2_sel,
    rf_d3_sel => rf_d3_sel,
    regwrite_select => regwrite_select,
    reg_write => reg_write,
    t1_write => t1_write,
    t2_write => t2_write,
    t3_write => t3_write,
    ar_write => ar_write,
    carry_en => carry_en,
    zero_en => zero_en,
    PC_en => PC_en,
    rd => rd,
    alu_op_sel => alu_op_sel,
    mem_d_sel => mem_d_sel,

    pego => pego,
    CARRY => CARRY,
    ZERO => ZERO,
    ir_out => ir_out,
    clk => clk,
    reset => reset
    );
DP: Datapath
    port map (
    inst_write => inst_write,
    pc_write => pc_write,
    pc_in_select => pc_in_select,
    alu1_select => alu1_select,
    alu2_select => alu2_select,
    addr_select => addr_select,
    MEMWRITE => MEMWRITE,
    t1_sel => t1_sel,
    t2_sel => t2_sel,
    t3_sel => t3_sel,
    a1_sel => a1_sel,
    a2_sel => a2_sel,
    rf_d3_sel => rf_d3_sel,
    regwrite_select => regwrite_select,
    reg_write => reg_write,
    t1_write => t1_write,
    t2_write => t2_write,
    t3_write => t3_write,
    ar_write => ar_write,
    carry_en => carry_en,
    zero_en => zero_en,
    PC_en => PC_en,
    rd => rd,
    alu_op_sel => alu_op_sel,
    mem_d_sel => mem_d_sel,

    pego => pego,
    CARRY => CARRY,
    ZERO => ZERO,
    ir_out => ir_out,
    clk => clk,
    reset => reset
    );
end Struct;