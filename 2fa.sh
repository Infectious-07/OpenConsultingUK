#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Variables
PASSWORD="TestPassword123!"  # Default test password
GOOGLE_AUTH_CMD="/usr/bin/google-authenticator"

# Function to generate the next available username
generate_username() {
  prefix="u"
  i=1

  while true; do
    # Format the username with leading zeros, e.g., u001, u002
    USERNAME=$(printf "%s%03d" "$prefix" "$i")

    # Check if the user already exists
    if ! id -u "$USERNAME" >/dev/null 2>&1; then
      break
    fi

    # Increment the number
    i=$((i + 1))
  done

  echo "Next available username: $USERNAME"
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
