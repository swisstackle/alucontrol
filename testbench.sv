/* ***************************************************************\
| Name of program : datapathV2
| Author: Alain Schaerer, Alexander Bohosian
| Date Created : 11/11/2021
| Date last updated : 11/11/2021
| Function : It tests the DatapathV2 module
| Method : It iterates through every instruction in the memory file and gives it to the datapathV2 module. Then it outputs all |the outputs from the datapathV2
| Additional Comments : N/A
\****************************************************************/

`timescale 10ns/100ps

module l8_stage5_tb;
   //set up the variables that will be used to connect into the module being tested
  //it is a reg type so it updates only when told to
  reg [5:0]addr;
   
  //the result of the module being tested connects to a wire, so it can update as it needs to
  wire [2:0]ALUCtrl;
 
 
  initial //give initial value for what input to test first
	begin
  	addr=6'b00;   
	end
 
//Calling our datapath
  datapathV2 dut(.addr(addr), .ALUCtrl(ALUCtrl));
      	 
  always
	begin
  	#1 addr=addr+1; //cycle through all the addresses
	end
 
  initial //waveform generation code
	begin
  	$dumpfile("l9stage2.vcd");
  	$dumpvars;
	end
 
  initial
  begin //create the instructions for the simulator to output observations to the log
	$display("Mem Address:\tALUCtrl:");
	$monitor("%d\t\t\t\t%b",addr, ALUCtrl);
  end
 
  initial #31 $finish; //how many time units to run
      	 
 
endmodule

