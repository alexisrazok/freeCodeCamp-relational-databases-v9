#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ELEMENT=$($PSQL "SELECT atomic_number, name, symbol FROM elements WHERE atomic_number = $1")
  else
    ELEMENT=$($PSQL "SELECT atomic_number, name, symbol FROM elements WHERE symbol = '$1' OR name = '$1'")
  fi

  if [[ -z $ELEMENT ]]
  then
    echo "I could not find that element in the database."
  else
    while IFS='|' read -r ATOMIC_NUMBER NAME SYMBOL
    do
      PROPERTIES=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM properties JOIN types USING(type_id) WHERE atomic_number = $ATOMIC_NUMBER")
      while IFS='|' read -r MASS MELTING BOILING TYPE
      do
        echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
      done <<< "$PROPERTIES"
    done <<< "$ELEMENT"
  fi
fi