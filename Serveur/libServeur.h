#ifndef LIB_SERVEUR_H
#define LIB_SERVEUR_H

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <errno.h>

#include "../TCP/fonctionsTCP.h"
#include "../TCP/protocolYokai.h"

// Structure use to regroup game's information
typedef struct {
  int gameNumber;
  int scorePlayer1;
  int scorePlayer2;
  char player1Name[T_NOM];
  char player2Name[T_NOM];
  int nbStrike;
}TPartie;

/* Fonction permettant de vérifié les érreurs RÉSEAU sur la fonction RECV
  params:
    int err : return's value of the verificated function
    int sock : socket connecté au serveur
    TPartie game :
    int idPlayer
 */
void checkRecvrError(int err,int checkingSock,int sock,TPartie game, int idPlayer);

/* Fonction permettant de vérifié les érreurs RÉSEAU sur la fonction SEND
  params:
    int err : valeur de retour de la fonction recv
    int sock : socket connecté au serveur
 */
void checkSendError(int err,int checkingSock,int sock,TPartie game, int playerId);

/*
  params:
    int sockP1 :
    int sockP2
  */
int sendAnswers(int sockP1,int sockP2,TPartieReq player1,TPartieReq player2,TPartie *game);

/*
  params:
    int sockP1 :
    int sockP2
  */
void endGame(int sock1,int sock2,TPartie game);

/*
  params:
    int sockP1 :
    int sockP2
  */
void prepareStrikeAnswer(int sock1,int sock2,bool validation, TCoupReq strike,TPropCoup strikeProp,TCoupRep *strikeAns);

/*
  params:
    int sockP1 :
    int sockP2
  */
void sendStrikeAnswer(int sock1,int sock2, TCoupReq strike,TCoupRep strikeAns,TPartie game,int playerId);

/*
  params:

  */
void printStrikeServer(TCoupReq coup);

#endif
