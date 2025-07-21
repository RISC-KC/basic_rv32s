`include "C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_RV32I46F5SP/Clean_RV32I46F5SP.srcs/sim_1/new/opcode.vh"
`include "C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_RV32I46F5SP/Clean_RV32I46F5SP.srcs/sim_1/new/store.vh"
`include "C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_RV32I46F5SP/Clean_RV32I46F5SP.srcs/sim_1/new/load.vh"
`include "C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_RV32I46F5SP/Clean_RV32I46F5SP.srcs/sim_1/new/trap.vh"

module ExceptionDetector (
    input clk,
    input clk_enable,
    input reset,
    input [6:0] ID_opcode,            // opcode from ID Phase
    input [6:0] EX_opcode,            // opcode from EX Phase
    input [6:0] MEM_opcode,           // opcode from MEM Phase for Synchronous Exception Detector
    // input [4:0] rs1,                   // For Illegal Instruction Exception
    input [2:0] ID_funct3,                // funct3
    input [2:0] EX_funct3,
    input [2:0] MEM_funct3,
    input [1:0] alu_result,         // LSBs of jump target and data_memory_address
    input [1:0] MEM_alu_result,
    input [11:0] raw_imm,            // raw_imm field to distinguish EBREAK, ECALL and MRET, CSR_Address
    input [11:0] EX_raw_imm,
    input csr_write_enable,         // CSR WE signal from Control Unit for Detecting Illegal CSR access from ID Phase.
    input [1:0] branch_target_lsbs,        // LSBs of branch target
    input branch_estimation,
    
    output reg trapped,                // signal indicating if trap has occurred
    output reg [2:0] trap_status    // current trap status
);
    reg ID_trapped;
    reg [2:0] ID_trap_status;
    reg EX_trapped;
    reg [2:0] EX_trap_status;
    reg MEM_trapped;
    reg [2:0] MEM_trap_status;
    reg trapped_combinatorial;
    reg [2:0] trap_status_combinatorial;

    /* For Illegal Instruction Exception
    wire csr_write;
    assign csr_write = (ID_funct3 == `CSR_CSRRW || ID_funct3 == `CSR_CSRRWI) 
                    || ((ID_funct3 == `CSR_CSRRS || ID_funct3 == `CSR_CSRRSI) && (rs1 != 5'b0))
                    || ((ID_funct3 == `CSR_CSRRC || ID_funct3 == `CSR_CSRRCI) && (rs1 != 5'b0));

    wire valid_write_csr;
    assign valid_write_csr = (raw_imm == 12'h305) ||
                             (raw_imm == 12'h341) ||
                             (raw_imm == 12'h342);
*/
    always @(*) begin
        ID_trap_status = `TRAP_NONE;
        ID_trapped = 1'b0;

        case (ID_opcode)
            `OPCODE_FENCE: begin    // Zifencei
                if (ID_funct3 == 3'b001) begin
                    ID_trapped = 1'b1;
                    ID_trap_status = `TRAP_FENCEI;
                end
            end

            `OPCODE_ENVIRONMENT: begin // EBREAK, ECALL, MRET
                if (ID_funct3 == 3'b0) begin
                        ID_trapped = 1'b1;
                    if (raw_imm == 12'b0011_0000_0010) begin
                        ID_trap_status = `TRAP_MRET;
                    end
                    else if (raw_imm[0]) begin
                        ID_trap_status = `TRAP_EBREAK;
                    end
                    else if (raw_imm == 12'b0) begin
                        ID_trap_status = `TRAP_ECALL;
                    end
                end
                else begin
                    ID_trapped = 1'b0;
                    ID_trap_status = `TRAP_NONE;
                end
            end

            `OPCODE_BRANCH: begin // Misaligned
            if (branch_estimation == 1'b1) begin
                if (branch_target_lsbs == 2'b0) begin
                    ID_trapped = 1'b0;
                    ID_trap_status = `TRAP_NONE;
                end 
                else begin
                    ID_trapped = 1'b1;
                    ID_trap_status = `TRAP_MISALIGNED_INSTRUCTION;
                end
            end
            end

            default: begin
                ID_trapped = 1'b0;
                ID_trap_status = `TRAP_NONE;
            end

        endcase

        EX_trapped = 1'b0;
        EX_trap_status = `TRAP_NONE;

        case (EX_opcode)
            `OPCODE_ENVIRONMENT: begin // EBREAK, ECALL, MRET
                if (EX_funct3 == 3'b0) begin
                        EX_trapped = 1'b1;
                    if (EX_raw_imm == 12'b0011_0000_0010) begin
                        EX_trap_status = `TRAP_MRET;
                    end
                    else if (EX_raw_imm[0]) begin
                        EX_trap_status = `TRAP_EBREAK;
                    end
                    else if (EX_raw_imm == 12'b0) begin
                        EX_trap_status = `TRAP_ECALL;
                    end
                end
                else begin
                    EX_trapped = 1'b0;
                    EX_trap_status = `TRAP_NONE;
                end
            end

            `OPCODE_STORE: begin
                case (EX_funct3)
                    `STORE_SH: begin
                        if (alu_result[0] == 1'b1) begin
                            EX_trapped = 1'b1;
                            EX_trap_status = `TRAP_MISALIGNED_STORE;
                        end else begin
                            EX_trapped = 1'b0;
                            EX_trap_status = `TRAP_NONE;
                        end
                    end
                    `STORE_SW: begin
                        if (alu_result[1:0] != 2'b00) begin
                            EX_trapped = 1'b1;
                            EX_trap_status = `TRAP_MISALIGNED_STORE;
                        end else begin
                            EX_trapped = 1'b0;
                            EX_trap_status = `TRAP_NONE;
                        end
                    end
                    default: begin
                        EX_trapped = 1'b0;
                        EX_trap_status = `TRAP_NONE;
                    end 
                endcase
            end

            `OPCODE_LOAD: begin
                case (EX_funct3)
                    `LOAD_LH, `LOAD_LHU: begin
                        if (alu_result[0] == 1'b1) begin
                            EX_trapped = 1'b1;
                            EX_trap_status = `TRAP_MISALIGNED_LOAD;
                        end else begin
                            EX_trapped = 1'b0;
                            EX_trap_status = `TRAP_NONE;
                        end
                    end
                    `LOAD_LW: begin
                        if (alu_result[1:0] != 2'b00) begin
                            EX_trapped = 1'b1;
                            EX_trap_status = `TRAP_MISALIGNED_LOAD;
                        end else begin
                            EX_trapped = 1'b0;
                            EX_trap_status = `TRAP_NONE;
                        end
                    end
                    default: begin
                        EX_trapped = 1'b0;
                        EX_trap_status = `TRAP_NONE;
                    end
                endcase
            end
            `OPCODE_JAL, `OPCODE_JALR: begin
                if (alu_result == 2'b0) begin
                    EX_trapped = 1'b0;
                    EX_trap_status = `TRAP_NONE;
                end else begin
                    EX_trapped = 1'b1;
                    EX_trap_status = `TRAP_MISALIGNED_INSTRUCTION;
                end
            end    
            default: begin
                EX_trapped = 1'b0;
                EX_trap_status = `TRAP_NONE;
            end
        endcase

        MEM_trapped = 1'b0;
        MEM_trap_status = `TRAP_NONE;

        case (MEM_opcode)
            `OPCODE_STORE: begin
                case (MEM_funct3)
                    `STORE_SH: begin
                        if (MEM_alu_result[0] == 1'b1) begin
                            MEM_trapped = 1'b1;
                            MEM_trap_status = `TRAP_MISALIGNED_STORE;
                        end else begin
                            MEM_trapped = 1'b0;
                            MEM_trap_status = `TRAP_NONE;
                        end
                    end
                    `STORE_SW: begin
                        if (MEM_alu_result[1:0] != 2'b00) begin
                            MEM_trapped = 1'b1;
                            MEM_trap_status = `TRAP_MISALIGNED_STORE;
                        end else begin
                            MEM_trapped = 1'b0;
                            MEM_trap_status = `TRAP_NONE;
                        end
                    end
                    default: begin
                        MEM_trapped = 1'b0;
                        MEM_trap_status = `TRAP_NONE;
                    end 
                endcase
            end

            `OPCODE_LOAD: begin
                case (MEM_funct3)
                    `LOAD_LH, `LOAD_LHU: begin
                        if (MEM_alu_result[0] == 1'b1) begin
                            MEM_trapped = 1'b1;
                            MEM_trap_status = `TRAP_MISALIGNED_LOAD;
                        end else begin
                            MEM_trapped = 1'b0;
                            MEM_trap_status = `TRAP_NONE;
                        end
                    end
                    `LOAD_LW: begin
                        if (MEM_alu_result[1:0] != 2'b00) begin
                            MEM_trapped = 1'b1;
                            MEM_trap_status = `TRAP_MISALIGNED_LOAD;
                        end else begin
                            MEM_trapped = 1'b0;
                            MEM_trap_status = `TRAP_NONE;
                        end
                    end
                    default: begin
                        MEM_trapped = 1'b0;
                        MEM_trap_status = `TRAP_NONE;
                    end
                endcase
            end
            `OPCODE_JAL, `OPCODE_JALR: begin
                if (MEM_alu_result == 2'b0) begin
                    MEM_trapped = 1'b0;
                    MEM_trap_status = `TRAP_NONE;
                end else begin
                    MEM_trapped = 1'b1;
                    MEM_trap_status = `TRAP_MISALIGNED_INSTRUCTION;
                end
            end    
            default: begin
                MEM_trapped = 1'b0;
                MEM_trap_status = `TRAP_NONE;
            end
        endcase

        if (MEM_trapped) begin
            trapped_combinatorial = 1'b1;
            trap_status_combinatorial = MEM_trap_status;
        end else if (EX_trapped) begin
            trapped_combinatorial = 1'b1;
            trap_status_combinatorial = EX_trap_status;
        end else if (ID_trapped) begin
            trapped_combinatorial = 1'b1;
            trap_status_combinatorial = ID_trap_status;
        end else begin
            trapped_combinatorial = 1'b0;
            trap_status_combinatorial = `TRAP_NONE;
        end
    end
        /* For Illegal Instruction Exception
        if (csr_write_enable && csr_write && !valid_write_csr) begin
            trapped = 1'b1;
            trap_status = `TRAP_ILLEGAL_INSTRUCTION;
        end
        */

    // Synchronous trap signal output
    always @(posedge clk  or posedge reset) begin
        if (reset) begin
            trapped <= 1'b0;
            trap_status <= `TRAP_NONE;
        end else if (clk_enable) begin
            trapped <= trapped_combinatorial;
            trap_status <= trap_status_combinatorial;
        end
    end
endmodule