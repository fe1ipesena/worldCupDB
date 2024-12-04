#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Ler o arquivo games.csv e processar os dados
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Ignorar a linha de cabeçalho
  if [[ $YEAR != "year" ]]
  then
    # Inserir times únicos na tabela teams
    for TEAM in "$WINNER" "$OPPONENT"
    do
      # Verificar se o time já existe
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$TEAM'")
      
      # Se o time não existir, insira na tabela teams
      if [[ -z $TEAM_ID ]]
      then
        INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$TEAM')")
        if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
        then
          echo "Inserido time: $TEAM"
        fi
      fi
    done

    # Obter os IDs do vencedor e do oponente
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # Inserir os dados do jogo na tabela games
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserido jogo: $YEAR $ROUND ($WINNER vs $OPPONENT)"
    fi
  fi
done