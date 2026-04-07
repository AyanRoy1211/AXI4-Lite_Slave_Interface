module axi4_lite_slave #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 4 // 16 bytes, 4 words
)(
    input wire clk,
    input wire resetn, // Active low reset

    // Write Address Channel (AW)
    input wire [ADDR_WIDTH-1:0] awaddr,
    input wire awvalid,
    output reg awready,

    // Write Data Channel (W)
    input wire [DATA_WIDTH-1:0] wdata,
    input wire wvalid,
    output reg wready,

    // Write Response Channel (B)
    output reg [1:0] bresp,
    output reg bvalid,
    input wire bready,

    // Read Address Channel (AR)
    input wire [ADDR_WIDTH-1:0] araddr,
    input wire arvalid,
    output reg arready,

    // Read Data Channel (R)
    output reg [DATA_WIDTH-1:0] rdata,
    output reg [1:0] rresp,
    output reg rvalid,
    input wire rready
);

    // Internal Memory (4 words of 32 bits)
    reg [DATA_WIDTH-1:0] mem [0:3];
    reg [ADDR_WIDTH-1:0] write_addr;
    reg [ADDR_WIDTH-1:0] read_addr;

    // FSM States for Write
    typedef enum logic [1:0] {W_IDLE, W_WAIT_DATA, W_RESP} w_state_t;
    w_state_t w_state;

    // --- WRITE LOGIC (AW, W, B Channels) ---
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            w_state <= W_IDLE;
            awready <= 0;
            wready <= 0;
            bvalid <= 0;
            bresp <= 2'b00; // OKAY response
        end else begin
            case (w_state)
                W_IDLE: begin
                    bvalid <= 0;
                    if (awvalid) begin
                        awready <= 1;
                        write_addr <= awaddr;
                        w_state <= W_WAIT_DATA;
                    end
                end
                W_WAIT_DATA: begin
                    awready <= 0;
                    wready <= 1; // Ready to accept data
                    if (wvalid && wready) begin
                        mem[write_addr[3:2]] <= wdata; // Word aligned write
                        wready <= 0;
                        w_state <= W_RESP;
                    end
                end
                W_RESP: begin
                    bvalid <= 1;
                    if (bvalid && bready) begin
                        bvalid <= 0;
                        w_state <= W_IDLE;
                    end
                end
            endcase
        end
    end

    // --- READ LOGIC (AR, R Channels) ---
    // (Simplified state machine for reading)
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            arready <= 0;
            rvalid <= 0;
            rresp <= 2'b00;
        end else begin
            if (arvalid && !arready) begin
                arready <= 1;        // Acknowledge address
                read_addr <= araddr;
            end else if (arready) begin
                arready <= 0;
                rvalid <= 1;         // Data is valid next cycle
                rdata <= mem[read_addr[3:2]]; 
            end

            if (rvalid && rready) begin
                rvalid <= 0;         // Transaction complete
            end
        end
    end

endmodule
