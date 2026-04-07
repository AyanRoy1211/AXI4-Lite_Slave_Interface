# AXI4-Lite Slave Interface RTL Design

## 📌 Project Overview
This repository contains a synthesizable **AXI4-Lite Slave IP** core implemented in Verilog. AXI4-Lite is a subset of the AMBA AXI4 protocol, designed for simple, low-throughput memory-mapped register access. 

This project is specifically designed to demonstrate proficiency in:
* **Industry Standard Protocols:** Understanding the 5-channel AXI architecture.
* **Handshake Logic:** Implementing `VALID` and `READY` synchronization.
* **FSM Design:** Managing complex state transitions for read/write transactions.
* **Hardware-Software Interfacing:** Mapping CPU instructions to hardware register control.

## Architecture
The AXI4-Lite Slave manages data transfer through five independent channels:
1. **Write Address Channel (AW):** Receives the address for write operations.
2. **Write Data Channel (W):** Receives the data to be stored.
3. **Write Response Channel (B):** Sends status feedback to the Master.
4. **Read Address Channel (AR):** Receives the address for read operations.
5. **Read Data Channel (R):** Sends the requested data back to the Master.



## Key Features
* **Full Compliance:** Adheres to the AMBA AXI4-Lite specification.
* **Register Map:** Includes 4 internal 32-bit registers (expandable) for hardware control.
* **Moore FSM:** Uses a robust Finite State Machine to handle the `READY/VALID` handshake, preventing deadlocks.
* **Zero Wait States:** Optimized logic for high-speed register access.

## Technical Specifications

### AXI4-Lite Signal Map
| Signal | Direction | Description |
| :--- | :--- | :--- |
| `S_AXI_ACLK` | Input | Global Clock Signal |
| `S_AXI_ARESETN` | Input | Global Reset Signal (Active Low) |
| `S_AXI_AWADDR` | Input | Write Address Bus |
| `S_AXI_AWVALID` | Input | Write Address Valid |
| `S_AXI_AWREADY` | Output | Write Address Ready |
| `S_AXI_WDATA` | Input | Write Data Bus |
| `S_AXI_WVALID` | Input | Write Data Valid |
| `S_AXI_WREADY` | Output | Write Data Ready |
| `S_AXI_BVALID` | Output | Write Response Valid |
| `S_AXI_BREADY` | Input | Write Response Ready |
| `S_AXI_BRESP` | Output | Write Response (OKAY, EXOKAY, SLVERR, DECERR) |
| `S_AXI_ARADDR` | Input | Read Address Bus |
| `S_AXI_ARVALID` | Input | Read Address Valid |
| `S_AXI_ARREADY` | Output | Read Address Ready |
| `S_AXI_RDATA` | Output | Read Data Bus |
| `S_AXI_RVALID` | Output | Read Data Valid |
| `S_AXI_RREADY` | Input | Read Data Ready |

### FSM State Diagram
The slave logic transitions through states such as `IDLE`, `AD_DATA_WAIT` (Waiting for Address/Data), and `RESP_WAIT` (Waiting for Response Acknowledge) to ensure synchronization with the AXI Master.

### FSM Design
The core logic relies on a Moore Finite State Machine to handle the READY/VALID handshakes without deadlocks. The FSM is specifically designed to accept Write Address (`AWVALID`) and Write Data (`WVALID`) independently or simultaneously, ensuring standard protocol compliance and maximizing data throughput.


## 📉 Simulation & Verification
The design was verified using a custom **AXI Master BFM (Bus Functional Model)** in a Verilog testbench environment.

### Verification Scenarios:
1. **Single Write/Read:** Verifying data consistency when writing to and reading from `REG0`.
2. **Back-to-Back Transactions:** Testing the slave's ability to handle rapid successive requests.
3. **Invalid Address Handling:** Ensuring the slave remains stable when an out-of-bounds address is accessed.

### Waveform Analysis
*The screenshot below illustrates a successful Write transaction followed by a Read transaction, showing the precise timing of the READY/VALID handshakes:*

![AXI4 Waveform](axi_waveform.png) 

## 💻 Simulation Instructions
To run the simulation using **Icarus Verilog**:

```bash
# 1. Clone the repository
git clone [https://github.com/AyanRoy1211/AXI4-Lite-Slave-RTL.git](https://github.com/AyanRoy1211/AXI4-Lite-Slave-RTL.git)

# 2. Compile Design and Testbench
iverilog -o axi_sim axi_slave.v axi_slave_tb.v

# 3. Execute Simulation
vvp axi_sim

# 4. View Results
gtkwave dump.vcd
