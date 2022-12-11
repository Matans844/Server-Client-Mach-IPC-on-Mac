# MachPortsServer

## Target
Implementing Client-Server Inter-Process Communication (IPC) using mach messaging for Mac.

### Server requirements:
1. Save data sent by a client.
2. Send data back to client.
3. Visible to other processes.
4. Cannot be blocked by a single client.
5. Communication through mach messaging.
6. Sent / Received dataa up to 1024 bytes.

### Client requirements
1. Find te server.
2. Send data to server.
3. Recieve data back from server.
4. Check that received data is the same as the data sent.

### Bonus
1. When a process dies, remove data from server that contains data from it.
2. Server can handle two 'save' messages sent to it from the same client.
3. Optimize storage for data when multiple clients send the same data.
4. Implement in Objective-C using OOP.

## Project Status
### Base requirements:
Server and client requirements are implemented in logic.
#### Bonus 1
Not implemented. Implementation plan was to subscribe the Kernel to mach kernel signals for a specific process termination. Even after getting the signal, the server should wait a certain amount a time, to see if client respawns. Reference for implementaion.
References:
1. [Observing Process Lifetimes Without Polling](https://www.btaz.com/mac-os-x/find-the-process-listening-to-port-on-mac-os-x/).
2. [Finding PID for process listening on a given mach port 1](https://stackoverflow.com/questions/9347665/which-pid-listens-on-a-given-mach-port). 
3. [Finding PID for process listening on a given mach port 2](https://www.btaz.com/mac-os-x/find-the-process-listening-to-port-on-mac-os-x/). 

#### Bonus 2
Not fully supported: 
* Done: The logic components have the functionality to identify this, and there's a class for Error Handling.
* Remaining: Definin error codes.
Refences:
1. [Best Practices for NSError domains for own project or app](https://stackoverflow.com/questions/3276127/best-practice-nserror-domains-and-codes-for-your-own-project-app).

#### Bonus 3
Supported. The Data Manager class supports this.

#### Bonus 4
The code is entirely written in Objective-C, with OOP manner.

### Other capabilities implemented in logic
#### General
The logic parts supports multi-client and multi-server communication.

#### Server side:
1. Server can remove saved data.
2. Server can print its description, with its contents.

### Client Side:
1. Client can remove saved data.
2. Client can tell server to remove data it sent.
3. Client can tell server to print the server status.
4. Client can print its own description, with its contents.

## Project Details
## Implementation Details
* Server is listening to messages from its port. It handles incoming messages via placing itself as delegate.
* Client is also delegate to its port. When it sends messages to the server (to complete server dependent functionality), it is blocking for a response.
* The client makes requests to the server. A user makes requests to the client
* Server should be started first. Then client.

### Structure
There are 4 project folders:
1. Referenc: Contains an IPC implementation from [Dutt's book](https://www.amazon.com/Interprocess-Communication-macOS-Apple-Methods/dp/1484270444).
2. Logic: Contains the logical components with which the required functioality is implemented.
3. UserInterface: This part should be used to expose the logical components to inputs, while allowing it to show outputs. It is currently not implemented.
4. UnitTests: Contains tests for different components of the code. It is currently outdated and matches an earlier version of the code.


### Status
Number  | Name | Details | Implementation | Tested
------------- | ------------- | -------------
1  | Logic | Contains classes and files that support the IPC required functionality. | [x] | [ ]
2  | UserInterface | Refers to the driver of the service, which is the client | [ ] | [ ]

### Tasks
1. Update testing to current code version.
2. Implement UI.
3. Test.
4. Bonus 2: Define error codes.
5. Test.
6. Bonus 1: The Data Manager class, which is property of both the client and server should be able to maintain its content by subscribing to events that happen to PIDs managing ports from which it received data.


## Logic content
The main bulk of the program sits in the Logic folder. It contains 3 types of information in the logic folder:
1. File: "definitions.h": helps with spreading enumerations and "define"s, including enumeration types.
2. Folder: Components: These suppor the required functionality. The Correspondent class, which is a super class from which both MachClient and MachServer inherit is composed from these components.
3. Folder: Participants: Here the Correspondent class is built. From which MachServer and MachClient inherit.
A description of logical classes by their folder is folloewed, as the folder describes the supported functionality. All classes are Cocoa classes.

### Folder 1: Components
#### Folder 1.1ErrorHandler
* Contained class: ErrorHandler.
* Usage: "Fill holes" in execution flow with a class method from a single source. 
# Implementation detail: Upon defining error codes, each hole will be occupied by a relevant error code.

#### Folder 1.2: EncodingHandler
* Contained class: EncodingHandler
* Usage: To insert data into the DataManager databases and optimize for duplicate data, we use hash encoding, which is implemented here.
* Implementation detail: The code uses the SHA256 hash function.

#### Folder 1.3: Database: 
* Contained class: NSMutableDictionaryWrapper
* Usage: The DataManager object is uses 3 NSMutableDictionary objects to store data. To supply more information about this usage (and to overwrite "describe" method), I created a wrapper for the mutalbe dictionary called NSMutableDictionaryWrapper. 
* Implementaion detail To support generics in the wrapped dictionaries, they are initiated independently from the wrapper, and then are passed by pointer (that is retained) to the Wrapper object.

#### Folder 1.4: PortHandler:
* Contained class: PortHandler
* Usage: Concentrating port related reuests in one place. This includes both querying a port (by service name) and initislize port (by name).

#### Folder 1.5: ValidationHandler:
* Contained class: ValidationHandler
* Usage: Messages sent in this project are encoded to an array so that they contain both data and metadata. ValidationHandlers check that messages are valid.
Implementatino details:
* Validitiy is determined by message size, message sendPort, and message components.
* The message components field contains an NSArray pointer to an NSArray object which is organized (or encoded) so that it passes the original data and 3 metadata.
* Encoding is based on desired arragement of information in the NSArray.
* Metadata about the data contains 3 enumerable types that describe requested functiality, request status, and array arragement.

#### Folder 1.6: DataManager
* Contained class: DataManager
* Usage: Manages data for participants in the communication: Saving, Getting, and removing data.
Implementation details:
1. There are 3 wrapped NSMutableDictionaries contained here.
2. Dictionary 1 translates key correspondent (or participant) port (for client this is the server port, and for server this is the client port) into a hash of the data.
3. Dictionary 2 translates the hash into the original message
4. Dictinoary 3 counts the number of references made by key participant port to a hash. Only when no port refers to the same hash, we can delete the hash from dictionaries 1 and 2.

##### Folder 1.7: MessageHandler
* Contained class: MessageHandler
* Usage: Dealing with messages. This includes extracting data (or metadata) from them, and creating them.

### Folder 2: Participants
### Folder 2.1: Correspondent
* Contained class: Correspondent
* Usage: Being super class for both client and server. 
* Implementation detail: There are many common behaviors between the client and server. For example, the client wants to save data going to the server port, by server port, while the server wanted to save data coming in from sender port. This symmetry allows for code reuse.

### Folder 2.2: Participants
Here both the MachClient an MachServer classes are implemented.

