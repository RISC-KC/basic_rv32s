module InstructionDecoder (
    input [31:0] instr,
    
    output reg [6:0] opcode,
	output reg [2:0] funct3,
	output reg [6:0] funct7,
	output reg [4:0] rs1,
	output reg [4:0] rs2,
	output reg [4:0] rd,
	output reg [19:0] imm
);

	localparam LUI 			= 7'b0110111;
	localparam AUIPC 		= 7'b0010111;
	localparam JAL			= 7'b1101111;
	localparam JALR			= 7'b1100111;
	localparam BRANCH		= 7'b1100011;
	localparam LOAD			= 7'b0000011;
	localparam SAVE			= 7'b0100011;
	localparam AL_IMM		= 7'b0010011;
	localparam AL			= 7'b0110011;
	localparam FENCE		= 7'b0001111;
	localparam ENVIRONMENT	= 7'b1110011;

    always @(*) begin
		opcode = instr[6:0];
		
        case (opcode)
			LUI, AUIPC, JAL: begin // U, J type
                rd = instr[11:7];
				imm = instr[31:12];
				
				funct3 = 3'b000;
				rs1 = 5'b00000;
				rs2 = 5'b00000;
				funct7 = 7'b0000000;
            end
			
			JALR, LOAD, AL_IMM, FENCE, ENVIRONMENT: begin // I type
				rd = instr[11:7];
				funct3 = instr[14:12];
				rs1 = instr[19:15];
				imm = instr[31:20];
				
				rs2 = 5'b00000;
				funct7 = 7'b0000000;
			end
			
			BRANCH, SAVE: begin // S, B type
				funct3 = instr[14:12];
				rs1 = instr[19:15];
				rs2 = instr[24:20];
				imm = {instr[31:25], instr[11:7]};
				
				rd = 5'b00000;
				funct7 = 7'b0000000;
			end
			
			AL: begin // R type
				rd = instr[11:7];
				funct3 = instr[14:12];
				rs1 = instr[19:15];
				rs2 = instr[24:20];
				funct7 = instr[31:25];
				
				imm = 20'b00000000000000000000;
			end
		endcase
    end

endmodule
