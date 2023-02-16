#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE teams, games")
#year,round,winner,opponent,winner_goals,opponent_goals
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != 'year' ]]
  then

    # ~~ TEAMS TABLE ~~
    # determine if WINNER already in teams table
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    
    # if WINNER not found
    if [[ -z $WINNER_ID ]]
    then
      # insert WINNER into table
      INSERT_WINNER_RESULTS=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER_RESULTS = "INSERT 0 1" ]]
      then
        echo Inserted WINNER into teams, $WINNER
      fi
    fi

    # determine if OPPONENT already in teams table
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    
    # if WINNER not found
    if [[ -z $OPPONENT_ID ]]
    then
      # insert WINNER into table
      INSERT_OPPONENT_RESULTS=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT_RESULTS = "INSERT 0 1" ]]
      then
        echo Inserted OPPONENT into teams, $OPPONENT
      fi
    fi

  # ~~ GAMES TABLE ~~
  # get winner_id
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name ILIKE '$WINNER'")
  # get opponent_id
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name ILIKE '$OPPONENT'")
  # insert into table
  GAMES_INSERT_RESULTS=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")

  fi
done