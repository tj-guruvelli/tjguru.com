---
title: Task 1 - Foundational Concepts
date: 2025-10-19 00:00:00 +0000
categories: [Gatech, Courses]
hidden: true
published: false
tags: [html, javascript, promises, fetch-api, event-loop]
toc: true
---

## Introduction

Task 1 served as the foundation for all subsequent exploits in this project. While these questions appeared simple at first glance, each concept became critical in later tasks. This section explores why these foundational elements matter and how they enabled more sophisticated attacks.

## Iframe Sizing and Manipulation

### The Concept

HTML iframes can be sized using three different approaches, all of which are valid:

1. **HTML attributes with percentages:**

```html
<iframe src="https://example.com" width="100%" height="100%"></iframe>
```

2. **HTML attributes with pixel values:**

```html
<iframe src="https://example.com" width="100px" height="100px"></iframe>
```

3. **CSS via the style attribute:**

```html
<iframe src="https://example.com" style="width:100%;height:100%"></iframe>
```

### Why This Matters

Understanding iframe manipulation became essential for **Task 5.3 (Tabnabbing)**. In that attack, we needed to create a full-screen iframe that completely replaced the visible page content while preserving the original URL in the address bar. The CSS approach proved most flexible because it allowed dynamic manipulation via JavaScript:

```javascript
var iframe = document.createElement("iframe");
iframe.src = "/tabnabbing/gguruvelli3";
iframe.style =
  "position:fixed;top:0;left:0;width:100%;height:100vh;border:0;z-index:999999";
document.body.appendChild(iframe);
```

Key properties used in the tabnabbing attack:

- `position:fixed` - Keeps iframe in place even when scrolling
- `width:100%; height:100vh` - Full viewport coverage
- `border:0` - Removes iframe border for seamless appearance
- `z-index:999999` - Ensures iframe appears above all other content
- `top:0; left:0` - Positions iframe at top-left corner

The ability to dynamically create and style iframes via JavaScript enabled the attack to replace the entire page content after detecting that the user had switched tabs.

## Link Target Attribute

### The Concept

The `target="_blank"` attribute on anchor tags forces links to open in a new tab or window:

```html
<a href="https://example.com" target="_blank">Click me</a>
```

### Why This Matters

This attribute was the cornerstone of the **tabnabbing attack** in Task 5.3. The attack flow depended on:

1. User clicking a link that opens in a **new tab**
2. Original tab remaining open but **inactive**
3. Attack detecting the tab became **hidden**
4. After 60 seconds of inactivity, **replacing the original tab's content**

Without `target="_blank"`, clicking a link would navigate away from the attack page entirely, preventing the tab replacement. The attack required modifying all links on the page:

```javascript
function modifyLinks() {
  var links = document.querySelectorAll("a");
  links.forEach(function (link) {
    link.setAttribute("target", "_blank");
  });
}
```

For dynamically added links, a `MutationObserver` ensured all links (even those added after page load) would open in new tabs:

```javascript
new MutationObserver(function () {
  modifyLinks();
}).observe(document.body, { childList: true, subtree: true });
```

## JavaScript Closures and the Event Loop

### The Problem

Consider this code:

```javascript
for (var i = 0; i < 3; i++) {
  const promise = new Promise((resolve, reject) => {
    setTimeout(resolve, 1000 + i * 1000);
  });
  promise.then(() => alert(i));
}
```

**Question:** What numbers appear in the three alerts?  
**Answer:** `3, 3, 3`

### Why This Happens

The issue stems from how JavaScript's event loop and variable scoping work:

1. **`var` has function scope, not block scope** - There's only one `i` variable shared across all iterations
2. **The loop completes before any promises resolve** - By the time the first `setTimeout` fires (after 1 second), the loop has finished
3. **All callbacks reference the same `i`** - When they execute, `i` has the value `3`

**Execution timeline:**

```
t=0ms:    Loop starts, i=0, schedules promise to resolve at 1000ms
t=0ms:    Loop continues, i=1, schedules promise to resolve at 2000ms
t=0ms:    Loop continues, i=2, schedules promise to resolve at 3000ms
t=0ms:    Loop completes, i=3
t=1000ms: First promise resolves, alert(i) → alert(3)
t=2000ms: Second promise resolves, alert(i) → alert(3)
t=3000ms: Third promise resolves, alert(i) → alert(3)
```

### Why This Matters

Understanding JavaScript's event loop was **critical for Task 3 (Persistent Client-Side XSS)**. The challenge was to inject a payload that:

- Did **NOT** execute on the first visit
- **DID** execute on subsequent visits

The solution used `setTimeout` with a zero-millisecond delay:

```javascript
setTimeout(function () {
  localStorage.setItem(
    "cs6262-web-security-user-theme",
    "<img src=x onerror=alert(1)>"
  );
}, 0);
```

Even with a zero delay, `setTimeout` pushes the callback to the back of the event queue. This means:

