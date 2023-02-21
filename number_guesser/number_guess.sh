#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

echo Enter your username:
read USERNAME

# get username
USER_ID=$($PSQL "SELECT user_id FROM game WHERE username='$USERNAME'")
GAMES=$($PSQL "SELECT games_played FROM game WHERE username='$USERNAME'")
BEST=$($PSQL "SELECT best_game FROM game WHERE username='$USERNAME'")
# if username doesn't exist
if [[ -z $USER_ID ]]
then
  echo Welcome, $USERNAME! It looks like this is your first time here.
  # add username to db
  ADD_USER=$($PSQL "INSERT INTO game(username, games_played, best_game) VALUES('$USERNAME', 0, 0)")
  USER_ID=$($PSQL "SELECT user_id FROM game WHERE username = '$USERNAME'")
else
  # print info about users
  FORMATTED_GAMES=$(echo $GAMES | sed 's/ |/"/')
  FORMATTED_BEST=$(echo $BEST | sed 's/ |/"/')
  echo Welcome back, $USERNAME! You have played $FORMATTED_GAMES games, and your best game took $FORMATTED_BEST guesses.
fi

SECRET_NUMBER=$(($RANDOM % 1000 + 1))
TRIES=0
echo "Guess the secret number between 1 and 1000:"
while [[ $GUESS != $SECRET_NUMBER ]]
do
  # get guess
  read GUESS
  # if guess isn't an integer
  #if [[ $GUESS =~ ^[0-9]+$ ]] 
  if ! [ "$GUESS" -eq "$GUESS" ]
  then
    echo "That is not an integer, guess again:"
  else
    # if guess is an integer
    TRIES=$((TRIES+1))
    # if guess is higher than number
    if [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    fi
    # if guess is lower than number
    if [[ $GUESS -lt $SECRET_NUMBER ]] 
    then
      echo "It's higher than that, guess again:"
    fi
  fi
done

# if guess is correct
# if new guess is less than previous best
if [[ $BEST -eq 0 ]] || [[ $TRIES -lt $BEST ]]
then
  # update best 
  UPDATE_BEST=$($PSQL "UPDATE game SET best_game=$TRIES WHERE user_id=$USER_ID") 
fi
# update number of games
# increment games
GAMES=$((GAMES+1))
UPDATE_GAMES=$($PSQL "UPDATE game SET games_played=$GAMES WHERE user_id=$USER_ID")
echo You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!