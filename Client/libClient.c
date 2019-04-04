#include "libClient.h"

void checkRecvrError(int err,int sock){
    if(err <= 0){
        perror("(client) erreur sur la reception");
        shutdown(sock, SHUT_RDWR); close(sock);
        exit(-1);
    }

}

void checkSendError(int err,int sock ){
    if( err <= 0){
        perror("(client) erreur sur l'envoie");
        shutdown(sock, SHUT_RDWR); close(sock);
        exit(-2);
    }
}

void sendPartieGetRep(int sock, TPartieReq req, TPartieRep* res){
    int err;
    err = send(sock, &req, sizeof(TPartieReq), 0);
    checkSendError(err,sock);

    err = recv(sock, res, sizeof(TPartieRep), 0);
    checkRecvrError(err,sock);
    printf("Code : %d , valeur retourner : %s\n",res->err,res->nomAdvers);
}
