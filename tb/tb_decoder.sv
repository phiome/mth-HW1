module tb_decoder import typedef_pkg::*; ();
	logic clk;
	dinstr_t dinstr;
	dinstr_t expected_dinstr;
	logic[31:0] instr;

	int correct_count;
	int inst_count;
	logic compare_result;

	localparam TEST_COUNT=43;

	logic [6:0] opcode_set [TEST_COUNT] = {
		7'b1110101,	//LUI
		7'b1110100,	//AUIPC
		7'b1101111,	//JAL
		7'b1100111,	//JALR
		7'b1100011,	//BEQ
		7'b1100011,	//BNE
		7'b1100011,	//BGEU
		7'b1100011,	//BLTU
		7'b1100011,	//BGE
		7'b1100011,	//BLT
		7'b1100000,	//LBU
		7'b1100000,	//LHU
		7'b1100000,	//LB
		7'b1100000,	//LH
		7'b1100000,	//LW
		7'b1100001,	//SB
		7'b1100001,	//SH
		7'b1100001,	//SW
		7'b1100100,	//ADDI
		7'b1100100,	//SLTI
		7'b1100100,	//SLTIU
		7'b1100100,	//ORI
		7'b1100100,	//XORI
		7'b1100100,	//ANDI
		7'b1100100,	//SLLI
		7'b1100100,	//SRLI
		7'b1100100,	//SRAI
		7'b1110001,	//ADD
		7'b1110001,	//SUB
		7'b1110001,	//SLL
		7'b1110001,	//SLT
		7'b1110001,	//SLTU
		7'b1110001,	//XOR
		7'b1110001,	//SRL
		7'b1110001,	//SRA
		7'b1110001,	//OR
		7'b1110001,	//AND
		7'b0100001,	//INVALID
		7'b1100001,	//INVALID
		7'b1000001,	//INVALID
		7'b0000001,	//INVALID
		7'b1110001,	//INVALID
		7'b1110001	//INVALID
	};

 // below immediate_20_set encoding schema is valid_or_not, immediate_20_set
 // example  1_010   is valid and immediate_20_set = 010 (it must be longer but i guess you got the point)
 // example  0_010   is not valid
	logic [20:0] immediate_20_set [TEST_COUNT] = {
		21'b1_00001111000010101010,	//LUI
		21'b1_11010101010101010100,	//AUIPC
		21'b1_10100100100100010010,	//JAL
		21'b0_0, // not exist				//JALR
		21'b0_0, // not exist				//BEQ
		21'b0_0, // not exist				//BNE
		21'b0_0, // not exist				//BGEU
		21'b0_0, // not exist				//BLTU
		21'b0_0, // not exist				//BGE
		21'b0_0, // not exist				//BLT
		21'b0_0, // not exist				//LBU
		21'b0_0, // not exist				//LHU
		21'b0_0, // not exist				//LB
		21'b0_0, // not exist				//LH
		21'b0_0, // not exist				//LW
		21'b0_0, // not exist				//SB
		21'b0_0, // not exist				//SH
		21'b0_0, // not exist				//SW
		21'b0_0, // not exist				//ADDI
		21'b0_0, // not exist				//SLTI
		21'b0_0, // not exist				//SLTIU
		21'b0_0, // not exist				//ORI
		21'b0_0, // not exist				//XORI
		21'b0_0, // not exist				//ANDI
		21'b0_0, // not exist				//SLLI
		21'b0_0, // not exist				//SRLI
		21'b0_0, // not exist				//SRAI
		21'b0_0, // not exist				//ADD
		21'b0_0, // not exist				//SUB
		21'b0_0, // not exist				//SLL
		21'b0_0, // not exist				//SLT
		21'b0_0, // not exist				//SLTU
		21'b0_0, // not exist				//XOR
		21'b0_0, // not exist				//SRL
		21'b0_0, // not exist				//SRA
		21'b0_0, // not exist				//OR
		21'b0_0, // not exist				//AND
		21'b0_0, // not exist				//INVALID
		21'b0_0, // not exist				//INVALID
		21'b0_0, // not exist				//INVALID
		21'b0_0, // not exist				//INVALID
		21'b0_0, // not exist				//INVALID
		21'b0_0 // not exist				//INVALID
	};

	// every part exist
	logic [4:0] rd_or_imm5 [TEST_COUNT] = {
		5'b01010,	//LUI
		5'b10010,	//AUIPC
		5'b01100,	//JAL
		5'b01010,	//JALR
		5'b00100,	//BEQ
		5'b00100,	//BNE
		5'b01001,	//BGEU
		5'b01010,	//BLTU
		5'b00000,	//BGE
		5'b11000,	//BLT
		5'b11111,	//LBU
		5'b01110,	//LHU
		5'b00100,	//LB
		5'b00100,	//LH
		5'b01110,	//LW
		5'b11110,	//SB
		5'b01111,	//SH
		5'b01100,	//SW
		5'b01010,	//ADDI
		5'b10101,	//SLTI
		5'b01010,	//SLTIU
		5'b10101,	//ORI
		5'b01010,	//XORI
		5'b10101,	//ANDI
		5'b00011,	//SLLI
		5'b00110,	//SRLI
		5'b01100,	//SRAI
		5'b11000,	//ADD
		5'b00001,	//SUB
		5'b00010,	//SLL
		5'b00100,	//SLT
		5'b01000,	//SLTU
		5'b10000,	//XOR
		5'b01000,	//SRL
		5'b00100,	//SRA
		5'b00010,	//OR
		5'b00001,	//AND
		5'b00001,	//INVALID
		5'b00001,	//INVALID
		5'b00001,	//INVALID
		5'b00001,	//INVALID
		5'b00001,	//INVALID
		5'b00001	//INVALID
	};

 // below func3t encoding schema is func3t[2],func3t[1],func3t[0], valid_or_not
 // example  010_1   is valid and func3t=010
 // example  010_0   is not valid
	logic [3:0] func3t [TEST_COUNT] = {
		4'b000_0,	//LUI
		4'b000_0,	//AUIPC
		4'b000_0,	//JAL
		4'b000_1,	//JALR
		4'b100_1,	//BEQ
		4'b101_1,	//BNE
		4'b000_1,	//BGEU
		4'b001_1,	//BLTU
		4'b010_1,	//BGE
		4'b011_1,	//BLT
		4'b000_1,	//LBU
		4'b001_1,	//LHU
		4'b100_1,	//LB
		4'b101_1,	//LH
		4'b110_1,	//LW
		4'b000_1,	//SB
		4'b001_1,	//SH
		4'b010_1,	//SW
		4'b000_1,	//ADDI
		4'b010_1,	//SLTI
		4'b011_1,	//SLTIU
		4'b100_1,	//ORI
		4'b110_1,	//XORI
		4'b111_1,	//ANDI
		4'b001_1,	//SLLI
		4'b101_1,	//SRLI
		4'b101_1,	//SRAI
		4'b000_1,	//ADD
		4'b000_1,	//SUB
		4'b001_1,	//SLL
		4'b010_1,	//SLT
		4'b011_1,	//SLTU
		4'b100_1,	//XOR
		4'b101_1,	//SRL
		4'b101_1,	//SRA
		4'b110_1,	//OR
		4'b111_1,	//AND
		4'b111_1,	//INVALID
		4'b111_1,	//INVALID
		4'b111_1,	//INVALID
		4'b111_1,	//INVALID
		4'b111_1,	//INVALID
		4'b010_1	//INVALID
	};
 // below rs1 encoding schema is rd[4:0], valid_or_not
 // example  00010_1   is valid and rd=00010
 // example  00010_0   is not valid
	logic [5:0] rs1 [TEST_COUNT] = {
		6'b00000_0,		//LUI
		6'b00000_0,		//AUIPC
		6'b00000_0,		//JAL
		6'b01010_1,		//JALR
		6'b00100_1,		//BEQ
		6'b00000_1,		//BNE
		6'b01010_1,		//BGEU
		6'b01010_1,		//BLTU
		6'b00100_1,		//BGE
		6'b11111_1,		//BLT
		6'b01010_1,		//LBU
		6'b00001_1,		//LHU
		6'b00010_1,		//LB
		6'b00011_1,		//LH
		6'b00100_1,		//LW
		6'b00101_1,		//SB
		6'b00110_1,		//SH
		6'b00111_1,		//SW
		6'b01000_1,		//ADDI
		6'b01001_1,		//SLTI
		6'b01010_1,		//SLTIU
		6'b01011_1,		//ORI
		6'b01100_1,		//XORI
		6'b01101_1,		//ANDI
		6'b01110_1,		//SLLI
		6'b01111_1,		//SRLI
		6'b10000_1,		//SRAI
		6'b10001_1,		//ADD
		6'b10010_1,		//SUB
		6'b10011_1,		//SLL
		6'b10100_1,		//SLT
		6'b10101_1,		//SLTU
		6'b10110_1,		//XOR
		6'b10111_1,		//SRL
		6'b11000_1,		//SRA
		6'b01010_1,		//OR
		6'b01110_1,		//AND
		6'b01110_1,		//INVALID
		6'b01110_1,		//INVALID
		6'b01110_1,		//INVALID
		6'b01110_1,		//INVALID
		6'b01110_1,		//INVALID
		6'b01110_1		//INVALID
	};
 // below immediate_12_set encoding schema is valid_or_not, immediate_12_set
 // example  1_00010   is valid and immediate_12_set=00010
 // example  0_00010   is not valid
	logic [12:0] immediate_12_set [TEST_COUNT] = {
		13'b0_0,							//LUI
		13'b0_0,							//AUIPC
		13'b0_0,							//JAL
		13'b1_000100100101,	//JALR
		13'b0_0,							//BEQ
		13'b0_0,							//BNE
		13'b0_0,							//BGEU
		13'b0_0,							//BLTU
		13'b0_0,							//BGE
		13'b0_0,							//BLT
		13'b1_010101010101,	//LBU
		13'b1_101010101010,	//LHU
		13'b1_000101010100,	//LB
		13'b1_000010101000,	//LH
		13'b1_000001010000,	//LW
		13'b0_0,							//SB	
		13'b0_0,							//SH	
		13'b0_0,							//SW	
		13'b1_110011001100,	//ADDI
		13'b1_001100110000,	//SLTI
		13'b1_110011001100,	//SLTIU
		13'b1_001001111111,	//ORI
		13'b1_111111111111,	//XORI
		13'b1_000000001111,	//ANDI
		13'b0_0,							//SLLI		
		13'b0_0,							//SRLI		
		13'b0_0,							//SRAI		
		13'b0_0,							//ADD		
		13'b0_0,							//SUB		
		13'b0_0,							//SLL		
		13'b0_0,							//SLT		
		13'b0_0,							//SLTU		
		13'b0_0,							//XOR		
		13'b0_0,							//SRL		
		13'b0_0,							//SRA		
		13'b0_0,							//OR		
		13'b0_0,							//AND		
		13'b0_0,							//INVALID		
		13'b0_0,							//INVALID		
		13'b0_0,							//INVALID		
		13'b0_0,							//INVALID		
		13'b0_0,							//INVALID		
		13'b0_0 							//INVALID		
	};
 // below rs2_or_imm5 encoding schema is rs2_or_imm5[4:0], valid_or_not
 // example  00010_1   is valid and rs2_or_imm5=00010
 // example  00010_0   is not valid
	logic [5:0] rs2_or_imm5 [TEST_COUNT] = {
		6'b00001_0,	//LUI
		6'b01010_0,	//AUIPC
		6'b10010_0,	//JAL
		6'b01010_0,	//JALR
		6'b00000_1,	//BEQ
		6'b01100_1,	//BNE
		6'b00010_1,	//BGEU
		6'b00000_1,	//BLTU
		6'b01000_1,	//BGE
		6'b00110_1,	//BLT
		6'b01010_0,	//LBU
		6'b10100_0,	//LHU
		6'b01000_0,	//LB
		6'b10000_0,	//LH
		6'b00000_0,	//LW
		6'b01100_1,	//SB
		6'b00010_1,	//SH
		6'b01100_1,	//SW
		6'b11000_0,	//ADDI
		6'b00000_0,	//SLTI
		6'b11000_0,	//SLTIU
		6'b11110_0,	//ORI
		6'b11110_0,	//XORI
		6'b11110_0,	//ANDI
		6'b10001_1,	//SLLI
		6'b10101_1,	//SRLI
		6'b10001_1,	//SRAI
		6'b01010_1,	//ADD
		6'b01010_1,	//SUB
		6'b01010_1,	//SLL
		6'b00100_1,	//SLT
		6'b00100_1,	//SLTU
		6'b00100_1,	//XOR
		6'b01110_1,	//SRL
		6'b01010_1,	//SRA
		6'b01110_1,	//OR
		6'b00100_1,	//AND
		6'b00100_1,	//INVALID
		6'b00100_1,	//INVALID
		6'b00100_1,	//INVALID
		6'b00100_1,	//INVALID
		6'b00100_1,	//INVALID
		6'b00100_1	//INVALID
	};
 // below imm_7_or_fixed_val encoding schema is imm_7_or_fixed_val[4:0], valid_or_not
 // example  00010_1   is valid and imm_7_or_fixed_val=00010
 // example  00010_0   is not valid
	logic [7:0] imm_7_or_fixed_val [TEST_COUNT] = {
		8'b0000111_0,	//LUI
		8'b1101010_0,	//AUIPC
		8'b1010010_0,	//JAL
		8'b0001001_0,	//JALR
		8'b0010010_1,	//BEQ
		8'b1010110_1,	//BNE
		8'b0100100_1,	//BGEU
		8'b1001100_1,	//BLTU
		8'b1010000_1,	//BGE
		8'b0101000_1,	//BLT
		8'b0101010_0,	//LBU
		8'b1010101_0,	//LHU
		8'b0001010_0,	//LB
		8'b0000101_0,	//LH
		8'b0000010_0,	//LW
		8'b0000001_1,	//SB
		8'b0000010_1,	//SH
		8'b0110100_1,	//SW
		8'b1100110_0,	//ADDI
		8'b0011001_0,	//SLTI
		8'b1100110_0,	//SLTIU
		8'b0010011_0,	//ORI
		8'b1111111_0,	//XORI
		8'b0000000_0,	//ANDI
		8'b0000000_1,	//SLLI
		8'b0000000_1,	//SRLI
		8'b0000010_1,	//SRAI
		8'b0000000_1,	//ADD
		8'b0000010_1,	//SUB
		8'b0000000_1,	//SLL
		8'b0000000_1,	//SLT
		8'b0000000_1,	//SLTU
		8'b0000000_1,	//XOR
		8'b0000000_1,	//SRL
		8'b0000010_1,	//SRA
		8'b0000000_1,	//OR
		8'b0000000_1,	//AND
		8'b0000000_1,	//INVALID
		8'b0000000_1,	//INVALID
		8'b0000000_1,	//INVALID
		8'b0000000_1,	//INVALID
		8'b1000000_1,	//INVALID
		8'b0000010_1	//INVALID
	};
	
	
	// here generate the instruction schema using defined parts of instruction above which is rs1, imm, func3t etc.
	// firstly you must understand the instruction set and encoding schema above given examples shows how to understand
	// which index is for enable disable and which index is part of instructions. 

	// you must map instructions with filling xxxx parts
	logic [31:0] reordered_instruction_test [TEST_COUNT];
	initial begin
		for (int i = 0; i < TEST_COUNT; i++) begin
			logic [31:0] inst;
			inst = 32'b0;

			// --------------------------------------------------
			// OPCODE
			// --------------------------------------------------
			inst[xxxx] = opcode_set[i];

			// --------------------------------------------------
			// RD
			// --------------------------------------------------
			inst[xxxx] = rd_or_imm5[i];

			// --------------------------------------------------
			// FUNC3
			// func3t[3] = valid bit
			// func3t[2:0] = real func3
			// --------------------------------------------------
			if (func3t[i][0])
					inst[xxxx] = func3t[i][3:1];

			// --------------------------------------------------
			// RS1
			// rs1[i][0] = valid
			// rs1[i][5:1] = index
			// --------------------------------------------------
			if (rs1[i][0])
					inst[xxxx] = rs1[i][5:1];

			// --------------------------------------------------
			// RS2 or IMM[5:1]
			// rs2_or_imm5[i][0] = valid
			// --------------------------------------------------
			if (rs2_or_imm5[i][0])
					inst[xxxx] = rs2_or_imm5[i][5:1];

			// --------------------------------------------------
			// U-TYPE (LUI / AUIPC)
			// immediate_20_set[i][20] = valid
			// --------------------------------------------------
			if (immediate_20_set[i][20]) begin
					inst[xxxx] = immediate_20_set[i][19:8];
					inst[xxxx] = immediate_20_set[i][7:0];
			end

			// --------------------------------------------------
			// I-TYPE immediate
			// immediate_12_set[i][12] = valid
			// --------------------------------------------------
			if (immediate_12_set[i][12]) begin
					inst[xxxx] = immediate_12_set[i][11:0];
			end

			// --------------------------------------------------
			// B / S / R-type upper bits
			// imm_7_or_fixed_val[i][7] = valid
			// imm_7_or_fixed_val[i][6:0] = data
			// --------------------------------------------------
			if (imm_7_or_fixed_val[i][0]) begin
					inst[xxxx] = imm_7_or_fixed_val[i][7:1];
			end

			reordered_instruction_test[i] = inst;
		end
	end


	dinstr_t expected_dinstructions [TEST_COUNT] = {
		'{valid:1, op:LUI,  is_mem:0, is_pc_changer:0, rd_valid:1, rs1_valid:0, rs2_valid:0, imm_valid:1, rd_idx:5'b01010, rs1_idx:5'b00000, rs2_idx:5'b00000, imm:32'b00001111000010101010000000000000, default:'0},
		'{valid:1, op:AUIPC,is_mem:0, is_pc_changer:0, rd_valid:1, rs1_valid:0, rs2_valid:0, imm_valid:1, rd_idx:5'b10010, rs1_idx:5'b00000, rs2_idx:5'b00000, imm:32'b11010101010101010100000000000000, default:'0},
		'{valid:1, op:JAL,  is_mem:0, is_pc_changer:1, rd_valid:1, rs1_valid:0, rs2_valid:0, imm_valid:1, rd_idx:5'b01100, rs1_idx:5'b00000, rs2_idx:5'b00000, imm:32'b11111111111100010010101001001000, default:'0},
		'{valid:1, op:JALR, is_mem:0, is_pc_changer:1, rd_valid:1, rs1_valid:1, rs2_valid:0, imm_valid:1, rd_idx:5'b01010, rs1_idx:5'b01010, rs2_idx:5'b00000, imm:32'b00000000000000000000000100100101, default:'0},
		'{valid:1, op:BEQ,  is_mem:0, is_pc_changer:1, rd_valid:0, rs1_valid:1, rs2_valid:1, imm_valid:1, rd_idx:5'b00000, rs1_idx:5'b00100, rs2_idx:5'b00000, imm:32'b00000000000000000000001001000100, default:'0},
		'{valid:1, op:BNE,  is_mem:0, is_pc_changer:1, rd_valid:0, rs1_valid:1, rs2_valid:1, imm_valid:1, rd_idx:5'b00000, rs1_idx:5'b00000, rs2_idx:5'b01100, imm:32'b11111111111111111111001011000100, default:'0},
		'{valid:1, op:BGEU, is_mem:0, is_pc_changer:1, rd_valid:0, rs1_valid:1, rs2_valid:1, imm_valid:1, rd_idx:5'b00000, rs1_idx:5'b01010, rs2_idx:5'b00010, imm:32'b00000000000000000000110010001000, default:'0},
		'{valid:1, op:BLTU, is_mem:0, is_pc_changer:1, rd_valid:0, rs1_valid:1, rs2_valid:1, imm_valid:1, rd_idx:5'b00000, rs1_idx:5'b01010, rs2_idx:5'b00000, imm:32'b11111111111111111111000110001010, default:'0},
		'{valid:1, op:BGE,  is_mem:0, is_pc_changer:1, rd_valid:0, rs1_valid:1, rs2_valid:1, imm_valid:1, rd_idx:5'b00000, rs1_idx:5'b00100, rs2_idx:5'b01000, imm:32'b11111111111111111111001000000000, default:'0},
		'{valid:1, op:BLT,  is_mem:0, is_pc_changer:1, rd_valid:0, rs1_valid:1, rs2_valid:1, imm_valid:1, rd_idx:5'b00000, rs1_idx:5'b11111, rs2_idx:5'b00110, imm:32'b00000000000000000000010100011000, default:'0},
		'{valid:1, op:LBU,  is_mem:1, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:0, imm_valid:1, rd_idx:5'b11111, rs1_idx:5'b01010, rs2_idx:5'b00000, imm:32'b00000000000000000000010101010101, default:'0},
		'{valid:1, op:LHU,  is_mem:1, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:0, imm_valid:1, rd_idx:5'b01110, rs1_idx:5'b00001, rs2_idx:5'b00000, imm:32'b11111111111111111111101010101010, default:'0},
		'{valid:1, op:LB,   is_mem:1, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:0, imm_valid:1, rd_idx:5'b00100, rs1_idx:5'b00010, rs2_idx:5'b00000, imm:32'b00000000000000000000000101010100, default:'0},
		'{valid:1, op:LH,   is_mem:1, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:0, imm_valid:1, rd_idx:5'b00100, rs1_idx:5'b00011, rs2_idx:5'b00000, imm:32'b00000000000000000000000010101000, default:'0},
		'{valid:1, op:LW,   is_mem:1, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:0, imm_valid:1, rd_idx:5'b01110, rs1_idx:5'b00100, rs2_idx:5'b00000, imm:32'b00000000000000000000000001010000, default:'0},
		'{valid:1, op:SB,   is_mem:1, is_pc_changer:0, rd_valid:0, rs1_valid:1, rs2_valid:1, imm_valid:1, rd_idx:5'b00000, rs1_idx:5'b00101, rs2_idx:5'b01100, imm:32'b00000000000000000000000000111110, default:'0},
		'{valid:1, op:SH,   is_mem:1, is_pc_changer:0, rd_valid:0, rs1_valid:1, rs2_valid:1, imm_valid:1, rd_idx:5'b00000, rs1_idx:5'b00110, rs2_idx:5'b00010, imm:32'b00000000000000000000000001001111, default:'0},
		'{valid:1, op:SW,   is_mem:1, is_pc_changer:0, rd_valid:0, rs1_valid:1, rs2_valid:1, imm_valid:1, rd_idx:5'b00000, rs1_idx:5'b00111, rs2_idx:5'b01100, imm:32'b00000000000000000000011010001100, default:'0},
		'{valid:1, op:ADDI, is_mem:0, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:0, imm_valid:1, rd_idx:5'b01010, rs1_idx:5'b01000, rs2_idx:5'b00000, imm:32'b11111111111111111111110011001100, default:'0},
		'{valid:1, op:SLTI, is_mem:0, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:0, imm_valid:1, rd_idx:5'b10101, rs1_idx:5'b01001, rs2_idx:5'b00000, imm:32'b00000000000000000000001100110000, default:'0},
		'{valid:1, op:SLTIU,is_mem:0, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:0, imm_valid:1, rd_idx:5'b01010, rs1_idx:5'b01010, rs2_idx:5'b00000, imm:32'b11111111111111111111110011001100, default:'0},
		'{valid:1, op:ORI,  is_mem:0, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:0, imm_valid:1, rd_idx:5'b10101, rs1_idx:5'b01011, rs2_idx:5'b00000, imm:32'b00000000000000000000001001111111, default:'0},
		'{valid:1, op:XORI, is_mem:0, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:0, imm_valid:1, rd_idx:5'b01010, rs1_idx:5'b01100, rs2_idx:5'b00000, imm:32'b11111111111111111111111111111111, default:'0},
		'{valid:1, op:ANDI, is_mem:0, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:0, imm_valid:1, rd_idx:5'b10101, rs1_idx:5'b01101, rs2_idx:5'b00000, imm:32'b00000000000000000000000000001111, default:'0},
		'{valid:1, op:SLLI, is_mem:0, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:0, imm_valid:1, rd_idx:5'b00011, rs1_idx:5'b01110, rs2_idx:5'b10001, imm:32'b00000000000000000000000000010001, default:'0},
		'{valid:1, op:SRLI, is_mem:0, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:0, imm_valid:1, rd_idx:5'b00110, rs1_idx:5'b01111, rs2_idx:5'b10001, imm:32'b00000000000000000000000000010101, default:'0},
		'{valid:1, op:SRAI, is_mem:0, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:0, imm_valid:1, rd_idx:5'b01100, rs1_idx:5'b10000, rs2_idx:5'b10001, imm:32'b00000000000000000000000000010001, default:'0},
		'{valid:1, op:ADD,  is_mem:0, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:1, imm_valid:0, rd_idx:5'b11000, rs1_idx:5'b10001, rs2_idx:5'b01010, imm:32'b00000000000000000000000000000000, default:'0},
		'{valid:1, op:SUB,  is_mem:0, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:1, imm_valid:0, rd_idx:5'b00001, rs1_idx:5'b10010, rs2_idx:5'b01010, imm:32'b00000000000000000000000000000000, default:'0},
		'{valid:1, op:SLL,  is_mem:0, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:1, imm_valid:0, rd_idx:5'b00010, rs1_idx:5'b10011, rs2_idx:5'b01010, imm:32'b00000000000000000000000000000000, default:'0},
		'{valid:1, op:SLT,  is_mem:0, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:1, imm_valid:0, rd_idx:5'b00100, rs1_idx:5'b10100, rs2_idx:5'b00100, imm:32'b00000000000000000000000000000000, default:'0},
		'{valid:1, op:SLTU, is_mem:0, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:1, imm_valid:0, rd_idx:5'b01000, rs1_idx:5'b10101, rs2_idx:5'b00100, imm:32'b00000000000000000000000000000000, default:'0},
		'{valid:1, op:XOR,  is_mem:0, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:1, imm_valid:0, rd_idx:5'b10000, rs1_idx:5'b10110, rs2_idx:5'b00100, imm:32'b00000000000000000000000000000000, default:'0},
		'{valid:1, op:SRL,  is_mem:0, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:1, imm_valid:0, rd_idx:5'b01000, rs1_idx:5'b10111, rs2_idx:5'b01110, imm:32'b00000000000000000000000000000000, default:'0},
		'{valid:1, op:SRA,  is_mem:0, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:1, imm_valid:0, rd_idx:5'b00100, rs1_idx:5'b11000, rs2_idx:5'b01010, imm:32'b00000000000000000000000000000000, default:'0},
		'{valid:1, op:OR,   is_mem:0, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:1, imm_valid:0, rd_idx:5'b00010, rs1_idx:5'b01010, rs2_idx:5'b01110, imm:32'b00000000000000000000000000000000, default:'0},
		'{valid:1, op:AND,  is_mem:0, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:1, imm_valid:0, rd_idx:5'b00001, rs1_idx:5'b01110, rs2_idx:5'b00100, imm:32'b00000000000000000000000000000000, default:'0},
		'{valid:0, op:AND,  is_mem:0, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:1, imm_valid:0, rd_idx:5'b00001, rs1_idx:5'b01110, rs2_idx:5'b00100, imm:32'b00000000000000000000000000000000, default:'0},
		'{valid:0, op:AND,  is_mem:0, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:1, imm_valid:0, rd_idx:5'b00001, rs1_idx:5'b01110, rs2_idx:5'b00100, imm:32'b00000000000000000000000000000000, default:'0},
		'{valid:0, op:AND,  is_mem:0, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:1, imm_valid:0, rd_idx:5'b00001, rs1_idx:5'b01110, rs2_idx:5'b00100, imm:32'b00000000000000000000000000000000, default:'0},
		'{valid:0, op:AND,  is_mem:0, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:1, imm_valid:0, rd_idx:5'b00001, rs1_idx:5'b01110, rs2_idx:5'b00100, imm:32'b00000000000000000000000000000000, default:'0},
		'{valid:0, op:AND,  is_mem:0, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:1, imm_valid:0, rd_idx:5'b00001, rs1_idx:5'b01110, rs2_idx:5'b00100, imm:32'b00000000000000000000000000000000, default:'0},
		'{valid:0, op:AND,  is_mem:0, is_pc_changer:0, rd_valid:1, rs1_valid:1, rs2_valid:1, imm_valid:0, rd_idx:5'b00001, rs1_idx:5'b01110, rs2_idx:5'b00100, imm:32'b00000000000000000000000000000000, default:'0}
	};

	initial begin
	  $dumpfile("dump.fst");
	  $dumpvars();
	end

	initial begin
		clk=0;
		while(1) #10 clk=!clk; 
	end


	initial begin
		correct_count=0;
		inst_count=0;
		instr = '0;
		expected_dinstr='{op:ADDI, default:'0};
		@(posedge clk); 
		@(posedge clk); 
		#1;

		for(int i=0;i<TEST_COUNT;i++) begin
			test(i);
		end

		$display("All tests finished. TOTAL_SCORE:%0d/%0d", correct_count, inst_count);
		$finish();
	end



	task test(int index);
		instr = reordered_instruction_test[index];
		expected_dinstr = expected_dinstructions[index];
		@(posedge clk); 
		#1;
		compare_result=compare_dinstr(expected_dinstr, dinstr);
		correct_count+=compare_result;
		inst_count++;
		print_dinstr(dinstr); $display("\t%s\t%0d/%0d", compare_result ? "PASS" : "FAIL", correct_count, inst_count);
	endtask;

	task print_dinstr(dinstr_t dinstr);
		if(dinstr.valid) begin
			$write("%3d | %s ", inst_count, dinstr.op.name());
			if(dinstr.is_mem) begin
				if(dinstr.rd_valid)  $write("x%0d, ", dinstr.rd_idx);
				if(dinstr.rs2_valid) $write("x%0d, ", dinstr.rs2_idx);
				if(dinstr.imm_valid) $write("%0d",   $signed(dinstr.imm));
				if(dinstr.rs1_valid) $write("(x%0d)", dinstr.rs1_idx);
			end else begin
				if(dinstr.rd_valid)  $write("x%0d, ", dinstr.rd_idx);
				if(dinstr.rs1_valid) $write("x%0d, ", dinstr.rs1_idx);
				if(dinstr.rs2_valid) $write("x%0d, ", dinstr.rs2_idx);
				if(dinstr.imm_valid) $write("%0d ",  $signed(dinstr.imm));
			end
		end
	endtask;

	function automatic logic compare_dinstr(dinstr_t first, dinstr_t second);
		if(first.valid!=second.valid) begin 
			$display("%0t dinstr_o.valid expected to be %0d, got %0d", $time, first.valid, second.valid);
			return 0; 
		end else if(!first.valid) begin
			return 1; 
		end		

		if(first.op!=second.op) begin 
			$display("%0t dinstr_o.op expected to be %s, got %s", $time, first.op.name(), second.op.name());
			return 0; 
		end 
		
		if(first.is_mem!=second.is_mem) begin 
			$display("%0t dinstr_o.is_mem expected to be %0d, got %0d", $time, first.is_mem, second.is_mem);
			return 0; 
		end
		
		if(first.is_pc_changer!=second.is_pc_changer) begin 
			$display("%0t dinstr_o.is_pc_changer expected to be %0d, got %0d", $time, first.is_pc_changer, second.is_pc_changer);
			return 0; 
		end
		
		if(first.rd_valid!=second.rd_valid) begin 
			$display("%0t dinstr_o.rd_valid expected to be %0d, got %0d", $time, first.rd_valid, second.rd_valid);
			return 0; 
		end else if(first.rd_valid && first.rd_idx!=second.rd_idx) begin
			$display("%0t dinstr_o.rd_idx expected to be %0d, got %0d", $time, first.rd_idx, second.rd_idx);
			return 0; 
		end

		if(first.rs1_valid!=second.rs1_valid) begin 
			$display("%0t dinstr_o.rs1_valid expected to be %0d, got %0d", $time, first.rs1_valid, second.rs1_valid);
			return 0; 
		end else if(first.rs1_valid && first.rs1_idx!=second.rs1_idx) begin
			$display("%0t dinstr_o.rs1_idx expected to be %0d, got %0d", $time, first.rs1_idx, second.rs1_idx);
			return 0; 
		end


		if(first.rs2_valid!=second.rs2_valid) begin 
			$display("%0t dinstr_o.rs2_valid expected to be %0d, got %0d", $time, first.rs2_valid, second.rs2_valid);
			return 0; 
		end else if(first.rs2_valid && first.rs2_idx!=second.rs2_idx) begin
			$display("%0t dinstr_o.rs2_idx expected to be %0d, got %0d", $time, first.rs2_idx, second.rs2_idx);
			return 0; 
		end

		if(first.imm_valid!=second.imm_valid) begin 
			$display("%0t dinstr_o.imm_valid expected to be %0d, got %0d", $time, first.imm_valid, second.imm_valid);
			return 0; 
		end else if(first.imm_valid && first.imm!=second.imm) begin
			$display("%0t dinstr_o.imm expected to be %b, got %b", $time, first.imm, second.imm);
			return 0; 
		end

		return 1;
	endfunction;


	decoder i_decoder(
		.clk_i(clk),
		.instr_i(instr),
		.dinstr_o(dinstr)
	);

endmodule

