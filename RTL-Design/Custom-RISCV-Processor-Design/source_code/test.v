`timescale 1ns/1ps

`include "design.v"

module test;
    reg clk;
    reg rst;

    riscv dut (
        .clk(clk),
        .rst(rst)
    );

    always #5 clk = ~clk;

    initial begin
		$dumpfile("temp.vcd");
		$dumpvars(0, test);
		
        clk = 0;
        rst = 1;

        #20 rst = 0;

        // Load instructions into instruction memory
		dut.instr_mem[0] = 32'h00500093; // ADDI x1, x0, 5
		dut.instr_mem[1] = 32'h00A00113; // ADDI x2, x0, 10
		dut.instr_mem[2] = 32'h002081B3; // ADD  x3, x1, x2
		dut.instr_mem[3] = 32'h40110233; // SUB  x4, x2, x1
		dut.instr_mem[4] = 32'h0020E2B3; // OR   x5, x1, x2
		dut.instr_mem[5] = 32'h0020F3B3; // AND  x6, x1, x2
        
        #200;

        $display("x1 = %d", dut.regfile[1]);
        $display("x2 = %d", dut.regfile[2]);
        $display("x3 = %d", dut.regfile[3]);
        $display("x4 = %d", dut.regfile[4]);
        $display("x5 = %d", dut.regfile[5]);
        $display("x6 = %d", dut.regfile[6]);

        $finish;
    end
endmodule