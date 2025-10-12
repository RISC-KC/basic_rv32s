`include "C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_main/Clean_main.srcs/sources_1/imports/modules/headers/alu_src_select.vh"
`include "C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_main/Clean_main.srcs/sources_1/imports/modules/headers/csr.vh"
`include "C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_main/Clean_main.srcs/sources_1/imports/modules/headers/itype.vh"
`include "C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_main/Clean_main.srcs/sources_1/imports/modules/headers/opcode.vh"
`include "C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_main/Clean_main.srcs/sources_1/imports/modules/headers/rf_wd_select.vh"

module ControlUnit (
	input write_done,
	input trap_done,
	input csr_ready,
	input [6:0] opcode,
	input [2:0] funct3,
    
	output reg jump,
	output reg branch,
	output reg [1:0] alu_src_A_select,
	output reg [2:0] alu_src_B_select,
	output reg csr_write_enable,
	output reg register_file_write,
	output reg [2:0] register_file_write_data_select,
	output reg memory_read,
	output reg memory_write,
	output reg pc_stall
);

    always @(*) begin
		pc_stall = !write_done || !trap_done || !csr_ready;
        jump = 1'b0;
        branch = 1'b0;
        alu_src_A_select = `ALU_SRC_A_NONE;
        alu_src_B_select = `ALU_SRC_B_NONE; 
        csr_write_enable = 1'b0;
        register_file_write = 1'b0;
        register_file_write_data_select = `RF_WD_NONE;
        memory_read = 1'b0;
        memory_write = 1'b0;

		case (opcode)
			`OPCODE_LUI: begin
				jump = 0;
				branch = 0;
				alu_src_A_select = `ALU_SRC_A_NONE;
				alu_src_B_select = `ALU_SRC_B_NONE;
				csr_write_enable = 0;
				register_file_write = 1;
				register_file_write_data_select = `RF_WD_LUI;
				memory_read = 0;
				memory_write = 0;
			end
			`OPCODE_AUIPC: begin
				jump = 0;
				branch = 0;
				alu_src_A_select = `ALU_SRC_A_PC;
				alu_src_B_select = `ALU_SRC_B_IMM;
				csr_write_enable = 0;
				register_file_write = 1;
				register_file_write_data_select = `RF_WD_ALU;
				memory_read = 0;
				memory_write = 0;
			end
			`OPCODE_JAL: begin
				jump = 1;
				branch = 0;
				alu_src_A_select = `ALU_SRC_A_PC;
				alu_src_B_select = `ALU_SRC_B_IMM;
				csr_write_enable = 0;
				register_file_write = 1;
				register_file_write_data_select = `RF_WD_JUMP;
				memory_read = 0;
				memory_write = 0;
			end
			`OPCODE_JALR: begin
				jump = 1;
				branch = 0;
				alu_src_A_select = `ALU_SRC_A_RD1;
				alu_src_B_select = `ALU_SRC_B_IMM;
				csr_write_enable = 0;
				register_file_write = 1;
				register_file_write_data_select = `RF_WD_JUMP;
				memory_read = 0;
				memory_write = 0;
			end
			`OPCODE_BRANCH: begin
				jump = 0;
				branch = 1;
				alu_src_A_select = `ALU_SRC_A_RD1;
				alu_src_B_select = `ALU_SRC_B_RD2;
				csr_write_enable = 0;
				register_file_write = 0;
				register_file_write_data_select = `RF_WD_NONE;
				memory_read = 0;
				memory_write = 0;
			end
			`OPCODE_LOAD: begin
				jump = 0;
				branch = 0;
				alu_src_A_select = `ALU_SRC_A_RD1;
				alu_src_B_select = `ALU_SRC_B_IMM;
				csr_write_enable = 0;
				register_file_write = 1;
				register_file_write_data_select = `RF_WD_LOAD;
				memory_read = 1;
				memory_write = 0;
			end
			`OPCODE_STORE: begin
				jump = 0;
				branch = 0;
				alu_src_A_select = `ALU_SRC_A_RD1;
				alu_src_B_select = `ALU_SRC_B_IMM;
				csr_write_enable = 0;
				register_file_write = 0;
				register_file_write_data_select = `RF_WD_NONE;
				memory_read = 0;
				memory_write = 1;
			end
			`OPCODE_ITYPE: begin
				jump = 0;
				branch = 0;
				alu_src_A_select = `ALU_SRC_A_RD1;

				if (funct3 == `ITYPE_SRXI) begin
					alu_src_B_select = `ALU_SRC_B_SHAMT;
				end else begin
					alu_src_B_select = `ALU_SRC_B_IMM;
				end
				
				csr_write_enable = 0;
				register_file_write = 1;
				register_file_write_data_select = `RF_WD_ALU;
				memory_read = 0;
				memory_write = 0;
			end
			`OPCODE_RTYPE: begin
				jump = 0;
				branch = 0;
				alu_src_A_select = `ALU_SRC_A_RD1;
				alu_src_B_select = `ALU_SRC_B_RD2;
				csr_write_enable = 0;
				register_file_write = 1;
				register_file_write_data_select = `RF_WD_ALU;
				memory_read = 0;
				memory_write = 0;
			end
			`OPCODE_FENCE: begin
				jump = 0;
				branch = 0;
				alu_src_A_select = `ALU_SRC_A_NONE;
				alu_src_B_select = `ALU_SRC_B_NONE;
				csr_write_enable = 0;
				register_file_write = 0;
				register_file_write_data_select = `RF_WD_NONE;
				memory_read = 0;
				memory_write = 0;
			end
			`OPCODE_ENVIRONMENT: begin
				jump = 0;
				branch = 0;
				csr_write_enable = (funct3 == 0) ? 0 : 1;

				if (funct3 == 3'b0) begin
					alu_src_A_select = `ALU_SRC_A_NONE;
					alu_src_B_select = `ALU_SRC_B_NONE; 
					register_file_write = 0;
					register_file_write_data_select = `RF_WD_NONE;
				end
				else begin
					if (funct3 == `CSR_CSRRW || funct3 == `CSR_CSRRWI) begin
						alu_src_B_select = `ALU_SRC_B_NONE;
					end else begin
						alu_src_B_select = `ALU_SRC_B_CSR;
					end
					if (funct3 == `CSR_CSRRW || funct3 == `CSR_CSRRS || funct3 == `CSR_CSRRC) begin
						alu_src_A_select = `ALU_SRC_A_RD1;
					end else begin
						alu_src_A_select = `ALU_SRC_A_RS1;
					end
					register_file_write = 1;
					register_file_write_data_select = `RF_WD_CSR;
				end
				memory_read = 0;
				memory_write = 0;
			end
			default: begin
                jump = 1'b0;
                branch = 1'b0;
                alu_src_A_select = `ALU_SRC_A_NONE;
                alu_src_B_select = `ALU_SRC_B_NONE; 
                csr_write_enable = 1'b0;
                register_file_write = 1'b0;
                register_file_write_data_select = `RF_WD_NONE;
                memory_read = 1'b0;
                memory_write = 1'b0;
            end
		endcase
    end
endmodule