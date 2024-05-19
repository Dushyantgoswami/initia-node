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

    # Start Flask application
    cd /var/www/initia_status
    nohup python3 app.py > /dev/null 2>&1 &

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
