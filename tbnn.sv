// A simple test bench for reading and processing files to the nn3
// design problem
//

//
`timescale 1ns/10ps
`include "nn3.v"
`include "DW02_mult_2_stage.v"


module top();

reg clk,rst;
reg sel,RW;
reg [12:0] addr;
reg [31:0] din,dout;
reg pushA,stopA;
reg [31:0] dataA;
reg lastA,firstA;
reg pushB,stopB;
reg [31:0] dataB;
reg firstB,lastB;
reg [12:0] mwadr,mr0,mr1;
reg mwrite;
reg [31:0] mwdata,mrdata0,mrdata1;
reg c_pushB,c_firstB,c_lastB;
reg [31:0] c_dataB;
reg junk;

reg [31:0] edata;

reg [31:0] expected[$];
reg expFirst[$];
reg expLast[$];
reg [31:0] mm[0:(1<<13)-1];
int ix;

task die(input string msg);
    $display("\n\n\n====================================");
    $display("Error --- Error --- Error --- Error");
    $display(msg);
    $display("at time %t",$realtime());
    $display("Error --- Error --- Error --- Error");
    $display("====================================\n\n\n");
    #5;
    $finish();
endtask : die

task chkx(reg [31:0] v,string msg);
    if ((^v) === 1'bX) begin
        die(msg);
    end
endtask : chkx

task chkh(reg [31:0] vo,vn,string msg);
    if (vo !== vn) begin
        die(msg);
    end
endtask : chkh


always @(posedge(clk)) begin
    chkx(pushB,"pushB is X");
    chkx(lastB,"lastB is X");
    chkx(firstB,"FirstB is X");
    chkx(dataB,"dataB contains an X");
    chkx(stopB,"stopB is X (TB  problem)");
    c_pushB=pushB;
    c_lastB=lastB;
    c_firstB=firstB;
    c_dataB=dataB;
    #0.1;
    chkh(c_pushB,pushB,"No hold time on pushB");
    chkh(c_firstB,firstB,"No hold time on firstB");
    chkh(c_lastB,lastB,"No hold time on lastB");
    chkh(c_dataB,dataB,"No hold time on dataB");
    if(pushB && ! stopB) begin
        if(expected.size()==0) begin
            die("You pushed on the B interface\n and I'm not expecting anything now");
        end
        if(c_dataB !== expected[$]) begin
            die($sformatf("Received data error exp %x got %x",expected[$],c_dataB));
        end
        junk = expected.pop_back();
        if(c_firstB !== expFirst[$]) begin
            die($sformatf("firstB exp %x got %x",expFirst[$],c_firstB));
        end
        junk = expFirst.pop_back();
        if(c_lastB !== expLast[$]) begin
            die($sformatf("lastB exp %x got %x",expLast[$],c_lastB));
        end
        junk = expLast.pop_back();

    end
end

initial begin
    for (ix=0; ix < (1<<13)-1; ix += 1) mm[ix]=32'h12345678;
    clk=0;
    repeat(2300000) begin
        #5 clk=0;
        #5 clk=1;
    end
    #5;
    $display("\n\n\nRan out of clocks\n\n\n");
    $finish;
end

always @(posedge(clk)) begin
    if (mwrite===1) begin
        mm[mwadr]=mwdata;
    end
end

always @(*) begin
    mrdata0=mm[mr0];
    mrdata1=mm[mr1];
end

always @(posedge(clk)) begin


end


initial begin
    rst=1;
    sel=0;
    RW=0;
    addr=0;
    stopB=0;
    repeat(3) @(posedge(clk)) #1;
    rst=0;
end

task wmem(input reg [12:0] adri, input reg [31:0] dat);
    RW=1;
    sel=1;
    addr = adri;
    din = dat;
    pushA=0;
    firstA=0;
    lastA=0;
    dataA=32'h01234567;
    @(posedge(clk)) #1;
    RW=0;
    addr=$urandom();
    din=$urandom();
    sel=0;
endtask : wmem

initial begin
    integer fi;
    string line;
    integer junk;
    reg [12:0] adr;
    reg [31:0] dat;
    reg efirst,elast;
    din=0;
    pushA=0;
    dataA=0;
    firstA=0;
    lastA=0;
    repeat(5) @(posedge(clk)) #1;
    fi=$fopen("nc0.txt","r");
    if(fi == 0) begin
        $display("Couldn't open the file");
        $finish;
    end
    junk=$fgets(line,fi);
    while(! $feof(fi)) begin
        case(line[0])
          "m": begin
            while(expected.size()>0) @(posedge(clk)) #1;
            junk=$sscanf(line,"%*s %x %x",adr,dat);
            wmem(adr,dat);
          end
          "i": begin
            while(expected.size()>0) @(posedge(clk)) #1;
            junk=$sscanf(line,"%*s %x %x %x",firstA,lastA,dataA);
            pushA=1;
            @(posedge(clk));
            while(stopA==1) @(posedge(clk));
            #1;
            pushA=0;
            dataA=$urandom();
          end
          "o": begin
            junk=$sscanf(line,"%*s %x %x %x",efirst,elast,edata);
            expFirst.push_front(efirst);
            expLast.push_front(elast);
            expected.push_front(edata);
          end
        endcase
        junk=$fgets(line,fi);
    end
    
    $fclose(fi);
    while(expected.size() > 0) begin
        @(posedge(clk)) #1;
    end
    $display("\n\n\nWith great respect, you have passed the test\n\n\n");
    $finish();
end



nn3 n(clk,rst,sel,RW,addr,din,dout,pushA,stopA,dataA,firstA,lastA,
        pushB,stopB,dataB,firstB,lastB,mwadr,mwrite,mr0,mr1,mwdata,
        mrdata0,mrdata1);

initial begin
    //#22000000;
    $dumpfile("nn3.vpd");
    $dumpvars;
    #100000;
    $dumpoff;
end

endmodule : top
