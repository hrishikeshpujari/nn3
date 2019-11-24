// EE287 Project : Design of a Neural Network Calculation Engine
// Designed by Hrishikesh Pujari
// EE SJSU Fall 2018 

module nn3(
  input clk, 
  input rst, 
  input sel,
  input RW, 
  input [12:0] addr, 
  input [31:0] din, 
  output [31:0] dout, 
  input pushA, 
  output stopA, 
  input [31:0] dataA, 
  input firstA, 
  input lastA, 
  output pushB, 
  input stopB, 
  output [31:0] dataB, 
  output firstB, 
  output lastB, 
  output [12:0] mwadr,
  output mwrite, 
  output [12:0] mr0, 
  output [12:0] mr1, 
  output [31:0] mwdata, 
  input [31:0] mrdata0, 
  input [31:0] mrdata1);

  reg [31:0] datain,datain_d,dataout,dataout_d;
  reg [12:0] address,address_d,op_offset,op_offset_d;
  reg [31:0] dataBout,dataBout_d;
  reg [31:0] control_word,control_word_d;
  reg firstBout,firstBout_d,lastBout,lastBout_d;
  reg firstAin,lastAin;
  reg [31:0] dataAin,dataAin_d,dataA01,dataA01_d;
  reg rw,memwrite,memwrite_d,neuron_last,neuron_last_d,generating_op,generating_op_d,inputs_processed,inputs_processed_d;
  reg [12:0] rport0,rport0_d,rport1,rport1_d;
  reg [12:0] memwriteaddr,memwriteaddr_d,firstAaddr,firstAaddr_d,firstBaddr,firstBaddr_d;
  reg [31:0] memwritedata,memwritedata_d;
  reg signed [31:0] mul01,mul01_d,mul02,mul02_d,mul04,mul05,mul06,mul07;
  reg signed [71:0] mul03_d, mul03;
  reg signed [63:0] multiply01,multiply01_d,product;
  reg signed [71:0] add,add_d;
  reg [5:0] state,nextstate;
  reg [63:0] hold,hold_d;
  reg [7:0] no_inputs,no_inputs_d;
  reg [5:0] no_outputs,no_outputs_d;
  reg [7:0] no_iterations;
  reg [7:0] no_iterations_d;
  reg [31:0] counter;
  reg [31:0] counter_d;
  reg [31:0] first_counter;
  reg [31:0] first_counter_d;
  reg [31:0] second_counter;
  reg [31:0] second_counter_d;
  reg [31:0] third_counter;
  reg [31:0] third_counter_d;
  reg [31:0] fourth_counter;
  reg [31:0] op_counter;
  reg [31:0] op_counter_d;
  reg [3:0] opcode,opcode_d;
  reg stopin,stopout,stopout_d;
  reg push00,pushout,pushout_d;
  reg [12:0] neuron_addr1;
  reg [12:0] neuron_addr2;
  reg [12:0] neuron_addr1_d;
  reg [12:0] neuron_addr2_d;

  assign stopA = stopout;
  assign pushB = pushout;
  assign lastB = lastBout; 
  assign firstB = firstBout;
  assign dataB = dataBout;
  assign dout = dataout;
  assign rw = RW;
  assign mr0 = rport0;
  assign mr1 = rport1;
  assign mwadr = memwriteaddr;
  assign mwdata = memwritedata;
  assign mwrite = memwrite;

  parameter ST_IDLE  = 6'h00;
  parameter ST_START = 6'h01;
  parameter ST_READ  = 6'h02;
  parameter ST_CALC  = 6'h03;
  parameter ST_WRITE = 6'h04;
  parameter ST_DONE  = 6'h05;
  parameter ST_OUTPUT  = 6'h06;
  parameter limit_0 = 0;
  parameter UPPER_LIMIT_1 = 32'h7fff_fff0;
  parameter LOWER_LIMIT_1 = -(32'h7fff_fff0);
  parameter UPPER_LIMIT_2 = 32'h0100_0000;
  parameter LOWER_LIMIT_2 = -(32'h0100_0000);

  DW02_mult_2_stage #(32,32)multiplier00( .A(mul01_d), .B(mul02_d), .TC(1'b1), .CLK(clk), .PRODUCT(product));

  always @ (*) begin
              
    counter_d = counter;
    second_counter_d = second_counter;
    no_iterations_d = no_iterations;
    first_counter_d = first_counter;
    rport0_d = rport0;
    rport1_d = rport1;
    //rport0 = rport0;
    //rport1 = rport1;
    neuron_addr1_d = neuron_addr1;
    neuron_addr2_d = neuron_addr2;
    dataout_d = dataout;
    nextstate = state;
    add_d = add;
    stopout_d = stopout;
    no_outputs_d = no_outputs;
    opcode_d = opcode;
    memwrite_d = memwrite;
    memwritedata_d = memwritedata;
    no_inputs_d = no_inputs;
    pushout_d = pushout;
    memwriteaddr_d = memwriteaddr;
    op_counter_d = op_counter;
    op_offset_d = op_offset;
    neuron_last_d = neuron_last;
    dataBout_d = dataBout;
    firstAaddr_d = firstAaddr;
    firstBaddr_d = firstBaddr;
    lastBout_d = lastBout;
    firstBout_d = firstBout;
    hold_d = hold;
    control_word_d = control_word;
    mul01_d = mul01;
    mul02_d = mul02;
    //firstBout_d = firstBout;
    case (state)
      ST_IDLE: //engine idle state 
        begin
	  inputs_processed_d = 0;
	  generating_op_d = 0;
          control_word_d = 0;
          firstBout_d = 0;
	  lastBout_d = 0;
          firstAaddr_d = 0;
          firstBaddr_d = 0;
          hold_d = 0;
          neuron_last_d = 0;
          op_offset_d = 0;
          dataBout_d = 0;
          pushout_d = 0;
          memwriteaddr_d = 0;
          memwritedata_d = 0;
          rport0_d = 0;
          rport1_d = 0;
          memwrite_d = 0;
          no_inputs_d = 0;
          no_outputs_d = 0;
          opcode_d = 0;
          mul01_d = 0;
          mul02_d = 0;
          mul03_d = 0;
	  add_d = 0;
	  multiply01_d = 0;
	  stopout_d = 0;
	  dataout_d = 0;
	  no_iterations_d = 0;
          neuron_addr1_d = 1;
          neuron_addr2_d = 2;
	  op_counter_d = 1;
	  //product = 0;
          nextstate = ST_START;
        end
      ST_START: //storing din and dataA back in memory and reading the first neuron word
        begin	
          if (!pushA) begin
            if(rw && sel) begin
              pushout_d = 0;
              memwrite_d = 1;
              memwriteaddr_d = addr;
              memwritedata_d = din;
              rport1_d = 13'b0;
              control_word_d = mrdata1;
              firstAaddr_d = control_word[31:19];
              firstBaddr_d = control_word[18:6];
              no_outputs_d = control_word[5:0];					
            end
          end 
          if(pushA) begin
            if(firstA) begin 
              memwriteaddr_d = firstAa  ddr;
              memwritedata_d = dataA;
              memwrite_d = 1;
            end
            if(!firstA) begin
              memwriteaddr_d = memwriteaddr + 1;
              memwritedata_d = dataA;
              memwrite_d = 1;
            end
          end
          if (!pushA & lastA)begin 
            if(first_counter == 1) begin
              nextstate = ST_CALC;
              first_counter_d = 0;
              hold_d[63:32] = mrdata1;
              hold_d[31:0]  = mrdata0;
              no_inputs_d = hold_d[46:39];
              op_offset_d = hold_d[12:0];
              opcode_d = hold_d[53:50];
              neuron_last_d = hold_d[49];
	      generating_op_d = hold_d[48];
	      inputs_processed_d = hold_d[47];
            end else begin 
              rport0_d = neuron_addr1;
              rport1_d = neuron_addr2;
	      first_counter_d = first_counter + 1;
            end
          end
        end  
      ST_CALC: //reading the data and weight from the address given in the neuron
        begin
            if(no_iterations < no_inputs + 2) begin
	     if(no_iterations == 0) begin
	       rport0_d = hold[25:13];
               rport1_d = hold[38:26];
             end else begin
	       rport0_d = rport0 + 1;
               rport1_d = rport1 + 1;
	     end
	     if(no_iterations != 0) begin
              mul01_d = mrdata0;
              mul02_d = mrdata1;
              //multiply01_d = mul01_d * mul02_d;
	      multiply01_d = product;
              add_d =  add_d + multiply01_d;
              no_iterations_d = no_iterations + 1;
             end else no_iterations_d = no_iterations + 1;
           /*if(no_iterations < no_inputs + 1) begin		
            if(first_counter == 1) begin
              mul01_d = mrdata0;
              mul02_d = mrdata1;
              multiply01_d = mul01_d * mul02_d;
              add_d =  add + multiply01_d;
              first_counter_d = 0;	       
              no_iterations_d = no_iterations + 1;
            end else begin
              if(third_counter == 1) begin
                rport0_d = hold[25:13];
                rport1_d = hold[38:26];
                third_counter_d = 0;
                first_counter_d = first_counter + 1;	
              end else begin
                rport0_d = rport0 + 1;
                rport1_d = rport1 + 1;
                first_counter_d = first_counter + 1;	
              end
           end*/
          end else begin
            //opcode state machine start
            mul03_d = add_d >>> 24;
            case(opcode)
              0: 
                begin
                  //mul03_d = add_d[31:0];
                    if (mul03_d < -(32'sh7fff_fff0)) begin
                    memwriteaddr_d = op_offset;
                    memwritedata_d = -32'h7fff_fff0;
                    memwrite_d = 1;
                  end else if (mul03_d > 32'sh7fff_fff0) begin
                    memwriteaddr_d = op_offset;
                    memwritedata_d = 32'h7fff_fff0;
                    memwrite_d = 1;
	          end else begin
                   memwriteaddr_d = op_offset;
                   memwritedata_d = mul03_d;
                   memwrite_d = 1;
		  end
		  if(neuron_last)begin 
		    if(op_counter == 1)rport0_d = firstBaddr;
	            nextstate = ST_OUTPUT;
	          end else nextstate = ST_DONE;
		  mul01_d = 0;
	          mul02_d = 0;
                  no_iterations_d = no_iterations + 1;
                end
              1:
                begin
                  if(mul03_d > 0) begin 
                    memwriteaddr_d = op_offset;
                    memwritedata_d = 32'h0100_0000;
                    memwrite_d = 1;
                  end else begin 
                    memwriteaddr_d = op_offset;
                    memwritedata_d = -32'h0100_0000;
                    memwrite_d = 1;
                  end
		  mul01_d = 0;
	          mul02_d = 0;
                  no_iterations_d = no_iterations + 1;
		  if(neuron_last)begin 
		    if(op_counter == 1)rport0_d = firstBaddr;
	            nextstate = ST_OUTPUT;
	          end else nextstate = ST_DONE;
                end
              2:
                begin
                  add_d = add_d >>> 24;
                  if (add_d < -(32'sh0100_0000)) begin 
                    memwriteaddr_d = op_offset;
                    memwritedata_d = -32'h0100_0000;
                    memwrite_d = 1;
                  end else if (add_d > 32'sh0100_0000) begin 
                    memwriteaddr_d = op_offset;
                    memwritedata_d = 32'h0100_0000;
                    memwrite_d = 1;
	          end else begin 
                   memwriteaddr_d = op_offset;
                   memwritedata_d = add_d;
                   memwrite_d = 1;
		  end
		  mul01_d = 0;
	          mul02_d = 0;
                  no_iterations_d = no_iterations + 1;
		  if(neuron_last)begin 
		    if(op_counter == 1)rport0_d = firstBaddr;
	            nextstate = ST_OUTPUT;
	          end else nextstate = ST_DONE;
                end 
            endcase
            //opcode end
          end
        end
      ST_DONE:
        begin
          no_iterations_d = 0;
          if(second_counter <= 2 && second_counter > 0) begin
            hold_d[63:32] = mrdata1;
            hold_d[31:0]  = mrdata0;
            no_inputs_d = hold_d[46:39];
            op_offset_d = hold_d[12:0];
            opcode_d = hold_d[53:50];
            neuron_last_d = hold_d[49];
            pushout_d = 0;
            if(counter == 1) begin  
	      nextstate = ST_CALC;
              second_counter_d = 0;
              third_counter_d = 1; 
              counter_d = 0;
              multiply01_d = 0;
              add_d = 0;
            end else counter_d = counter + 1; 
          end 
         else begin 
            neuron_addr1_d = neuron_addr1 + 2;
            neuron_addr2_d = neuron_addr2 + 2;
            rport0_d = neuron_addr1_d;
            rport1_d = neuron_addr2_d;
            second_counter_d = second_counter + 1;
          end
        end
      ST_OUTPUT: 
        begin
          if(op_counter <= no_outputs) begin
            stopout_d = 1;
            if(op_counter == 1) begin
              pushout_d = 1;
              dataBout_d = mrdata0;
              firstBout_d = 1;
              op_counter_d = op_counter + 1;
	      rport0_d = rport0 + 1;
              //nextstate = ST_CALC;
            end else begin
              //nextstate = ST_CALC;
	      firstBout_d = 0;
	      if(op_counter != no_outputs)rport0_d = rport0 + 1;
              dataBout_d = mrdata0;
              op_counter_d = op_counter + 1;
            end
           end else begin
	     dataBout_d = 0;
	     pushout_d = 0;
	     stopout_d = 0;
             second_counter_d = 0;
             third_counter_d = 1; 
             counter_d = 0;
             multiply01_d = 0;
             add_d = 0;
	     neuron_addr1_d = 1;
	     neuron_addr2_d = 2;
             no_iterations_d = 0;
	     op_counter_d = 1;
	     nextstate = ST_START;
           end
	  if(op_counter == no_outputs) lastBout_d = 1;
	  else begin 
	    lastBout_d = 0;
          end
        end
    endcase
  end

  always @(*) begin
    datain_d = din;
    firstAin = firstA;
    lastAin = lastA;
    dataAin_d = dataA;
    if(!pushA)address_d = addr;
  end

  always @(posedge (clk) or posedge (rst)) begin
    if(rst) begin
      state            <= ST_IDLE;
      pushout	       <= 0;
      stopout          <= 0;
      lastBout         <= 0;
      firstBout        <= 0;
      dataBout         <= 0;
      dataAin          <= 0;
      datain           <= 0;
      dataA01          <= 0;
      address          <= 0;
      mul01            <= 0;
      mul02            <= 0;
      mul03            <= 0;
      mul04            <= 0;
      mul05            <= 0;
      mul06            <= 0;
      mul07            <= 0;
      //multiply01       <= 0;
      add              <= 0;
      memwrite         <= 0; 
      memwriteaddr     <= 0; 
      memwritedata     <= 0; 
      firstAaddr       <= 0; 
      firstBaddr       <= 0; 
      no_outputs       <= 0; 
      no_inputs        <= 0; 
      op_offset        <= 0; 
      opcode           <= 0; 
      neuron_last      <= 0;
      hold 	       <= 0;
      no_iterations    <= 0;
      first_counter    <= 0;
      third_counter    <= 0;
      rport0           <= 0;	
      rport1           <= 0;
      second_counter   <= 0;	
      neuron_addr1     <= 0;
      neuron_addr2     <= 0;
      counter          <= 0;
      control_word     <= 0;
      op_counter       <= 0;
      inputs_processed <= 0;
      generating_op    <= 0;
      dataout          <= 0;
    end else begin
      datain           <= #1 datain_d;
      dataAin          <= #1 dataAin_d;
      stopout          <= #1 stopout_d;
      dataA01          <= #1 dataA01_d;
      state            <= #1 nextstate;
      address          <= #1 address_d;
      firstAaddr       <= #1 firstAaddr_d;
      firstBaddr       <= #1 firstBaddr_d;
      dataBout         <= #1 dataBout_d ;
      mul01            <= #1 mul01_d;
      mul02            <= #1 mul02_d;
      mul03            <= #1 mul03_d;
      //multiply01       <= #1 multiply01_d;
      add 	       <= #1 add_d;
      pushout          <= #1 pushout_d;
      memwrite         <= #1 memwrite_d;
      memwriteaddr     <= #1 memwriteaddr_d;
      memwritedata     <= #1 memwritedata_d;
      no_outputs       <= #1 no_outputs_d;
      no_inputs        <= #1 no_inputs_d;
      op_offset        <= #1 op_offset_d;
      opcode           <= #1 opcode_d;
      neuron_last      <= #1 neuron_last_d;
      hold 	       <= #1 hold_d;
      no_iterations    <= #1 no_iterations_d;
      first_counter    <= #1 first_counter_d;	
      third_counter    <= #1 third_counter_d;	
      rport0           <= #1 rport0_d;	
      rport1           <= #1 rport1_d;	
      second_counter   <= #1 second_counter_d;	
      neuron_addr1     <= #1 neuron_addr1_d;
      neuron_addr2     <= #1 neuron_addr2_d;
      counter          <= #1 counter_d;
      firstBout        <= #1 firstBout_d;
      control_word     <= #1 control_word_d;
      op_counter       <= #1 op_counter_d;
      lastBout         <= #1 lastBout_d;
      inputs_processed <= #1 inputs_processed_d;
      generating_op    <= #1 generating_op_d;
      dataout          <= #1 dataout_d;
    end
  end
endmodule
