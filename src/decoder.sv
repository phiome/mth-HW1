module decoder import typedef_pkg::*; (
    input  logic        clk_i,   // Bu sinyal sadece Verilator uyarılarını önlemek içindir.
    input  logic [31:0] instr_i,
    output dinstr_t     dinstr_o // struct tanımı pkg içindedir.
);

    // ==========================================
    // 1. ADIM: Sinyalleri Parçalama (Decode)
    // ==========================================
    logic [6:0] opcode;
    logic [4:0] rd_idx, rs1_idx, rs2_idx;
    logic [2:0] funct3;

    // Tablodaki şifrelenmiş yerleşimlere göre atamalar:
    assign opcode  = instr_i[19:13];
    assign rs2_idx = instr_i[24:20];
    assign rs1_idx = instr_i[12:8];
    assign funct3  = instr_i[7:5];
    assign rd_idx  = instr_i[4:0];

    // ==========================================
    // 2. ADIM: Kombinasyonel Mantık Bloğu
    // ==========================================
    always_comb begin
        // LATCH ÖNLEYİCİ: Tüm sinyalleri varsayılan duruma (0) getir
        dinstr_o.valid         = 1'b0;
        dinstr_o.is_mem        = 1'b0;
        dinstr_o.is_pc_changer = 1'b0;
        dinstr_o.rd_valid      = 1'b0;
        dinstr_o.rs1_valid     = 1'b0;
        dinstr_o.rs2_valid     = 1'b0;
        dinstr_o.imm_valid     = 1'b0;
        dinstr_o.rd_idx        = '0;
        dinstr_o.rs1_idx       = '0;
        dinstr_o.rs2_idx       = '0;
        dinstr_o.imm           = '0;
        // Not: dinstr_o.op için typedef_pkg.sv'de muhtemelen bir "UNKNOWN" veya "NOP" varsayılanı vardır, 
        // eğer hata alırsan buraya onu da ekleyebilirsin (örn: dinstr_o.op = NOP;)

        // ==========================================
        // 3. ADIM: Opcode'a Göre Komut İşleme
        // ==========================================
        case (opcode)
            
            // --- LUI Komutu ---
            7'b1110101: begin 
                dinstr_o.valid     = 1'b1;
                dinstr_o.rd_valid  = 1'b1;
                dinstr_o.rd_idx    = rd_idx;
                dinstr_o.imm_valid = 1'b1;
                dinstr_o.imm       = {instr_i[31:20], instr_i[12:5], 12'b0};
                dinstr_o.op        = LUI;
            end

            // --- AUIPC Komutu ---
            7'b1110100: begin 
                dinstr_o.valid     = 1'b1;
                dinstr_o.rd_valid  = 1'b1;
                dinstr_o.rd_idx    = rd_idx;
                dinstr_o.imm_valid = 1'b1;
                dinstr_o.imm       = {instr_i[31:20], instr_i[12:5], 12'b0};
                dinstr_o.op        = AUIPC;
            end

            // --- JAL Komutu ---
            7'b1101111: begin 
                dinstr_o.valid         = 1'b1;
                dinstr_o.is_pc_changer = 1'b1; 
                dinstr_o.rd_valid      = 1'b1;
                dinstr_o.rd_idx        = rd_idx;
                dinstr_o.imm_valid     = 1'b1;
                dinstr_o.imm           = { {11{instr_i[31]}}, instr_i[31], instr_i[12:5], instr_i[20], instr_i[30:21], 1'b0 };
                dinstr_o.op            = JAL;
            end

            // --- JALR Komutu ---
            7'b1100111: begin 
                dinstr_o.valid         = 1'b1;
                dinstr_o.is_pc_changer = 1'b1;
                dinstr_o.rd_valid      = 1'b1;
                dinstr_o.rs1_valid     = 1'b1;
                dinstr_o.rd_idx        = rd_idx;
                dinstr_o.rs1_idx       = rs1_idx;
                dinstr_o.imm_valid     = 1'b1;
                dinstr_o.imm           = { {20{instr_i[31]}}, instr_i[31:20] };
                dinstr_o.op            = JALR;
            end

            // --- Branch Komutları (BEQ, BNE, BLT vb.) ---
            7'b1100011: begin 
                dinstr_o.valid         = 1'b1;
                dinstr_o.is_pc_changer = 1'b1; 
                dinstr_o.rs1_valid     = 1'b1;
                dinstr_o.rs2_valid     = 1'b1; 
                dinstr_o.rs1_idx       = rs1_idx;
                dinstr_o.rs2_idx       = rs2_idx;
                dinstr_o.imm_valid     = 1'b1;
                dinstr_o.imm           = { {19{instr_i[31]}}, instr_i[31], instr_i[0], instr_i[30:25], instr_i[4:1], 1'b0 };
                
                case (funct3)
                    3'b100: dinstr_o.op = BEQ;
                    3'b101: dinstr_o.op = BNE;
                    3'b000: dinstr_o.op = BGEU;
                    3'b001: dinstr_o.op = BLTU;
                    3'b010: dinstr_o.op = BGE;
                    3'b011: dinstr_o.op = BLT;
                    default: ;
                endcase
            end

            // --- Load Komutları (LW, LB vb.) ---
            7'b1100000: begin 
                dinstr_o.valid     = 1'b1;
                dinstr_o.is_mem    = 1'b1; 
                dinstr_o.rd_valid  = 1'b1;
                dinstr_o.rs1_valid = 1'b1;
                dinstr_o.rd_idx    = rd_idx;
                dinstr_o.rs1_idx   = rs1_idx;
                dinstr_o.imm_valid = 1'b1;
                dinstr_o.imm       = { {20{instr_i[31]}}, instr_i[31:20] };
                
                case (funct3)
                    3'b000: dinstr_o.op = LBU;
                    3'b001: dinstr_o.op = LHU;
                    3'b100: dinstr_o.op = LB;
                    3'b101: dinstr_o.op = LH;
                    3'b110: dinstr_o.op = LW;
                    default: ;
                endcase
            end

            // --- Store Komutları (SW, SB vb.) ---
            7'b1100001: begin 
                dinstr_o.valid     = 1'b1;
                dinstr_o.is_mem    = 1'b1; 
                dinstr_o.rs1_valid = 1'b1;
                dinstr_o.rs2_valid = 1'b1; 
                dinstr_o.rs1_idx   = rs1_idx;
                dinstr_o.rs2_idx   = rs2_idx;
                dinstr_o.imm_valid = 1'b1;
                dinstr_o.imm       = { {20{instr_i[31]}}, instr_i[31:25], instr_i[4:0] };
                
                case (funct3)
                    3'b000: dinstr_o.op = SB;
                    3'b001: dinstr_o.op = SH;
                    3'b010: dinstr_o.op = SW;
                    default: ;
                endcase
            end

            // --- I-Tipi Aritmetik/Mantık ve Shift (ADDI, SLLI vb.) ---
            7'b1100100: begin 
                dinstr_o.valid     = 1'b1;
                dinstr_o.rd_valid  = 1'b1;
                dinstr_o.rs1_valid = 1'b1;
                dinstr_o.rd_idx    = rd_idx;
                dinstr_o.rs1_idx   = rs1_idx;
                dinstr_o.imm_valid = 1'b1;

                // Shift komutlarında zero-extend, diğerlerinde sign-extend
                if (funct3 == 3'b001 || funct3 == 3'b101) begin
                    dinstr_o.imm = { 27'b0, instr_i[24:20] }; 
                end else begin
                    dinstr_o.imm = { {20{instr_i[31]}}, instr_i[31:20] };
                end
                
                case (funct3)
                    3'b000: dinstr_o.op = ADDI;
                    3'b010: dinstr_o.op = SLTI;
                    3'b011: dinstr_o.op = SLTIU;
                    3'b100: dinstr_o.op = ORI;
                    3'b110: dinstr_o.op = XORI;
                    3'b111: dinstr_o.op = ANDI;
                    3'b001: dinstr_o.op = SLLI;
                    3'b101: begin
                        if (instr_i[31:25] == 7'b0000000)
                            dinstr_o.op = SRLI;
                        else if (instr_i[31:25] == 7'b0000010)
                            dinstr_o.op = SRAI;
                    end
                    default: ;
                endcase
            end

            // --- R-Tipi Komutlar (ADD, SUB, AND vb.) ---
            7'b1110001: begin 
                dinstr_o.valid     = 1'b1;
                dinstr_o.rd_valid  = 1'b1;
                dinstr_o.rs1_valid = 1'b1;
                dinstr_o.rs2_valid = 1'b1;
                dinstr_o.rd_idx    = rd_idx;
                dinstr_o.rs1_idx   = rs1_idx;
                dinstr_o.rs2_idx   = rs2_idx;
                
                case (funct3)
                    3'b000: begin
                        if (instr_i[31:25] == 7'b0000000)
                            dinstr_o.op = ADD;
                        else if (instr_i[31:25] == 7'b0000010)
                            dinstr_o.op = SUB;
                    end
                    3'b001: dinstr_o.op = SLL;
                    3'b010: dinstr_o.op = SLT;
                    3'b011: dinstr_o.op = SLTU;
                    3'b100: dinstr_o.op = XOR;
                    3'b101: begin
                        if (instr_i[31:25] == 7'b0000000)
                            dinstr_o.op = SRL;
                        else if (instr_i[31:25] == 7'b0000010)
                            dinstr_o.op = SRA;
                    end
                    3'b110: dinstr_o.op = OR;
                    3'b111: dinstr_o.op = AND;
                    default: ; 
                endcase
            end

            default: begin
                // Tanımsız opcode gelirse valid = 0 olarak kalır (başta atandığı gibi)
            end
        endcase
    end

endmodule