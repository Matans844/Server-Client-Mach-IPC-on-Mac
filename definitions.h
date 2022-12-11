//
//  definitions.h
//  MachPortsServer
//
//  Created by matan on 08/12/2022.
//

#ifndef definitions_h
#define definitions_h

#define ERROR_CODE_TO_DO 1
#define MAX_SIZE_MSG 1024
#define DEFAULT_STRUCTURED_COMPONENT_SIZE 4
#define START_OF_COUNTER_COUNT 1
#define START_OF_INSTANCES_COUNT 0
#define WAITING_PERIOD_FOR_MESSAGE_SENDING 5.0

#define DEFAULT_SERVER_SERVICE_NAME @"org.matan.appdome_ipcp_project.server_num_0"
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

// TODO: A better communication protocol between client and server would include a pre-communication setup step in which the client asks the server to send the client the services it offers.
typedef NS_ENUM(NSInteger, eRequestedFunctionalityFromServer){
    serverNothing = 0,
    serverSaveData = 1,
    serverGetData = 2,
    serverRemoveData = 3,
    serverPrintStatus = 4,
};

typedef NS_ENUM(NSInteger, eUserChosenFunctionalityFromClient){
    clientNothing = 0,
    tellServerSaveData = 1,
    tellServerGetData = 2,
    tellServerRemoveData = 3,
    tellServerPrintStatus = 4,
    clientFindServer = 5,
    clientCheckData = 6,
    clientPrintStatus = 7,
    clientRemoveData = 8,
};

typedef NS_ENUM(NSInteger, eServerDependentClientFunctionality){
    toldServerSaveData = 1,
    toldServerGetData = 2,
    toldServerRemoveData = 3,
    toldServerToPrintStatus = 4,
};

typedef NS_ENUM(NSInteger, eRequestStatus){
    initRequest = 0,
    resultError = 1,
    resultNoError = 2,
};


#endif /* definitions_h */
