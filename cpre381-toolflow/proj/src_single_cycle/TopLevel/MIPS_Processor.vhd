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
  SIGNAL s_Halt : STD_LOGIC; -- TODO: this signal indicates to the simulation that intended program execution has completed. (Opcode: 01 0100)

  -- Required overflow signal -- for overflow exception detection
  SIGNAL s_Ovfl : STD_LOGIC; -- TODO: this signal indicates an overflow exception would have been initiated

  --control file signals
  SIGNAL s_RegDst, s_Unsigned, s_Extender, s_Signed, s_AluSrc, s_MemToReg, s_J, s_JAL, s_JR, s_LuiIndex : STD_LOGIC;
  SIGNAL s_AluOp : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL s_Branch : STD_LOGIC_VECTOR(1 DOWNTO 0);
  --ALU file Signals
  SIGNAL s_AluRsInput, s_AluRtInput, s_ImmTemp, s_MUXOUT, s_UnmaskedLui, s_Lower, s_Lui, s_LuiAddress, s_LWData : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
  SIGNAL s_Cout, s_Zero, s_SWJ, s_NotAndi : STD_LOGIC;

  --fetch signals
  SIGNAL s_JumpAddress, s_JalData : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
  SIGNAL s_JalTemp, s_JTemp : STD_LOGIC_VECTOR(4 DOWNTO 0);

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
      o_OVERFLOW : OUT STD_LOGIC;
      o_ZERO : OUT STD_LOGIC
    );
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
      i_IMM : IN STD_LOGIC_VECTOR(31 DOWNTO 0); --signed imm value after bitwidth extender
      i_RSDATA : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
      i_JADDRESS : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
      o_JALDATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      o_IMEMADDRESS : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
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

