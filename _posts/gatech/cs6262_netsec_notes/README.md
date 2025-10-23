# Advanced Web Security - Project 2 Knowledge Dump

This directory contains comprehensive documentation of all tasks completed in CS6262 Advanced Web Security Project 2. Each file represents a complete walkthrough of a specific task, including background, approach, implementation, debugging sessions, stuck points, and breakthroughs.

## Files

### Core Tasks

1. **2025-10-19-task-1-foundational-concepts.md** (11K)
   - HTML iframe sizing and manipulation
   - Link target attributes for new tabs
   - JavaScript closures and event loop behavior
   - Script tag escaping techniques
   - Fetch API fundamentals
   - Why each concept matters for later tasks

2. **2025-10-19-task-2-reflected-xss.md** (9.7K)
   - Basic reflected XSS exploitation
   - Understanding output encoding vulnerabilities
   - Attack flow and defense mechanisms
   - Real-world impact examples

3. **2025-10-19-task-3-persistent-client-side-xss.md** (15K)
   - Exploiting localStorage for persistent XSS
   - Understanding JavaScript event loop timing
   - Multiple failed attempts and debugging
   - Breakthrough with setTimeout(0)
   - Finding the right localStorage keys
   - Choosing effective payloads

4. **2025-10-19-task-4-session-hijacking.md** (21K)
   - Stored XSS to session hijacking exploit chain
   - Bypassing HttpOnly cookies
   - CSRF token extraction techniques
   - Promise chaining for asynchronous requests
   - Two complete solutions (fetch-based and DOM manipulation)
   - Extensive debugging and error handling

### Advanced Attacks (Task 5)

5. **2025-10-19-task-5-1-redos.md** (12K)
   - Regular Expression Denial of Service
   - Understanding catastrophic backtracking
   - Crafting ReDoS payloads
   - Defense mechanisms and safe regex patterns

6. **2025-10-19-task-5-2-network-scanning.md** (17K)
   - Using XSS to scan internal networks
   - Fetch API with no-cors mode
   - Parallel network scanning techniques
   - Discovering internal services
   - Defense strategies

7. **2025-10-19-task-5-3-tabnabbing.md** (27K)
   - Social engineering via tab replacement
   - Page Visibility API exploitation
   - Extensive timer debugging sessions
   - MutationObserver for dynamic content
   - Complete attack flow with detailed timeline
   - Multiple failed attempts and breakthroughs

## Total Content

- **7 comprehensive markdown files**
- **~112K of detailed technical documentation**
- **All code snippets, debugging output, and thought processes included**
- **Complete journey from initial attempts to final solutions**

## Usage

These files are formatted for Jekyll-based static site generators (like GitHub Pages) with front matter including:
- Title
- Date
- Categories
- Tags
- Table of contents enabled

Each file can be used as:
- Personal knowledge base reference
- Blog post for technical writing portfolio
- Study material for web security concepts
- Documentation for similar security research

## Key Themes

- **Defense in Depth**: Multiple security layers working together
- **XSS is the Root Vulnerability**: Most attacks start with XSS
- **Understanding Browser APIs**: Modern attacks leverage powerful browser features
- **Debugging Methodology**: Extensive logging and iterative refinement
- **Real-World Impact**: Practical implications of each vulnerability

---

*All sensitive information (usernames, specific endpoints, hashes) has been removed or anonymized.*
