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


#endif /* definitions_h */
