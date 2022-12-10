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
    indexOfError = 2,
    indexOfComponentArrangementFlag = 3,
};

typedef NS_ENUM(NSInteger, eMessageComponentArrangementType){
    notArrangedByStructuredArrangement = 0,
    arrangedByStructuredArrangement = 1,
};

typedef NS_ENUM(NSInteger, eRoleInCommunication){
    server = 0,
    client = 1,
};

typedef NS_ENUM(NSInteger, eRequestedFunctionalityFromServer){
    saveData = 0,
    getData = 1,
};


#endif /* definitions_h */
