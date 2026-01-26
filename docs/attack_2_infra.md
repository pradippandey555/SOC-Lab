# Attack Simulation 2: Infrastructure Hacking

Web attacks are fun, but let's break into a server.
We will use our **Kali Linux** container to attack the **Metasploitable** container.

## Step 1: Become the Hacker (Enter Kali)
We need to get inside the Kali container to run commands.
1.  **Go to your SSH Terminal** (where you are `ubuntu@...`).
2.  **Jump into Kali**:
    ```bash
    docker exec -it kali /bin/bash
    ```
    *(Your prompt should change to `root@kali:/#`)*.

3.  **Find the Target IP**:
    Inside the container, names resolve automatically.
    ```bash
    ping -c 2 metasploitable
    ```
    *   Note the IP address (e.g., `172.18.0.3` or similar).

## Step 2: Reconnaissance (Nmap)
Let's see what doors are open.
1.  **Run a Fast Scan**:
    ```bash
    nmap -F metasploitable
    ```
    *(This scans the top 100 ports).*

2.  **Run a Script Scan** (This detects service versions):
    ```bash
    nmap -sV -p 21,22,80 metasploitable
    ```
    *   Look for **Port 21 (FTP)**. Does it say `vsftpd 2.3.4`?

## Step 3: Brute Force Attack (Hydra)
We see Port 21 (FTP) is open. Let's try to guess the password.
1.  **Create a Password List**:
    ```bash
    echo -e "admin\nroot\nmsfadmin\nuser\npassword\n123456" > pass.txt
    ```
2.  **Launch Hydra**:
    ```bash
    hydra -l msfadmin -P pass.txt ftp://metasploitable
    ```
    *   `-l`: Username we are guessing (`msfadmin`).
    *   `-P`: List of passwords to try.

    **Result**: Did it find the password in green text? (`login: msfadmin` / `password: msfadmin`)?

## Step 4: Detection (Splunk)
Type `exit` to leave Kali. Go back to Splunk.
1.  Search for the port scan:
    ```splunk
    index=soc_lab src_ip=* dest_port=*
    ```
2.  Search for the brute force:
    ```splunk
    index=soc_lab "ftp" OR "fail"
    ```
    *(Note: Metasploitable logs are noisy, search for 'authentication failure').*
