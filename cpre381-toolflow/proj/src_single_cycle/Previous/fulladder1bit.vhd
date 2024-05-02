LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

--entity
ENTITY fulladder1bit IS
  PORT (
    i_x1 : IN STD_LOGIC;
    i_x2 : IN STD_LOGIC;
    i_cin : IN STD_LOGIC;
    o_sum : OUT STD_LOGIC;
    o_cout : OUT STD_LOGIC);

END fulladder1bit;

ARCHITECTURE structural OF fulladder1bit IS

  --AND gate--
  COMPONENT andg2 IS
    PORT (
      i_A, i_B : IN STD_LOGIC;
      o_F : OUT STD_LOGIC);
  END COMPONENT;

  --OR gate--
  COMPONENT org2 IS
    PORT (
      i_A, i_B : IN STD_LOGIC;
      o_F : OUT STD_LOGIC);
  END COMPONENT;

  --XOR gate--
  COMPONENT xorg2 IS
    PORT (
      i_A, i_B : IN STD_LOGIC;
      o_F : OUT STD_LOGIC);
  END COMPONENT;

  -- intermediate signal declaration--
  SIGNAL x1_out, a1_out, a2_out : STD_LOGIC;

BEGIN

  x1 : xorg2 PORT MAP(
    i_A => i_x1,
    i_B => i_x2,
    o_F => x1_out);

  a1 : andg2 PORT MAP(
    i_A => i_x1,
    i_B => i_x2,
    o_F => a1_out);

  x2 : xorg2 PORT MAP(
    i_A => x1_out,
    i_B => i_cin,
    o_F => o_sum);

  a2 : andg2 PORT MAP(
    i_A => x1_out,
    i_B => i_cin,
    o_F => a2_out);

  o1 : org2 PORT MAP(
    i_A => a2_out,
    i_B => a1_out,
    o_F => o_cout);

END structural;