//
//  definitions.h
//  MachPortsServer
//
//  Created by matan on 08/12/2022.
//

#ifndef definitions_h
#define definitions_h

#define MAX_SIZE_MSG 1024;

typedef NS_ENUM(NSInteger,eMessageComponentCellType){
    data = 0,
    functionality = 1,
    error = 2,
    componentArrangementFlag = 3,
};

typedef NS_ENUM(NSInteger, eMessageComponentArrangementType){
    composite = 0,
    nonComposite = 1,
};


#endif /* definitions_h */
