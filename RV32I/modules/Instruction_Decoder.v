`include "modules/headers/opcode.vh"

module InstructionDecoder (
    input [31:0] instr,
    
    output reg [6:0] opcode,
	output reg [2:0] funct3,
	output reg [6:0] funct7,
	output reg [4:0] rs1,
	output reg [4:0] rs2,
	output reg [4:0] rd,
	output reg [31:0] imm
);

    always @(*) begin
		opcode = instr[6:0];
		
        case (opcode)
			`OPCODE_LUI, `OPCODE_AUIPC: begin // U-type
                rd = instr[11:7];
				imm = {instr[31:12], 12'b0};
				
				funct3 = 3'b000;
				rs1 = 5'b00000;
				rs2 = 5'b00000;
				funct7 = 7'b0000000;
            end
			
			`OPCODE_JAL: begin // J-type
				rd = instr[11:7];
				imm = {11'b0, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
				
				funct3 = 3'b000;
				rs1 = 5'b00000;
				rs2 = 5'b00000;
				funct7 = 7'b0000000;
			end
			
			`OPCODE_JALR, `OPCODE_LOAD, `OPCODE_ITYPE, `OPCODE_FENCE, `OPCODE_ENVIRONMENT: begin // I-type
				rd = instr[11:7];
				funct3 = instr[14:12];
				rs1 = instr[19:15];
				imm = {20'b0, instr[31:20]};
				
				rs2 = 5'b00000;
				funct7 = 7'b0000000;
			end
			
			`OPCODE_BRANCH: begin // B-type
				funct3 = instr[14:12];
				rs1 = instr[19:15];
				rs2 = instr[24:20];
				imm = {19'b0, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
				
				rd = 5'b00000;
				funct7 = 7'b0000000;
			end
			
			`OPCODE_STORE: begin // S-type
				funct3 = instr[14:12];
				rs1 = instr[19:15];
				rs2 = instr[24:20];
				imm = {20'b0, instr[31:25], instr[11:7]};
				
				rd = 5'b00000;
				funct7 = 7'b0000000;
			end
			
			`OPCODE_RTYPE: begin // R type
				rd = instr[11:7];
				funct3 = instr[14:12];
				rs1 = instr[19:15];
				rs2 = instr[24:20];
				funct7 = instr[31:25];
				
				imm = 32'b0;
			end
		endcase
    end

endmodule
