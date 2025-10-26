# 🚦 FPGA Traffic Light Controller with 7-Segment Display

A Verilog-based **two-way traffic light control system** designed and implemented on the **Basys 3 FPGA board**.  
This project demonstrates the use of a **Finite State Machine (FSM)** for real-time traffic control, integrating **digital design**, **timing management**, and **display multiplexing** concepts.  
Countdown timers are displayed on a **dual 7-segment display**, and the system dynamically switches based on traffic sensor inputs.

---

## 🧩 Overview

Urban intersections require efficient control mechanisms to reduce waiting time and prevent collisions.  
This FPGA design simulates a two-road intersection (North–East) traffic system, where each road alternates between red, yellow, and green lights based on preset time intervals and sensor inputs indicating vehicle presence.

The FSM governs state transitions for each signal, while clock dividers control both timing and 7-segment display refresh rates.

---

## ⚙️ System Architecture

### 🔹 FSM Design
The system operates across **four primary states**:
| State | North | East | Description |
|:------|:-------|:------|:-------------|
| s0 | Green | Red | North traffic flows |
| s1 | Yellow | Red | Transition from North to East |
| s2 | Red | Green | East traffic flows |
| s3 | Red | Yellow | Transition from East to North |

Each state persists for a countdown duration displayed on the 7-segment display.

---

### 🔹 Clock Dividers
- **1 Hz Divider**: Controls timing for state changes and countdown logic.  
- **100 Hz Divider**: Drives fast multiplexing of the 7-segment display for smooth visual output.

---

### 🔹 Sensor Inputs
- `sN` (North Sensor) and `sE` (East Sensor) allow **demand-based control**, where traffic lights change only when vehicles are detected.

---

## 🛠 Tools & Environment

| Tool | Purpose |
|------|----------|
| **Xilinx Vivado 2022.2+** | Design entry, synthesis, and implementation |
| **ModelSim / Vivado Simulator** | Functional simulation and verification |
| **Basys 3 FPGA (XC7A35T-1CPG236C)** | Hardware implementation platform |
| **Verilog HDL** | Hardware description and FSM logic design |



