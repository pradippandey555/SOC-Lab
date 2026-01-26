# Phase 4.1: Turning Searches into Alarms (Alerting)

You found the logs manually. Now, let's teach Splunk to watch for them 24/7 and scream if they happen again.

## Alert 1: The "Critical" Alarm (Reverse Shell)
If untrusted traffic connects to a shell, we want to know *immediately*.

1.  **Run the Search**:
    ```splunk
    index=soc_lab "nc -e" OR "/bin/sh" OR "dev/tcp"
    ```
2.  **Save As Alert**:
    *   Click **Save As** (Top Right) -> **Alert**.
    *   **Title**: `[CRITICAL] Reverse Shell Detected`
    *   **Permissions**: Private (Default is fine).
    *   **Alert Type**: **Real-time**. (We want to know NOW).
    *   **Trigger Condition**: **Per Result**.
    *   **Throttle**: Check this!
        *   *Suppress results for*: `60 seconds` (So you don't get 100 emails for 1 attack).
    *   **Trigger Actions** -> **Add Actions**:
        *   Select **Add to Triggered Alerts**.
        *   *Severity*: **Critical**.
    *   Click **Save**.

## Alert 2: The "Threshold" Alarm (Brute Force)
One failed login is normal. 100 failures is an attack.

1.  **Run the Search**:
    ```splunk
    index=soc_lab tag=metasploitable "ftp" AND "failed"
    ```
2.  **Save As Alert**:
    *   Title: `[HIGH] FTP Brute Force Detected`
    *   Alert Type: **Real-time**.
    *   **Trigger Condition**: **Number of Results** is greater than `20`.
        *   *Window*: in `1 minute` (This is the key! 20 failures in 1 minute = Attack).
    *   **Throttle**: Suppress for `5 minutes`.
    *   **Trigger Actions**:
        *   **Add to Triggered Alerts**.
        *   *Severity*: **High**.
    *   Click **Save**.

## Step 3: Verify (Make it Scream)
1.  Go to **Activity** (Top Bar) -> **Triggered Alerts**. (It should be empty).
2.  **Launch the Attacks Again!**
    *   Run Hydra again.
    *   Run the Reverse Shell payload on DVWA again.
3.  **Refresh the Page**.
    *   Do you see your alerts appear in the list?

**You have now built an Automated SOC.**
