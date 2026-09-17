<div align="center">

# 🛡️ AFK FoxG Integrity Guard
### Advanced Pre-Auth & Dynamic Heartbeat Anti-Tamper System for FiveM

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)
[![Platform: FiveM](https://img.shields.io/badge/Platform-FiveM%20%2F%20Cfx.re-orange?style=for-the-badge)](https://fivem.net)
[![Lua: 5.4](https://img.shields.io/badge/Language-Lua%205.4-000080.svg?style=for-the-badge&logo=lua)](https://www.lua.org)
[![Discord](https://img.shields.io/badge/Discord-Join%20Community-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/GY5mSJFg77)
[![Website](https://img.shields.io/badge/Website-mamadreza.top-00c853?style=for-the-badge&logo=googlechrome&logoColor=white)](https://mamadreza.top)

<p align="center">
  <b>A lightweight, ultra-secure security bridge engineered to ensure client integrity before and during active FiveM sessions.</b>
</p>

[Key Features](#-key-features) •
[Architecture Flow](#-architecture-flow) •
[Installation](#-installation) •
[Configuration](#-configuration) •
[Commands](#-commands) •
[Community & Support](#-support--community)

</div>

---

## 📌 Overview

**AFK FoxG Integrity Guard** is a specialized FiveM security middleware. Unlike generic anticheat scripts that run heavy client threads and cause frame drops, this system adopts a zero-overhead **Asynchronous Challenge-Response Model**. 

It validates the client's execution environment at the **deferral stage** (before connection acceptance) and continuously verifies integrity during the session using randomized, state-backed heartbeat tokens and runtime function analysis.

---

## ⚡ Key Features

* **🔒 Strict Pre-Auth Deferral:** Rejects unauthenticated connections before player spawn using FiveM native deferral pipes.
* **🎲 Dynamic Challenge-Response:** Generates unique, non-predictable tokens per tick cycle to thwart packet injection and network replay attacks.
* **💉 Hook & Memory Tamper Detection:** Implements raw type checks and sandboxed `pcall` guards to detect function overriding, dummy returns, and Lua table hijacking.
* **🛑 Instant Quarantine (Lockdown):** Neutralizes compromised clients on the spot (controls disabled, ped frozen, screen blacked out) to prevent malicious memory exploitation before dropping.
* **📊 Discord Webhook Logging:** Embedded real-time telemetry including Discord ID, Steam ID, License, IP, Ping, RP Name, Job, and Permission levels.
* **💾 Database Banning:** Built-in adapter for `oxmysql` and legacy `mysql-async` to issue hardware/license bans automatically.
* **🚀 Zero Performance Impact:** 0.00ms idle resmon; non-blocking asynchronous event loops.

---

## 🔄 Architecture Flow
```mermaid
sequenceDiagram
autonumber
actor Player as FiveM Client
participant Deferral as Server Deferrals
participant Server as Auth Server
participant DB as oxmysql / Discord

Player->>Deferral: playerConnecting
Deferral->>Server: Initialize Session & Token
Player->>Server: StateBag ("afkfoxg_ready")
Server->>Player: Trigger afk_foxg:challenge (Token, PreAuth)
Player->>Player: Evaluate() Integrity & Hook Check
Player-->>Server: Reply with Result & Token
alt Integrity Passed
Server->>Deferral: deferrals.done()
Note over Player,Server: Active Heartbeat Loop Initiated
else Tamper / Hook Detected
Server->>DB: Log Action / Issue Ban
Server-->>Player: Drop / Lockdown
end
