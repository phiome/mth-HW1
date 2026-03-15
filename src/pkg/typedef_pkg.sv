package typedef_pkg;
	typedef enum [5:0] {
		LUI,
		AUIPC,
		JAL,
		JALR,
		BEQ,
		BNE,
		BGEU,
		BLTU,
		BGE,
		BLT,
		LBU,
		LHU,
		LB,
		LH,
		LW,
		SB,
		SH,
		SW,
		ADDI,
		SLTI,
		SLTIU,
		ORI,
		XORI,
		ANDI,
		SLLI,
		SRLI,
		SRAI,
		ADD,
		SUB,
		SLL,
		SLT,
		SLTU,
		XOR,
		SRL,
		SRA,
		OR,
		AND
	} op_e;

	typedef struct packed {
		logic valid;
		logic is_mem;
		logic is_pc_changer;
		logic rd_valid;
		logic rs1_valid;
		logic rs2_valid;
		logic[4:0] rd_idx;
		logic[4:0] rs1_idx;
		logic[4:0] rs2_idx;
		logic imm_valid;
		logic[31:0] imm;
		op_e op;
	} dinstr_t;
endpackage;
