-------------------------------------------------------------------------
-- Advaith Thimmancherla
-- Iowa State University
-------------------------------------------------------------------------
-- mux32to1.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a dataflow implementation of a  
-- 32-bit 32 to 1 multiplexor.

-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.MIPS_types.ALL;

--entity
ENTITY mux32to1 IS
    PORT (
        i_D : IN t_bus_32x32;
        i_S : IN STD_LOGIC_VECTOR(4 DOWNTO 0) := "00000";
        o_O : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000000");

END mux32to1;

ARCHITECTURE dataflow OF mux32to1 IS

BEGIN

    o_O <= i_D(to_integer(unsigned(i_S)));
END dataflow;