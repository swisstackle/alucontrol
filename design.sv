/* ***************************************************************\
| Every module is in one file
| Name of program : datapathV2
| | Author: Alain Schaerer, Alexander Bohosian
| Date Created : 11/11/2021
| Date last updated : 11/11/2021
| Function : It calculates the ALU Control codes (3 bits)
| Method : The module takes in the address of the instruction in the memory file, fetches the address, splits the instruction, |calculates the ALUOps, and calculates the ALUControl bits.
| Additional Comments : N/A
\****************************************************************/

`timescale 10ns/100ps
module datapathV2(addr, ALUCtrl);
//Outputs for every part of the instruction
	input [5:0]addr;
	wire [31:0]instruction;
	wire [5:0]opcode;
  	wire [5:0] funcCode;
  	wire [4:0] rs;
 	wire [4:0] rt;
 	wire [4:0] rd;
 	wire [4:0] shamt;
wire [15:0] immediate; // for certain instruction types
 	wire [25:0] address;
	wire aluop0, aluop1;

	wire [1:0]ALUOp; //ALUOps for our alucontrol module
      output [2:0] ALUCtrl; //Alucontrol module output
	
	//fetching the address
	l8_stage1 fetchInstr(.a(addr), .rd(instruction)); //fetching the instruction from the memory file
	//splitting the address
	instSplit getOpcode(.ad(instruction), .opcode(opcode), .funcCode(funcCode), .rs(rs), .rt(rt), .rd(rd), .shamt(shamt), .immediate(immediate), .address(address)); //splitting the instruction into its pieces to get the opcode
	//get the ALUop's
l8_stage4 getAluop(.opcode(opcode), .aluop0(aluop0), .aluop1(aluop1)); //feeding the opcode to the aluop calculator 
	
//combine aluop's into our ALUOp vector
	  buf(ALUOp[0], aluop0);
        buf(ALUOp[1], aluop1);
	//Call our alucontrol module to get alucontrol codes
	alucontrol getALU(.ALUOp(ALUOp), .func(funcCode), .ALUCtrl(ALUCtrl));

endmodule

module alucontrol(ALUOp, func, ALUCtrl);
  input [1:0]ALUOp;
  input [5:0]func;
  output [2:0]ALUCtrl;
 
  reg [31:0]ALUCtrl0_in; 
  reg [31:0]ALUCtrl1_in;
  reg [31:0]ALUCtrl2_in;
  reg [4:0] in0;
  reg [4:0] in1;
  reg [4:0] in2;

  initial
    begin
      ALUCtrl0_in[7:0]=0;
ALUCtrl0_in[15:8]=0;
ALUCtrl0_in[16]=0;
ALUCtrl0_in[18]=0;
ALUCtrl0_in[20]=0;
ALUCtrl0_in[21]=1;
ALUCtrl0_in[24]=0;
ALUCtrl0_in[26]=0;
ALUCtrl0_in[28]=0;
ALUCtrl0_in[29]=1;

ALUCtrl1_in[7:0]=255; 
ALUCtrl1_in[15:8]=255; 
ALUCtrl1_in[16]=1; 
ALUCtrl1_in[18]=1; 
ALUCtrl1_in[20]=0; 
ALUCtrl1_in[21]=0; 
ALUCtrl1_in[24]=1; 
ALUCtrl1_in[26]=1; 
ALUCtrl1_in[28]=0; 
ALUCtrl1_in[29]=0;

ALUCtrl2_in[7:0]=0; 
ALUCtrl2_in[15:8]=255; 
ALUCtrl2_in[16]=0; 
ALUCtrl2_in[18]=1; 
ALUCtrl2_in[20]=0; 
ALUCtrl2_in[21]=0; 
ALUCtrl2_in[24]=0; 
ALUCtrl2_in[26]=1; 
ALUCtrl2_in[28]=0; 
ALUCtrl2_in[29]=0;
    end
 
	buf(in0[4], ALUOp[1]);
	buf(in0[3], ALUOp[0]);
	buf(in0[2], func[2]);
      buf(in0[1], func[1]);
      buf(in0[0], func[0]);

      buf(in1[4], ALUOp[1]);
	buf(in1[3], ALUOp[0]);
	buf(in1[2], func[2]);
      buf(in1[1], func[1]);
      buf(in1[0], func[0]);

      buf(in2[4], ALUOp[1]);
	buf(in2[3], ALUOp[0]);
	buf(in2[2], func[2]);
      buf(in2[1], func[1]);
      buf(in2[0], func[0]);
  //instantiate as appropriate
  
  mux32to1 ALUCtrl0(ALUCtrl0_in, in0, ALUCtrl[0]);
  mux32to1 ALUCtrl1(ALUCtrl1_in, in1, ALUCtrl[1]);
  mux32to1 ALUCtrl2(ALUCtrl2_in, in2, ALUCtrl[2]);

endmodule

module instSplit(ad, opcode, funcCode, rs, rt, rd, shamt, immediate, address);
//outputs for all the parts of the address
  input [31:0] ad;
  output [5:0] opcode;
  output [5:0] funcCode;
  output [4:0] rs;
  output [4:0] rt;
  output [4:0] rd;
  output [4:0] shamt;
  output [15:0] immediate;// for certain instruction types
  output [25:0] address;
 //using the buf gate, we assign the correct parts of the opcode to the correct outputs

// assigning the ocpde
  buf(opcode[5], ad[31]);
  buf(opcode[4], ad[30]);
  buf(opcode[3], ad[29]);
  buf(opcode[2], ad[28]);
  buf(opcode[1], ad[27]);
  buf(opcode[0], ad[26]);
 
//assigning the function code
  buf(funcCode[5], ad[5]);
  buf(funcCode[4], ad[4]);
  buf(funcCode[3], ad[3]);
  buf(funcCode[2], ad[2]);
  buf(funcCode[1], ad[1]);
  buf(funcCode[0], ad[0]);
 //assigning the rs
  buf(rs[4], ad[25]);
  buf(rs[3], ad[24]);
  buf(rs[2], ad[23]);
  buf(rs[1], ad[22]);
  buf(rs[0], ad[21]);
 //assigning the rt
  buf(rt[4], ad[20]);
  buf(rt[3], ad[19]);
  buf(rt[2], ad[18]);
  buf(rt[1], ad[17]);
  buf(rt[0], ad[16]);
 //assigining the rd register
  buf(rd[4], ad[15]);
  buf(rd[3], ad[14]);
  buf(rd[2], ad[13]);
  buf(rd[1], ad[12]);
  buf(rd[0], ad[11]);
 //Assigning the shift amount register
  buf(shamt[4], ad[10]);
  buf(shamt[3], ad[9]);
  buf(shamt[2], ad[8]);
  buf(shamt[1], ad[7]);
  buf(shamt[0], ad[6]);
 //assigning the immediate value
  buf(immediate[15], ad[15]);
  buf(immediate[14], ad[14]);
  buf(immediate[13], ad[13]);
  buf(immediate[12], ad[12]);
  buf(immediate[11], ad[11]);
  buf(immediate[10], ad[10]);
  buf(immediate[9], ad[9]);
  buf(immediate[8], ad[8]);
  buf(immediate[7], ad[7]);
  buf(immediate[6], ad[6]);
  buf(immediate[5], ad[5]);
  buf(immediate[4], ad[4]);
  buf(immediate[3], ad[3]);
  buf(immediate[2], ad[2]);
  buf(immediate[1], ad[1]);
  buf(immediate[0], ad[0]);
 //assigning the address for jump
  buf(address[25], ad[25]);
  buf(address[24], ad[24]);
  buf(address[23], ad[23]);
  buf(address[22], ad[22]);
  buf(address[21], ad[21]);
  buf(address[20], ad[20]);
  buf(address[19], ad[19]);
  buf(address[18], ad[18]);
  buf(address[17], ad[17]);
  buf(address[16], ad[16]);
  buf(address[15], ad[15]);
  buf(address[14], ad[14]);
  buf(address[13], ad[13]);
  buf(address[12], ad[12]);
  buf(address[11], ad[11]);
  buf(address[10], ad[10]);
  buf(address[9], ad[9]);
  buf(address[8], ad[8]);
  buf(address[7], ad[7]);
  buf(address[6], ad[6]);
  buf(address[5], ad[5]);
  buf(address[4], ad[4]);
  buf(address[3], ad[3]);
  buf(address[2], ad[2]);
  buf(address[1], ad[1]);
  buf(address[0], ad[0]);

endmodule

module l8_stage1( a, rd);

  input  [5:0]  a; //address for the register
  output [31:0] rd; //register being returned with value loaded
  reg [31:0] RAM[31:0]; //internal variable to store the data being read from the file

  initial
	begin
  	$readmemh("memfile.dat",RAM); // initialize memory
	end

  assign rd = RAM[a]; // word aligned
 
 
endmodule

module l8_stage4(opcode, aluop0, aluop1);
   input [5:0]opcode; //opcode input
  reg [3:0]m1;// O0, O2, O3 for the aluop1
  reg [3:0]m2; // O0, O2, O3 for the aluop0

  wire notM1_0; // O(0) which is being negated
  output aluop0;
  output aluop1;
//hardcoding of O's
initial begin
	m1[1] = 0; m1[2] = 0; m1[3] = 0;
	m2[0] = 0; m2[1] = 1; m2[2] = 0; m2[3] = 0;
end
   
  wire mux_1_1, mux_1_2, mux_2_1, mux_2_2;

//negating O0
  not(notM1_0, opcode[0]); //assuming opcode[0] is O0
//This uses the design from the lab8 instructions (using the m2to1 muxes)

  mux2to1 U_mux1_1 (notM1_0,m1[1],opcode[2],mux_1_1),
                 U_mux1_2 (m1[2],m1[3],opcode[2],mux_1_2),
                 U_mux1_3 (mux_1_1,mux_1_2,opcode[3],aluop1);

  mux2to1 U_mux2_1 (m2[0],m2[1],opcode[2],mux_2_1),
                 U_mux2_2 (m2[2],m2[3],opcode[2],mux_2_2),
                 U_mux2_3 (mux_2_1,mux_2_2,opcode[3],aluop0);
  
 endmodule

//mux code from Lab 6
module mux2to1(x,y,s,m);
  input x,y; //establishing x and y are representing the inputs to select from
  input s; //establishing s represents the input that is the selector for the mux
  output m; //establishing that the output of the mux will be connected to m
 
  wire s_not; //creating an internal connection element for the s_not signal
 
  not(s_not,s); //implementing the not gate that takes the input s and nots it
 
  wire p1, p2; //these are intermediates to represent the result of each and gate
  //the choice of p comes from the idea that and is a product operation, so these are product terms
 
  //implement the and gates in the diagram
  and(p1,x,s_not);
  and(p2,y,s);
 
  //produce the outcome m by implementing the or gate
  or(m, p1,p2);
 
endmodule

module mux4to1(inputs,sel,m);
  input [3:0]inputs; //inputs is a 4-bit vector which represents the inputs to the mux
  input [1:0]sel; //sel is a 2-bit vector which represents the selectors of the mux
  output m; //m is the output of the mux
  wire mux1_out, mux2_out; //These wire store the intermediate results of the the mux
  mux2to1 mux1(inputs[0], inputs[1], sel[0], mux1_out); //Part of First stage of the 4to1 mux
  mux2to1 mux2(inputs[2], inputs[3], sel[0], mux2_out); //Part of First stage of the 4to1 mux
  mux2to1 mux3(mux1_out, mux2_out, sel[1], m); //Second stage of the 4to1 mux, selects between the two
     											 //signals provided by the two muxes in the first stage
     											 //and sends it to the output.
endmodule

module mux8to1(inputs,sel,m);
  input [7:0]inputs; //inputs is a 8-bit vector which represents the inputs to the mux
  input [2:0]sel; //sel is a 3-bit vector which represents the selectors of the mux
  output m; //m is the output of the mux
  wire mux1_out, mux2_out; //These wire store the intermediate results of the the mux
  mux4to1 mux1(inputs[3:0], sel[1:0], mux1_out); //Part of First stage of the 8to1 mux
  mux4to1 mux2(inputs[7:4], sel[1:0], mux2_out); //Part of First stage of the 8to1 mux
  mux2to1 mux3(mux1_out, mux2_out, sel[2], m); //Second stage of the 8to1 mux, selects between the two
     											 //signals provided by the two muxes in the first stage
     											 //and sends it to the output.
 
endmodule

module mux16to1(inputs,sel,m);
  input [15:0]inputs; //inputs is a 16-bit vector which represents the inputs to the mux
  input [3:0]sel; //sel is a 4-bit vector which represents the selectors of the mux
  output m; //m is the output of the mux
  wire mux1_out, mux2_out; //These wire store the intermediate results of the the mux
  mux8to1 mux1(inputs[7:0], sel[2:0], mux1_out); //Part of First stage of the 8to1 mux
  mux8to1 mux2(inputs[15:8], sel[2:0], mux2_out); //Part of First stage of the 8to1 mux
  mux2to1 mux3(mux1_out, mux2_out, sel[3], m); //Second stage of the 16to1 mux, selects between the two
     											 //signals provided by the two muxes in the first stage
     											 //and sends it to the output.
endmodule

module mux32to1(inputs,sel,m);
  input [31:0]inputs; //inputs is a 32-bit vector which represents the inputs to the mux
  input [4:0]sel; //sel is a 5-bit vector which represents the selectors of the mux
  output m; //m is the output of the mux
  wire mux1_out, mux2_out; //These wire store the intermediate results of the the mux
  mux16to1 mux1(inputs[15:0], sel[3:0], mux1_out); //Part of First stage of the 8to1 mux
  mux16to1 mux2(inputs[31:16], sel[3:0], mux2_out); //Part of First stage of the 8to1 mux
  mux2to1 mux3(mux1_out, mux2_out, sel[4], m); //Second stage of the 32to1 mux, selects between the two
     											 //signals provided by the two muxes in the first stage
     											 //and sends it to the output.
endmodule
