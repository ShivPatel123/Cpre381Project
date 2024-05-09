-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- MIPS_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a MIPS_Processor  
-- implementation.

-- 01/29/2019 by H3::Design created.
-------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

LIBRARY work;
USE work.MIPS_types.ALL;

ENTITY MIPS_Processor IS
  GENERIC (N : INTEGER := DATA_WIDTH);
  PORT (
    iCLK : IN STD_LOGIC;
    iRST : IN STD_LOGIC;
    iInstLd : IN STD_LOGIC;
    iInstAddr : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    iInstExt : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    oALUOut : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

END MIPS_Processor;
ARCHITECTURE structure OF MIPS_Processor IS

  COMPONENT mem IS
    GENERIC (
      ADDR_WIDTH : INTEGER;
      DATA_WIDTH : INTEGER);
    PORT (
      clk : IN STD_LOGIC;
      addr : IN STD_LOGIC_VECTOR((ADDR_WIDTH - 1) DOWNTO 0);
      data : IN STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0);
      we : IN STD_LOGIC := '1';
      q : OUT STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0));
  END COMPONENT;

  COMPONENT mips_reg_file IS
    PORT (
      i_CLK : IN STD_LOGIC; -- Clock Input
      i_RST : IN STD_LOGIC; -- Reset
      i_WE : IN STD_LOGIC; -- Write Enbale
      i_RSaddr : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- Read Address 1 (register)
      i_RTaddr : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- Read Address 2 (register)        
      i_RDaddr : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- Write Address (register)
      i_RDdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- Write Data
      o_RS : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- Read Output 1
      o_RT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)); -- Read Output 2   

  END COMPONENT;

  COMPONENT ALU IS
    PORT (
      i_RSDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_RTDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_IMM : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
      i_ALUOP : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      i_ALUSRC : IN STD_LOGIC;
      i_SHAMT : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      o_RESULT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_CARRYOUT : OUT STD_LOGIC;
      o_OVERFLOW : OUT STD_LOGIC;
      o_ZERO : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT fulladder_N IS
    GENERIC (N : INTEGER := 32);
    PORT (
      i_x1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      i_x2 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      i_cin : IN STD_LOGIC := '0';
      o_sum : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      o_cout : OUT STD_LOGIC);
  END COMPONENT;
  COMPONENT FetchLogic IS
    PORT (
      i_CLK : IN STD_LOGIC;
      i_RST : IN STD_LOGIC;
      i_BRANCH : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      i_JAL : IN STD_LOGIC;
      i_ZERO : IN STD_LOGIC;
      i_JR : IN STD_LOGIC;
      i_J : IN STD_LOGIC;
      i_PCPLUS4 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      i_IMM : IN STD_LOGIC_VECTOR(31 DOWNTO 0); --signed imm value after bitwidth extender
      i_RSDATA : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
      i_JADDRESS : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
      o_JALDATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_IMEMADDRESS : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
  END COMPONENT;

  COMPONENT PC IS
    PORT (
      i_CLK : IN STD_LOGIC;
      i_WE : IN STD_LOGIC;
      i_RST : IN STD_LOGIC;
      i_ADDRESS : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_ADDRESS : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));

  END COMPONENT;
  COMPONENT addersubtractor_N IS
    GENERIC (
      N : INTEGER := 32
    );
    PORT (
      i_A : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      i_B : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      i_Imm : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      i_Ctrl : IN STD_LOGIC;
      -- i_Unsigned : IN STD_LOGIC;
      i_ALUSrc : IN STD_LOGIC;
      o_sum : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      o_cout : OUT STD_LOGIC
    );
  END COMPONENT;
  COMPONENT n_bit_reg IS
    GENERIC (N : INTEGER := 32);
    PORT (
      i_D : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      i_RST : IN STD_LOGIC;
      i_CLK : IN STD_LOGIC;
      i_WE : IN STD_LOGIC;
      o_Q : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
    );
  END COMPONENT;
  COMPONENT control IS
    PORT (
      i_Op : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
      i_Funct : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
      o_RegDst : OUT STD_LOGIC; -- rt vs rd for different instruction types
      o_J : OUT STD_LOGIC; -- jump operation
      o_Branch : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- 0: no branch 1: beq 2: bne
      o_AxMOut : OUT STD_LOGIC; -- picks between ALUOut and MemOut for the datat to write back
      o_ALUOp : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- ALUOp
      o_MemWrite : OUT STD_LOGIC; -- Memory's WE
      o_ALUSrc : OUT STD_LOGIC; -- Picks between immidiate value and register operand
      o_Unsigned : OUT STD_LOGIC; -- 1 if unisigned instructions
      o_Jr : OUT STD_LOGIC; -- jr instruction
      o_Jal : OUT STD_LOGIC; -- jal instruction
      o_RegWrite : OUT STD_LOGIC; -- register file WE
      o_shiftSel : OUT STD_LOGIC; -- 1 if shamt part of the instructions needs to be used
      o_Halt : OUT STD_LOGIC;
      o_Lui : OUT STD_LOGIC
    );
  END COMPONENT;
  COMPONENT bit_width_extender IS
    PORT (
      signedval : IN STD_LOGIC;
      i_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      o_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
  END COMPONENT;

  COMPONENT mux2t1_N IS
    GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
    PORT (
      i_S : IN STD_LOGIC;
      i_D0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      i_D1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));

  END COMPONENT;
  -- TODO: You may add any additional signals or components your implementation 
  --       requires below this comment

  -- Required data memory signals
  SIGNAL s_DMemWr : STD_LOGIC; -- TODO: use this signal as the final active high data memory write enable signal
  SIGNAL s_DMemAddr : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- TODO: use this signal as the final data memory address input
  SIGNAL s_DMemData : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- TODO: use this signal as the final data memory data input
  SIGNAL s_DMemOut : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- TODO: use this signal as the data memory output

  -- Required register file signals 
  SIGNAL s_RegWr : STD_LOGIC; -- TODO: use this signal as the final active high write enable input to the register file
  SIGNAL s_RegWrAddr : STD_LOGIC_VECTOR(4 DOWNTO 0); -- TODO: use this signal as the final destination register address input
  SIGNAL s_RegWrData : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- TODO: use this signal as the final data memory data input
  -- Required instruction memory signals
  SIGNAL s_IMemAddr : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- Do not assign this signal, assign to s_NextInstAddr instead
  SIGNAL s_NextInstAddr : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- TODO: use this signal as your intended final instruction memory address input.
  SIGNAL s_Inst : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- TODO: use this signal as the instruction signal 

  -- Required halt signal -- for simulation
  SIGNAL s_Halt, s_HaltTemp, s_BranchYesOrNo, s_Extender : STD_LOGIC; -- TODO: this signal indicates to the simulation that intended program execution has completed. (Opcode: 01 0100)

  -- Required overflow signal -- for overflow exception detection
  SIGNAL s_Ovfl : STD_LOGIC; -- TODO: this signal indicates an overflow exception would have been initiated

  --control file signals
  SIGNAL s_RegDst, s_Unsigned, s_AluSrc, s_MemToReg, s_J, s_JAL, s_JR, s_LuiIndex : STD_LOGIC;
  SIGNAL s_AluOp : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL s_Branch : STD_LOGIC_VECTOR(1 DOWNTO 0);
  --ALU file Signals
  SIGNAL s_AluRsInput, s_LuiImm, s_AluOutput, s_AluRtInput, s_ImmTemp, s_SignExtender, s_ALUOutTemp : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
  SIGNAL s_Cout, s_RegWrDecode, s_ZeroAlu, s_Jump, s_DMemWrTemp, s_NotAndi : STD_LOGIC;

  --fetch signals
  SIGNAL s_JumpAddress, s_MemToRegData, s_ZeroChecker, s_LuiOrData, s_RegData, s_BranchAddress, s_BranchTemp, s_Target, s_TargetAddress, s_RegWriteData, s_BranchOrNext : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
  SIGNAL s_RegDest, s_RdorRt : STD_LOGIC_VECTOR(4 DOWNTO 0);

  --Pipeline register signals
  SIGNAL s_Fetch : STD_LOGIC_VECTOR(63 DOWNTO 0);
  SIGNAL s_Decode : STD_LOGIC_VECTOR(176 DOWNTO 0);
  SIGNAL s_Execute : STD_LOGIC_VECTOR(105 DOWNTO 0);
  SIGNAL s_Memory : STD_LOGIC_VECTOR(38 DOWNTO 0);
  SIGNAL s_CURRENTADDRESS, s_PCPLUS4 : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);

