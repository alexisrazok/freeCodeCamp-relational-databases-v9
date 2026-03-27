#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

START_GAME() {
  SECRET_NUMBER=$(( RANDOM % 10 + 1 ))
  NUMBER_OF_GUESSES=0
  USER_ID=$1
  CURRENT_GAMES=$2
  CURRENT_BEST=$3

  echo "Guess the secret number between 1 and 1000:"

  while true
  do
    read GUESS

    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
      continue
    fi

    NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1 ))

    if [[ $GUESS -eq $SECRET_NUMBER ]]
    then
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

      NEW_GAMES=$(( CURRENT_GAMES + 1 ))

      if [[ -z $CURRENT_BEST || $NUMBER_OF_GUESSES -lt $CURRENT_BEST ]]
      then
        UPDATE_USER=$($PSQL "UPDATE users SET games_played = $NEW_GAMES, best_game = $NUMBER_OF_GUESSES WHERE user_id = $USER_ID")
      else
        UPDATE_USER=$($PSQL "UPDATE users SET games_played = $NEW_GAMES WHERE user_id = $USER_ID")
      fi
      break

    elif [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
  done
}

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
  START_GAME $USER_ID 0 0
else
  IFS='|' read -r GAMES_PLAYED BEST_GAME <<< $($PSQL "SELECT games_played, best_game FROM users WHERE user_id = $USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  START_GAME $USER_ID $GAMES_PLAYED $BEST_GAME
fi