module ForwardUnit (
    input wire hazard_op                    // signal indicating data hazard has been occured
    input wire [31:0] MEM_imm;              // from EX/MEM Register for LUI
    input wire [31:0] MEM_alu_result;       
    input wire [31:0] MEM_csr_read_data;
    input wire [31:0] MEM_read_data;        // from Data Memory
    input wire [31:0] MEM_pc_plus_4;        // from EX/MEM Register
    input wire [6:0] MEM_opcode;            // from EX/MEM Register
    
    output reg [31:0] alu_forward_source_data_a;    // Forwarded source A data signal
    output reg [31:0] alu_forward_source_data_b;    // Forwarded source B data signal
    output reg [1:0] alu_forward_source_select_a; // ALU source A selection between normal source and forwarded source
    output reg [1:0] alu_forward_source_select_b; // ALU source B selection between normal source and forwarded source

    localparam OPCODE_LOAD = ;

    always @(*) begin
        if (hazard_op == 1'b1) begin
            case (param)
                : 
                default: 
            endcase
        end
        
    end
);
    
endmodule