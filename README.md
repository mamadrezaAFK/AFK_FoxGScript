<div align="center">

# 🛡️ AFK FoxG Integrity Guard (VMP Edition)
### Dedicated Client-State & Anti-Tamper Verification for VMP Launcher (`vmp.ir`)

[![Platform: VMP.ir](https://img.shields.io/badge/Platform-VMP.ir%20Exclusive-ff4757?style=for-the-badge&logo=shield)](https://vmp.ir)
[![Language: Lua](https://img.shields.io/badge/Language-Lua%205.4-000080.svg?style=for-the-badge&logo=lua)](https://www.lua.org)
[![Discord](https://img.shields.io/badge/Discord-Join%20Community-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/GY5mSJFg77)
[![Website](https://img.shields.io/badge/Website-mamadreza.top-00c853?style=for-the-badge&logo=googlechrome&logoColor=white)](https://mamadreza.top)

<p align="center">
  <b>یک میدل‌ور امنیتی سبک و پیشرفته، طراحی‌شده به‌طور اختصاصی برای سرورهای مبتنی بر لانچر VMP جهت اعتبارسنجی لانچر، بررسی هوک حافظه و مقابله با بای‌پس کلاینت.</b>
</p>

[ویژگی‌های کلیدی](#-ویژگی‌های-کلیدی-key-features) •
[نحوه عملکرد](#-نحوه-عملکرد-architecture-flow) •
[نصب و راه‌اندازی](#-نصب-و-راه‌اندازی-installation) •
[کانفیگ](#-تنظیمات-configuration) •
[کامندها](#-دستورات-commands) •
[پشتیبانی و ارتباط](#-پشتیبانی-و-ارتباطات-support)

</div>

---

## 📌 معرفی پروژه (Overview)

اسکریپت **AFK FoxG Integrity Guard** یک راهکار امنیتی بهینه‌سازی‌شده برای پلتفرم **[VMP.ir](https://vmp.ir)** است. این اسکریپت تضمین می‌کند که تمامی کلاینت‌های متصل به سرور، الزامات فعال بودن لانچر VMP و ماژول‌های امنیتی FoxG (`IsFoxAlive`) را پاس کرده باشند.

سیستم با بهره‌گیری از **Pre-Auth Handshake** (در فاز `deferrals` قبل از ورود به سرور) و چالش‌های رمزشده پویا (Challenge-Response Heartbeat)، مانع از حضور کلاینت‌های دستکاری‌شده، فیک، یا بدون لانچر در سرور می‌شود.

---

## ⚡ ویژگی‌های کلیدی (Key Features)

* **🇮🇷 سازگاری اختصاصی با VMP:** اعتبارسنجی مستقیم کدهای اختصاصی لانچر ایرانی VMP بدون تداخل یا کرش.
* **🔒 تأیید قبل از ورود (Pre-Auth Deferral):** اعتبارسنجی لانچر قبل از لود شدن کامل پلیر در سرور (جلوگیری از بار اضافه بر منابع گیم).
* **💉 مانیتورینگ عدم دستکاری توابع (Anti-Hook & Tamper Guard):** استفاده از چالش‌های خام (`raw_type` و `pcall`) جهت بررسی دست‌نخورده بودن توابع بومی لانچر و جلوگیری از Hook / Dummy Return.
* **🎲 توکن‌های چالش چرخشی (Dynamic Heartbeat):** ردوبدل کردن توکن‌های یک‌بارمصرف بر بستر زمان‌بندی نامتقارن، جهت بی‌اثر کردن پکت‌های تزریقی (Replay Attack).
* **🛑 قرنطینه آنی (Instant Lockdown):** در صورت تشخیص دور زدن یا بسته شدن لانچر، پلیر در لحظه فریز، نامرئی و صفحه سیاه شده و سپس مجازات اعمال می‌گردد.
* **📊 لاگ telemetry جامع در دیسکورد:** ارسال گزارش کامل همراه با لاینسس، متادیتاهای کاراکتر ESX (شغل، دسترسی، آیدی رول‌پلی)، مشخصات شبکه و وضعیت تخلف.
* **💾 سیستم بن خودکار:** سازگار با دیتابیس‌های `oxmysql` و `mysql-async` جهت اعمال بن بر روی شناسه پلیر.

---

## 🔄 نحوه عملکرد (Architecture Flow)
```mermaid
sequenceDiagram
autonumber
actor Player as VMP Client
participant Deferral as Server Deferrals
participant Server as AFK Auth Server
participant DB as Discord / Database

Note over Player: لانچر VMP در حال اجراست (FoxG Active)
Player->>Deferral: درخواست اتصال (playerConnecting)
Deferral->>Server: ایجاد نشست امنیتی با توکن موقت
Player->>Server: ارسال StateBag آماده‌سازی کلاینت
Server->>Player: ارسال چالش اولیه (afk_foxg:challenge)
Player->>Player: اجرای Evaluate() برای صحت‌سنجی IsFoxAlive و Anti-Hook
Player-->>Server: برگشت پاسخ با توکن معتبر
alt اعتبارسنجی موفق (VMP تایید شد)
Server->>Deferral: deferrals.done() (ورود مجاز)
Note over Player,Server: ورود به چرخه مانیتورینگ Heartbeat مداوم
else لانچر فعال نیست یا دستکاری شده
Server->>DB: ثبت تخلف در دیسکورد و اعمال بن دیتابیس
Server-->>Player: قطع ارتباط (Drop / Ban) با قرنطینه کامل
end
