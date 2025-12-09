`include "modules/RV32I46F_5SP_Debug.v"
`include "modules/Button_Controller.v"
`include "modules/UART_TX.v"
`include "modules/Debug_UART_Controller.v"

module RV32I46F5SPSoCTOP #(
    parameter XLEN = 32
)(
    input clk,                      // 100MHz system clock from Nexys Video
    input reset_n,                  // System reset (active low)
    
    // Button Interface (Nexys Video)
    input btn_center,               // Benchmark Start
    
    // LED state indicator
    output [7:0] led,                // states LED
    
    // UART Interface
    output uart_tx_in                  // UART TX pin
);

    // Clock Divider: 100MHz -> 50MHz
    reg clk_50mhz_unbuffered;
    wire clk_50mhz;
    wire reset = ~reset_n;
    
    BUFG clk_50mhz_bufg (               // Automatically synthesized in Vivado without `include module
        .I(clk_50mhz_unbuffered),
        .O(clk_50mhz)
    );
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_50mhz_unbuffered <= 1'b0;
        end else begin
            clk_50mhz_unbuffered <= ~clk_50mhz_unbuffered;
        end
    end

    // Clock enable control
    reg cpu_clk_enable;
    reg [1:0] step_state;
    wire cpu_clk;
    assign cpu_clk = (cpu_clk_enable | continuous_mode);
    
    // Button control signals  
    wire step_pulse;                // Single step execution pulse
    wire continuous_mode;           // Continuous execution mode
    wire pc_inst_trigger;
    wire reg_trigger;
    wire alu_trigger;
    
    // UART signals
    wire tx_start;
    wire [7:0] tx_data;
    wire tx_busy;
    
    // CPU Internal states debug signals
    wire [31:0] pc_value;
    wire [31:0] current_instruction;
    wire [4:0] debug_reg_addr_wire;
    wire [31:0] debug_reg_data_wire;

    // ALU Signals
    wire [31:0] debug_alu_result_wire;

    // internal reset control signals
    wire internal_reset;
    reg reset_sync [0:2];
    assign internal_reset = reset_sync[2];
    
    // CPU states LED Indicator
    assign led[0] = current_instruction[0];
    assign led[1] = current_instruction[1];
    assign led[2] = current_instruction[2];
    assign led[3] = current_instruction[3];
    assign led[4] = current_instruction[4];
    assign led[5] = current_instruction[5];
    assign led[6] = current_instruction[6];
    assign led[7] = current_instruction[7];

    // Module instances
    ButtonController button_controller (
        .clk(clk_50mhz),               // 50MHz
        .reset(internal_reset),
        
        .btn_center(btn_center),
        .btn_up(btn_up),
        .btn_down(btn_down),
        .btn_left(btn_left),
        .btn_right(btn_right),
        
        .step_pulse(step_pulse),
        .continuous_mode(continuous_mode),
        .pc_inst_trigger(pc_inst_trigger),
        .reg_trigger(reg_trigger),
        .alu_trigger(alu_trigger)
    );

    // UART Transmitter
    UARTTX uart_tx (
        .clk(clk_50mhz),
        .reset(internal_reset),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(uart_tx_in),
        .tx_busy(tx_busy)
    );
    
    // CPU - clock enable
    RV32I46F5SPMMIO #(.XLEN(XLEN)) rv32i46f_5sp_mmio (
        .clk(clk_50mhz),           // 50MHz
        .reset(internal_reset),
        .UART_busy(tx_busy),

        .retire_instruction(retire_instruction),
        .mmio_uart_tx_data(tx_data),
        .mmio_uart_tx_start(tx_start)
    );
    
    // Synchronous Reset
    always @(posedge clk_50mhz or posedge reset) begin
        if (reset) begin
            reset_sync[0] <= 1'b1;
            reset_sync[1] <= 1'b1;
            reset_sync[2] <= 1'b1;
        end else begin
            reset_sync[0] <= 1'b0;
            reset_sync[1] <= reset_sync[0];
            reset_sync[2] <= reset_sync[1];
        end
    end
    
    // CPU Clock enable control Logics
    always @(posedge clk_50mhz or posedge internal_reset) begin
        if (internal_reset) begin
            // CPU Debug logics
            cpu_clk_enable <= 1'b0;
            step_state <= 2'b00;
            
        end else begin
            // CPU Step control
            case (step_state)
                2'b00: begin // Idle
                    cpu_clk_enable <= 1'b0;
                    if (step_pulse) begin
                        step_state <= 2'b01;
                    end else if (continuous_mode) begin
                        cpu_clk_enable <= 1'b1;
                    end
                end
                
                2'b01: begin // Single step - enable clock
                    cpu_clk_enable <= 1'b1;
                    step_state <= 2'b10;
                end
                
                2'b10: begin // Single step - disable clock
                    cpu_clk_enable <= 1'b0;
                    step_state <= 2'b00;
                end
                
                default: step_state <= 2'b00;
            endcase
        end
    end

endmodule