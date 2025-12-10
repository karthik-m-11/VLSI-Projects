`timescale 1ns/1ps

`include "design.v"

module test;

    reg clk;
    reg rst;
    reg start_stop;
    reg reset_btn;
    wire [7:0] seconds;

	stopwatch dut (
        .clk(clk),
        .rst(rst),
        .start_stop(start_stop),
        .reset_btn(reset_btn),
        .seconds(seconds)
    );

    // Clock generation (10 Hz -> 0.1 s period)
    always #10 clk = ~clk;

    initial begin
        clk = 1;
        rst = 1;
        start_stop = 0;
        reset_btn = 0;

        #50 rst = 0;

        #100 start_stop = 1; #20 start_stop = 0;
        #2000; 

        #20 start_stop = 1; #20 start_stop = 0;
        #1000;

        #20 start_stop = 1; #20 start_stop = 0;
        #1500;

        #20 reset_btn = 1; #20 reset_btn = 0;

        #100 $finish;
    end

    initial begin
        $dumpfile("temp.vcd");
	$dumpvars(0, test);
    end
endmodule