1. XSS payload executes (via reflected XSS)
2. `setTimeout` schedules the callback
3. Current script completes
4. Page's legitimate JavaScript reads from `localStorage` (finds nothing malicious)
5. Page renders normally (**no alert on first visit**)
6. Event loop processes the `setTimeout` callback
7. Callback sets the malicious `localStorage` value
8. On next visit, malicious value is already stored (**alert triggers**)

Without understanding the event loop, it would be impossible to create a payload that doesn't execute immediately.

## Script Tag Escaping

### The Problem

Which of these correctly sets a variable to a string containing a `<script>` tag?

```javascript
// A - WRONG
<script>let jsScript=<script>a=2</script></script>

// B - WRONG
<script>let jsScript='<script>a=2</script>'</script>

// C - CORRECT
<script>let jsScript='<script>a=2<\/script>'</script>
```

### Why B Fails

The browser's **HTML parser** runs before the **JavaScript engine**. When the HTML parser encounters `</script>` inside a string, it doesn't understand JavaScript syntax—it just sees the end of a script block.

**What the browser sees:**

```html
<script>let jsScript='<script>a=2</script>  ← Parser thinks script ends here
'</script>  ← Parser sees this as malformed HTML
```

This causes a syntax error because the JavaScript is incomplete.

### The Solution

Escape the forward slash to break up the closing tag pattern:

```javascript
<script>let jsScript='<script>a=2<\/script>'</script>
```

The HTML parser doesn't recognize `<\/script>` as a closing tag (because of the backslash), so it continues. The JavaScript engine later interprets `<\/script>` as the string `</script>` (the backslash is just an escape character).

### Why This Matters

This technique was essential for **Task 3 (Persistent Client-Side XSS)** when injecting payloads into `localStorage`:

```javascript
localStorage.setItem("userTheme", "<script>alert(1)</script>");
```

Without escaping the closing tag, the browser would prematurely end the script block, breaking the XSS payload. The escaped version ensures the payload is stored correctly as a string and only executed when the application reads it from `localStorage` and injects it into the DOM.

## Fetch API Fundamentals

### The Task

Use the Fetch API to make a POST request to the Message Receiver Endpoint with the body `{username: 'gguruvelli3'}` and retrieve the hash.

### Implementation

```javascript
fetch("https://cs6262.gtisc.gatech.edu/receive/gguruvelli3/2065", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
  },
  body: JSON.stringify({ username: "gguruvelli3" }),
})
  .then((response) => response.json())
  .then((data) => {
    console.log("Hash:", data.hash);
  });
```

**Result:** `c98105f77512ac416e17b79e9d139fc2460c4514423eaf5bb21d73f9366abe7f1ec09ef9b17321fbdab1dde2edd9d41e1e344b45801a97fae474e08fe455215b`

### Why This Matters

The Fetch API became the primary tool for **Task 4 (Session Hijacking)**. Key concepts learned:

#### 1. Credentials and Cookies

```javascript
fetch("https://cs6262.gtisc.gatech.edu/console", {
  credentials: "include", // Sends cookies with the request
});
```

The `credentials: 'include'` option tells the browser to send cookies (including `HttpOnly` cookies) with the request. This enabled session hijacking without directly accessing `document.cookie`.

#### 2. Promise Chaining

```javascript
fetch("/endpoint1")
  .then((response) => response.text())
  .then((html) => {
    // Extract data from html
    return fetch("/endpoint2", {
      headers: { "X-Token": extractedToken },
    });
  })
  .then((response) => response.json())
  .then((data) => {
    // Use data from second request
  });
```

Chaining promises ensured asynchronous operations happened in the correct order—critical when extracting CSRF tokens before making authenticated requests.

#### 3. Request Methods and Headers

```javascript
fetch("/session-hijacking/gguruvelli3", {
  method: "POST",
  headers: {
    "X-CSRFToken": csrfToken,
  },
  credentials: "include",
});
```

Understanding how to set custom headers (like CSRF tokens) and specify HTTP methods was essential for bypassing CSRF protection.

#### 4. Response Handling

```javascript
.then(function(res) {
    if (res.ok) return res.json();
    else return {};  // Handle errors gracefully
})
.then(function(data) {
    if (data.hash) {  // Check if expected data exists
        // Process hash
    }
})
```

Proper error handling prevented the exploit from breaking when responses weren't as expected.

## Conclusion

These foundational concepts weren't just academic exercises—each one became a critical building block for the more sophisticated attacks in later tasks:

- **Iframe manipulation** → Tabnabbing attack (Task 5.3)
- **`target="_blank"`** → Tabnabbing attack (Task 5.3)
- **Event loop and closures** → Persistent XSS timing (Task 3)
- **Script tag escaping** → Persistent XSS payload storage (Task 3)
- **Fetch API** → Session hijacking (Task 4)

Understanding these fundamentals deeply, rather than just memorizing answers, made the difference between successfully exploiting vulnerabilities and getting stuck on implementation details.
