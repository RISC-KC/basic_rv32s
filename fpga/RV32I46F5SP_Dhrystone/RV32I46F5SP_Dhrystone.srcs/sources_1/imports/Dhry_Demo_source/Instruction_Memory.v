`include "./branch.vh"
`include "./itype.vh"
`include "./load.vh"
`include "./rtype.vh"
`include "./store.vh"
`include "./opcode.vh"
`include "./csr.vh"

module InstructionMemory (
    input [31:0] pc,
    output reg [31:0] instruction,

	input [31:0] rom_address,
	output reg [31:0] rom_read_data
);

	reg [31:0] data [0:16383];
	
	initial begin
        $readmemh("C:/Users/KHWL2025/Desktop/RISC-KC/FPGA_Verification/Clean_RV32I46F5SP/Clean_RV32I46F5SP.srcs/sim_1/imports/benchmark-dhrystone/dhrystone.mem", data);
        // ──────────────────────────────────────────────
		// Trap Handler 시작 주소. mtvec = 0000_1000 = 4096 ÷ 4 Byte = 1024
		// Trap Handler 진입 시 기존 GPR의 레지스터 내용들을 별도의 메모리 Heap 구역에 store하고 수행해야하지만, 현재 단계에서는 생략함.
		// CSR mcause 확인해서 ecall이면 x1 = 0000_0000으로 만들기, misaligned면 x2에 FF더하기
		// 조건 분기; 비교문 작성을 위한 적재 작업
		data[7000] = {12'h342, 5'd0, 3'b010, 5'd6, `OPCODE_ENVIRONMENT}; 					// csrrs x6, mcause, x0:	레지스터 x6에 mcause값 적재
		data[7001] = {12'd11, 5'd0, `ITYPE_ADDI, 5'd7, `OPCODE_ITYPE};						// addi x7, x0, 11: 		레지스터 x7에 ECALL 코드 값 11 적재 (mcause가 11인지 비교하기 위해서는 해당 11이라는 값을 레지스터 넣고 레지스터끼리 비교해야하므로)	
		data[7002] = {12'd2, 5'd0, `ITYPE_ADDI, 5'd8, `OPCODE_ITYPE};						// addi x8, x0, 2: 			레지스터 x8에 ILLEGAL INSTRUCTION 코드 값 2 적재 (mcause가 2인지 비교하기 위해서는 해당 2이라는 값을 레지스터 넣고 레지스터끼리 비교해야하므로)	

		// mcause 분석해서 해당하는 Trap Handler 주소로 분기
		data[7003] = {1'b0, 6'd0, 5'd7, 5'd6, `BRANCH_BEQ, 4'b1101, 1'b0, `OPCODE_BRANCH};	// beq x6, x7, +26: 		ECALL; x6과 x7이 같다면 26바이트 이후 주솟값으로 분기 = data[7010]
		data[7004] = {1'b0, 6'd0, 5'd0, 5'd6, `BRANCH_BEQ, 4'b1010, 1'b0, `OPCODE_BRANCH};	// beq x6, x0, +20: 		MISALIGNED; x6값이 0과 같다면 16바이트 이후 주솟값으로 분기 = data[7009]
		data[7005] = {1'b0, 6'd0, 5'd0, 5'd6, `BRANCH_BEQ, 4'b1000, 1'b0, `OPCODE_BRANCH};	// beq x6, x8, +16: 		ILLEGAL; x6값이 x8과 같다면 16바이트 이후 주솟값으로 분기 = data[1033]
		data[7006] = {1'b0, 10'b000_0001_000, 1'b0, 8'b0, 5'd0, `OPCODE_JAL};				// jal x0, +16: 			TH 끝내기 (mret 명령어 주소로 가기)
		
		// ECALL Trap Handler @ data[1029]
		data[7007] = {12'd0, 5'd0, `ITYPE_ADDI, 5'd1, `OPCODE_ITYPE};						//addi x1, x0, 0: 			레지스터 x1 값 0으로 비우기
		data[7008] = {1'b0, 10'b000_0000_100, 1'b0, 8'b0, 5'd0, `OPCODE_JAL};				//jal x0, +8:				TH 끝내기 (mret 명령어 주소로 가기)

		// ILLEGAL / MISALIGNED Trap Handler @ data[1031]
		data[7009] = {12'hFF, 5'd2, `ITYPE_ADDI, 5'd30, `OPCODE_ITYPE};						//addi x30, x2, 255: 		x30 레지스터에 x2(BC00_0000) + 0xFF = bc00_00ff

		// ESCAPE Trap Handler @ data[1032]
		data[7010] = {12'b001100000010, 5'b0, 3'b0, 5'b0, `OPCODE_ENVIRONMENT};				//MRET:						PC = CSR[mepc]

		// HINT; NOP for 'x' signal after MRET in pipeline
		data[7011] = {12'h2BC, 5'd0, `ITYPE_ADDI, 5'd0, `OPCODE_ITYPE};
		data[7012] = {12'h2BC, 5'd0, `ITYPE_ADDI, 5'd0, `OPCODE_ITYPE};		
	end
	
	always @(*) begin
		instruction = data[pc[31:2]];
	end

	wire rom_access = (rom_address[31:16] == 16'h0000);
    always @(*) begin
        if (rom_access) begin
            rom_read_data = data[rom_address[15:2]];
        end else begin
            rom_read_data = 32'b0;
        end
    end

endmodule