`timescale 1ns/1ps

`include "design.v"

module test;
    localparam CLK_PERIOD_NS = 10; // 100 MHz
    localparam WIDTH = 16;

    reg clk = 1;
    reg rst = 0;
    reg [WIDTH-1:0] period = 16'd10; // 10 MHz PWM at 100 MHz clk
	reg [6:0] duty = 'd50; // 50% duty
    reg [WIDTH-1:0] duty_on;

    wire pwm_out;

    pwm_signal_generator #
	(
		.WIDTH(WIDTH)
	) dut (
        .clk(clk),
        .rst(rst),
        .period(period),
        .duty_on(duty_on),
        .pwm_out(pwm_out)
    );

    always #(CLK_PERIOD_NS/2) clk = ~clk;

    initial begin		
	    $dumpfile("temp.vcd");
	    $dumpvars(0, test);
		
        rst = 0;
        #(5*CLK_PERIOD_NS);
        rst = 1;
		
		// normal test cases
        repeat (1) begin
            duty = 10; duty_on = (period * duty) / 100; #(period * CLK_PERIOD_NS);
            duty = 30; duty_on = (period * duty) / 100; #(period * CLK_PERIOD_NS);
            duty = 50; duty_on = (period * duty) / 100; #(period * CLK_PERIOD_NS);
            duty = 70; duty_on = (period * duty) / 100; #(period * CLK_PERIOD_NS);
            duty = 90; duty_on = (period * duty) / 100; #(period * CLK_PERIOD_NS);
        end
		
		// edge test cases
        duty_on = 0;                      				#(period * CLK_PERIOD_NS);
        duty_on = period;                 				#(period * CLK_PERIOD_NS);
        duty_on = period + 8'd100;        				#(period * CLK_PERIOD_NS); // saturated to period

        $finish;
    end
endmodule