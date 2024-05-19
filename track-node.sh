#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <your_server_ip>"
    exit 1
fi

server_ip="$1"

# Step 1: Install Nginx
sudo apt update
sudo apt install nginx -y

# Start Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Step 2: Create a Simple Web Interface
sudo mkdir -p /var/www/initia_status
sudo chown -R $USER:$USER /var/www/initia_status

cat <<EOF | sudo tee /var/www/initia_status/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Initia Node Status</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
        }
        h1 {
            color: #333;
        }
        .status {
            background-color: #f9f9f9;
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 8px;
            margin-top: 20px;
        }
        .status p {
            margin: 0;
        }
    </style>
</head>
<body>
    <h1>Initia Node Status</h1>
    <div class="status" id="status">
        Loading node status...
    </div>

    <script>
        async function fetchNodeStatus() {
            try {
                const response = await fetch('/status');
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                const data = await response.json();
                displayNodeStatus(data);
            } catch (error) {
                document.getElementById('status').innerHTML = '<p>Error loading node status</p>';
                console.error('There was a problem with the fetch operation:', error);
            }
        }



        function displayNodeStatus(data) {
            const statusDiv = document.getElementById('status');
            const networkHeight = parseInt(data.sync_info.latest_block_height);
            const nodeHeight = networkHeight; // Using network height for node height
            const blocksLeft = networkHeight - nodeHeight;

            statusDiv.innerHTML = \`
                <p><strong>Node Moniker:</strong> \${data.node_info.moniker}</p>
                <p><strong>Chain ID:</strong> \${data.node_info.network}</p>
                <p><strong>Latest Block Height:</strong> \${data.sync_info.latest_block_height}</p>
                <p><strong>Latest Block Time:</strong> \${new Date(data.sync_info.latest_block_time).toLocaleString()}</p>
                <p><strong>Catching Up:</strong> \${data.sync_info.catching_up}</p>
                <hr>
                <p><strong>Your Node Height:</strong> \${nodeHeight}</p>
                <p><strong>Network Height:</strong> \${networkHeight}</p>
                <p><strong>Blocks Left:</strong> \${blocksLeft}</p>
            \`;
        }



        fetchNodeStatus();
       </script>
</body>
</html>
EOF

# Step 3: Set Up a Proxy to Serve Node Status
sudo apt install python3-pip -y
pip3 install flask requests

cat <<EOF | sudo tee /var/www/initia_status/app.py
from flask import Flask, jsonify
import subprocess
import json
import psutil  # Import psutil for system information

app = Flask(__name__)

def get_node_status():
    try:
        # Get local node status
        local_status = subprocess.run(["initiad", "status"], capture_output=True, text=True)
        local_data = json.loads(local_status.stdout)

        # Get network status
        network_status = subprocess.run(["curl", "-s", "https://rpc-initia-testnet.trusted-point.com/status"], capture_output=True, text=True)
        network_data = json.loads(network_status.stdout)

        local_height = int(local_data['sync_info']['latest_block_height'])
        network_height = int(network_data['result']['sync_info']['latest_block_height'])
        blocks_left = network_height - local_height

        return {
            "node_info": local_data['node_info'],
            "sync_info": local_data['sync_info'],
            "network_sync_info": network_data['result']['sync_info'],
            "local_height": local_height,
            "network_height": network_height,
            "blocks_left": blocks_left,
        }
    except Exception as e:
        print("Error retrieving system information:", e)
        return None

@app.route('/status', methods=['GET'])
def status():
    data = get_node_status()
    return jsonify(data)


if __name__ == '__main__':
    app.run(host='0.0.0.0')

EOF

# Step 4: Configure Nginx to Proxy Requests to the Flask App
cat <<EOF | sudo tee /etc/nginx/sites-available/initia_status
server {
    listen 80;
    server_name $server_ip;

    location / {
        root /var/www/initia_status;
        index index.html;
    }

    location /status {
        proxy_pass http://localhost:5000/status;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/initia_status /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Step 5: Access Your Website
echo "Your Initia Node Status website is now accessible at http://$server_ip"

# Optional: Run Flask App as a Service
cat <<EOF | sudo tee /etc/systemd/system/initia_status.service
[Unit]
Description=Initia Status Web App
After=network.target

[Service]
User=root
WorkingDirectory=/var/www/initia_status
ExecStart=/usr/bin/python3 /var/www/initia_status/app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable initia_status
sudo systemctl start initia_status

echo "Initia Status Web App service is now running."
