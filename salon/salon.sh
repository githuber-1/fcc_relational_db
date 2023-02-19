#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c "
# get services
SERVICES=$($PSQL "SELECT service_id, name FROM services")

SELECT_SERVICE() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nHow can I help you today?"
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    if [[ $SERVICE_ID =~ ^[0-9]+$ ]] 
    then
      echo "$SERVICE_ID) $NAME"
    fi
  done
  read SERVICE_ID_SELECTED
  # if service selection is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send to service selection menu
    SELECT_SERVICE "That is an invalid service"
  else
    # get service
    SERVICE_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    echo $SERVICE_RESULT
    # is not a service
    if [[ -z $SERVICE_RESULT ]] 
    then
      # send to service selection menu
      SELECT_SERVICE "That is an invalid service"
    else
      # get phone number
      echo -e "\nPlease enter your phone number:"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      # if customer does not exist
      if [[ -z $CUSTOMER_NAME ]]
      then
        # get name
        echo -e "\nWhat's your name?"
        read CUSTOMER_NAME

        # insert new customer
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi

      # get time
      echo -e "\nEnter a time for your service:"
      read SERVICE_TIME

      # get customer id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      # insert appt
      INSERT_APPT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed -r 's/^ *| *$//g')
      CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')
      echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
    fi
  fi 


  # if service is invalid
}

SELECT_SERVICE
