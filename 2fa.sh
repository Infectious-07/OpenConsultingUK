#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Variables
GOOGLE_AUTH_CMD="/usr/bin/google-authenticator"

# Function to ask user for username and password
ask_username_password() {
  echo 'Please enter a username: '
  read USERNAME
  echo 'Please enter a password: '
  read PASSWORD
}

# Function to create a new user and set the password
create_user() {
  # Create the new user
  useradd -m "$USERNAME"
  
  # Set the user's password
  echo "$USERNAME:$PASSWORD" | chpasswd
  
  echo "User '$USERNAME' created with password '$PASSWORD'"
}

# Function to setup Google Authenticator
setup_google_authenticator() {
  # Switch to the user's account and run google-authenticator with specified options
  su - "$USERNAME" -c "$GOOGLE_AUTH_CMD -t -f -d -w 3 -r 3 -R 30"

  echo "Google Authenticator setup for user '$USERNAME' with the specified settings"
}

# Check if Google Authenticator is installed
if [ ! -x "$GOOGLE_AUTH_CMD" ]; then
  echo "Google Authenticator is not installed. Please install it using your package manager."
  exit 1
fi

# Generate the next available username
generate_username

# Create user and setup Google Authenticator
create_user
setup_google_authenticator

echo "User creation and Google Authenticator setup complete."
