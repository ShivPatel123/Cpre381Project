LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY mux4t1_N IS
    GENERIC (N : INTEGER);
    PORT (
        i_S : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        i_D0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        i_D1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        i_D2 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        i_D3 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));

END mux4t1_N;

ARCHITECTURE structural OF mux4t1_N IS

BEGIN

    WITH i_S SELECT o_O <=
        i_D0 WHEN "00",
        i_D1 WHEN "01",
        i_D2 WHEN "10",
        i_D3 WHEN "11",
        (OTHERS => '0') WHEN OTHERS;

END structural;