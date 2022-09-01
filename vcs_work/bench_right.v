
///////////////////////////////////////////////////////////////////
////                                                             ////
////  AES Test Bench                                             ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/aes_core/  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: test_bench_top.v,v 1.1.1.1 2005/08/03 14:59:38 kesava Exp $
//
//  $Date: 2005/08/03 14:59:38 $
//  $Revision: 1.1.1.1 $
//  $Author: kesava $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: test_bench_top.v,v $
//               Revision 1.1.1.1  2005/08/03 14:59:38  kesava
//               ssi3Aug05
//
//               Revision 1.2  2002/11/12 16:10:12  rudi
//
//               Improved test bench, added missing timescale file.
//
//               Revision 1.1.1.1  2002/11/09 11:22:56  rudi
//               Initial Checkin
//
//
//
//
//
//
`timescale 1ns/1ps
//`include "timescale.v"
//`delay_mode_path
module testbench;

  reg		clk;
  reg		rst;

  reg [383:0]   tv[512:0];	// Test vectors
  wire [383:0]  tmp;
  reg		kld;
  wire [127:0]  key, plain, ciph;
  wire [127:0]  text_in;
  wire [127:0]  text_out;
  reg [127:0]   text_exp;
  wire          done;
  integer       n, error_cnt;


  initial
    begin
      $display("\n\n");
      $display("*****************************************************");
      $display("* AES Test bench ...");
      $display("*****************************************************");
      $display("\n");
      
      // while(1)
      begin
	      kld = 0;
	      rst = 0;
	      error_cnt = 0;
	      repeat(4)	@(posedge clk);
	      rst = 1;
	      repeat(20)	@(posedge clk);

	      $display("");
	      $display("");
	      $display("Started random test ...");

        tv[0]= 384'h00000000000000000000000000000000f34481ec3cc627bacd5dc3fb08f273e60336763e966d92595a567cc9ce537f5e;

        // for(n=0;n<284;n=n+1)
        for(n=0;n<1;n=n+1)
        begin
	        @(posedge clk);
	        #1;
	        kld = 1;
	        @(posedge clk);
	        #1;
	        kld = 0;
	        @(posedge clk);
	        while(!done)	@(posedge clk);
	        // $display("INFO: (a) Vector %3d/284: xpected %x, Got %x %t", n, ciph, text_out, $time);
	        $display("INFO: (a) Vector %2d/28: xpected %x, Got %x %t", n, ciph, text_out, $time);
          // $display("ERROR: (a) Vector %0d mismatch. Expected %x, Got %x",n, ciph, text_out);
	        if(text_out != ciph)
	        begin
		        $display("ERROR: (a) Vector %0d mismatch. Expected %x, Got %x", n, ciph, text_out);
		        error_cnt = error_cnt + 1;
	        end
          // $fflush;
	        @(posedge clk);
	        #1;
        end // for (n=0;n<284;n=n+1)

	        $display("");
	        $display("");
	        $display("Test Done. Found %0d Errors.", error_cnt);
	        $display("");
	        $display("");
	        repeat(10)	@(posedge clk);
      end // while (1)
      
      	$finish;
    end // initial begin
  
  // while(1)
  // begin 
    assign tmp = tv[n];
    assign key     = tmp[383:256]; //kld ? tmp[383:256] : 128'hx;
    assign text_in = tmp[255:128]; //kld ? tmp[255:128] : 128'hx;
    assign plain   = tmp[255:128];
    assign ciph    = tmp[127:0];
  // end

  initial 
  begin
    clk <= 0;
    forever 
    begin
      // $display("CLK: %b", clk);
      #5; clk <= ~clk;
    end
  end

  aes_cipher_top	 u0
    (
     .clk(		clk		),
     .rst(		rst		),
     .ld(		kld		),
     .done(		done		),
     .key(		key		),
     .text_in(	text_in		),
     .text_out(	text_out	)
     );
  
  integer cycle = 0;
  always @(posedge clk) 
  begin
  	cycle = cycle + 1;
	// $display("CYCLE %d", cycle);
	  if (cycle == 10000) 
    begin
		  $display("Reached limit of 10000 cycles.");
		  $finish;
	  end
  end

  initial 
  begin
    // $sdf_annotate("aes_core.sdf",testbench.u0);
    $dumpfile("bench.vcd");
    $dumpvars(0, testbench);
    $read_lib_saif("Nangate_45_rechar_slow.saif");
  end
  
endmodule
// Local Variables:
// verilog-library-directories:("." "./gl")
// End:
