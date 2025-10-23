---
title: "Project 9 – Honeypot (MHN‑Admin + Dionaea)"
date: 2022-02-22 00:00:00 +0000
categories: [Knowledge, Cybersecurity]
tags: [honeypot, mhn, dionaea, gcp, malware]
toc: true
---

Source: Unit9_Project-Honeypot — repository: https://github.com/tj-guruvelli/Unit9_Project-Honeypot

Time spent: 10 hours total

## MHN‑Admin Deployment

- Platform: Google Cloud Platform (GCP)
- Flask‑based admin UI; firewall + VM setup; sensors and scripts deployed from console
- Artifact: <img src="/assets/img/posts/cybersecurity/mhn-admin.gif" width="900" />

## Dionaea Deployment

- Purpose: low‑interaction honeypot to capture malware samples and metadata (e.g., MD5)
- Artifact: <img src="/assets/img/posts/cybersecurity/dionaea-honeypot.gif" width="900" />

## Database Backup

- MHN Server uses MongoDB (e.g., `mongoexport --db mnemosyne --collection session > session.json`)
- Exported JSON records honeypot activity for analysis and rule management

## Notes

- Findings summarized for executive reporting; supports rationale for security investment

---

Unit9_Project-Honeypot
Honeypot Assignment
Time spent: 10 hours spent in total

Objective: Create a honeynet using MHN-Admin. Present your findings as if you were requested to give a brief report of the current state of Internet security. Assume that your audience is a current employer who is questioning why the company should allocate anymore resources to the IT security team.

MHN-Admin Deployment
Summary: How did you deploy it? Did you use GCP, AWS, Azure, Vagrant, VirtualBox, etc.?

MHN-admin was deployed using Google Cloud Platform (GCP). After setting up the firewalls configurations, billing, regions, and services enabled, the MHN-Admin console was being designed using the Flask frameowrk to create the UI interface. After the application has been created, the user can ssh into the MHN-Admin VM and also navigate to the directed endpoint (IP Address) where the application is being hosted from the configurations set during the inital setup. When the MHN-ADMIN VM is functional, the user can now deploy scripts to honeypots, setup honeypots or other tools, and deploy sensors to capture data or potential malware attacks for future research or anaylsis for prevention.
mhn-admin.gif

![mhn-admin](/assets/img/posts/cybersecurity/mhn-admin.gif)

Dionaea Honeypot Deployment
Summary: Briefly in your own words, what does dionaea do?

Dionaea is classified as a low-interaction honeypot designed to capture malware by gaining a copy of the malware. It's intention is to trap malware exploiting vulnerabilities exposed on a network. The logs will include hash values of those files it detects such as MD5 hashing, which can be used for further intelligence gathering for malware capturing and analysis.
dionaea-honeypot.gif

![dionaea-honeypot](/assets/img/posts/cybersecurity/dionaea-honeypot.gif)

Database Backup
Summary:

What is the RDBMS that MHN-Admin uses?
MHN Server allows users to manipulate data using MongoDB as the export command uses a MongoDB command: mongoexport --db mnemosyne --collection session > session.json. The command aggregates the data from the mnemosyne database table into seesion.json

What information does the exported JSON file record?
MHN allows users to:

Download a deploy script
Connect and register
Download snort rules
Send intrusion detection logs
The exported file with record or collect all the data for a specific honeypot setup that allows system administrators to:

View a list of new attacks
Manage snort rules: enable, disable, download
Notes
Describe any challenges encountered while doing the assignment.
