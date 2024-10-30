#!/bin/bash

# Function to display services
DISPLAY_SERVICES() {
  echo "Available services:"
  # Query to list services in the required format
  psql --username=freecodecamp --dbname=salon -t -c "SELECT service_id, name FROM services ORDER BY service_id;" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Function to get user input and make an appointment
MAKE_APPOINTMENT() {
  # Display services and prompt for service selection
  DISPLAY_SERVICES
  echo -e "\nEnter the number for the service you'd like:"
  read SERVICE_ID_SELECTED

  # Check if the selected service exists
  SERVICE_NAME=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;" | sed -e 's/^[ \t]*//')

  if [[ -z $SERVICE_NAME ]]; then
    # If service is invalid, show services again and prompt again
    echo -e "\nInvalid selection. Please choose a valid service."
    MAKE_APPOINTMENT
  else
    # Prompt for phone number
    echo -e "\nEnter your phone number:"
    read CUSTOMER_PHONE

    # Check if customer exists
    CUSTOMER_NAME=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';" | sed -e 's/^[ \t]*//')

    # If customer doesn't exist, prompt for their name and add to the database
    if [[ -z $CUSTOMER_NAME ]]; then
      echo -e "\nIt seems you are a new customer. Please enter your name:"
      read CUSTOMER_NAME
      psql --username=freecodecamp --dbname=salon -c "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');"
    fi

    # Get customer ID (whether they were already in the database or newly added)
    CUSTOMER_ID=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';" | sed -e 's/^[ \t]*//')

    # Prompt for appointment time
    echo -e "\nEnter the time you would like your $SERVICE_NAME appointment:"
    read SERVICE_TIME

    # Insert the appointment into the appointments table
    psql --username=freecodecamp --dbname=salon -c "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"

    # Confirm appointment with the user
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

# Run the function to start the appointment booking process
MAKE_APPOINTMENT
