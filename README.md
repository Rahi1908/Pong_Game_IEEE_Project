# Ping Pong Game on FPGA

An FPGA-based implementation of the classic Ping Pong game using Verilog HDL, displayed on a VGA-compatible monitor via a Nexys 4 DDR (Artix-7) FPGA board. The game supports two-player mode and a CPU opponent mode, with features including randomized ball physics, a power-up system, and adjustable difficulty.

---

## Table of Contents

- [Overview](#overview)
- [Hardware Requirements](#hardware-requirements)
- [Features](#features)
- [Module Descriptions](#module-descriptions)
- [Pin Constraints (XDC)](#pin-constraints-xdc)
- [Controls](#controls)
- [Game Flow & FSM](#game-flow--fsm)
- [Project Structure](#project-structure)
- [How to Build & Flash](#how-to-build--flash)

---

## Overview

This project implements Pong entirely in hardware — no microcontroller or processor involved. The FPGA directly handles user input, game logic, collision detection, and VGA output generation. Ball kinematics, paddle movement, collision physics, and dynamic score tracking are implemented through synchronous logic and a finite state machine (FSM).

The game is displayed at **640×480 @ 60Hz** via the onboard VGA connector, and scores are shown on both the VGA screen and the **8-digit 7-segment display**.

---

## Hardware Requirements

| Component | Details |
|-----------|---------|
| FPGA Board | Digilent Nexys 4 DDR (Xilinx Artix-7, XC7A100TCSG324) |
| Display | VGA-compatible monitor |
| Clock | 100 MHz onboard oscillator |
| Input | 4 push buttons (paddle control), 4 slide switches (mode selection) |

---

## Features

- **Two-Player Mode** — Both players control paddles independently using push buttons
- **CPU / AI Mode** — Player 1's paddle is replaced by an automated opponent
  - **Beatable CPU** — Reacts only when the ball is within 200px of its paddle
  - **Unbeatable (Hard) CPU** — Reacts from halfway across the court; moves faster than the ball
- **Noob Switch** — Slows down ball and paddle movement for beginners or demonstrations
- **Power-Up System** — A randomly spawned block doubles a paddle's height for ~7 seconds upon collection
- **Randomized Serves** — LFSR-based random ball direction at the start of every rally
- **5-Zone Paddle Physics** — Ball speed varies (5–8 px/frame) based on which region of the paddle it strikes
- **Look-Ahead Collision Detection** — Prevents ball tunneling at high speeds
- **Start Screen & Game Over Screen** — Rendered entirely from combinational pixel logic

---

## Module Descriptions

### `pong_game_10.v` — Top-Level Module
The top-level module integrating all subsystems. Manages the game FSM, ball physics, paddle interactions, collision detection, CPU opponent logic, and wires together all submodules.

**FSM States:**

| State | Description |
|-------|-------------|
| `IDLE` | Ball is stationary at center; waits for a button press to start rally |
| `PLAY` | Ball is in motion; collision and scoring logic is active |
| `MISS` | Ball passed a paddle; point awarded; transitions to IDLE or game over |
| `DELAY` | Brief hold state after a miss before the next serve |

### `vga_controller.v` — VGA Sync Generator
Driven by a 25 MHz pixel clock. Generates `hsync` and `vsync` pulses for 640×480 @ 60Hz. Exports live `h_counter` and `v_counter` pixel coordinates to the rendering logic.

### `clk_divider_25MHz.v` — 25 MHz Clock Divider
Divides the 100 MHz system clock down to 25 MHz for the VGA controller.

### `clk_divider_120Hz.v` — 120 Hz Clock Divider
Used for the random power-up generation logic, providing controlled spawning update rate.

### `clk_60Hz.v` — 60 Hz Clock Divider
Drives ball movement and paddle physics, synchronized to the display refresh rate for smooth gameplay.

### `clk_500Hz.v` — 500 Hz Clock Divider
Drives the 7-segment display multiplexer so both scores appear to be simultaneously illuminated.

### `horizontal_counter.v` / `vertical_counter.v` — Pixel Counters
Maintain the horizontal and vertical scan counters used by the VGA controller.

### `random_velocity.v` — Random Ball Direction Generator
Implements an 8-bit LFSR running at the system clock frequency. Samples bit 0 (horizontal direction) and bit 7 (vertical direction) on each serve to randomize the ball's initial trajectory.

### `rand_generator_power_up.v` — Power-Up Randomness Engine
A 20-bit LFSR clocked at 120 Hz. XOR feedback on bits 19, 16, 13, and 12 ensures a long, non-repeating pseudo-random sequence. Maps LFSR output to valid VGA coordinates for power-up spawn position and randomizes the timer interval between spawns (`pu_time`).

### `power_ups.v` — Power-Up Lifecycle Controller
Manages the power-up's visibility and spawning state. Increments an internal timer until it matches the random threshold from `rand_generator_power_up`. Latches spawn coordinates when activated, and resets on collection (`pu_collected` signal asserted by ball collision).

### `sevenseg_score.v` — 7-Segment Score Display
Uses Time-Division Multiplexing at 500 Hz to alternate between Player 1 and Player 2 score digits across the shared cathode bus. Decodes 2-bit binary scores (0–3) into the correct active-low 8-bit segment patterns.

---

## Controls

```
Left Paddle (Player 1):        Right Paddle (Player 2):
  ↑  →  Button P17 (lu)          ↑  →  Button M18 (ru)
  ↓  →  Button P18 (ld)          ↓  →  Button M17 (rd)

Mode Switches:
  SW J15  →  game_start   : Flip to enter game from start screen
  SW L16  →  AI_mode      : Enable CPU opponent for left paddle
  SW M13  →  hard_mode    : Make CPU unbeatable
  SW R15  →  noob_switch  : Enable slow/beginner mode
```

In **CPU mode**, Player 1's paddle is controlled by the AI. Player 2 still uses `ru`/`rd` buttons.

---


First player to reach **3 points** wins. The game over screen displays the winner and scores.

---
## Results

1. RTL Analysis
   ![imahe_alt](https://github.com/Rahi1908/Pong_Game_IEEE_Project/blob/f00cdf9942d639c42a616639609438e9829409ed/docs/Schematic%2003-06-2026%2009_51_18.png)

2. ![image_alt](https://github.com/Rahi1908/Pong_Game_IEEE_Project/blob/b21c3c853aa0a7144486b5ea59d06f04fca45ed1/docs/img1.jpeg)

3. Milestone 1: Initial ball movement
Successfully implemented basic ball motion considering collisions with
walls using if-else comditions and clock-controlled updates, laying the
foundation for real-time gameplay.

https://drive.google.com/file/d/13qbepvP8ANcZta4ua9xr5WejCspDSvZD/view

4. Milestone 2: Paddles Motion
Implemented logic for paddles motion using user inputs through push
buttons on FPGA . Adding restrictions over paddle’s motion after collisions
with top and bottom walls.

https://drive.google.com/file/d/1TYbvBeY7XMHHtXg-2SXcD2Fm0uwU-PGv/view

5. Milestone 3: Integration of ball and paddles with scores
IIntergrated ball and paddles motion. Displayed scores on screen and 7
seg dislay on FPGA.

https://drive.google.com/file/d/1mOatqXPppXHzkLknBs1P3t1UHvqamtwB/view


## How to Build & Flash

1. **Open Vivado** and create a new project targeting `xc7a100tcsg324-1` (Nexys 4 DDR).
2. **Add all `.v` source files** listed above.
3. **Add `ball_constrain.xdc`** as the constraints file.
4. Set `pong_game_10` as the **top module**.
5. Run **Synthesis → Implementation → Generate Bitstream**.
6. **Program the FPGA** via the USB-JTAG port using Vivado Hardware Manager.
7. Connect a VGA monitor, set the mode switches as desired, and press any paddle button to start.

---

## Acknowledgements

Project developed as part of **Virtual Expo 2026 — D07**.

Mentors: Jaya Surya, Shreyan Ghosh, Rupankar

Mentees: Rahi Pakhale, Gowrinanda R.
