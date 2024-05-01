LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY bit_width_extender IS
    PORT (
        signedval : IN STD_LOGIC;
        i_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        o_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
END bit_width_extender;

ARCHITECTURE behavioral OF bit_width_extender IS
BEGIN
    -- Sign extension based on 'signedval'
    PROCESS (i_in, signedval)
    BEGIN
        IF signedval = '1' THEN
            -- Zero extension (no change to input)
            o_out <= (31 DOWNTO 16 => '0') & i_in(15 DOWNTO 0);
        ELSE
            -- Sign extension (replicate MSB to higher bits)
            o_out <= (31 DOWNTO 16 => i_in(15)) & i_in(15 DOWNTO 0);
        END IF;
    END PROCESS;
END behavioral;