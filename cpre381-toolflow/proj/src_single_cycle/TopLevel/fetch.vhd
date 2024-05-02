LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY FetchLogic IS
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
END FetchLogic;

ARCHITECTURE structural OF FetchLogic IS
    -- Component declarations

    COMPONENT mux2t1_N IS
        GENERIC (
            N : INTEGER := 32
        );
        PORT (
            i_S : IN STD_LOGIC;
            i_D0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            i_D1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
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

    COMPONENT andg2 IS
        PORT (
            i_A : IN STD_LOGIC;
            i_B : IN STD_LOGIC;
            o_F : OUT STD_LOGIC
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
    -- Internal signals

    SIGNAL s_CURRENTADDRESS, s_NEXTADDRESS, s_PCPLUS4, s_BRANCHADDRESS, s_BRANCHMUX, s_JMUX, s_IMM4 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_BRANCH, s_JUMP : STD_LOGIC;

BEGIN

    PC1 : PC PORT MAP(
        i_CLK => i_CLK,
        i_WE => '1',
        i_RST => i_RST,
        i_ADDRESS => s_NEXTADDRESS,
        o_ADDRESS => s_CURRENTADDRESS);

    o_IMEMADDRESS <= s_CURRENTADDRESS;

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

    JALOutput : addersubtractor_N
    GENERIC MAP(n => 32)
    PORT MAP(
        i_A => s_CURRENTADDRESS, -- Current PC
        i_B => (OTHERS => '0'), -- Unused for branch
        i_Imm => X"00000004", -- Branch offset
        i_Ctrl => '0',
        i_ALUSrc => '1',
        o_sum => o_JALDATA, -- Result of addition
        o_cout => OPEN -- Unused for branch
    );

    s_IMM4 <= i_IMM(29 DOWNTO 0) & "00";
    BranchAddress : addersubtractor_N
    GENERIC MAP(n => 32)
    PORT MAP(
        i_A => s_PCPLUS4, -- Current PC
        i_B => (OTHERS => '0'), -- Unused for branch
        i_Imm => s_IMM4, -- Branch offset
        i_Ctrl => '0',
        i_ALUSrc => '1',
        o_sum => s_BRANCHADDRESS, -- Result of addition
        o_cout => OPEN -- Unused for branch
    );

    s_BRANCH <= (i_BRANCH(0) AND i_ZERO) OR (i_BRANCH(1) AND (NOT i_ZERO));

    branchorincrament : mux2t1_N
    PORT MAP(
        i_S => s_BRANCH,
        i_D0 => s_PCPLUS4,
        i_D1 => s_BRANCHADDRESS,
        o_O => s_BRANCHMUX
    );
    s_JUMP <= i_J OR i_JAL;
    branchtojump : mux2t1_N
    PORT MAP(
        i_S => s_JUMP,
        i_D0 => s_BRANCHMUX,
        i_D1 => i_JADDRESS,
        o_O => s_JMUX
    );
    jumptojr : mux2t1_N
    PORT MAP(
        i_S => i_JR,
        i_D0 => s_JMUX,
        i_D1 => i_RSDATA,
        o_O => s_NEXTADDRESS
    );
END structural;