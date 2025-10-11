module ButtonController (
    input clk,
    input reset,
    input btn_center,
    input btn_up,
    input btn_down,
    input btn_left,
    input btn_right,
    
    output step_pulse,
    output continuous_mode,
    output alu_trigger, 
    output pc_inst_trigger,
    output reg_trigger
);

    localparam DEBOUNCE_CYCLES = 20'd500000;
    
    reg [19:0] debounce_counter [0:4];
    reg [4:0] button_sync [0:2];
    reg [4:0] button_stable;
    reg [4:0] button_prev;
    reg [4:0] button_rising_edge;
    reg step_pulse_reg;
    reg continuous_mode_reg;
    reg reg_trigger_reg;
    reg pc_inst_trigger_reg;
    reg alu_trigger_reg;
    reg [25:0] continuous_counter;
    reg continuous_pulse;
    integer i;
    wire [4:0] button_inputs = {btn_right, btn_left, btn_down, btn_up, btn_center};
    
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
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 5; i = i + 1) begin
                debounce_counter[i] <= 0;
            end
            button_stable <= 5'b0;
        end else begin
            for (i = 0; i < 5; i = i + 1) begin
                if (button_sync[2][i] != button_stable[i]) begin
                    if (debounce_counter[i] < DEBOUNCE_CYCLES) begin
                        debounce_counter[i] <= debounce_counter[i] + 1;
                    end else begin
                        button_stable[i] <= button_sync[2][i];
                        debounce_counter[i] <= 0;
                    end
                end else begin
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
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            continuous_counter <= 0;
            continuous_pulse <= 1'b0;
        end else begin
            if (continuous_counter >= 26'd33500000) begin
                continuous_counter <= 0;
                continuous_pulse <= 1'b1;
            end else begin
                continuous_counter <= continuous_counter + 1;
                continuous_pulse <= 1'b0;
            end
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            step_pulse_reg <= 1'b0;
            continuous_mode_reg <= 1'b0;
            pc_inst_trigger_reg <= 1'b0;
            reg_trigger_reg <= 1'b0;
            alu_trigger_reg <= 1'b0;
        end else begin
            step_pulse_reg <= 1'b0;          
            if (button_rising_edge[0]) begin
                if (!continuous_mode_reg) begin
                    step_pulse_reg <= 1'b1;
                end
            end
            if (button_rising_edge[1]) begin
                continuous_mode_reg <= ~continuous_mode_reg;
            end
            if (button_rising_edge[2]) begin
                pc_inst_trigger_reg <= 1'b1;
            end else begin
                pc_inst_trigger_reg <= 1'b0;
            end
            if (button_rising_edge[3]) begin
                reg_trigger_reg <= 1'b1;
            end else begin
                reg_trigger_reg <= 1'b0;
            end
            if (button_rising_edge[4]) begin
                alu_trigger_reg <= 1'b1;
            end else begin
                alu_trigger_reg <= 1'b0;
            end
            if (continuous_mode_reg && continuous_pulse) begin
                step_pulse_reg <= 1'b1;
            end
        end
    end
    
    assign step_pulse = step_pulse_reg;
    assign continuous_mode = continuous_mode_reg;
    assign pc_inst_trigger = pc_inst_trigger_reg;
    assign reg_trigger = reg_trigger_reg;
    assign alu_trigger = alu_trigger_reg;

endmodule