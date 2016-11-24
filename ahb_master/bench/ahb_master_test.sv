module ahb_master_test;

parameter BUS_WDT = 32;

// =====================================
// AHB signals. 
// =====================================
bit                       i_hclk;
bit                       i_hreset_n;

bit                       i_hready;
bit                       i_hgrant;
bit    [BUS_WDT-1:0]      i_hrdata;
bit    [1:0]              i_hresp;

logic   [BUS_WDT-1:0]      o_hwdata;
logic   [31:0]             o_haddr;
logic   [1:0]              o_htrans;
logic   [1:0]              o_hburst;
logic   [1:0]              o_hsize;
logic   [3:0]              o_hprot;
logic                      o_hwrite;
logic                      o_hlock;
logic                      o_hbusreq;

// =====================================
// UI
// =====================================
logic  [BUS_WDT-1:0]      i_xfer_wdata;
bit    [31:0]             i_xfer_addr;
bit    [1:0]              i_xfer_size;
bit                       i_xfer_dav;
bit                       i_xfer_trig;
bit                       i_xfer_en;
bit                       i_xfer_write;
bit    [3:0]              i_xfer_prot;
bit                       i_xfer_lock;
bit                       i_xfer_full;

logic                      o_xfer_adv;   // Advance UI Combo.        
logic   [BUS_WDT-1:0]      o_xfer_rdata;
logic                      o_xfer_rdav;
logic                      o_xfer_ok_to_shutdown;

ahb_master #(.BUS_WDT(BUS_WDT)) u_ahb_master (.*);

always #10 i_hclk++;

initial
begin
        $dumpfile("ahb_master.vcd");
        $dumpvars;

       @(posedge i_hclk);
        i_hreset_n <= 1'd0; 

        @(posedge i_hclk);
        i_xfer_en <= 1'd1;

        repeat(50)
        @(posedge i_hclk);

        @(posedge i_hclk);
        i_hgrant <= 1'd1;
        i_hreset_n <= 1'd1;

        @(posedge i_hclk);
        i_xfer_en    <= 1'd1;
        i_xfer_trig  <= 1'd1;
        i_xfer_write <= 1'd1;
        i_xfer_wdata <= $random;
        i_xfer_addr  <= 32'h2000_0000;
        i_xfer_dav   <= 1'd1;
        i_hready     <= 1'd1;

        @(posedge i_hclk);
        i_xfer_wdata <= $random;
        i_xfer_trig  <= 1'd0;

        @(posedge i_hclk);
        i_hready     <= 1'd1;
        i_xfer_wdata <= $random;

        @(posedge i_hclk);
        i_hresp      <= 2'd3;
        i_hready     <= 1'd0;
        i_xfer_wdata <= $random;

        @(posedge i_hclk);
        i_hresp      <= 2'd3;
        i_hready     <= 1'd0;

        @(posedge i_hclk);
        i_hresp      <= 2'd3;
        i_hready     <= 1'd1;

        @(posedge i_hclk);
        i_hresp      <= 2'd0;
        i_hready     <= 1'd1;

        @(posedge i_hclk);

        @(posedge i_hclk);
        i_xfer_wdata  <= $random;
        i_xfer_dav   <= 1'd1;

        fork
        
                repeat(10) 
                begin
                        @(posedge i_hclk);
                        i_xfer_trig <= 1'd1;
                        i_xfer_dav  <= 1'd0;
                end

                begin
                        repeat(3) @(posedge i_hclk);
                        i_xfer_en <= 1'd0;
                end
        join

        $finish;
end

task delay (int x);
        repeat(x) @(posedge i_hclk);
endtask

endmodule
