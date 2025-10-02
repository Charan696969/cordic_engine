# 🚀 FSM-based 32-bit CORDIC Engine for Skywater 130nm

![Verilog](https://img.shields.io/badge/Verilog-2001-blue.svg?style=for-the-badge)
![Synthesis](https://img.shields.io/badge/Synthesis-Yosys-brightgreen.svg?style=for-the-badge)
![Technology](https://img.shields.io/badge/PDK-Skywater%20130nm-blueviolet.svg?style=for-the-badge)

Implementation of a 32-bit, fixed-point CORDIC engine using a sequential FSM architecture for efficient trigonometric computations.

---

## 📝 Project Overview

This design implements a **32-bit, fixed-point FSM-based CORDIC engine**, capable of computing **sine and cosine** for arbitrary input angles. Key characteristics:

1. **Iterative FSM architecture** – single datapath reused over multiple clock cycles.
2. **Angle preprocessing** – wrapper module maps input angles to `[0, π/2]` and outputs quadrant information.
3. **Sign correction** – uses quadrant bits for final sine/cosine outputs.
4. **Technology mapping** – synthesizable using Yosys with Skywater 130nm standard cell library.

**Trade-off:** Computation takes 32 cycles per operation, but hardware usage is minimized (~2200 standard cells).

---

## ✨ Design Features

* **Architecture:** FSM-based, iterative CORDIC.
* **Data format:** 32-bit signed fixed-point (**Q2.29 format**).
* **Precision:** 32 iterations per computation.
* **Resource sharing:** Single adder/subtractor + shifter reused across iterations.
* **Wrapper module:** Preprocesses angles and generates quadrant bits.
* **Sign correction:** Final output adjusted according to quadrant.
* **Hardware-efficient:** Minimal logic; no multipliers required.

---

## 💡 Design & Implementation Insights

### 1. Wrapper Module

**Function:** Preprocesses the input angle and generates quadrant information.

* Maps input to `[0, π/2]`.
* Outputs 2-bit quadrant info for correct sine/cosine sign.
* Simple comparators and multiplexers → minimal hardware cost.

---

### 2. CORDIC Engine Module

**Function:** Computes sine and cosine iteratively using FSM and LUT.

**Highlights:**

* FSM with states `IDLE`, `COMPUTE`, `DONE`.
* Uses **32-entry arctangent LUT**.
* Iterative **shift-add/subtract operations**.
* Applies quadrant-based **sign correction** for final outputs.

---

### 3. Top Module Flow

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

---

### 4. Precision vs Bit-width Trade-offs

| Datapath Width | Iterations | Max Error (radians) | Std Cell Estimate | Notes                                            |
| -------------- | ---------- | ------------------- | ----------------- | ------------------------------------------------ |
| 24-bit         | 32         | ~1.2e-6             | ~1600             | Slightly lower accuracy, ~20–30% fewer cells     |
| 32-bit         | 32         | ~3e-7               | ~2200             | Full precision, marginal improvement over 24-bit |

> Using a 32-bit datapath provides marginal precision improvement but increases area. Iterative architecture allows a **small footprint** while maintaining high-accuracy outputs.

---

## 📊 Synthesis Results (Skywater 130nm)

* **Total standard cells:** 2241

  * Sequential logic (flip-flops): 203
  * Combinational logic: 2038

**Observation:** Efficient iterative FSM-based CORDIC vs fully parallel multiplier-based approaches (>10k cells).

---

## 💻 Running the Project

### 1. Simulation (Icarus Verilog)

```bash
cd /path/to/CORDIC

# Compile all source files
iverilog -o cordic_sim.vvp tb_cordic_top.v wrapper.v cordic_engine.v engine.v

# Run simulation
vvp cordic_sim.vvp
```

**Simulation Screenshot Placeholder:**

<img width="2351" height="779" alt="image" src="https://github.com/user-attachments/assets/54ccfb5b-3e61-4dd6-95f0-060ab0a67546" />


---

### 2. Synthesis (Yosys)

```tcl
# synth_sky130.ys
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

---

## 📝 Design Remarks & Notes

* The CORDIC engine uses a **short, iterative 32-bit datapath** and a **32-entry LUT**, which suggests that it can operate at relatively high clock frequencies compared to larger, more complex modules.
* In principle, the engine could be clocked faster than the surrounding system, potentially improving overall throughput when integrated with a slower, larger module.
* These observations are **based on datapath simplicity and estimated combinational delays**. **Static timing analysis (STA)** has not yet been performed, and actual achievable frequency may be limited by fanout, register setup/hold times, or LUT implementation delays.
* Proper **clock domain crossing and handshake mechanisms** would be necessary if the engine runs on a separate, faster clock to ensure data integrity.
* This approach highlights a **trade-off between speed and area**, and demonstrates a design methodology where a small, efficient accelerator can coexist with a larger, slower system.