BEGIN

  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  --IF/ID Stage

  -- s_NextInstAddr <= s_TargetAddress WHEN iRST = '0' ELSE
  --   x"00000000";

  PC1 : PC
  PORT MAP(
    i_CLK => iCLK,
    i_WE => '1',
    i_RST => iRST,
    i_ADDRESS => s_TargetAddress,
    o_ADDRESS => s_CURRENTADDRESS);

  PCplus4 : addersubtractor_N
  GENERIC MAP(n => 32)
  PORT MAP(
    i_A => s_CURRENTADDRESS, -- Current PC
    i_B => (OTHERS => '0'), -- Unused for branch
    i_Imm => X"00000004", -- Branch offset
    i_Ctrl => '0',
    i_ALUSrc => '1',
    o_sum => s_PCPLUS4, -- Result of addition
    o_cout => OPEN -- Unused for branch
  );

  s_NextInstAddr <= s_CURRENTADDRESS;

  WITH iInstLd SELECT
    s_IMemAddr <= s_NextInstAddr WHEN '0',
    iInstAddr WHEN OTHERS;
  IMem : mem
  GENERIC MAP(
    ADDR_WIDTH => ADDR_WIDTH,
    DATA_WIDTH => N)
  PORT MAP(
    clk => iCLK,
    addr => s_IMemAddr(11 DOWNTO 2),
    data => iInstExt,
    we => iInstLd,
    q => s_Inst);

  -- current address 32 bits 63 to 32
  -- instruction code 32 bits 32 to 0
  Fetch : n_bit_reg
  GENERIC MAP(N => 64)
  PORT MAP(
    i_D (31 DOWNTO 0) => s_Inst,
    i_D (63 DOWNTO 32) => s_PCPLUS4,
    i_RST => iRST,
    i_CLK => iCLK,
    i_WE => '1',
    o_Q => s_Fetch
  );

  --ID/EX Stage

  -- s_NotAndi <= '1' WHEN (NOT (s_Fetch(31 DOWNTO 26) = "001100")) ELSE
  --   '0';
  -- s_Extender <= '0' WHEN (s_Fetch(15) = '1' AND s_NotAndi = '1') ELSE
  --   s_Unsigned;

  -- SignExtender : bit_width_extender
  -- PORT MAP(
  --   signedval => s_Extender,
  --   i_in => s_Fetch(15 DOWNTO 0),
  --   o_out => s_ImmTemp);

  -- brancheqcheck : addersubtractor_N
  -- GENERIC MAP(N => 32)
  -- PORT MAP(
  --   i_A => s_Fetch(25 DOWNTO 21),
  --   i_B => s_Fetch(20 DOWNTO 16),
  --   i_Imm => X"00000000",
  --   i_Ctrl => '1',
  --   i_ALUSrc => '0',
  --   o_sum => s_BranchComparison,
  --   o_cout => OPEN
  -- );

  -- s_ZERO <= '1' WHEN s_BranchComparison = X"00000000" ELSE
  --   '0';

  -- fetch : FetchLogic
  -- PORT MAP(
  --   i_CLK => iCLK,
  --   i_RST => iRST,
  --   i_BRANCH => s_Branch,
  --   i_JAL => s_Jal,

  --   i_ZERO => s_Zero, --****NEED TO FIX IMPLEMENT COMPARATOR IN DECODE!!!!!****
  --   i_PCPLUS4 => s_Fetch(63 DOWNTO 32),
  --   i_JR => s_Jr,
  --   i_J => s_J,
  --   i_IMM => s_ImmTemp, --signed imm value after bitwidth extender
  --   i_RSDATA => s_AluRsInput,
  --   i_JADDRESS => s_JumpAddress,
  --   o_JALDATA => s_JalData,
  --   o_IMEMADDRESS => s_NextInstAddr
  -- );
  RegisterFile : mips_reg_file
  PORT MAP(
    i_CLK => iCLK, -- Clock Input
    i_RST => iRST, -- Reset
    i_WE => s_RegWr, -- Write Enbale
    i_RSaddr => s_Fetch(25 DOWNTO 21), -- Read Address 1 (register)
    i_RTaddr => s_Fetch(20 DOWNTO 16), -- Read Address 2 (register)        
    i_RDaddr => s_RegWrAddr, -- Write Address (register)
    i_RDdata => s_RegWrData, -- Write Data
    o_RS => s_AluRsInput, -- Read Output 1 goes to alu
    o_RT => s_AluRtInput); -- Read Output 2   goes to mux to choose between imm and rt

  ControlUnit : control
  PORT MAP(
    i_Op => s_Fetch(31 DOWNTO 26),
    i_Funct => s_Fetch(5 DOWNTO 0),
    o_RegDst => s_RegDst, -- rt vs rd for different instruction types
    o_J => s_J, -- jump operation
    o_Branch => s_Branch, -- 0: no branch 1: beq 2: bne
    o_AxMOut => s_MemToReg, -- picks between ALUOut and MemOut for the datat to write back
    o_ALUOp => s_AluOp, -- ALUOp
    o_MemWrite => s_DMemWrTemp, -- Memory's WE
    o_ALUSrc => s_AluSrc, -- Picks between immidiate value and register operand
    o_Unsigned => s_Unsigned, -- 1 if unisigned instructions
    o_Jr => s_Jr, -- jr instruction
    o_Jal => s_Jal, -- jal instruction
    o_RegWrite => s_RegWrDecode, -- register file WE
    o_shiftSel => OPEN, -- 1 if shamt part of the instructions needs to be used
    o_Halt => s_HaltTemp,
    o_Lui => s_LuiIndex
  );

  s_NotAndi <= '1' WHEN (NOT (s_Fetch(31 DOWNTO 26) = "001100" OR s_Fetch(31 DOWNTO 26) = "001101" OR s_Fetch(31 DOWNTO 26) = "001110")) ELSE
    '0';
  -- s_Extender <= '0' WHEN (s_Fetch(15) = '1' AND s_NotAndi = '1') ELSE
  --   s_Unsigned;

  SignExtender : bit_width_extender
  PORT MAP(
    signedval => s_Unsigned,
    i_in => s_Fetch(15 DOWNTO 0),
    o_out => s_SignExtender);

  s_ImmTemp <= X"FFFF" & s_Fetch(15 DOWNTO 0) WHEN s_Unsigned = '1' AND s_Fetch(15) = '1' AND s_NotAndi = '1' ELSE
    s_SignExtender;
  s_BranchTemp <= s_ImmTemp(29 DOWNTO 0) & "00";

  branchAddress : fulladder_N
  GENERIC MAP(N => 32)
  PORT MAP(
    i_x1 => s_Fetch(63 DOWNTO 32),
    i_x2 => s_BranchTemp,
    i_cin => '0',
    o_sum => s_BranchAddress,
    o_cout => OPEN
  );

  Comparator : addersubtractor_N
  GENERIC MAP(
    N => 32
  )
  PORT MAP(
    i_A => s_AluRsInput,
    i_B => s_AluRtInput,
    i_Imm => X"00000000",
    i_Ctrl => '1',
    i_ALUSrc => '0',
    o_sum => s_ZeroChecker,
    o_cout => OPEN
  );

  s_ZeroAlu <= '1' WHEN s_ZeroChecker = X"00000000" ELSE
    '0';

  s_BranchYesOrNo <= (s_Branch(0) AND s_ZeroAlu) OR (s_Branch(1) AND (NOT s_ZeroAlu));

  Branchselector : mux2t1_N
  GENERIC MAP(N => 32)
  PORT MAP(
    i_D0 => s_PCPLUS4,
    i_D1 => s_BranchAddress,
    i_S => s_BranchYesOrNo,
    o_O => s_BranchOrNext
  );

  s_JumpAddress <= "0000" & s_Decode(25 DOWNTO 0) & "00";

  s_Jump <= s_Decode(129) OR s_Decode(141);

  TargetAddress : mux2t1_N
  GENERIC MAP(N => 32)
  PORT MAP(
    i_D0 => s_BranchOrNext,
    i_D1 => s_JumpAddress,
    i_S => s_Jump,
    o_O => s_Target
  );

  jrSelect : mux2t1_N
  GENERIC MAP(N => 32)
  PORT MAP(
    i_D0 => s_Target,
    i_D1 => s_Decode(95 DOWNTO 64),
    i_S => s_Decode(140),
    o_O => s_TargetAddress
  );

  Decode : n_bit_reg
  GENERIC MAP(N => 177)
  PORT MAP(
    i_D (31 DOWNTO 0) => s_Fetch(31 DOWNTO 0),
    i_D(63 DOWNTO 32) => s_Fetch(63 DOWNTO 32),
    i_D(95 DOWNTO 64) => s_AluRsInput,
    i_D(127 DOWNTO 96) => s_AluRtInput,
    i_D(128) => s_RegDst,
    i_D(129) => s_J,
    i_D(131 DOWNTO 130) => s_Branch,
    i_D(132) => s_MemToReg,
    i_D(136 DOWNTO 133) => s_AluOp,
    i_D(137) => s_DMemWrTemp,
    i_D(138) => s_AluSrc,
    i_D(139) => s_Unsigned,
    i_D(140) => s_Jr,
    i_D(141) => s_Jal,
    i_D(142) => s_RegWrDecode,
    i_D(143) => s_HaltTemp,
    i_D(144) => s_LuiIndex,
    i_D(176 DOWNTO 145) => s_ImmTemp,
    i_RST => iRST,
    i_CLK => iCLK,
    i_WE => '1',
    o_Q => s_Decode
  );
  --EX Stage
  RtorRd : mux2t1_N
  GENERIC MAP(N => 5)
  PORT MAP(
    i_D0 => s_Decode(20 DOWNTO 16),
    i_D1 => s_Decode(15 DOWNTO 11),
    i_S => s_Decode(128),
    o_O => s_RdorRt
  );

  RegDest : mux2t1_N
  GENERIC MAP(N => 5)
  PORT MAP(
    i_D0 => s_RdorRt,
    i_D1 => "11111",
    i_S => s_Decode(141),
    o_O => s_RegDest
  );
  ALUnit : ALU
  PORT MAP(
    i_RSDATA => s_Decode(95 DOWNTO 64),
    i_RTDATA => s_Decode(127 DOWNTO 96),
    i_IMM => s_Decode(176 DOWNTO 145),
    i_ALUOP => s_Decode(136 DOWNTO 133),
    i_ALUSRC => s_Decode(138),
    i_SHAMT => s_Decode(10 DOWNTO 6),
    o_RESULT => s_ALUOutTemp,
    o_CARRYOUT => OPEN,
    o_OVERFLOW => OPEN,
    o_ZERO => OPEN -- used for branch comparison
  );

  oALUOut <= s_ALUOutTemp;
  JalWrite : mux2t1_N
  GENERIC MAP(N => 32)
  PORT MAP(
    i_D0 => s_ALUOutTemp,
    i_D1 => s_Decode(63 DOWNTO 32),
    i_S => s_Decode(141),
    o_O => s_RegData
  );

  Execute : n_bit_reg
  GENERIC MAP(N => 106)
  PORT MAP(
    i_D (31 DOWNTO 0) => s_RegData,
    i_D (63 DOWNTO 32) => s_Decode(127 DOWNTO 96),
    i_D (68 DOWNTO 64) => s_RegDest,
    i_D (69) => s_Decode(137), --MemWe
    i_D(70) => s_Decode(143), --halt
    i_D(71) => s_Decode(132), --memtoreg
    i_D(72) => s_Decode(142), --reg write
    i_D(73) => s_Decode(144), --lui yes or no
    i_D(105 DOWNTO 74) => s_Decode(31 DOWNTO 0),
    i_RST => iRST,
    i_CLK => iCLK,
    i_WE => '1',
    o_Q => s_Execute
  );
  --MEM Stage
  s_DMemData <= s_Execute(63 DOWNTO 32);
  s_DMemAddr <= s_Execute(31 DOWNTO 0);
  s_DMemWr <= s_Execute(69);
  DMem : mem
  GENERIC MAP(
    ADDR_WIDTH => ADDR_WIDTH,
    DATA_WIDTH => N)
  PORT MAP(
    clk => iCLK,
    addr => s_DMemAddr(11 DOWNTO 2),
    data => s_DMemData,
    we => s_DMemWr,
    q => s_DMemOut);

  -- MemToReg : mux2t1_N
  -- GENERIC MAP(N => 32)
  -- PORT MAP(
  --   i_S => s_Execute(70),
  --   i_D0 => s_Execute(31 DOWNTO 0),
  --   i_D1 => s_Execute(63 DOWNTO 32),
  --   o_O => s_LuiOrData);

  memtoreg2 : mux2t1_N
  PORT MAP(
    i_S => s_Execute(71),
    -- i_D0 => s_LuiOrData,
    i_D0 => s_DMemAddr, --aluout
    i_D1 => s_DMemOut,
    o_O => s_MemToRegData
  );
  s_LuiImm <= s_Execute(89 DOWNTO 74) & X"0000";
  lui : mux2t1_N
  PORT MAP(
    i_S => s_Execute(73),
    i_D0 => s_MemToRegData,
    i_D1 => s_LuiImm,
    o_O => s_RegWriteData
  );

  -- s_RegWr <= s_Execute(72);
  -- s_RegWrAddr <= s_Execute (68 DOWNTO 64);
  -- s_RegWrData <= s_RegWriteData;
  -- s_Halt <= s_Execute(70);

  Memory : n_bit_reg
  GENERIC MAP(N => 39)
  PORT MAP(
    i_D (31 DOWNTO 0) => s_RegWriteData,
    i_D (36 DOWNTO 32) => s_Execute (68 DOWNTO 64),
    i_D(37) => s_Execute(70), --halt
    i_D(38) => s_Execute(72), --regwe
    i_RST => iRST,
    i_CLK => iCLK,
    i_WE => '1',
    o_Q => s_Memory
  );
  --WB Stage
  s_RegWr <= s_Memory(38);
  s_RegWrAddr <= s_Memory(36 DOWNTO 32);
  s_RegWrData <= s_Memory(31 DOWNTO 0);
  s_Halt <= s_Memory(37);
  ---

END structure;