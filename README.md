<div align="center">

# 🛡️ AFK FoxG Integrity Guard (VMP Edition)
### High-Performance Client Integrity & Anti-Tamper Middleware for [VMP.ir](https://vmp.ir) Launcher

[![Platform: VMP.ir](https://img.shields.io/badge/Platform-VMP.ir%20Exclusive-ff4757?style=for-the-badge&logo=shield)](https://vmp.ir)
[![Language: Lua](https://img.shields.io/badge/Language-Lua%205.4-000080.svg?style=for-the-badge&logo=lua)](https://www.lua.org)
[![Discord](https://img.shields.io/badge/Discord-Join%20Community-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/GY5mSJFg77)
[![Website](https://img.shields.io/badge/Website-mamadreza.top-00c853?style=for-the-badge&logo=googlechrome&logoColor=white)](https://mamadreza.top)

<p align="center">
  <b>A specialized, zero-overhead client validation middleware designed exclusively for FiveM servers utilizing the Iranian VMP launcher. Guarantees active launcher state, defends against function hooking, and terminates unauthenticated sessions.</b>
</p>

[Key Features](#-key-features) •
[Architecture Flow](#-architecture-flow) •
[Installation](#-installation) •
[Configuration](#-configuration) •
[Commands](#-commands) •
[Support & Community](#-support--community)

</div>

---

## 📌 Overview

**AFK FoxG Integrity Guard** is an anti-bypass and validation suite engineered specifically for the **VMP.ir** platform. Rather than relying on intrusive, CPU-heavy scanning routines, it utilizes a non-blocking **Asynchronous Challenge-Response Model** that interacts directly with VMP's native runtime environment (`IsFoxAlive`).

The system validates client legitimacy during the native **deferrals pipeline** (before the player is accepted onto the server) and continuously enforces cryptographic token-based heartbeats during active gameplay. If a client attempts to bypass the launcher, mock launcher functions, or disconnect the client-side bridge, the server automatically quarantines and drops/bans the target.

---

## ⚡ Key Features

* **🇮🇷 Exclusive VMP.ir Architecture:** Built from the ground up to interface seamlessly with the VMP launcher environment without causing game crashes, stuttering, or compatibility issues.
* **🔒 Pre-Auth Handshake Deferral:** Enforces integrity verification *before* player initialization. Malicious clients without the active launcher are dropped before they ever load a single resource.
* **💉 Memory Hook & Anti-Tamper Protection:** Evaluates function definitions using raw sandboxed `pcall` wrappers and strict type-validation to detect API overrides, Lua hijackers, and dummy return values.
* **🎲 Asynchronous Dynamic Heartbeat:** Server dispatches randomized, single-use cryptographic tokens per verification tick to completely neutralize packet spoofing and replay attacks.
* **🛑 Instant Quarantine (Lockdown):** If a client loses its verified state during a session, the script triggers an immediate client lockdown (disables controls, freezes entity, blacks out screen) to prevent memory exploitation before removal.
* **📊 Discord Telemetry Logging:** Comprehensive reporting system forwarding rich embeds containing Discord ID, Steam ID, License, IP, Ping, RP Name, Job, and Permission levels.
* **💾 Database Banning:** Out-of-the-box integration for `oxmysql` and `mysql-async` with configurable penalty types (kick vs. permanent/timed bans).
* **⚡ 0.00ms Resmon Profile:** Highly optimized event loops ensure zero impact on both client frame rates and server-side tick times.

---

## 🔄 Architecture Flow
```mermaid
sequenceDiagram
autonumber
actor Player as VMP Client
participant Deferral as Server Deferrals
participant Server as AFK Auth Server
participant DB as Discord / Database

Note over Player: VMP Launcher Running (FoxG Active)
Player->>Deferral: Connection Request (playerConnecting)
Deferral->>Server: Initialize Session with Deferral Hold
Player->>Server: Signal Client StateBag ("afkfoxg_ready")
Server->>Player: Issue Challenge (afk_foxg:challenge + Token)
Player->>Player: Run Evaluate() (Anti-Hook & IsFoxAlive Check)
Player-->>Server: Dispatch Reply (replyPreAuth + Token)
alt Integrity Verified (Launcher Valid)
Server->>Deferral: deferrals.done() (Player Joins)
Note over Player,Server: Active Heartbeat Monitoring Initiated
else Integrity Failed / Tampered
Server->>DB: Telemetry Alert & Database Ban
Server-->>Player: Quarantine & Drop Connection
end
