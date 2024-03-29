/* BOISSON Romain - GUY Timothée
 *
 * Yokai No-Mori project - UFR-ST 2019
 *
 * libClient.h - client functions library header
 *
 */

#ifndef LIB_CLIENT_H
#define LIB_CLIENT_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <errno.h>

#include "../TCP/fonctionsTCP.h"
#include "../TCP/protocolYokai.h"
#include "protocoleIa.h"

/*  Function to send a game request to the server

    params:
      int sock : socket connected to the server
      TPartieReq req  : stucture send to the server
      TPartieRep *rep : structure used to read server's answer
  */
void sendPartieGetRep(int sock, TPartieReq req, TPartieRep *res);

/* Function to check recv's errors

  params:
    int err : recv's return value
    int sock : socket connected to the server
 */
void checkRecvrError(int err, int sock);

/* Function to check send's errors

  params:
    int err : send's return value
    int sock : socket connected to the server
 */
void checkSendError(int err, int sock );

/*  Function to send a move to the server, and process the answer

    params:
      int sock : socket connected to the server
      TCoupReq reqCoup  : request to send
      TCoupRep *repCoup : server's answer
 */
void sendCoupGetRep(int sock,TCoupReq reqCoup,TCoupRep *repCoup);

/*  Function to send a move to the server, and process the answer

    params:
      int sock : socket connected to the server
      TCoupRep repCoup : opponent's move
      bool *win : result of the game if it's ended
 */
void readEnnemyAction(int sock,TCoupIa *coupAdv,bool *win);

/*  Function to read an int from a Java application

    params:
      int sock : socket connected to the Java application

    return : the int value
  */
int receiveIntFromJava(int sock);

/*  Function to read a boolean from a Java application

    params:
      int sock : socket connected to the Java application

    return : the boolean value
  */
int receiveBoolFromJava(int sock);

/*  Function to read a move from the AI

    params:
      int sock : socket connected to the AI
      TCoupIa *res : the move
  */
void getCoupFromAI(int sock, TCoupIa *res);

/*  Function to send a move to the AI

    params:
      int sock : socket connected to the AI
      TCoupIa : the move to send
  */
void sendCoupToAI(int sock, TCoupIa coupIa);

/*  Function to convert an AI-shaped move to a server-shaped move

    params:
      TCoupIa *ai : the AI-shaped move
      TCoupReq *req ; the conversion result into a server-shaped move
      bool sens : the orientation in the game
      int nbPartie : the game number
  */
void convertAItoServer(TCoupIa *ai, TCoupReq *req, bool sens, int nbPartie);

/*  Function to convert a server-shaped move to an AI-shaped move

    params:
      TCoupIa *ai : the conversion result into an AI-shaped move
      TCoupReq *req ; the server-shaped move
      bool end : boolean representing the game's end
			int nbPartie : the game number
  */
void convertServerToAI(TCoupIa *ai, TCoupReq *req, bool end);

/*  Function to print an AI-shaped move

    params:
      TCoupIa coup : the move to print
  */
void printStrikeIa(TCoupIa coup);

/*  Function to print a server-shaped move

    params:
      TCoupReq coup : the move to print
  */
void printStrikeServer(TCoupReq coup);

#endif
