# Attack Simulation 1: The SQL Injection (SQLi)

We are now wearing the **Attacker's Hat**.
We will hack into our own server (DVWA) to steal data.

## Step 1: Prepare the Target (DVWA)
1.  Go to `http://<YOUR_IP>:80` in your browser.
2.  **Login**:
    *   User: `admin`
    *   Pass: `password` (Default for DVWA).
3.  **Setup Database**:
    *   If you see a button "Create / Reset Database", click it.
4.  **Lower Security**:
    *   Go to **DVWA Security** (Left menu).
    *   Change "Security Level" to **Low**.
    *   Click **Submit**.

## Step 2: The Attack
1.  Go to **SQL Injection** (Left menu).
2.  **The "User ID" Box**:
    *   This box asks for a number (ID).
    *   Try entering `1`. Result: It shows "admin".
    *   Try entering `2`. Result: It shows "Gordon Brown".
3.  **The Hack**:
    *   We want to trick the database into showing *everything*.
    *   Enter this "Magic String":
        `%` or `' OR '1'='1`
    *   Try copying this exactly:
        `%' or '0'='0`
    *   Click **Submit**.

**Result**: Do you see a huge list of users? You just dumped the database.

## Step 3: The Detection (Blue Team Mode)
Now, switch hats. You are the SOC Analyst.

1.  Go to **Splunk** -> Search.
2.  Run this search:
    ```splunk
    index=soc_lab tag=dvwa "%" OR "'"
    ```
    *   *Explanation*: We are looking for the special characters we used in the attack.
3.  **Advanced Search**:
    ```splunk
    index=soc_lab "SELECT" OR "UNION" OR "1=1"
    ```
    *(Note: DVWA doesn't log the full SQL query by default in Docker logs, so we look for the URL request).*

    Try searching for the URL encoded version:
    ```splunk
    index=soc_lab "%27" OR "OR"
    ```

**Did you find your attack in the logs?**
