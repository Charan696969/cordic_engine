# 🚀 FSM-based 24-bit CORDIC Engine for Skywater 130nm

Implementation of a 24-bit, fixed-point CORDIC engine using a sequential FSM architecture for efficient trigonometric computations.

-----

## 📝 Project Overview

This design implements a **24-bit, fixed-point FSM-based CORDIC engine**, capable of computing **sine and cosine** for arbitrary input angles. Key characteristics:

1.  **Iterative FSM architecture** – single datapath reused over multiple clock cycles.
2.  **Angle preprocessing** – wrapper module maps input angles to `[0, π/2]` and outputs quadrant information.
3.  **Sign correction** – uses quadrant bits for final sine/cosine outputs.
4.  **Technology mapping** – synthesizable using Yosys with Skywater 130nm standard cell library.

**Trade-off:** Computation takes 26 cycles per operation, but hardware usage is minimized (\~1670 standard cells).

-----

## ✨ Design Features

  * **Architecture:** FSM-based, iterative CORDIC.
  * **Data format:** 24-bit signed fixed-point (**Q2.21 format**).
  * **Precision:** 23 iterations per computation. Results every 26 cycles to account for pre-processing and FSM delay.
  * **Resource sharing:** Single adder/subtractor + shifter reused across iterations.
  * **Wrapper module:** Preprocesses angles and generates quadrant bits.
  * **Sign correction:** Final output adjusted according to quadrant.
  * **Hardware-efficient:** Minimal logic; no multipliers required.

-----

## 💡 Design & Implementation Insights

### 1\. Wrapper Module

**Function:** Preprocesses the input angle and generates quadrant information.

  * Maps input to `[0, π/2]`.
  * Outputs 2-bit quadrant info for correct sine/cosine sign.
  * Simple comparators and multiplexers → minimal hardware cost.

-----

### 2\. CORDIC Engine Module

**Function:** Computes sine and cosine iteratively using FSM and LUT.

**Highlights:**

  * FSM with states `IDLE`, `COMPUTE`, `DONE`.
  * Uses **23-entry arctangent LUT**.
  * Iterative **shift-add/subtract operations**.
  * Applies quadrant-based **sign correction** for final outputs.

-----

### 3\. Top Module Flow

```
angle_in
    │
    ▼
┌───────────┐
│  Wrapper  │
└───────────┘
    │  processed_angle + quadrant_bits
    ▼
┌───────────┐
│  CORDIC   │ ──▶ sine, cosine
└───────────┘
```

**Notes:**

  * Modular structure allows easy integration into larger DSP or control systems.
  * Clean separation of **preprocessing** and **computation**.

-----

## 📊 Synthesis Results (Skywater 130nm)

  * **Total standard cells:** 1678

      * Sequential logic (flip-flops): 176
      * Combinational logic: 1502

**Observation:** Efficient iterative FSM-based CORDIC vs fully parallel multiplier-based approaches (\>10k cells).

-----

## 🎯 Accuracy & Error Margin

The accuracy of the CORDIC engine was verified against a set of test vectors. The table below summarizes the absolute error between the CORDIC output and the expected mathematical result.

| Function | Minimum Error | Maximum Error | Average Error |
| :--- | :--- | :--- | :--- |
| **Sine** | $1 \times 10^{-6}$ | $0.000320$ | $0.000179$ |
| **Cosine** | $0.0$ | $0.000319$ | $0.000131$ |

This level of precision is suitable for a wide range of applications, including graphics, robotics, and digital signal processing, where the small error is well within acceptable tolerance.

-----

## 💻 Running the Project

### 1\. Simulation (Icarus Verilog)

```bash
cd /path/to/CORDIC

# Compile all source files
iverilog -o cordic_sim.vcd tb_cordic_top.v wrapper.v cordic_engine.v engine.v

# Run simulation
vvp cordic_sim.vcd
```

**Simulation Screenshot:**

<img width="2321" height="789" alt="image" src="https://github.com/user-attachments/assets/48613cb8-6cb3-4956-8bf9-aa8c43c4954d" />


-----

### 2\. Synthesis (Yosys)

```tcl
# synth_sky130.ys
read_liberty -lib ~/VLSI/sky130RTLDesignAndSynthesisWorkshop/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog wrapper.v
read_verilog engine.v
read_verilog cordic_engine.v
hierarchy -check -top cordic_engine
proc; opt; fsm; opt; memory; opt;
synth -top cordic_engine
dfflibmap -liberty /home/bozzc/VLSI/sky130RTLDesignAndSynthesisWorkshop/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
abc -liberty /home/bozzc/VLSI/sky130RTLDesignAndSynthesisWorkshop/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
clean
tee -o synthesis_report.txt stat -liberty /home/bozzc/VLSI/sky130RTLDesignAndSynthesisWorkshop/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
write_verilog -noattr cordic_engine_synth.v
```

Run with:

```bash
yosys -s synth_sky130.ys
```

  * Outputs:

      * `cordic_engine_synth.v` → synthesized netlist
      * `synthesis_report.txt` → cell-level breakdown

-----

## 📝 Design Remarks & Notes

  * The CORDIC engine uses a **short, iterative 24-bit datapath** and a **23-entry LUT**, which suggests that it can operate at relatively high clock frequencies compared to larger, more complex modules.
  * In principle, the engine could be clocked faster than the surrounding system, potentially improving overall throughput when integrated with a slower, larger module.
  * These observations are **based on datapath simplicity and estimated combinational delays**. **Static timing analysis (STA)** has not yet been performed, and actual achievable frequency may be limited by fanout, register setup/hold times, or LUT implementation delays.
  * Proper **clock domain crossing and handshake mechanisms** would be necessary if the engine runs on a separate, faster clock to ensure data integrity.
  * This approach highlights a **trade-off between speed and area**, and demonstrates a design methodology where a small, efficient accelerator can coexist with a larger, slower system.
