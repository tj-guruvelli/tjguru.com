---
title: "Project 7 – WordPress Pen Testing"
date: 2022-02-08 00:00:00 +0000
categories: [Knowledge, Cybersecurity]
tags: [wordpress, xss, csrf, open-redirect, user-enumeration]
toc: true
---

Source: Unit-7-Project-WordPress-vs.-Kali — repository: https://github.com/tj-guruvelli/Unit-7-Project-WordPress-vs.-Kali

Objective: Find, analyze, recreate, and document five vulnerabilities affecting an old version of WordPress.

Time spent: 6 hours total

## 1) User Enumeration

- Version: 4.1 (fixed in 4.1.14)
- Summary: Probe user IDs; error messages reveal valid usernames (brute‑force risk)
- Artifact: `UserEnumer.gif`

## 2) Comment Stored Cross‑Site Scripting (XSS)

- Version: 4.1 (fixed in 4.1.26)
- Summary: Malicious scripts in comments execute for readers/admins
- Artifact: `CommentXSS.gif`

## 3) Accessibility Mode CSRF

- Version: 4.1 (fixed in 4.1.14)
- Summary: Forged requests abuse authenticated state; cookie theft demo
- Artifact: `StoleCookie.gif`

## 4) Open Redirect

- Version: 4.1 (fixed in 4.1.10)
- Summary: Unvalidated redirect parameter forwards users to attacker URLs
- Artifact: `OpenRedirect.gif`

## Steps to Recreate

Detailed reproduction steps and payloads are in the repository README, including sample payloads such as:

```html
<script>
  alert("XSS");
</script>
```

Open redirect PoC:

```html
<body onload="window.location='https://codepath.org/'"></body>
```

## Notes

Environment, payloads, and screenshots retained in the repo for auditability.

---

Project 7 - WordPress Pen Testing
Time spent: 6 hours spent in total

Objective: Find, analyze, recreate, and document five vulnerabilities affecting an old version of WordPress

Pen Testing Report

1. User Enumeration
   Summary: Username is confirmed based on probing different user ids and finds existing ones.
   Vulnerability types: User Enumeration
   Tested in version: 4.1
   Fixed in version: 4.1.14
   GIF Walkthrough: UserEnumer.gif

![User Enumeration](/assets/img/posts/cybersecurity/UserEnumer.gif)

Steps to recreate: User from the outside tries different user logins and finds an exisitng username based on error message. Error message comfirms an existing username and password can be brute forced 2. Comment Stored Cross-Site Scripting (XSS)
Summary: Allows attackers to hide dangerous links and code so that when a user interacts with an element such as a comment, the page can track the user's data or input or lead them to a dangerous sites such as psuedo copies to steal their data
Vulnerability types: XSS
Tested in version: 4.1
Fixed in version: 4.1.26
GIF Walkthrough: CommentXSS.gif

![Comment XSS](/assets/img/posts/cybersecurity/CommentXSS.gif)

Steps to recreate: In a post, place a script or a tag in the post or comment that leads to a dangerous link. For example: triggers the alert which could be used to track data when combined with other attacks. 3. Accessibility Mode Cross-Site Request Forgery (CSRF)
Summary: Cross-Site Request Forgery (CSRF) is an attack that forces authenticated users to submit a request to a Web application against which they are currently authenticated.
Vulnerability types: Cross-Site Request Forgery (CSRF)
Tested in version: 4.1
Fixed in version: 4.1.14
GIF Walkthrough: StoleCookie.gif

![CSRF Cookie Theft](/assets/img/posts/cybersecurity/StoleCookie.gif)

Steps to recreate: User has to be posting a comment for Cross-Site Scripting to be possible. If the user inspects the DOM to manipulate and can Test with script tag to set cookies. For example entering alert(document.cookie) in the console which triggers the alert. User can set their DOM cookie and potentially inject sensitive data to track steal from the user 4. Open Redirect
Summary: Allows attackers to mask links to external dangerous sites or track user's data through input or stealing session data
Vulnerability types: Redirection
Tested in version: 4.1
Fixed in version: 4.1.10
GIF Walkthrough: OpenRedirect.gif

![Open Redirect](/assets/img/posts/cybersecurity/OpenRedirect.gif)

Steps to recreate: In a post, place a body tag tht leads to a dangerous link or allows an eternal script to exceute code. For example:

```html
<body onload="window.location" ="https://codepath.org/"></body>
```

and that will redirect the user to external sources without an further interaction from the user.
Assets
List any additional assets, such as scripts or files

Resources
WordPress Source Browser
WordPress Developer Reference
GIFs created with ...

Notes
Describe any challenges encountered while doing the work
