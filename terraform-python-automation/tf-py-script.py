import os

# Update package lists
os.system('sudo apt update')
print("Package lists updated.")

# Install Nginx
os.system('sudo apt install -y nginx')
print("Nginx installed.")

# Copy index.html (adjust paths as needed)
os.system('sudo cp /home/ubuntu/index.html /var/www/html/index.html')
print("Index page copied.")

# Start Nginx
os.system('sudo systemctl start nginx')
print("Nginx started and running.")

