module pwm_signal_generator #
(
    parameter integer WIDTH = 16
)
(
    input  wire                 clk,
    input  wire                 rst,
    input  wire [WIDTH-1:0]     period,
    input  wire [WIDTH-1:0]     duty_on,
    output reg                  pwm_out
);
    reg [WIDTH-1:0] counter;
    wire [WIDTH-1:0] duty_sat = (duty_on > period) ? period : duty_on;

    always @(posedge clk) begin
        if (!rst) begin
            counter <= {WIDTH{1'b0}};
            pwm_out <= 1'b0;
        end else begin
            if (counter >= (period - 1)) begin
                counter <= {WIDTH{1'b0}};
            end else begin
                counter <= counter + 1'b1;
            end
            pwm_out <= (counter < duty_sat);
        end
    end
endmodule