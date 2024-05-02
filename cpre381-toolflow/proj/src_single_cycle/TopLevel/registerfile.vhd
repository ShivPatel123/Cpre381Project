------------------------------------------------------------------------
-- Advaith Thimmancherla
-- Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- mips_reg_file.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a functional MIPS 
-- register file complete with all of its components.
--
--
-- NOTES:
-- 2/8/24
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.MIPS_types.ALL;

ENTITY mips_reg_file IS
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

END mips_reg_file;

ARCHITECTURE structural OF mips_reg_file IS

    COMPONENT n_bit_reg IS
        GENERIC (N : INTEGER := 32);
        PORT (
            i_CLK : IN STD_LOGIC; -- Clock Input
            i_RST : IN STD_LOGIC; -- Reset input
            i_WE : IN STD_LOGIC; -- Write enable input
            i_D : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- Data value input
            o_Q : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)); -- Data value output

    END COMPONENT;

    COMPONENT decoder_5to32 IS
        PORT (
            i_D : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            o_O : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));

    END COMPONENT;

    COMPONENT mux32to1 IS
        PORT (
            i_D : IN t_bus_32x32;
            i_S : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            o_O : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));

    END COMPONENT;

    COMPONENT dffg
        PORT (
            i_CLK : IN STD_LOGIC; -- Clock input
            i_RST : IN STD_LOGIC; -- Reset input
            i_WE : IN STD_LOGIC; -- Write enable input
            i_D : IN STD_LOGIC; -- Data value input
            o_Q : OUT STD_LOGIC); -- Data value output
    END COMPONENT;

    SIGNAL register_array : t_bus_32x32 := (OTHERS => (OTHERS => '0'));

    SIGNAL rdAddrOut : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN

    Decoder : decoder_5to32 PORT MAP(
        i_D => i_RDaddr,
        o_O => rdAddrOut);

    RSMux : mux32to1 PORT MAP(
        i_S => i_RSaddr,
        o_O => o_RS,
        i_D(0) => register_array(0),
        i_D(1) => register_array(1),
        i_D(2) => register_array(2),
        i_D(3) => register_array(3),
        i_D(4) => register_array(4),
        i_D(5) => register_array(5),
        i_D(6) => register_array(6),
        i_D(7) => register_array(7),
        i_D(8) => register_array(8),
        i_D(9) => register_array(9),
        i_D(10) => register_array(10),
        i_D(11) => register_array(11),
        i_D(12) => register_array(12),
        i_D(13) => register_array(13),
        i_D(14) => register_array(14),
        i_D(15) => register_array(15),
        i_D(16) => register_array(16),
        i_D(17) => register_array(17),
        i_D(18) => register_array(18),
        i_D(19) => register_array(19),
        i_D(20) => register_array(20),
        i_D(21) => register_array(21),
        i_D(22) => register_array(22),
        i_D(23) => register_array(23),
        i_D(24) => register_array(24),
        i_D(25) => register_array(25),
        i_D(26) => register_array(26),
        i_D(27) => register_array(27),
        i_D(28) => register_array(28),
        i_D(29) => register_array(29),
        i_D(30) => register_array(30),
        i_D(31) => register_array(31));
    RTMux : mux32to1 PORT MAP(
        i_S => i_RTaddr,
        o_O => o_RT,
        i_D(0) => register_array(0),
        i_D(1) => register_array(1),
        i_D(2) => register_array(2),
        i_D(3) => register_array(3),
        i_D(4) => register_array(4),
        i_D(5) => register_array(5),
        i_D(6) => register_array(6),
        i_D(7) => register_array(7),
        i_D(8) => register_array(8),
        i_D(9) => register_array(9),
        i_D(10) => register_array(10),
        i_D(11) => register_array(11),
        i_D(12) => register_array(12),
        i_D(13) => register_array(13),
        i_D(14) => register_array(14),
        i_D(15) => register_array(15),
        i_D(16) => register_array(16),
        i_D(17) => register_array(17),
        i_D(18) => register_array(18),
        i_D(19) => register_array(19),
        i_D(20) => register_array(20),
        i_D(21) => register_array(21),
        i_D(22) => register_array(22),
        i_D(23) => register_array(23),
        i_D(24) => register_array(24),
        i_D(25) => register_array(25),
        i_D(26) => register_array(26),
        i_D(27) => register_array(27),
        i_D(28) => register_array(28),
        i_D(29) => register_array(29),
        i_D(30) => register_array(30),
        i_D(31) => register_array(31));
    -- $zero register
    Zero : n_bit_reg PORT MAP(
        i_CLK => i_CLK,
        i_RST => '1',
        i_WE => rdAddrOut(0), -- check 
        i_D => i_RDdata, -- not sure if I fixed this right
        o_Q => register_array(0)); -- not sure "

    -- rest of the registers
    G_NBit_regs : FOR i IN 1 TO 31 GENERATE
        REGS : n_bit_reg PORT MAP(
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE => rdAddrOut(i),
            i_D => i_RDdata, -- maybe check
            o_Q => register_array(i)); -- not sure if I fixed this right
    END GENERATE G_NBit_regs;
END structural;