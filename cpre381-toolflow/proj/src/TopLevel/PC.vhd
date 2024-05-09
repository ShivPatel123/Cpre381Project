LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY PC IS
    GENERIC (N : INTEGER := 32);
    PORT (
        i_CLK : IN STD_LOGIC;
        i_WE : IN STD_LOGIC;
        i_RST : IN STD_LOGIC;
        i_ADDRESS : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        o_ADDRESS : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));

END PC;

ARCHITECTURE structural OF PC IS

    COMPONENT n_bit_reg IS
        PORT (
            i_Clk : IN STD_LOGIC;
            i_RST : IN STD_LOGIC;
            i_WE : IN STD_LOGIC;
            i_D : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            o_Q : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));

    END COMPONENT;

    COMPONENT mux2t1_N IS
        GENERIC (N : INTEGER := 32);
        PORT (
            i_S : IN STD_LOGIC;
            i_D0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            i_D1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));

    END COMPONENT;

    SIGNAL s_data : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00400000";

BEGIN

    mux : mux2t1_N PORT MAP(
        i_S => i_RST,
        i_D0 => i_ADDRESS,
        i_D1 => x"00400000",
        o_O => s_data);
    reg : n_bit_reg PORT MAP(
        i_Clk => i_CLK,
        i_RST => '0',
        i_WE => i_WE,
        i_D => s_data,
        o_Q => o_ADDRESS);

END structural;