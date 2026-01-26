# Phase 4: The Hunt (SOC Analyst Mode)

You have successfully hacked your own systems. Now, imagine you are the SOC Analyst who was sleeping while this happened.
Your job is to find the "Smoking Gun".

## 1. Detecting the Reverse Shell
The hacker (you) used `nc` to connect to port 4444. This is extremely noisy.

**Search 1: The Network Connection**
```splunk
index=soc_lab dest_port=4444
```
*   **What you see**: A connection from `172.18.0.5` (DVWA) to `172.18.0.3` (Kali).
*   **Meaning**: "Why is my Web Server talking to another server on a weird port?"

**Search 2: The Command Execution**
```splunk
index=soc_lab "nc -e" OR "/bin/sh" OR "dev/tcp"
```
*   **What you see**: The actual command injected into the web form.

## 2. Detecting the SQL Injection
Remember when you dumped the database?

**Search 3: The SQLi Pattern**
```splunk
index=soc_lab "%" OR "UNION" OR "1=1"
```

## 3. Detecting the Brute Force
Remember Hydra?

**Search 4: The Brute Force**
```splunk
index=soc_lab "ftp" AND "failed"
```

## 4. The "Mega correlation" (Advanced)
Can you find ONE search that shows all activity from the Attacker IP?

1.  Find your Kali IP (e.g., `172.18.0.3`).
2.  Search **Everything** involving that IP:
    ```splunk
    index=soc_lab "172.18.0.3"
    ```
3.  Click the **Timeline** properly. You should see:
    *   Port Scans (Nmap)
    *   FTP Attacks (Hydra)
    *   Reverse Shell Connection (Netcat)

**Congratulations! You have completed the Full SOC Lifecycle.**
1.  **Build** (Infrastructure)
2.  **Attack** (Red Team)
3.  **Detect** (Blue Team)
