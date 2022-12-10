//
//  definitions.h
//  MachPortsServer
//
//  Created by matan on 08/12/2022.
//

#ifndef definitions_h
#define definitions_h

#define MAX_SIZE_MSG 1024;
#define DEFAULT_STRUCTURED_COMPONENT_SIZE 4

#define SERVER_SERVICE_BASE_NAME @"org.matan.appdome_ipcp_project.server_num_"
#define CLIENT_SERVICE_BASE_NAME @"org.matan.appdome_ipcp_project.client_num_"

typedef NS_ENUM(NSInteger,eMessageComponentCellType){
    indexOfData = 0,
    indexOfRequestedFunctionality = 1,
    indexOfRequestResult = 2,
    indexOfComponentArrangementFlag = 3,
};

typedef NS_ENUM(NSInteger, eMessageComponentArrangementType){
    notArrangedByStructuredArrangement = 0,
    arrangedByStructuredArrangement = 1,
};

typedef NS_ENUM(NSInteger, eRoleInCommunication){
    serverSide = 0,
    clientSide = 1,
};

// A better communication protocol between client and server would include a pre-communication setup step in which the client asks the server to send the client the services it offers.
typedef NS_ENUM(NSInteger, eRequestedFunctionalityFromServer){
    saveData = 0,
    getData = 1,
    removeData = 2,
    printStatus = 3,
};

typedef NS_ENUM(NSInteger, eUserChosenFunctionalityFromClient){
    findServer = 0,
    tellServerSaveData = 1,
    tellServerGetData = 2,
    checkData = 3,
    printClientStatus = 4,
    printServerStatus = 5,
};

typedef NS_ENUM(NSInteger, eRequestStatus){
    initRequest = 0,
    resultError = 1,
    resultNoError = 2,
};


#endif /* definitions_h */
