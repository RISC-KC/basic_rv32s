`include "C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_RV32I46F5SP/Clean_RV32I46F5SP.srcs/sim_1/new/opcode.vh"

module InstructionDecoder (
	input [31:0] instruction,
    
    output reg [6:0] opcode,
	output reg [2:0] funct3,
	output reg [6:0] funct7,
	output reg [4:0] rs1,
	output reg [4:0] rs2,
	output reg [4:0] rd,
	output reg [19:0] raw_imm
);

	wire [6:0] opcode_wire = instruction[6:0];

    always @(*) begin
		opcode = opcode_wire;
        case (opcode_wire)
			`OPCODE_LUI, `OPCODE_AUIPC: begin // U-type
                rd = instruction[11:7];
				raw_imm = instruction[31:12];
				
				funct3 = 3'b000;
				rs1 = 5'b00000;
				rs2 = 5'b00000;
				funct7 = 7'b0000000;
            end
			
			`OPCODE_JAL: begin // J-type
				rd = instruction[11:7];
				raw_imm = {instruction[31], instruction[19:12], instruction[20], instruction[30:21]};
				
				funct3 = 3'b000;
				rs1 = 5'b00000;
				rs2 = 5'b00000;
				funct7 = 7'b0000000;
			end
			
			`OPCODE_JALR, `OPCODE_LOAD, `OPCODE_ITYPE, `OPCODE_FENCE, `OPCODE_ENVIRONMENT: begin // I-type
				rd = instruction[11:7];
				funct3 = instruction[14:12];
				rs1 = instruction[19:15];
				raw_imm = {8'b0, instruction[31:20]};
				
				rs2 = 5'b00000;
				funct7 = 7'b0000000;
			end
			
			`OPCODE_BRANCH: begin // B-type
				funct3 = instruction[14:12];
				rs1 = instruction[19:15];
				rs2 = instruction[24:20];
				raw_imm = {instruction[31], instruction[7], instruction[30:25], instruction[11:8]};
				
				rd = 5'b00000;
				funct7 = 7'b0000000;
			end
			
			`OPCODE_STORE: begin // S-type
				funct3 = instruction[14:12];
				rs1 = instruction[19:15];
				rs2 = instruction[24:20];
				raw_imm = {8'b0, instruction[31:25], instruction[11:7]};
				
				rd = 5'b00000;
				funct7 = 7'b0000000;
			end
			
			`OPCODE_RTYPE: begin // R type
				rd = instruction[11:7];
				funct3 = instruction[14:12];
				rs1 = instruction[19:15];
				rs2 = instruction[24:20];
				funct7 = instruction[31:25];
				
				raw_imm = 32'b0;
			end
			default: begin
			funct3 = 3'b0;
            funct7 = 7'b0;
            rs1 = 5'b0;
            rs2 = 5'b0;
            rd = 5'b0;
            raw_imm = 20'b0;
            end
		endcase
    end

endmodule
