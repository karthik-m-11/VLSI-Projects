module riscv (
    input  wire clk,
    input  wire rst
);
    // Program Counter
    reg [31:0] pc;
    wire [31:0] next_pc;

    // Instruction Memory (simple ROM)
    reg [31:0] instr_mem [0:255];
    wire [31:0] instr = instr_mem[pc[9:2]]; // word aligned

    // Decode fields
    wire [6:0] opcode = instr[6:0];
    wire [4:0] rd     = instr[11:7];
    wire [2:0] funct3 = instr[14:12];
    wire [4:0] rs1    = instr[19:15];
    wire [4:0] rs2    = instr[24:20];
    wire [6:0] funct7 = instr[31:25];

    // Register File
    reg [31:0] regfile [0:31];

	// Read ports
	wire [31:0] reg_rs1 = (rs1 == 5'd0) ? 32'd0 : regfile[rs1];
	wire [31:0] reg_rs2 = (rs2 == 5'd0) ? 32'd0 : regfile[rs2];

    // Immediate generator (I-type)
    wire [31:0] imm_i = {{20{instr[31]}}, instr[31:20]};

    // ALU
    reg [31:0] alu_result;
    always @(*) begin
        case (opcode)
            7'b0110011: begin // R-type
                case (funct3)
                    3'b000: alu_result = (funct7 == 7'b0100000) ? reg_rs1 - reg_rs2 : reg_rs1 + reg_rs2; // ADD/SUB
                    3'b111: alu_result = reg_rs1 & reg_rs2; // AND
                    3'b110: alu_result = reg_rs1 | reg_rs2; // OR
                    default: alu_result = 0;
                endcase
            end
            7'b0010011: begin // I-type (ADDI)
                alu_result = reg_rs1 + imm_i;
            end
            default: alu_result = 0;
        endcase
    end

    // Write Back
	integer i;
	always @(posedge clk) begin
    	if (rst) begin
    	    pc <= 32'd0;
    	    for (i = 0; i < 32; i = i + 1) regfile[i] <= 32'd0;
    	end else begin
        	pc <= next_pc;
        	if (rd != 5'd0) regfile[rd] <= alu_result; // write result
    	end
	end

    // Next PC
    assign next_pc = pc + 4;
endmodule