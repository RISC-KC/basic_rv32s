`timescale 1ns/1ps

module InstructionMemory_tb;
    reg [31:0] pc;
    reg [31:0] rom_address;
    wire [31:0] instruction;
    wire [31:0] rom_read_data;

    InstructionMemory instruction_memory (
        .pc(pc),
        .instruction(instruction),
        .rom_address(rom_address),
        .rom_read_data(rom_read_data)
    );

    initial begin
        $dumpfile("testbenches/results/waveforms/Instruction_Memory_tb_result.vcd");
        $dumpvars(0, InstructionMemory_tb.instruction_memory);

        $writememb("testbenches/test_code.mem", instruction_memory.data);

        // Test sequence
        $display("==================== Instruction Memory Test START ====================\n");

        // ========================================================================
        // Test 1: PC-based Instruction Fetch (Basic functionality)
        // ========================================================================
        $display("[Test 1] PC-based Instruction Fetch:");
        
        pc = 32'h00000000; 
        rom_address = 32'h00000000;
        #10;
        $display("  pc=%h, instruction=%h", pc, instruction);
        $display("  -> Expected: ADDI x1, x0, 0x2BC instruction");
        
        pc = 32'h00000004; #10;
        $display("  pc=%h, instruction=%h", pc, instruction);
        $display("  -> Expected: SLLI x2, x1, 24 instruction");
        
        pc = 32'h00000008; #10;
        $display("  pc=%h, instruction=%h", pc, instruction);
        $display("  -> Expected: SLTI x3, x2, 0 instruction");

        pc = 32'h0000000C; #10;
        $display("  pc=%h, instruction=%h", pc, instruction);
        $display("  -> Expected: SLTIU x4, x2, 0 instruction");

        // ========================================================================
        // Test 2: Trap Handler Address Instruction Fetch (pc = 0x00001000)
        // ========================================================================
        $display("\n[Test 2] Trap Handler Address Instruction Fetch:");
        
        pc = 32'h00001000; #10;
        $display("  pc=%h (Trap Handler), instruction=%h", pc, instruction);
        $display("  -> Expected: CSRRS x6, mcause, x0 instruction (data[1024])");

        pc = 32'h00001004; #10;
        $display("  pc=%h, instruction=%h", pc, instruction);
        $display("  -> Expected: ADDI x7, x0, 11 instruction (data[1025])");

        pc = 32'h0000100C; #10;
        $display("  pc=%h, instruction=%h", pc, instruction);
        $display("  -> Expected: BEQ x6, x7, +16 instruction (data[1027])");

        // ========================================================================
        // Test 3: ROM Address Read - ROM Region (0x0000xxxx)
        // ========================================================================
        $display("\n[Test 3] ROM Address Read - ROM Region (0x0000xxxx):");
        
        // Read from address 0x00000000
        rom_address = 32'h00000000; #10;
        $display("  rom_address=%h, rom_read_data=%h", rom_address, rom_read_data);
        $display("  -> Expected: ADDI x1, x0, 0x2BC instruction (data[0])");
        
        // Read from address 0x00000004
        rom_address = 32'h00000004; #10;
        $display("  rom_address=%h, rom_read_data=%h", rom_address, rom_read_data);
        $display("  -> Expected: SLLI x2, x1, 24 instruction (data[1])");
        
        // Read from address 0x0000001C (SW instruction at data[7])
        rom_address = 32'h0000001C; #10;
        $display("  rom_address=%h, rom_read_data=%h", rom_address, rom_read_data);
        $display("  -> Expected: ORI x8, x2, 0xBC instruction (data[7])");
        
        // Read from address 0x00000050 (Store instruction at data[20])
        rom_address = 32'h00000050; #10;
        $display("  rom_address=%h, rom_read_data=%h", rom_address, rom_read_data);
        $display("  -> Expected: SH instruction (data[20])");

        // ========================================================================
        // Test 4: ROM Address Read - Trap Handler Region (0x00001000)
        // ========================================================================
        $display("\n[Test 4] ROM Address Read - Trap Handler Region:");
        
        rom_address = 32'h00001000; #10;
        $display("  rom_address=%h, rom_read_data=%h", rom_address, rom_read_data);
        $display("  -> Expected: CSRRS x6, mcause, x0 (data[1024])");
        
        rom_address = 32'h00001004; #10;
        $display("  rom_address=%h, rom_read_data=%h", rom_address, rom_read_data);
        $display("  -> Expected: ADDI x7, x0, 11 (data[1025])");
        
        rom_address = 32'h0000101C; #10;
        $display("  rom_address=%h, rom_read_data=%h", rom_address, rom_read_data);
        $display("  -> Expected: ADDI x1, x0, 0 (data[1031] - ECALL handler)");

        // ========================================================================
        // Test 5: ROM Address Read - Upper Boundary (0x0000FFFC)
        // ========================================================================
        $display("\n[Test 5] ROM Address Read - ROM Region Upper Boundary:");
        
        rom_address = 32'h0000FFFC; #10;
        $display("  rom_address=%h, rom_read_data=%h", rom_address, rom_read_data);
        $display("  -> Expected: Valid ROM data or 0 if not initialized");
        
        rom_address = 32'h00008000; #10;
        $display("  rom_address=%h, rom_read_data=%h", rom_address, rom_read_data);
        $display("  -> Expected: ROM data at address 0x8000 (data[2048])");

        // ========================================================================
        // Test 6: ROM Address Read - Invalid Region (not 0x0000xxxx)
        // ========================================================================
        $display("\n[Test 6] ROM Address Read - Invalid Region:");
        
        rom_address = 32'h10000000; #10;
        $display("  rom_address=%h, rom_read_data=%h", rom_address, rom_read_data);
        $display("  -> Expected: 00000000 (RAM region, should return 0)");
        
        rom_address = 32'h20000000; #10;
        $display("  rom_address=%h, rom_read_data=%h", rom_address, rom_read_data);
        $display("  -> Expected: 00000000 (invalid region, should return 0)");
        
        rom_address = 32'hFFFFFFFF; #10;
        $display("  rom_address=%h, rom_read_data=%h", rom_address, rom_read_data);
        $display("  -> Expected: 00000000 (invalid region, should return 0)");

        // ========================================================================
        // Test 7: ROM vs PC Read Comparison
        // ========================================================================
        $display("\n[Test 7] ROM vs PC Read Comparison:");
        
        pc = 32'h00000024;
        rom_address = 32'h00000024;
        #10;
        $display("  pc=%h, instruction=%h", pc, instruction);
        $display("  rom_address=%h, rom_read_data=%h", rom_address, rom_read_data);
        $display("  -> Both should read data[9] (ADD instruction)");
        
        if (instruction == rom_read_data) begin
            $display("  PASS: PC and ROM address read the same data");
        end else begin
            $display("  FAIL: PC and ROM address read different data!");
        end

        // ========================================================================
        // Test 8: ROM Address Access to Stored Data
        // ========================================================================
        $display("\n[Test 8] ROM Address Access - Various Instruction Types:");
        
        // R-type at data[9] (0x00000024)
        rom_address = 32'h00000024; #10;
        $display("  R-type (ADD): rom_address=%h, rom_read_data=%h", rom_address, rom_read_data);
        
        // S-type at data[19] (0x0000004C)
        rom_address = 32'h0000004C; #10;
        $display("  S-type (SW):  rom_address=%h, rom_read_data=%h", rom_address, rom_read_data);
        
        // B-type at data[30] (0x00000078)
        rom_address = 32'h00000078; #10;
        $display("  B-type (BEQ): rom_address=%h, rom_read_data=%h", rom_address, rom_read_data);
        
        // J-type at data[29] (0x00000074)
        rom_address = 32'h00000074; #10;
        $display("  J-type (JAL): rom_address=%h, rom_read_data=%h", rom_address, rom_read_data);
        
        // U-type at data[27] (0x0000006C)
        rom_address = 32'h0000006C; #10;
        $display("  U-type (LUI): rom_address=%h, rom_read_data=%h", rom_address, rom_read_data);

        // ========================================================================
        // Test 9: Sequential ROM Address Read
        // ========================================================================
        $display("\n[Test 9] Sequential ROM Address Read:");
        
        rom_address = 32'h00000000; #10;
        $display("  rom_address=%h, rom_read_data=%h (data[0])", rom_address, rom_read_data);
        
        rom_address = 32'h00000004; #10;
        $display("  rom_address=%h, rom_read_data=%h (data[1])", rom_address, rom_read_data);
        
        rom_address = 32'h00000008; #10;
        $display("  rom_address=%h, rom_read_data=%h (data[2])", rom_address, rom_read_data);
        
        rom_address = 32'h0000000C; #10;
        $display("  rom_address=%h, rom_read_data=%h (data[3])", rom_address, rom_read_data);

        // ========================================================================
        // Test 10: ROM Address Region Boundary Check
        // ========================================================================
        $display("\n[Test 10] ROM Address Region Boundary Check:");
        
        // Just below ROM boundary (0x0000FFFF)
        rom_address = 32'h0000FFF8; #10;
        $display("  rom_address=%h (ROM region), rom_read_data=%h", rom_address, rom_read_data);
        
        // Just above ROM boundary (0x00010000)
        rom_address = 32'h00010000; #10;
        $display("  rom_address=%h (not ROM), rom_read_data=%h", rom_address, rom_read_data);
        $display("  -> Expected: 00000000 (address[31:16] != 0x0000)");
        
        // ROM lower boundary (0x00000000)
        rom_address = 32'h00000000; #10;
        $display("  rom_address=%h (ROM region), rom_read_data=%h", rom_address, rom_read_data);

        $display("\n====================  Instruction Memory Test END  ====================");

        $stop;
    end

endmodule