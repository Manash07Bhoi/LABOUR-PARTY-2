# Future Roadmap

This document captures high-level feature ideas and architectural trajectories for the Labour Party application.

> **Important:** The features listed below are purely conceptual. Do **not** attempt to implement them without explicit business validation, rigorous architecture review, and a formalized PRD.

## 1. Advanced Reporting & Exports

- **PDF Generation:** Implementing a local-only PDF engine to generate end-of-day reports, trip summaries, and labour timesheets directly on the device for immediate printing or sharing via WhatsApp/Email.
- **CSV Spreadsheets:** Exporting raw trip and labour data into standardized `.csv` files for legacy accounting integration.

## 2. Synchronization Capabilities

While maintaining a strict offline-first rule, future iterations could include:
- **Peer-to-Peer Sync (Bluetooth/Wi-Fi Direct):** Allowing multiple supervisors on the same physical site to synchronize trip databases without an internet connection.
- **Opt-In Cloud Sync:** A manual, heavily secured "Sync to Cloud" button in Settings to backup the Hive database to Google Drive or an enterprise server, strictly only when explicitly invoked by the user upon reaching connectivity.

## 3. Enhanced Input Mechanisms

- **Voice Input:** Utilizing on-device speech-to-text models to allow supervisors to log quick trips rapidly by saying "Add Trip, Sonalika, John, three labours".
- **NFC Tagging:** Assigning NFC tags to tractors or labour cards, allowing the supervisor to tap their device against the tag to instantly log presence or assign a vehicle.

## 4. Advanced Analytics

- **Local Dashboard Analytics:** Generating rich charts, graphs, and utilization metrics natively on the device to show workforce efficiency, most active tractors, and highest attendance over a selected date range.
