module stopwatch (
    input wire clk,
    input wire rst,
    input wire start_stop,
    input wire reset_btn,
    output reg [7:0] seconds 
);
	parameter IDLE  = 2'b00;
    parameter RUN   = 2'b01;
    parameter STOP  = 2'b10;
    parameter RESET = 2'b11;

    reg [1:0] current_state, next_state;

    // Clock divider for 1 Hz tick (assuming 10 Hz input clock)
    reg [25:0] clk_div;
    wire one_sec_pulse;

    always @(posedge clk or posedge rst) begin
        if (rst)
            clk_div <= 0;
        else if (clk_div == 10 - 1) 
            clk_div <= 0;
        else
            clk_div <= clk_div + 1;
    end

    assign one_sec_pulse = (clk_div == 10 - 1);

    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    always @(*) begin
        case (current_state)
            IDLE:  if (start_stop) next_state = RUN;
                   else next_state = IDLE;

            RUN:   if (start_stop) next_state = STOP;
                   else if (reset_btn) next_state = RESET;
                   else next_state = RUN;

            STOP:  if (start_stop) next_state = RUN;
                   else if (reset_btn) next_state = RESET;
                   else next_state = STOP;

            RESET: next_state = IDLE;

            default: next_state = IDLE;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst)
            seconds <= 0;
        else begin
            case (current_state)
                IDLE:   seconds <= seconds;
                RUN:    if (one_sec_pulse) seconds <= seconds + 1;
                STOP:   seconds <= seconds;
                RESET:  seconds <= 0;
            endcase
        end
    end
endmodule