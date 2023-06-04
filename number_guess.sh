#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"


GAME() {

  # get username
  echo "Enter your username:"
  read USERNAME

  # check username
  USER_ID=$($PSQL "SELECT user_id from users WHERE username='$USERNAME'")

  # if user found
  if [[ $USER_ID ]]
  then
    # get info
    GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games INNER JOIN users USING(user_id) WHERE USERNAME='$USERNAME'")
    BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games INNER JOIN users  USING(user_id) WHERE USERNAME='$USERNAME'")

    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."

  # if user not found
  else
    # save user into database
    INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    USER_ID=$($PSQL "SELECT user_id from users WHERE username='$USERNAME'")

    echo "Welcome, $USERNAME! It looks like this is your first time here."
  fi

  # generate random number
  SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
  TRIES=0

	# get guess
	echo "Guess the secret number between 1 and 1000:"
	read GUESS

	while [[ $GUESS != $SECRET_NUMBER ]]
	do
		# check if input is integer
		if [[ ! $GUESS =~ ^[0-9]+$ ]]
		then
			echo "That is not an integer, guess again:"
			read GUESS
		else
			# increment number of guesses
			TRIES=$(($expr $TRIES + 1))

			# check if number is less than random number
			if [[ $GUESS -lt $SECRET_NUMBER ]]
			then
				echo "It's higher than that, guess again:"
				read GUESS
			# check if number is greater than random number
			elif [[ $GUESS -gt $SECRET_NUMBER ]]
			then
				echo "It's lower than that, guess again:"
				read GUESS
			fi
		fi
	done

	# check if guess is right
	if [[ $GUESS -eq $SECRET_NUMBER ]]
	then
		# increment number of guesses
		TRIES=$(($expr $TRIES + 1))

		# print and insert to the database
		echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
		INSERT_GAME=$($PSQL "INSERT INTO games(user_id,guesses) VALUES($USER_ID, $TRIES)")
	fi
}

GAME