LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY control IS
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
END control;

ARCHITECTURE behavioral OF control IS
BEGIN
    PROCESS (i_Op, i_Funct)
    BEGIN
        -- Default assignments
        o_RegDst <= '0';
        o_J <= '0';
        o_Branch <= "00";
        o_AxMOut <= '0';
        o_ALUOp <= (OTHERS => '0');
        o_MemWrite <= '0';
        o_ALUSrc <= '0';
        o_Unsigned <= '0';
        o_Jr <= '0';
        o_Jal <= '0';
        o_RegWrite <= '0';
        o_shiftSel <= '0';
        o_Halt <= '0';
        o_Lui <= '0';

        -- Decode i_Funct and i_Op for control signals
        CASE i_Op IS
            WHEN "000000" => -- R-type instructions
                CASE i_Funct IS
                    WHEN "100000" => -- add
                        o_Halt <= '0';
                        o_Lui <= '0';

                        o_ALUOp <= "0001";
                        o_ALUSrc <= '0';
                        o_RegWrite <= '1';
                        o_RegDst <= '1';
                        o_Unsigned <= '0';
                        o_AxMOut <= '0';
                        o_MemWrite <= '0';
                        o_Branch <= "00";
                        o_J <= '0';
                        o_Jr <= '0';
                        o_Jal <= '0';
                        o_shiftSel <= '0';
                    WHEN "100001" => -- addu
                        o_Halt <= '0';
                        o_Lui <= '0';

                        o_ALUOp <= "0001";
                        o_ALUSrc <= '0';
                        o_RegWrite <= '1';
                        o_RegDst <= '1';
                        o_Unsigned <= '1';
                        o_AxMOut <= '0';
                        o_MemWrite <= '0';
                        o_Branch <= "00";
                        o_J <= '0';
                        o_Jr <= '0';
                        o_Jal <= '0';
                        o_shiftSel <= '0';
                    WHEN "100010" => -- sub
                        o_Halt <= '0';
                        o_Lui <= '0';

                        o_ALUOp <= "0010";
                        o_ALUSrc <= '0';
                        o_RegWrite <= '1';
                        o_RegDst <= '1';
                        o_Unsigned <= '0';
                        o_AxMOut <= '0';
                        o_MemWrite <= '0';
                        o_Branch <= "00";
                        o_J <= '0';
                        o_Jr <= '0';
                        o_Jal <= '0';
                        o_shiftSel <= '0';
                    WHEN "100011" => -- subu
                        o_Halt <= '0';
                        o_Lui <= '0';

                        o_ALUOp <= "0010";
                        o_ALUSrc <= '0';
                        o_RegWrite <= '1';
                        o_RegDst <= '1';
                        o_Unsigned <= '1';
                        o_AxMOut <= '0';
                        o_MemWrite <= '0';
                        o_Branch <= "00";
                        o_J <= '0';
                        o_Jr <= '0';
                        o_Jal <= '0';
                        o_shiftSel <= '0';
                    WHEN "100100" => -- and
                        o_Halt <= '0';
                        o_Lui <= '0';

                        o_ALUOp <= "0011";
                        o_ALUSrc <= '0';
                        o_RegWrite <= '1';
                        o_RegDst <= '1';
                        o_Unsigned <= '0';
                        o_AxMOut <= '0';
                        o_MemWrite <= '0';
                        o_Branch <= "00";
                        o_J <= '0';
                        o_Jr <= '0';
                        o_Jal <= '0';
                        o_shiftSel <= '0';
                    WHEN "100101" => -- or 
                        o_Halt <= '0';
                        o_Lui <= '0';

                        o_ALUOp <= "0100";
                        o_ALUSrc <= '0';
                        o_RegWrite <= '1';
                        o_RegDst <= '1';
                        o_Unsigned <= '0';
                        o_AxMOut <= '0';
                        o_MemWrite <= '0';
                        o_Branch <= "00";
                        o_J <= '0';
                        o_Jr <= '0';
                        o_Jal <= '0';
                        o_shiftSel <= '0';
                    WHEN "100110" => -- xor
                        o_Halt <= '0';
                        o_Lui <= '0';

                        o_ALUOp <= "0101";
                        o_ALUSrc <= '0';
                        o_RegWrite <= '1';
                        o_RegDst <= '1';
                        o_Unsigned <= '0';
                        o_AxMOut <= '0';
                        o_MemWrite <= '0';
                        o_Branch <= "00";
                        o_J <= '0';
                        o_Jr <= '0';
                        o_Jal <= '0';
                        o_shiftSel <= '0';
                    WHEN "100111" => -- nor
                        o_Halt <= '0';
                        o_Lui <= '0';

                        o_ALUOp <= "0110";
                        o_ALUSrc <= '0';
                        o_RegWrite <= '1';
                        o_RegDst <= '1';
                        o_Unsigned <= '0';
                        o_AxMOut <= '0';
                        o_MemWrite <= '0';
                        o_Branch <= "00";
                        o_J <= '0';
                        o_Jr <= '0';
                        o_Jal <= '0';
                        o_shiftSel <= '0';
                    WHEN "101010" => -- slt
                        o_Halt <= '0';
                        o_Lui <= '0';

                        o_ALUOp <= "0111";
                        o_ALUSrc <= '0';
                        o_RegWrite <= '1';
                        o_RegDst <= '1';
                        o_Unsigned <= '0';
                        o_AxMOut <= '0';
                        o_MemWrite <= '0';
                        o_Branch <= "00";
                        o_J <= '0';
                        o_Jr <= '0';
                        o_Jal <= '0';
                        o_shiftSel <= '0';
                    WHEN "000000" => -- sll 
                        o_Halt <= '0';
                        o_Lui <= '0';

                        o_ALUOp <= "1000";
                        o_ALUSrc <= '1';
                        o_RegWrite <= '1';
                        o_RegDst <= '1';
                        o_Unsigned <= '0';
                        o_AxMOut <= '0';
                        o_MemWrite <= '0';
                        o_Branch <= "00";
                        o_J <= '0';
                        o_Jr <= '0';
                        o_Jal <= '0';
                        o_shiftSel <= '1';
                    WHEN "000100" => -- sllv 
                        o_Halt <= '0';
                        o_Lui <= '0';

                        o_ALUOp <= "1000";
                        o_ALUSrc <= '0';
                        o_RegWrite <= '1';
                        o_RegDst <= '1';
                        o_Unsigned <= '0';
                        o_AxMOut <= '0';
                        o_MemWrite <= '0';
                        o_Branch <= "00";
                        o_J <= '0';
                        o_Jr <= '0';
                        o_Jal <= '0';
                        o_shiftSel <= '0';
                    WHEN "000010" => -- srl
                        o_Halt <= '0';
                        o_Lui <= '0';

                        o_ALUOp <= "1001";
                        o_ALUSrc <= '1';
                        o_RegWrite <= '1';
                        o_RegDst <= '1';
                        o_Unsigned <= '0';
                        o_AxMOut <= '0';
                        o_MemWrite <= '0';
                        o_Branch <= "00";
                        o_J <= '0';
                        o_Jr <= '0';
                        o_Jal <= '0';
                        o_shiftSel <= '1';
                    WHEN "000110" => -- srlv
                        o_Halt <= '0';
                        o_Lui <= '0';

                        o_ALUOp <= "1001";
                        o_ALUSrc <= '0';
                        o_RegWrite <= '1';
                        o_RegDst <= '1';
                        o_Unsigned <= '0';
                        o_AxMOut <= '0';
                        o_MemWrite <= '0';
                        o_Branch <= "00";
                        o_J <= '0';
                        o_Jr <= '0';
                        o_Jal <= '0';
                        o_shiftSel <= '0';
                    WHEN "000011" => -- sra
                        o_Halt <= '0';
                        o_Lui <= '0';

                        o_ALUOp <= "1010";
                        o_ALUSrc <= '1';
                        o_RegWrite <= '1';
                        o_RegDst <= '1';
                        o_Unsigned <= '0';
                        o_AxMOut <= '0';
                        o_MemWrite <= '0';
                        o_Branch <= "00";
                        o_J <= '0';
                        o_Jr <= '0';
                        o_Jal <= '0';
                        o_shiftSel <= '1';
                    WHEN "000111" => -- srav
                        o_Halt <= '0';
                        o_Lui <= '0';

                        o_ALUOp <= "1010";
                        o_ALUSrc <= '0';
                        o_RegWrite <= '1';
                        o_RegDst <= '1';
                        o_Unsigned <= '0';
                        o_AxMOut <= '0';
                        o_MemWrite <= '0';
                        o_Branch <= "00";
                        o_J <= '0';
                        o_Jr <= '0';
                        o_Jal <= '0';
                        o_shiftSel <= '0';
                    WHEN "001000" => -- jr
                        o_Halt <= '0';
                        o_Lui <= '0';

                        o_ALUOp <= "0000"; -- don't care
                        o_ALUSrc <= '0';
                        o_RegWrite <= '0';
                        o_RegDst <= '0';
                        o_Unsigned <= '0';
                        o_AxMOut <= '0';
                        o_MemWrite <= '0';
                        o_Branch <= "00";
                        o_J <= '0';
                        o_Jr <= '1';
                        o_Jal <= '0';
                        o_shiftSel <= '0';
                    WHEN OTHERS =>
                        o_Halt <= '0';
                        o_Lui <= '0';

                        NULL; -- No action for other function codes
                END CASE;

                -- start I type instructions
            WHEN "001000" => -- addi
                o_Halt <= '0';
                o_Lui <= '0';

                o_ALUOp <= "0001";
                o_ALUSrc <= '1';
                o_RegWrite <= '1';
                o_RegDst <= '0';
                o_Unsigned <= '0';
                o_AxMOut <= '0';
                o_MemWrite <= '0';
                o_Branch <= "00";
                o_J <= '0';
                o_Jr <= '0';
                o_Jal <= '0';
                o_shiftSel <= '0';
            WHEN "001001" => -- addiu
                o_Halt <= '0';
                o_Lui <= '0';

                o_ALUOp <= "0001";
                o_ALUSrc <= '1';
                o_RegWrite <= '1';
                o_RegDst <= '0';
                o_Unsigned <= '1';
                o_AxMOut <= '0';
                o_MemWrite <= '0';
                o_Branch <= "00";
                o_J <= '0';
                o_Jr <= '0';
                o_Jal <= '0';
                o_shiftSel <= '0';
            WHEN "001100" => --  andi
                o_Halt <= '0';
                o_Lui <= '0';

                o_ALUOp <= "0011";
                o_ALUSrc <= '1';
                o_RegWrite <= '1';
                o_RegDst <= '0';
                o_Unsigned <= '1';
                o_AxMOut <= '0';
                o_MemWrite <= '0';
                o_Branch <= "00";
                o_J <= '0';
                o_Jr <= '0';
                o_Jal <= '0';
                o_shiftSel <= '0';
            WHEN "001101" => -- ori
                o_Halt <= '0';
                o_Lui <= '0';

                o_ALUOp <= "0100";
                o_ALUSrc <= '1';
                o_RegWrite <= '1';
                o_RegDst <= '0';
                o_Unsigned <= '1';
                o_AxMOut <= '0';
                o_MemWrite <= '0';
                o_Branch <= "00";
                o_J <= '0';
                o_Jr <= '0';
                o_Jal <= '0';
                o_shiftSel <= '0';
            WHEN "001110" => -- xori
                o_Halt <= '0';
                o_Lui <= '0';

                o_ALUOp <= "0101";
                o_ALUSrc <= '1';
                o_RegWrite <= '1';
                o_RegDst <= '0';
                o_Unsigned <= '1';
                o_AxMOut <= '0';
                o_MemWrite <= '0';
                o_Branch <= "00";
                o_J <= '0';
                o_Jr <= '0';
                o_Jal <= '0';
                o_shiftSel <= '0';
            WHEN "001010" => -- slti
                o_Halt <= '0';
                o_Lui <= '0';

                o_ALUOp <= "0111";
                o_ALUSrc <= '1';
                o_RegWrite <= '1';
                o_RegDst <= '0';
                o_Unsigned <= '0';
                o_AxMOut <= '0';
                o_MemWrite <= '0';
                o_Branch <= "00";
                o_J <= '0';
                o_Jr <= '0';
                o_Jal <= '0';
                o_shiftSel <= '0';
                -- Load and store instructions
            WHEN "100011" => --lw
                o_Halt <= '0';
                o_Lui <= '0';

                o_ALUOp <= "0001";
                o_ALUSrc <= '1';
                o_RegWrite <= '1';
                o_RegDst <= '0';
                o_Unsigned <= '0';
                o_AxMOut <= '1';
                o_MemWrite <= '0';
                o_Branch <= "00";
                o_J <= '0';
                o_Jr <= '0';
                o_Jal <= '0';
                o_shiftSel <= '0';
            WHEN "100000" => --lb
                o_Halt <= '0';
                o_Lui <= '0';

                o_ALUOp <= "0001";
                o_ALUSrc <= '1';
                o_RegWrite <= '1';
                o_RegDst <= '0';
                o_Unsigned <= '0';
                o_AxMOut <= '1';
                o_MemWrite <= '0';
                o_Branch <= "00";
                o_J <= '0';
                o_Jr <= '0';
                o_Jal <= '0';
                o_shiftSel <= '0';
            WHEN "100001" => --lh
                o_Halt <= '0';
                o_Lui <= '0';

                o_ALUOp <= "0001";
                o_ALUSrc <= '1';
                o_RegWrite <= '1';
                o_RegDst <= '0';
                o_Unsigned <= '0';
                o_AxMOut <= '1';
                o_MemWrite <= '0';
                o_Branch <= "00";
                o_J <= '0';
                o_Jr <= '0';
                o_Jal <= '0';
                o_shiftSel <= '0';
            WHEN "100100" => --lbu
                o_Halt <= '0';
                o_Lui <= '0';

                o_ALUOp <= "0001";
                o_ALUSrc <= '1';
                o_RegWrite <= '1';
                o_RegDst <= '0';
                o_Unsigned <= '1';
                o_AxMOut <= '1';
                o_MemWrite <= '0';
                o_Branch <= "00";
                o_J <= '0';
                o_Jr <= '0';
                o_Jal <= '0';
                o_shiftSel <= '0';
            WHEN "100101" => --lhu
                o_Halt <= '0';
                o_Lui <= '0';

                o_ALUOp <= "0001";
                o_ALUSrc <= '1';
                o_RegWrite <= '1';
                o_RegDst <= '0';
                o_Unsigned <= '1';
                o_AxMOut <= '1';
                o_MemWrite <= '0';
                o_Branch <= "00";
                o_J <= '0';
                o_Jr <= '0';
                o_Jal <= '0';
                o_shiftSel <= '0';
            WHEN "001111" => -- lui
                o_Halt <= '0';
                o_Lui <= '1';
                o_ALUOp <= "0001";
                o_ALUSrc <= '1';
                o_RegWrite <= '1';
                o_RegDst <= '0';
                o_Unsigned <= '0';
                o_AxMOut <= '0';
                o_MemWrite <= '0';
                o_Branch <= "00";
                o_J <= '0';
                o_Jr <= '0';
                o_Jal <= '0';
                o_shiftSel <= '0';
            WHEN "101011" => --sw
                o_Halt <= '0';
                o_Lui <= '0';

                o_ALUOp <= "0001";
                o_ALUSrc <= '1';
                o_RegWrite <= '0';
                o_RegDst <= '0';
                o_Unsigned <= '0';
                o_AxMOut <= '0';
                o_MemWrite <= '1';
                o_Branch <= "00";
                o_J <= '0';
                o_Jr <= '0';
                o_Jal <= '0';
                o_shiftSel <= '0';
            WHEN "000100" => -- beq
                o_Halt <= '0';
                o_Lui <= '0';

                o_ALUOp <= "0010";
                o_ALUSrc <= '0';
                o_RegWrite <= '0';
                o_RegDst <= '0';
                o_Unsigned <= '0';
                o_AxMOut <= '0';
                o_MemWrite <= '0';
                o_Branch <= "01";
                o_J <= '0';
                o_Jr <= '0';
                o_Jal <= '0';
                o_shiftSel <= '0';
            WHEN "000101" => --  bne
                o_Halt <= '0';
                o_Lui <= '0';

                o_ALUOp <= "0010";
                o_ALUSrc <= '0';
                o_RegWrite <= '0';
                o_RegDst <= '0';
                o_Unsigned <= '0';
                o_AxMOut <= '0';
                o_MemWrite <= '0';
                o_Branch <= "10";
                o_J <= '0';
                o_Jr <= '0';
                o_Jal <= '0';
                o_shiftSel <= '0';
            WHEN "000010" => -- j
                o_Halt <= '0';
                o_Lui <= '0';

                o_ALUOp <= "0000"; -- don't care
                o_ALUSrc <= '0';
                o_RegWrite <= '0';
                o_RegDst <= '0';
                o_Unsigned <= '0';
                o_AxMOut <= '0';
                o_MemWrite <= '0';
                o_Branch <= "00";
                o_J <= '1';
                o_Jr <= '0';
                o_Jal <= '0';
                o_shiftSel <= '0';
                o_Lui <= '0';

            WHEN "000011" => -- jal
                o_Halt <= '0';
                o_Lui <= '0';

                o_ALUOp <= "0000"; -- don't care
                o_ALUSrc <= '0';
                o_RegWrite <= '1';
                o_RegDst <= '0';
                o_Unsigned <= '0';
                o_AxMOut <= '0';
                o_MemWrite <= '0';
                o_Branch <= "00";
                o_J <= '0';
                o_Jr <= '0';
                o_Jal <= '1';
                o_shiftSel <= '0';
                o_Lui <= '0';
                o_Halt <= '0';
            WHEN "010100" => --halt
                o_Lui <= '0';
                o_Halt <= '1';

            WHEN OTHERS =>
                NULL; -- No action for other opcodes
        END CASE;
    END PROCESS;
END behavioral;