BEGIN

  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
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

  s_DMemData <= s_AluRtInput;
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

  RTorRD : mux2t1_N
  GENERIC MAP(N => 5)
  PORT MAP(
    i_S => s_RegDst,
    i_D0 => s_Inst(20 DOWNTO 16),
    i_D1 => s_Inst(15 DOWNTO 11),
    o_O => s_JalTemp
  );

  JalRegAddress : mux2t1_N
  GENERIC MAP(N => 5)
  PORT MAP(
    i_S => s_Jal,
    i_D0 => s_JalTemp,
    i_D1 => "11111",
    o_O => s_JTemp
  );

  s_SWJ <= s_J OR s_DMemWr;

  JRegAddress : mux2t1_N
  GENERIC MAP(N => 5)
  PORT MAP(
    i_S => s_SWJ,
    i_D0 => s_JTemp,
    i_D1 => "00000",
    o_O => s_RegWrAddr
  );

  RegisterFile : mips_reg_file
  PORT MAP(
    i_CLK => iCLK, -- Clock Input
    i_RST => iRST, -- Reset
    i_WE => s_RegWr, -- Write Enbale
    i_RSaddr => s_Inst(25 DOWNTO 21), -- Read Address 1 (register)
    i_RTaddr => s_Inst(20 DOWNTO 16), -- Read Address 2 (register)        
    i_RDaddr => s_RegWrAddr, -- Write Address (register)
    i_RDdata => s_RegWrData, -- Write Data
    o_RS => s_AluRsInput, -- Read Output 1 goes to alu
    o_RT => s_AluRtInput); -- Read Output 2   goes to mux to choose between imm and rt

  -- if unsigned is 1, check if it is negative and if it is set unsigned to 0 only if it is not andi instruction.

  s_NotAndi <= '1' WHEN (NOT (s_Inst(31 DOWNTO 26) = "001100" OR s_Inst(31 DOWNTO 26) = "001101" OR s_Inst(31 DOWNTO 26) = "001110")) ELSE
    '0';
  s_Extender <= '0' WHEN (s_Inst(15) = '1' AND s_NotAndi = '1') ELSE
    s_Unsigned;

  SignExtender : bit_width_extender
  PORT MAP(
    signedval => s_Extender,
    i_in => s_Inst(15 DOWNTO 0),
    o_out => s_ImmTemp);

  ALUnit : ALU
  PORT MAP(
    i_RSDATA => s_AluRsInput,
    i_RTDATA => s_AluRtInput,
    i_IMM => s_ImmTemp,
    i_ALUOP => s_AluOp,
    i_ALUSRC => s_AluSrc,
    i_SHAMT => s_Inst(10 DOWNTO 6),
    o_RESULT => s_DMemAddr,
    -- o_OVERFLOW => s_Ovfl,
    o_OVERFLOW => OPEN,
    o_ZERO => s_Zero
  );

  oALUOut <= s_DMemAddr;

  --lui
  s_UnmaskedLui <= s_Inst(15 DOWNTO 0) & X"0000";
  s_Lower <= X"0000" & s_AluRtInput(15 DOWNTO 0);
  s_Lui <= s_UnmaskedLui OR s_Lower;

  LuiorMemAddr : mux2t1_N
  GENERIC MAP(N => 32)
  PORT MAP(
    i_S => s_LuiIndex,
    i_D0 => s_DMemAddr,
    i_D1 => s_UnmaskedLui,
    o_O => s_LuiAddress);

  s_LWData <= X"000000" & s_DMemOut(7 DOWNTO 0) WHEN s_Inst(31 DOWNTO 26) = "100100" ELSE
    X"0000" & s_DMemOut(15 DOWNTO 0) WHEN s_Inst(31 DOWNTO 26) = "100101" ELSE
    X"000000" & s_DMemOut(7 DOWNTO 0) WHEN s_Inst(31 DOWNTO 26) = "100000" AND s_DMemOut(7) = '0' ELSE
    X"FFFFFF" & s_DMemOut (7 DOWNTO 0) WHEN s_Inst(31 DOWNTO 26) = "100000" AND s_DmemOut(7) = '1' ELSE
    X"0000" & s_DMemOut(15 DOWNTO 0) WHEN s_Inst(31 DOWNTO 26) = "100001" AND s_DmemOut(15) = '0' ELSE
    X"FFFF" & s_DMemOut(15 DOWNTO 0) WHEN s_Inst(31 DOWNTO 26) = "100001" AND s_DmemOut(15) = '1' ELSE
    s_DMemOut;

  MemtoRegMux : mux2t1_N
  GENERIC MAP(N => 32)
  PORT MAP(
    i_S => s_MemToReg,
    i_D0 => s_LuiAddress,
    i_D1 => s_LWData,
    o_O => s_MUXOUT);
  ControlUnit : control
  PORT MAP(
    i_Op => s_Inst(31 DOWNTO 26),
    i_Funct => s_Inst(5 DOWNTO 0),
    o_RegDst => s_RegDst, -- rt vs rd for different instruction types
    o_J => s_J, -- jump operation
    o_Branch => s_Branch, -- 0: no branch 1: beq 2: bne
    o_AxMOut => s_MemToReg, -- picks between ALUOut and MemOut for the datat to write back
    o_ALUOp => s_AluOp, -- ALUOp
    o_MemWrite => s_DMemWr, -- Memory's WE
    o_ALUSrc => s_AluSrc, -- Picks between immidiate value and register operand
    o_Unsigned => s_Unsigned, -- 1 if unisigned instructions
    o_Jr => s_Jr, -- jr instruction
    o_Jal => s_Jal, -- jal instruction
    o_RegWrite => s_RegWr, -- register file WE
    o_shiftSel => OPEN, -- 1 if shamt part of the instructions needs to be used
    o_Halt => s_Halt,
    o_Lui => s_LuiIndex
  );

  s_JumpAddress <= "0000" & s_Inst(25 DOWNTO 0) & "00";

  fetch : FetchLogic
  PORT MAP(
    i_CLK => iCLK,
    i_RST => iRST,
    i_BRANCH => s_Branch,
    i_JAL => s_Jal,
    i_ZERO => s_Zero,
    i_JR => s_Jr,
    i_J => s_J,
    i_IMM => s_ImmTemp, --signed imm value after bitwidth extender
    i_RSDATA => s_AluRsInput,
    i_JADDRESS => s_JumpAddress,
    o_JALDATA => s_JalData,
    o_IMEMADDRESS => s_NextInstAddr
  );

  s_RegWrData <= s_JalData WHEN s_Jal = '1' ELSE
    s_MUXOUT;
  -- TODO: Ensure that s_Halt is connected to an output control signal produced from decoding the Halt instruction (Opcode: 01 0100)
  -- TODO: Ensure that s_Ovfl is connected to the overflow output of your ALU

  -- TODO: Implement the rest of your processor below this comment! 

END structure;