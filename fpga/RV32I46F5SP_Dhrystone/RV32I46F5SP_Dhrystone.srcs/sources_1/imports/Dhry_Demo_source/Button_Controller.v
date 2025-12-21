module ButtonController (
    input clk,                      // 50MHz system clock
    input reset,
    
    // Physical Button inputs (active high)
    input btn_center,               // Center - Step by Step Execution Mode
    input btn_up,                   // Up - Benchmark start
    input btn_down,                 // Down - UART Trigger
    input btn_left,                 // Left - Previous Register select
    input btn_right,                // Right - Next Register select
    
    // Output control signals
    output step_pulse,              // One clock cycle pulse for single step execution
    output result_trigger, 
    output pc_inst_trigger,
    output reg_trigger,
    output benchmark_start
);

    // Debouncing parameter for FPGA
    localparam DEBOUNCE_CYCLES = 20'd500000; // 10ms @ 50MHz
    
    // Debouncing counter for each buttons
    reg [19:0] debounce_counter [0:4];
    reg [4:0] button_sync [0:2];        // 3 level synchronization
    reg [4:0] button_stable;            // Stable button state
    reg [4:0] button_prev;              // Previous button state
    reg [4:0] button_rising_edge;       // Rising edge detection
    
    // Output registers
    reg step_pulse_reg;
    //reg continuous_mode_reg;
    reg benchmark_start_reg;
    reg reg_trigger_reg;
    reg pc_inst_trigger_reg;
    //reg alu_trigger_reg;
    reg result_trigger_reg;
    
    integer i;
    
    // Button input array
    wire [4:0] button_inputs = {btn_right, btn_left, btn_down, btn_up, btn_center};
    
    // 3 level synchronization for metastability
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            button_sync[0] <= 5'b0;
            button_sync[1] <= 5'b0;
            button_sync[2] <= 5'b0;
        end else begin
            button_sync[0] <= button_inputs;
            button_sync[1] <= button_sync[0];
            button_sync[2] <= button_sync[1];
        end
    end
    
    // Debouncing logic for each buttons
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 5; i = i + 1) begin
                debounce_counter[i] <= 0;
            end
            button_stable <= 5'b0;
        end else begin
            for (i = 0; i < 5; i = i + 1) begin
                if (button_sync[2][i] != button_stable[i]) begin
                    // When button state has been changed
                    if (debounce_counter[i] < DEBOUNCE_CYCLES) begin
                        debounce_counter[i] <= debounce_counter[i] + 1;
                    end else begin
                        button_stable[i] <= button_sync[2][i];
                        debounce_counter[i] <= 0;
                    end
                end else begin
                    // When button state is stable
                    debounce_counter[i] <= 0;
                end
            end
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            button_prev <= 5'b0;
            button_rising_edge <= 5'b0;
        end else begin
            button_prev <= button_stable;
            button_rising_edge <= button_stable & ~button_prev;
        end
    end
    
    // Main control Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            step_pulse_reg <= 1'b0;
            benchmark_start_reg <= 1'b0;
            pc_inst_trigger_reg <= 1'b0;
            reg_trigger_reg <= 1'b0;
            result_trigger_reg <= 1'b0;
        end else begin
            step_pulse_reg <= 1'b0;
            benchmark_start_reg <= 1'b0;
            pc_inst_trigger_reg <= 1'b0;
            reg_trigger_reg <= 1'b0;
            result_trigger_reg <= 1'b0;
            
            // Center button
            if (button_rising_edge[0]) begin
                    step_pulse_reg <= 1'b1;
            end
            
            // Up button
            if (button_rising_edge[1]) begin
                benchmark_start_reg <= 1'b1;
            end
            
            // Down button - UART Trigger
            if (button_rising_edge[2]) begin
                pc_inst_trigger_reg <= 1'b1;
            end
            
            // Left Button
            if (button_rising_edge[3]) begin
                reg_trigger_reg <= 1'b1;
            end
            
            // Right Button
            if (button_rising_edge[4]) begin
                result_trigger_reg <= 1'b1;
            end
        end
    end
    
    // output assign
    assign step_pulse = step_pulse_reg;
    assign benchmark_start = benchmark_start_reg;
    assign pc_inst_trigger = pc_inst_trigger_reg;
    assign reg_trigger = reg_trigger_reg;
    assign result_trigger = result_trigger_reg;

endmodule