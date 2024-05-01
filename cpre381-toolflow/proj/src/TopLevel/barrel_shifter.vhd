LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY barrel_shifter IS
    PORT (
        i_sType : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- bit 0: if 0 - right if 1 - left  bit 1: if 0 - logical if 1 - arithmetic  bit 2: 0 - shamt  1 - reg
        i_shamt : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- shift amount
        i_Data : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- rt input to shift 
        i_rs : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- register input for shift amount if the 'v' version of instruction is used
        o_Shift : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) -- shifted output
    );
END barrel_shifter;

--possible error with the regDst bit in control so try changing how that works if there is an error

ARCHITECTURE mixed OF barrel_shifter IS

COMPONENT mux2t1 is
    port(i_S             : in std_logic;
         i_D0            : in std_logic;
         i_D1            : in std_logic;
         o_O             : out std_logic);
  END COMPONENT;



SIGNAL s_shamt : STD_LOGIC_VECTOR(4 DOWNTO 0); 
SIGNAL s_shiftBit : STD_LOGIC;
SIGNAL s_DataIn, s_backIn, s_backOut : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL s_shift1, s_shift2, s_shift4, s_shift8, s_shift16 : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN
    
    backwardIn : for i in 0 to 31 generate
        s_backIn(31 - i)  <= i_Data(i);
    end generate backwardIn;

    -- dir input select 
    dirSelectIn : for i in 0 to 31 generate 
    bs1: mux2t1 port map(i_S  => i_sType(0),
                                    i_D0 => i_Data(i),
                                    i_D1 => s_backIn(i),
                                    o_O  => s_DataIn(i));
    end generate dirSelectIn;

    -- shift input select
    shiftSelectIn : for i in 0 to 4 generate
    bs2: mux2t1 port map(i_S  => i_sType(2),
                                    i_D0 => i_shamt(i),
                                    i_D1 => i_rs(i),
                                    o_O  => s_shamt(i));
    end generate shiftSelectIn;

    -- logical vs arithmetic select
    typeSelectIn:
        mux2t1 port map(i_S  => i_sType(1),
                        i_D0 => '0',
                        i_D1 => s_DataIn(31),
                        o_O  => s_shiftBit);
    


    -- 1st level (shift by 1)
    shift11: mux2t1 port map(i_S  => s_shamt(0),
                             i_D0 => s_DataIn(31),
                             i_D1 => s_shiftBit,
                             o_O  => s_shift1(31));

    shift12: for i in 0 to 30 generate 
    bs3: mux2t1 port map(i_S  => s_shamt(0),
                                    i_D0 => s_DataIn(i),
                                    i_D1 => s_DataIn(i + 1),
                                    o_O  => s_shift1(i));
    end generate shift12;

    -- 2nd level (shift by 2)
    shift21: for i in 30 to 31 generate 
    bs4: mux2t1 port map(i_S  => s_shamt(1),
                                    i_D0 => s_shift1(i),
                                    i_D1 => s_shiftBit,
                                    o_O  => s_shift2(i));
    end generate shift21;

    shift22: for i in 0 to 29 generate
    bs5: mux2t1 port map(i_S  => s_shamt(1),
                                    i_D0 => s_shift1(i),
                                    i_D1 => s_shift1(i + 2),
                                    o_O  => s_shift2(i));
    end generate shift22;

    -- 3rd level (shift by 4)
    shift31: for i in 28 to 31 generate
    bs6: mux2t1 port map(i_S  => s_shamt(2),
                                    i_D0 => s_shift2(i),
                                    i_D1 => s_shiftBit,
                                    o_O  => s_shift4(i));
    end generate shift31;

    shift32: for i in 0 to 27 generate 
    bs7: mux2t1 port map(i_S  => s_shamt(2),
                                    i_D0 => s_shift2(i),
                                    i_D1 => s_shift2(i + 4),
                                    o_O  => s_shift4(i));
    end generate shift32;

    -- 4th level (shift by 8)
    shift41: for i in 24 to 31 generate 
    bs8: mux2t1 port map(i_S  => s_shamt(3),
                                    i_D0 => s_shift4(i),
                                    i_D1 => s_shiftBit,
                                    o_O  => s_shift8(i));
    end generate shift41;

    shift42: for i in 0 to 23 generate 
    bs9: mux2t1 port map(i_S  => s_shamt(3),
                                    i_D0 => s_shift4(i),
                                    i_D1 => s_shift4(i + 8),
                                    o_O  => s_shift8(i));
    end generate shift42;

    -- 5th level (shift by 16)
    shift51: for i in 16 to 31 generate 
    bs10: mux2t1 port map(i_S  => s_shamt(4),
                                    i_D0 => s_shift8(i),
                                    i_D1 => s_shiftBit,
                                    o_O  => s_shift16(i));
    end generate shift51;

    shift52: for i in 0 to 15 generate 
    bs11: mux2t1 port map(i_S  => s_shamt(4),
                                    i_D0 => s_shift8(i),
                                    i_D1 => s_shift8(i + 16),
                                    o_O  => s_shift16(i));
    end generate shift52;

    -- backward order (for left shift)
    backwardOut : for i in 0 to 31 generate
        s_backOut(31 - i)  <= s_shift16(i);
    end generate backwardOut;

    -- dir input select 
    dirSelectOut : for i in 0 to 31 generate
    bs12: mux2t1 port map(i_S  => i_sType(0),
                                    i_D0 => s_shift16(i),
                                    i_D1 => s_backOut(i),
                                    o_O  => o_Shift(i));
    end generate dirSelectOut;



END mixed;