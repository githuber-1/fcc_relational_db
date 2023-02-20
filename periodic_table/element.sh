PSQL="psql --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# Check if no input
if [[ ! $1 ]]
then
  # exit
  echo "Please provide an element as an argument."
else
  # if input is a number, then query atomic_number for all
  if [[ $1 =~ ^[0-9]+$ ]] 
  then
    FORMATTED_ATOMIC_NUMBER=$1
  else
  # if input is not a number and longer than 2 characters it is an element name
    if [[ ${#1} > 2 ]]
    then
      NAME=$1
      # get atomic_number
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name ILIKE '$NAME'")
      FORMATTED_ATOMIC_NUMBER=$(echo $ATOMIC_NUMBER | sed -E 's/^ *| *$//g')
    else
      # it is a symbol
      SYMBOL=$1
      # get atomic_number
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol ILIKE '$SYMBOL'")
      FORMATTED_ATOMIC_NUMBER=$(echo $ATOMIC_NUMBER | sed -E 's/^ *| *$//g')
    fi
  fi

  ELEMENT_RESULTS=$($PSQL "SELECT symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM properties LEFT JOIN types USING(type_id) LEFT JOIN elements USING(atomic_number) WHERE atomic_number=$FORMATTED_ATOMIC_NUMBER")
    # If doesn't exist
    if [[ -z $ELEMENT_RESULTS ]]
    then
      echo "I could not find that element in the database."
    else
      # if does exist
      echo $ELEMENT_RESULTS | while read SYMBOL BAR NAME BAR MASS BAR MELTING BAR BOILING BAR TYPE
      do
        echo -e "The element with atomic number $FORMATTED_ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
      done 
    fi
fi