# Trio — Pressure- and Location-Based Second Factor (macOS HCI Prototype)

Trio is a macOS HCI prototype that explores using **how you click**—your trackpad **pressure** and **click spot**—as a subtle second factor, inspired by Duo but designed to feel **seamless** instead of interruptive.

The app mimics a Stony Brook–style NetID login with Duo, then layers Trio on top as an **invisible behavioral factor**. It’s not about full fledge security yet; it’s about **interaction design, feedback, and feasibility**.

> ⚠️ **Prototype only.** No real SBU accounts, no network calls, and no persistent storage. All data lives in memory and resets when you quit the app.

---

## 🧱 Tech Stack

- **Platform:** macOS app
- **Language:** Swift
- **UI:** SwiftUI
- **Input:** Mac trackpad (`NSEvent.pressure` via `NSViewRepresentable`)
- **Storage:** In-memory only (`ObservableObject` + Swift models), wiped on restart

No backend, no keychain, no real Duo integration. Everything is local and fake-data only.

---

## 🧪 Developer Beta vs Public Beta

**Developer Beta Testing mode:**

- Explicit labels: Soft / Medium / Firm.
- Live pressure indicator on the login screen.
- Spot visualizations with tolerance circles.
- Great for screen-recorded demos and user testing.

**Public Beta mode:**

- Keeps pressure/spot logic but hides raw internals.
- UI feels like a polished Duo login page.
- Trio behaves like a subtle, invisible second factor.

Mode differences are purely presentational; the underlying auth logic is the same.

---

## 🚀 Running the App

1. Clone the repo:

   ```bash
   git clone https://github.com/merul01/Trio.git
   cd Trio

2.	Open the Xcode project:

    ```bash
    open Trio.xcodeproj

3.	In Xcode:

  	•	Select the macOS target.
	  •	Build & Run (⌘R).

    
