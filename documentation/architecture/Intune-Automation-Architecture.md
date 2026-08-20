# 🏗️ Intune Automation Architecture

## 📌 Overview

This document describes the architecture and design approach used in the **Intune PowerShell Automation Toolkit**.

The project demonstrates how PowerShell and Microsoft Graph API can be combined to automate common Microsoft Intune endpoint-management and reporting activities.

The architecture is designed around a simple principle:

> **PowerShell handles automation and orchestration, while Microsoft Graph API provides access to Microsoft Intune and Microsoft 365 management data.**

---

## Architecture Objectives

The primary objectives of this project are:

- Automate common Microsoft Intune administrative tasks
- Retrieve Intune device information through Microsoft Graph API
- Generate reusable PowerShell-based reports
- Separate automation scripts according to operational functions
- Demonstrate secure, read-only API interaction
- Provide a maintainable structure for future automation
- Demonstrate practical endpoint-management engineering skills

---

## 🧩 High-Level Architecture

```text
                    ┌─────────────────────────┐
                    │       Administrator     │
                    │       / Engineer        │
                    └────────────┬────────────┘
                                 │
                                 │ Executes
                                 ▼
                    ┌─────────────────────────┐
                    │    PowerShell Scripts   │
                    │                         │
                    │ Device Management       │
                    │ Application Management  │
                    │ Compliance              │
                    │ Reporting               │
                    │ Graph API               │
                    └────────────┬────────────┘
                                 │
                                 │ Microsoft Graph API
                                 ▼
                    ┌─────────────────────────┐
                    │    Microsoft Graph      │
                    │          API            │
                    └────────────┬────────────┘
                                 │
                                 ▼
              ┌────────────────────────────────────┐
              │       Microsoft Intune / MDM       │
              │                                    │
              │ Managed Devices                    │
              │ Applications                       │
              │ Compliance                         │
              │ Endpoint Information               │
              └────────────────┬───────────────────┘
                               │
                               │ Retrieved Data
                               ▼
                    ┌─────────────────────────┐
                    │    PowerShell Objects   │
                    │                         │
                    │ Filtering               │
                    │ Formatting              │
                    │ Reporting               │
                    └────────────┬────────────┘
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │       CSV / Console     │
                    │         Reports         │
                    └─────────────────────────┘
