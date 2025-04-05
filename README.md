# ImbCleaner

**ImbCleaner** is a lightweight and powerful Windows cleanup tool written in PowerShell with a graphical user interface (GUI) using WPF.  
It removes temporary files, junk folders, cache files from popular apps, and system trash to free up space and improve performance.

---

## 💻 Features

- Cleans up:
  - Gradle cache & daemon files
  - Windows temporary files (`TEMP`, `C:\Windows\Temp`)
  - Prefetch data
  - Windows Update cache
  - Recycle Bin
  - App-specific junk (Discord, Telegram, Chrome, Spotify, etc.)
- Simple WPF GUI with progress bar and animated status
- Auto-elevates to administrator if not already
- Minimalist green-on-black hazcker aesthetic 😎

---

## 🛠 Requirements

- **Windows** (Tested on 10/11)
- **PowerShell 5.1+**
- **.NET Framework 4.5+** (for WPF support)

---

## 🚀 How to Use

1. Download or copy the script: `ImbCleaner.ps1`
2. **Right-click > Run with PowerShell**
3. If not running as admin, it will auto-restart with elevated permissions.
4. Press the **Clean all the junk** button and let the ImbCleaner do its job.

---

## ⚠️ Disclaimer

This tool removes system and application cache files.  
While it's safe for most systems, use at your own risk. Make sure you understand what’s being deleted before running.

---

## 📁 Targeted Cleanup Paths

- `%USERPROFILE%\.gradle\caches`, `daemon`, `native`, etc.
- `%TEMP%`, `C:\Windows\Temp`
- `C:\Windows\Prefetch`
- `C:\Windows\SoftwareDistribution\Download`
- `Recycle Bin`
- App Caches:
  - Discord (`Stable`, `PTB`, `Canary`)
  - Telegram Desktop
  - Google Chrome (ShaderCache, CodeCache)
  - Spotify
  - System logs

---

## 🧠 Tip

You can customize `$pathsToClean` at the end of the script to add/remove specific folders you want cleaned.

---
```
 ____  _  _                                
(  _ \( \/ )                               
 ) _ < \  /                                
(____/ (__)                                
 ____  ____  _  _  _  _    __    ____  ___ 
(  _ \( ___)( \/ )( \/ )  /__\  (  _ \/ __)
 )   / )__)  )  (  )  (  /(__)\  )___/\__ \
(_)\_)(____)(_/\_)(_/\_)(__)(__)(__)  (___/
```
