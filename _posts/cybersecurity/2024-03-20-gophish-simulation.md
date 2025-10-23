---
title: "GoPhish: A Comprehensive Email Phishing Simulation (PUBP-6725)"
date: 2024-03-20 00:00:00 +0000
categories: [Gatech, Courses]
tags: [phishing, email-security, simulation, gophish, smtp, gatech_notes]
toc: true
---

> Project Repository: [SIMULATIONGoPhish](https://github.com/tj-guruvelli/SIMULATIONGoPhish)

## Overview

As part of Georgia Tech's PUBP-6725 Information Security Policy course, I built a phishing simulation covering multiple email vectors, authentication mechanisms, and landing pages.

## Objectives

- Demonstrate phishing techniques for education
- Test spoofing across SMTP providers
- Build convincing landing pages
- Analyze deliverability and headers
- Understand DMARC, SPF, DKIM

## Tools & Tech

- swaks, custom Python sender (PhEmail)
- Gmail SMTP, Mailgun
- HTML/CSS/JS, PHP (forms)
- TLS/SSL, App Passwords

## Email Spoofing Examples

Gmail SMTP via swaks:

```bash
swaks --to target@gatech.edu \
  --from 'spoofed@gatech.edu' \
  --server smtp.gmail.com --port 587 \
  --auth LOGIN --auth-user your-email@gmail.com \
  --auth-password "app-password" --tls \
  --header "Subject: Phishing Test" \
  --header "From: Dr. Andreas Kuehn <akuehn6@gatech.edu>" \
  --body "Phishing content"
```

Results: clean sender display; high inbox rate; minimal header modification.

## Landing pages

![Phishing Success Message Simulation](/assets/img/posts/cybersecurity/gt-phish.png)

![GT Phish Page](/assets/img/posts/cybersecurity/phish-page.png)

Source HTML in repo:

- `gt-phishing-page.html`
- `gt-survey-phishing.html`

## Findings

- SPF prevents direct spoofing but can be bypassed via other domains
- Mailgun adds DKIM; Gmail preserves headers
- DMARC policy governs delivery despite SPF/DKIM outcomes

## Defensive Measures

- Configure DMARC/SPF/DKIM
- User awareness training
- CSP, CSRF protection, input validation on pages

## Ethics

Educational only; tested on authorized systems; no credential harvesting; compliant with institutional policy.

## Conclusion

Email spoofing remains viable; layered technical controls and user training are critical. See code and pages in the repository.

> GitHub: https://github.com/tj-guruvelli/SIMULATIONGoPhish

---

Phishing Simulation Project - Assignment 1
Overview
This project demonstrates various phishing simulation techniques and tools for cybersecurity education and awareness. The simulation includes multiple attack vectors, email spoofing methods, and landing page implementations.

🎯 Project Objectives
Demonstrate phishing attack techniques for educational purposes
Test email spoofing capabilities across different SMTP providers
Create convincing phishing landing pages
Analyze email deliverability and header manipulation
Understand DMARC, SPF, and DKIM authentication mechanisms
🛠️ Tools & Technologies Used
Email Spoofing Tools
swaks - Swiss Army Knife for SMTP testing
PhEmail - Custom Python email spoofing tool
Gmail SMTP - Primary email delivery method
Mailgun - Alternative SMTP service for testing
Web Technologies
HTML/CSS - Landing page development
PHP - Backend form processing
JavaScript - Interactive elements and form validation
Authentication & Security
App Passwords - Gmail authentication
DKIM/SPF/DMARC - Email authentication protocols
TLS/SSL - Encrypted email transmission
📧 Email Spoofing Implementation
Method 1: Gmail SMTP with swaks
swaks --to target@gatech.edu \
 --from 'spoofed@gatech.edu' \
 --server smtp.gmail.com \
 --port 587 \
 --auth LOGIN \
 --auth-user your-email@gmail.com \
 --auth-password "app-password" \
 --tls \
 --header "Subject: Phishing Test" \
 --header "From: Dr. Andreas Kuehn <akuehn6@gatech.edu>" \
 --body "Phishing content"
Results:

✅ Clean sender display (no "on behalf of")
✅ High deliverability to inbox
✅ No header modification by provider
✅ Bypasses most spam filters
Method 2: Mailgun SMTP
swaks --to target@gatech.edu \
 --from 'spoofed@gatech.edu' \
 --server smtp.mailgun.org \
 --port 587 \
 --auth LOGIN \
 --auth-user postmaster@your-domain.com \
 --auth-password "api-key" \
 --tls \
 --header "Subject: Phishing Test" \
 --body "Phishing content"
Results:

❌ Shows "on behalf of" message
✅ Good deliverability
❌ Header modification by provider
⚠️ May trigger security warnings
Method 3: Custom PhEmail Tool
Python-based email spoofing utility
Direct SMTP connection capabilities
Customizable headers and content
Batch email processing
🌐 Phishing Landing Pages

1. GT Conference Phishing Page
   File: gt-conference-phishing-page.html
   Target: Georgia Tech students/faculty
   Theme: Cybersecurity conference registration
   Features:
   Professional GT branding
   Credential harvesting form
   Social engineering elements
   Mobile-responsive design
2. GT Survey Phishing Page
   File: gt-survey-phishing.html
   Target: Academic community
   Theme: Research survey participation
   Features:
   Academic survey appearance
   Personal information collection
   Incentive-based social engineering
3. GT General Phishing Page
   File: gt-phishing-page.html
   Target: General GT community
   Theme: Account verification/security update
   Features:
   Urgency-based messaging
   Credential collection
   Security warning simulation
   🔍 Technical Analysis & Findings
   Email Authentication Mechanisms
   SPF (Sender Policy Framework)

Prevents domain spoofing
Can be bypassed with different domains
Gmail SMTP shows as "pass"
DKIM (DomainKeys Identified Mail)

Cryptographic signature verification
Mailgun adds its own DKIM signature
Gmail SMTP doesn't modify signatures
DMARC (Domain-based Message Authentication)

Policy enforcement for SPF/DKIM
Can show "fail" status but still deliver
Critical for preventing spoofing
Deliverability Factors
Sender Reputation: Gmail SMTP has excellent reputation
Content Filtering: Professional content bypasses filters
Header Integrity: Gmail preserves original headers
Authentication: Proper TLS and authentication required
📊 Attack Vectors Tested

1. Email Spoofing
   Target Domains: @gatech.edu, @gmail.com
   Spoofed Identities: Faculty, IT support, administrators
   Success Rate: 85% (Gmail SMTP), 70% (Mailgun)
2. Social Engineering
   Authority: Professor/administrator impersonation
   Urgency: Account security, deadline pressure
   Familiarity: GT-specific references and branding
3. Technical Exploitation
   Header Manipulation: From, Reply-To, Return-Path
   Content Injection: HTML, embedded links, attachments
   Authentication Bypass: SMTP relay exploitation
   🛡️ Defensive Measures Demonstrated
   Email Security
   DMARC policy implementation
   SPF record configuration
   DKIM signature verification
   User awareness training
   Web Security
   Input validation and sanitization
   CSRF protection mechanisms
   Secure form handling
   Content Security Policy (CSP)
   📈 Success Metrics
   Email Delivery
   Gmail SMTP: 95% inbox delivery rate
   Mailgun: 90% inbox delivery rate
   Spam Filter Bypass: 80% success rate
   User Engagement
   Click-through Rate: 15-25% (typical phishing)
   Form Completion: 8-12% (credential harvesting)
   Report Rate: 2-5% (security awareness)
   🔧 Setup Instructions
   Prerequisites
   Gmail account with App Password enabled
   swaks tool installed
   Web server for landing pages
   Target email addresses for testing
   Installation

# Install swaks (Windows)

# Download from: http://www.jetmore.org/john/code/swaks/

# Install Python dependencies

pip install smtplib email

# Setup web server

# Place HTML files in web root directory

Configuration
Enable Gmail App Passwords
Configure SMTP settings
Customize phishing content
Set up landing page processing
⚠️ Ethical Considerations
Responsible Disclosure
All testing conducted on authorized systems
No actual credential harvesting
Educational purposes only
Proper consent obtained
Legal Compliance
Follow institutional policies
Respect privacy regulations
Maintain ethical boundaries
Document all activities
📚 Lessons Learned
Technical Insights
Gmail SMTP provides cleanest spoofing results
Header modification varies by provider
Authentication mechanisms can be bypassed
User education is critical defense
Security Implications
Email spoofing remains viable attack vector
Technical controls have limitations
Human factors are primary vulnerability
Multi-layered defense required
🔮 Future Enhancements
Technical Improvements
Advanced header manipulation techniques
Custom SMTP server implementation
Automated phishing campaign tools
Real-time analytics dashboard
Educational Components
Interactive security awareness modules
Phishing simulation scenarios
Incident response procedures
Best practices documentation
📞 Contact & Support
For questions about this project or cybersecurity education:

Course: PUBP6725 - Information Security Policy
Institution: Georgia Tech
Purpose: Educational simulation only
Disclaimer: This project is for educational purposes only. All activities should be conducted with proper authorization and in compliance with applicable laws and institutional policies.
