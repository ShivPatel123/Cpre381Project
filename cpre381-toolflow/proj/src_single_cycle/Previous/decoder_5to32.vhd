-------------------------------------------------------------------------
-- Advaith Thimmancherla
-- Iowa State University
-------------------------------------------------------------------------
-- decoder_5to32.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a structural implementation of a  
-- 5-32 bit decoder. 

-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

--entity
ENTITY decoder_5to32 IS
    PORT (
        i_D : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        o_O : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));

END decoder_5to32;

ARCHITECTURE behavioral OF decoder_5to32 IS

BEGIN

    WITH i_D SELECT o_O <=
        x"00000001" WHEN "00000",
        x"00000002" WHEN "00001",
        x"00000004" WHEN "00010",
        x"00000008" WHEN "00011",

        x"00000010" WHEN "00100",
        x"00000020" WHEN "00101",
        x"00000040" WHEN "00110",
        x"00000080" WHEN "00111",

        x"00000100" WHEN "01000",
        x"00000200" WHEN "01001",
        x"00000400" WHEN "01010",
        x"00000800" WHEN "01011",

        x"00001000" WHEN "01100",
        x"00002000" WHEN "01101",
        x"00004000" WHEN "01110",
        x"00008000" WHEN "01111",

        x"00010000" WHEN "10000",
        x"00020000" WHEN "10001",
        x"00040000" WHEN "10010",
        x"00080000" WHEN "10011",

        x"00100000" WHEN "10100",
        x"00200000" WHEN "10101",
        x"00400000" WHEN "10110",
        x"00800000" WHEN "10111",

        x"01000000" WHEN "11000",
        x"02000000" WHEN "11001",
        x"04000000" WHEN "11010",
        x"08000000" WHEN "11011",

        x"10000000" WHEN "11100",
        x"20000000" WHEN "11101",
        x"40000000" WHEN "11110",
        x"80000000" WHEN "11111",

        x"00000000" WHEN OTHERS;
END behavioral;