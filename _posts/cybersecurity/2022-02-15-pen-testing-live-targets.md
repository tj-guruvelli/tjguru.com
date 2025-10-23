---
title: "Project 8 – Pen Testing Live Targets"
date: 2022-02-15 00:00:00 +0000
categories: [Knowledge, Cybersecurity]
tags: [idor, sqli, xss, username-enumeration]
toc: true
---

Source: Unit-8-Project-Pen-Testing-Live-Targets — repository: https://github.com/tj-guruvelli/Unit-8-Project-Pen-Testing-Live-Targets

Time spent: 4 hours total

Targets: three Globitek sites (blue, green, red). Each color exposes two vulnerabilities.

## Blue

- Vulnerability: SQL Injection (SQLi)
- PoC: `id` parameter injection in “Find a Salesperson” reveals DB failures; time‑based payloads
- Artifact: `sqliBlue.gif`

## Green

- Vulnerability #1: Username Enumeration (login feedback)
- Vulnerability #2: Cross‑Site Scripting (XSS) in Contact form
- Artifacts: `userEnumerGreen.gif`, `xssGreen.gif`

## Red

- Vulnerability: Insecure Direct Object Reference (IDOR)
- PoC: Iterate `id` to access other users’ profiles
- Artifact: `UrlManipulateRed.gif`

Details and full write‑ups are in the repo README, with GIFs for each exploit.

---

Unit-8-Project-Pen-Testing-Live-Targets
Pen Testing Live Targets
Time spent: 4 hours spent in total

Objective: Identify vulnerabilities in three different versions of the Globitek website: blue, green, and red.

The six possible exploits are:

Username Enumeration
Insecure Direct Object Reference (IDOR)
SQL Injection (SQLi)
Cross-Site Scripting (XSS)
Cross-Site Request Forgery (CSRF)
Session Hijacking/Fixation
Each color is vulnerable to only 2 of the 6 possible exploits. First discover which color has the specific vulnerability, then write a short description of how to exploit it, and finally demonstrate it using screenshots compiled into a GIF.

Blue
Vulnerability #1: SQL Injection (SQLi)
Description: In the "Find a Salesperson" section of the website, the url can be exploited with "id=x", x being some number. With attempts of other sql statement injections revealed a "Database query failed" error, which proves the blue site is vulnerable to SQL injection attacks. Using queries such as ' OR 1=1 --' and ' OR SLEEP(5)=0--'. ' OR SLEEP(5)=0-- without the clsoing quote trigger the database query to fail since the SQL syntax is not correct. The green and red websites redirects the user when anything in the url is manipulated and the sleep SQL statement did not work

![SQLi Blue](/assets/img/posts/cybersecurity/sqliBlue.gif)

Green
Vulnerability #1: Username Enumeration
Description: In the Login section of the website, the feedback message gives clues to potential usernames. With attempts of "Testy" and "Lazyman" reveals an error message of "Login attempt was unsuccessful" but once a proper username like "pperson" was entered with a random password it reveals "Login attempt was unsuccessful", but in bold. This proves that the green website is vulnerable to user enumeration that an attacker can exploit to brute force passwords and gain unauthorized access.

![User Enumer Green](/assets/img/posts/cybersecurity/userEnumerGreen.gif)

Vulnerability #2: Cross-Site Scripting (XSS)
Description: In the Contact section of the website, the textbox section can be exploited with html tags or script tags: "<script>alert('Tej found the XSS!');</script>. Once the feedback was submitted and the user is an admin who decides to check the feedback will be bombarded with alert messgaes or if other tags were used could potentially steal the admin's info whitout any further action from the user. This exploit in allowing html tags like script could be exploited using forms, buttons, images, or svgs too, proving that the green website is vulerable to Cross Site Scripting (XSS). The red and blue websites just stores the script tags or any other html tags in the databse without triggering in the browser like it does on the greeen website.

![XSS Green](/assets/img/posts/cybersecurity/xssGreen.gif)

Red
Vulnerability #1: Insecure Direct Object Reference (IDOR)
Description: In the "Find a Salesperson" section of the website, section of the website, the url can be exploited with "id=x", x being some number as provided when a person is clicked. Using Burp, the id=x was attacked with enumerating through other numbers in order to find other users. Iterating from 1-100 only a couple of IDs returned interesting users. Users such as Lazy Lazyman and Testy McTesterson, including their phone number and emails, which could be used for impersonation or social engineering to retrive info from that user. This ID manipulation in the url to exploit other users proves that the red website is vulernable to Insecure Direct Object Reference (IDOR) since manipulating the id reveals unauthorized access to other users profiles. The blue and green websites just redirects back to the "Find a Sales Person" section on the website when the Id or anything in the url is manipulated.

![IDOR Red](/assets/img/posts/cybersecurity/UrlManipulateRed.gif)

Notes
Describe any challenges encountered while doing the work
