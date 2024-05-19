#!/bin/bash

# Function to install dependencies and setup Flask application
setup_flask_app() {
    # Install required packages
    sudo apt update
    sudo apt install -y python3-pip python3-venv nginx

    # Clone or copy your Flask application to the correct directory
    # Adjust this path accordingly if your application is located elsewhere
    sudo cp -r /path/to/your/flask/application /var/www/initia_status

    # Create and activate virtual environment
    cd /var/www/initia_status
    python3 -m venv venv
    source venv/bin/activate

    # Install Flask and other dependencies
    pip install flask

    # Deactivate virtual environment
    deactivate
}

# Function to configure Nginx
configure_nginx() {
    # Create Nginx configuration file
    sudo tee /etc/nginx/sites-available/initia_status > /dev/null <<EOF
server {
    listen 80;
    server_name $1; # Use the provided server IP address

    location / {
        include proxy_params;
        proxy_pass http://127.0.0.1:5000;
    }
}
EOF

    # Enable the site by creating a symbolic link
    sudo ln -s /etc/nginx/sites-available/initia_status /etc/nginx/sites-enabled/

    # Remove the default Nginx configuration
    sudo rm /etc/nginx/sites-enabled/default

    # Reload Nginx to apply changes
    sudo systemctl reload nginx
}

# Function to start Flask application as a background process
start_flask_app() {
    # Activate virtual environment
    source /var/www/initia_status/venv/bin/activate

    # Create HTML file with the status template
    sudo tee /var/www/initia_status/templates/status.html > /dev/null <<EOF
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
            statusDiv.innerHTML = \`
                <p><strong>Node Moniker:</strong> \${data.node_info.moniker}</p>
                <p><strong>Chain ID:</strong> \${data.node_info.network}</p>
                <p><strong>Latest Block Height:</strong> \${data.sync_info.latest_block_height}</p>
                <p><strong>Latest Block Time:</strong> \${new Date(data.sync_info.latest_block_time).toLocaleString()}</p>
                <p><strong>Catching Up:</strong> \${data.sync_info.catching_up}</p>
                <hr>
                <p><strong>Your Node Height:</strong> \${data.sync_info.latest_block_height}</p>
                <p><strong>Network Height:</strong> \${data.sync_info.latest_block_height}</p>
                <p><strong>Blocks Left:</strong> 0</p> <!-- Assuming blocks_left is always 0 based on your previous information -->
            \`;
        }

        fetchNodeStatus();
    </script>
</body>
</html>
EOF

    # Start Flask application
    nohup flask run --host=127.0.0.1 --port=5000 > /dev/null 2>&1 &

    # Deactivate virtual environment
    deactivate
}

# Main function
main() {
    # Check if server IP argument is provided
    if [ -z "$1" ]; then
        echo "Error: Server IP address not provided."
        exit 1
    fi

    # Setup Flask application
    setup_flask_app

    # Configure Nginx with provided server IP address
    configure_nginx "$1"

    # Start Flask application
    start_flask_app

    # Display status message
    echo "Initia Status Web App is now running. You can access it at http://$1"
}

# Execute main function with provided server IP address
main "$1"
