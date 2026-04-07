module tb_axi4_lite_slave;

    // Parameters
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 4;

    // Signals
    reg clk;
    reg resetn;

    // AW Channel
    reg [ADDR_WIDTH-1:0] awaddr;
    reg awvalid;
    wire awready;

    // W Channel
    reg [DATA_WIDTH-1:0] wdata;
    reg wvalid;
    wire wready;

    // B Channel
    wire [1:0] bresp;
    wire bvalid;
    reg bready;

    // AR Channel
    reg [ADDR_WIDTH-1:0] araddr;
    reg arvalid;
    wire arready;

    // R Channel
    wire [DATA_WIDTH-1:0] rdata;
    wire [1:0] rresp;
    wire rvalid;
    reg rready;

    // Instantiate Design Under Test (DUT)
    axi4_lite_slave #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .clk(clk), .resetn(resetn),
        .awaddr(awaddr), .awvalid(awvalid), .awready(awready),
        .wdata(wdata), .wvalid(wvalid), .wready(wready),
        .bresp(bresp), .bvalid(bvalid), .bready(bready),
        .araddr(araddr), .arvalid(arvalid), .arready(arready),
        .rdata(rdata), .rresp(rresp), .rvalid(rvalid), .rready(rready)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period
    end

    // VCD Dump for EPWave
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_axi4_lite_slave);
    end

    // Test Sequence
    initial begin
        // Initialize Signals
        resetn = 0;
        awvalid = 0; wvalid = 0; bready = 0;
        arvalid = 0; rready = 0;

        // Reset system
        #15 resetn = 1;
        #10;

        // --- 1. WRITE TRANSACTION ---
        $display("Starting Write Transaction to Address 0x4 with Data 0xDEADBEEF");
        
        // Master drives Address
        @(posedge clk);
        awaddr = 4'h4;
        awvalid = 1;
        
        // Wait for Slave to accept Address
        wait(awready);
        @(posedge clk);
        awvalid = 0;

        // Master drives Data
        wdata = 32'hDEADBEEF;
        wvalid = 1;
        
        // Wait for Slave to accept Data
        wait(wready);
        @(posedge clk);
        wvalid = 0;

        // Master waits for Response
        bready = 1;
        wait(bvalid);
        @(posedge clk);
        bready = 0;
        
        #20;

        // --- 2. READ TRANSACTION ---
        $display("Starting Read Transaction from Address 0x4");

        // Master drives Read Address
        @(posedge clk);
        araddr = 4'h4;
        arvalid = 1;

        // Wait for Slave to accept Read Address
        wait(arready);
        @(posedge clk);
        arvalid = 0;

        // Master waits for Read Data
        rready = 1;
        wait(rvalid);
        @(posedge clk);
        if (rdata == 32'hDEADBEEF)
            $display("SUCCESS: Read Data Matched! Data: %h", rdata);
        else
            $display("ERROR: Read Data Mismatch! Data: %h", rdata);
        
        rready = 0;

        #50;
        $finish;
    end
endmodule