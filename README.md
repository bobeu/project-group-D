# project-group-D
# 500DEV4ETH-groupD
This is a final project of the first set of participants in the 500 ethereum Developers in Nigeria. 

Introduction

The purpose of creating the Certification Smart Contract is to ensure that the students of the program are able to create a production ready smart contract that will then be itself used to assign them tasks, grade them and finally award them certification for the same.

The smart contract also enables the owner of the smart contract to add Admins that can then also grade the students of the program.

Features
The Following functionalities are needed in the smart contract:

Ability to define the owner of the smart contract
Ability to transfer the ownership of the smart contract
Ability to renounce the ownership of the smart contract
Ability to automatically add the owner as one of the admin of the smart contract
Ability to add / adjust the amount of admins of the smart contract by the owner
Ability to add admins to the smart contract by the current owner
Ability to remove admins of the smart contract by the current owner
Ability to add students by the admins of the smart contract
Ability to disabled added students by the admins of the smart contract
Ability to update email, name, commendation, grade, etc of the students by admins
Ability to add new assignments for valid students by admins
Ability to fetch Owner, Admins, Students and their Assignment Info
Ability to iterate Admins, Students and their Assignment Information

Requirements
The contract should be able to:

Have a way to loop through the number of Admins
Have a way to detect Admins
Have the ability to map a student by unique integer id
Reverse map the student email to the student profile
Have the ability to grade students as “Good, Great, Outstanding, Epic, Legendary”
Have the ability to assign assignment tasks as “Inactive, Pending, Completed, Cancelled”

Specifications
The following specifications are desired in the smart contract

Parent Contract (Inheritance) 
The contract requires some functions to be accessible only by the owner of the smart contract and thus it’s a requirement to inherit the Ownable.sol library of OpenZeppelin.
https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/ownership/Ownable.sol

Note: Ensure that the inheritance of openZepplin contract is also accounted for

Library Functions
The contract uses additions and subtractions in various functions, thus, it’s also a requirement to import and use the SafeMath library of OpenZeppelin. 
https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol

Note: The SafeMath library provided only deals with uint256 functions. You are also required to create a SafeMath library for uint16 functions as the contract requires addition and subtraction functionality for that variable as well. 

Recommended to create a SafeMath16 library out of the provided openZeppelin link and import that in the contract as well

Enums
The following enums are required:

Name
Values
grades
Good, Great, Outstanding, Epic, Legendary
assignmentStatus
Inactive, Pending, Completed, Cancelled

Structs
The following structs are required:

Name
Structure
Admin
Admin Struct handles the admin mapping of address as well as the id to which they are assigned to.

Name
Type
authorized
bool
To check if the admin is authorized or not
id
uint
To reverse map the id of the admin to the address of the admin 




Assignment
Assignment Struct handles the assignments given to the studens. The assignmentStatus enum is used to find out if the assignment is active or not and the associated status. 

Since all assignment will have their status as Inactive at first, it can also be used to determine the status of final project.

The mapping 0 of Assignment Struct for these reasons is reserved ie index 0 always points to the final project.

Name
Type
link
string
To store the github link of the assignment given
status
assignmentStatus (enum)
To store the assignment status for each assignment




Student
Certification of Students can be handled in a struct, proposed solution:
    We use mapping of uint to store id which is mapped to individual students, a 
    reverse function to map that id to student email id is also used to retrieve the student 
    using their email id.
    - firstName - using bytes32 to save space, handles 32 characters 
    - lastName - using bytes32 to save space, handles 32 characters
    - commendation - using bytes32 to save space, handles 32 characters
    - grade - using grades enum since grade is from 1 to 5, max range 256
    - assignmentIndex - using uint16 to handle it, max range 65536 | IMP: 0 is always reserved for Final Project
    - active - determines if the student has been deemed active or inactive by the admins 
    - email - is used to reverse map for a student and to display email as well
    - assigments - is a mapping of uint16 to struct Assignment

Tip: Learn Tight Packing in solidity: this is a good start: https://medium.com/coinmonks/gas-optimization-in-solidity-part-i-variables-9d5775e43dde

Name
Type
firstName
bytes32
To store first name of the student, translate string to bytes32 and vice-versa in frontend
lastName
bytes32
To store last name of the student, translate string to bytes32 and vice-versa in frontend
commendation
bytes32
To store commendation of the student, translate string to bytes32 and vice-versa in frontend
grade
grades (enum)
To store last name of the student, translate string to bytes32 and vice-versa in frontent
assignmentIndex
uint16
We assume that assignments count will never go above 65535
active
bool
To store if the student is active or not
email
string
Stores the email of the student to reverse map to the integer id of the student
assignments
mapping
Maps the assignmentIndex to the Assignment struct, is used to pull up the individual assignment of the student



Variables
The following variables are recommended to be used:


Name
Type
maxAdmins
integer
This is used in the constructor to initially set the number of admins and in the later function to increase or decrease the number of admins allowed
adminIndex
integer
This is used to mark the number of admins currently allocated in the smart contract, the mapping given below helps us in determining and displaying all the available admins as well
admins
mapping
This is the mapping between the address of the admins and the Admin struct. It is used to pull information about the admin including their integer id for reverse mapping and whether they are still authorized to carry out the functions or not
adminsReverseMapping
mapping
This is the mapping between the adminIndex of the admins and the address of the admin, it is used to find the address of the admin given their id, thereby helping us in pulling the struct of the admins
studentIndex
integer
This is used to store the number of students which then can be used to provide a loopable functionality to pull out all the information of the student
students
mapping
This is the mapping between the studentIndex of the students and the Student struct. The index is used to pull up the struct of individual student which contains their info and their assignments info. 
studentsReverseMapping
mapping
This is the mapping between email of the student and their studentIndex (or id). The purpose of this mapping is to pull up the information of the students by first finding the student id through this mapping and then using that id in the students mapping.

Events
The following events are recommended to be included in the smart contract:

Events
Purpose
AdminAdded
When an admin is added. Should emit admin address and the maximum admin index number.
AdminRemoved
When an admin is removed. Should emit admin address and the maximum admin index number.
AdminLimitChanged
When the limit of Admin is changed. Should emit the new admin limit number.
StudentAdded
When a student is added. Should emit email, first name, last name, commendation and the grade of the student. 

Note: Emit enum wherever applicable
StudentRemoved
When a student is removed. Should emit the email of the removed student
StudentNameUpdated
When the name of the student is updated, should emit the email and new first name and last name of the student
StudentCommendationUpdated
When the commendation of the student is updated. Should emit the email and the new commendation of the student
StudentGradeUpdated
When the grade of the student is updated. Should emit the email and the grade of the student
StudentEmailUpdated
When the email of the student is updated. Should emit the old and the new email of the student
AssignmentAdded
When an assignment is added for a particular student. Should emit the student email, link of the assignment, the status of the assignment, the assignment index at which the assignment is at for the student.
AssignmentUpdated
When an assignment is updated. Should emit the email of the student, the assignment index at which the assignment is at for the student and the new status of the assignment.
 
Modifiers
The following modifiers is recommended to ensure proper restrictions on the smart contract functions:

Modifiers
Purpose
onlyAdmins()
To check if the caller of the smart contract is an admin or not. Can use the admins mapping to achieve this. 
onlyNonOwnerAdmins(address _addr)
Since owner is also an admin, this modifier checks if the address passed into it belongs to an admin which is not an owner. Can use the admins mapping to achieve this along with the owner() function of the Ownable.sol to achieve this.

For Reference: https://ethereum.stackexchange.com/questions/5946/can-solidity-function-modifiers-access-function-arguments
onlyPermissibleAdminLimit()
To check if the number of max admins is within the permissible admin limit.
onlyNonExistentStudents(string memory _email)
To check if the email given is not already mapped to an active student
onlyValidStudents(string memory _email)
To check if the email given is already mapped to an active student

Functions
The following functions should be present in the smart contract, The student should decide on the visibility of the functions and variables along with view and pure.

For Reference: https://solidity.readthedocs.io/en/v0.4.24/contracts.html
Constructor

Functions
Purpose
constructor
Set the maxAdmin limit (Default is 2)
Call the _addAdmin function (see below) to add the owner of the contract as an admin as well

Admin Related Functions

Functions
Purpose
addAdmin
Passes the address of the admin that needs to be added
Only called by the owner of the contract
Only called if the maximum number of admins are not exceeded
Calls _addAdmin function described below

_addAdmin
Passes the address of the admin that needs to be added
Checks if the address already exists in the admins mapping and is authorized, if so, don’t do anything
Otherwise, create the Admin struct and assign it to admins mapping
Also map the address of the admin in the reverseAdminMapping variable
Finally, use safeMath to increase the adminIndex (so that the next admin doesn’t overwrite the previous one)
Emit using the proper event

removeAdmin
Passes the address of the admin that needs to be removed
Only called by the owner of the contract
Only called if the address passed is not the owner’s
Calls _removeAdmin function described below

_removeAdmin
Passes the address of the admin that needs to be removed
Fail if the admin index is 1, since 1 admin is absolutely required, also failsafe for owner
Check if the address passed is authorized or not, don’t do anything if the address is not authorized (as per the admin struct)
We need to perform a neat trick over here to ensure that the looping functionality dictated by adminIndex remains intact
This means that we first find out the index (id) at which the address of points to in relation to the admins mapping
Then we overwrite the now to be deleted admin information with the last admin information
Then we delete the admins mapping of the address, delete the last adminIndex and subtract the adminIndex by 1
For Reference: https://medium.com/rayonprotocol/creating-a-smart-contract-having-iterable-mapping-9b117a461115
Finally emit the event

changeAdminLimit
Passes the new limit for the number of admins
Check if the new limit is greater than 1 and the new limit is greater than already added admins count
If so increase the max limit to the new limit
Finally emit the event

Overriding Ownable Functions
Since we introduced adding and deleting admins functionality in our smart contract which also involves the owner. 

This creates an issue of deleting their admin status (and adding new one) when an owner of the smart contract transfers the ownership of the contract to someone else or renounces the ownership (see https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/ownership/Ownable.sol).
To mitigate this problem, we override the following Ownable function to ensure that even when these methods are called, our contract still maintains the same rules as before.

For Reference: https://ethereum.stackexchange.com/questions/29127/use-of-function-overriding-in-solidity

Functions
Purpose
transferOwnership
Remove admin on the existing owner address
Add admin on the new owner address
Call the parent function (or super function) 
Note: You will need to be creative with the modifiers or how you code the functions described above to ensure proper functioning

renounceOwnership
Remove admin on the existing owner address
Call the parent function (or super function) 
Note: You will need to be creative with the modifiers or how you code the functions described above to ensure proper functioning

Students Related Functions

Functions
Purpose
addStudent
Passes first name, last name, commendation, grades enum and email of the student
Only called by the admins of the smart contract
Only called if the student doesn’t already exist
Create the Student struct on the current studentIndex, pass assignment index as 0 and set the student as active
Also map the student email to the studentIndex in the student reverse mapping
Increment the student index to ensure that the next student doesn’t override this one
Emit the event out

removeStudent
Passes the email of the student
Only called by the admins of the smart contract
Only called if the student already exists
Since this doesn’t remove the student, it just marks them as inactive, all we have to do is
Find the index (or id) of the student via the reverse mapping of email to the student index
Once found, set the active bool in that particular Student struct to false
Emit the event out

changeStudentName,
changeStudentCommendation,
changeStudentGrade,
changeStudentEmail
Pass the parameters as necessary for each of the function
Only called by the admin of the smart contract
Only called if the student already exists
Find the index (or id) of the student via the reverse mapping of email to the student index
Once found, set the necessary parameters
Emit the specific event out

Student’s Assignments Related Functions

Functions
Purpose
_calcAndFetchAssignmentIndex
Passes Student struct as storage and indicator (isFinalProject) to tell if the project is final project or just an assignment
Calculates and returns the index of the assignment for that particular student based on the following conditions
If it is the final project then as per requirements assignmentIndex 0 is reserved for it and hence that is returned
Else, it is a new assignment which means that we pull the assignmentIndex of the particular student, increment it using SafeMath and then return that value 

addAssignment
Passes student email, assignment link, assignment status and indicator (isFinalProject) telling if the assignment is the final project or not
Only called by the admin of the smart contract
Only called if the student already exists
Find the student id by the reverse mapping of the email
Using that id, find the specific student struct
Call _calcAndFetchAssignmentIndex to find the assignment index
Fill the assignment struct with the link and status of the assignment
Emit the event out

updateAssignmentStatus
Passes student email, assignment status and indicator (isFinalProject) telling if the assignment is the final project or not
Only called by the admin of the smart contract
Only called if the student already exists
Find the student id by the reverse mapping of the email
Using that id, find the specific student struct
Call _calcAndFetchAssignmentIndex to find the assignment index
Update the assignment status
Emit the event out

getAssignmentInfo
Since Assignment Struct is created within the Student Struct. We can’t have the visibility of it as public and thus we need to set a getter for it
Passes student email and the assignment id (index) for which the information needs to be pulled
Only called if the student already exists
Find the student id by the reverse mapping of the email
Using that id, find the specific student struct
Check if the assignment id is greater than or equal to 0 and also if the assignment id is within the permissible limit of assignmentIndex (ie: can’t pull assignment id 20 if the assignment index indicates that the student only has 10 assignments in it)
Return the assignment link and the assignment status

Bonus Points
Additional points for all the students who are able to:
Are able to use the proper visibility and pure / view functions
Create a donateEth() function in the contract that can deposit the specified ether into the contract with limits of 0.005 or above.
Create a withdrawEth() function that withdraws the donated ether in the smart contract to the owner address, can only be called by the owner

Helper Functions
Since we are using bytes32 in some cases to tightly pack the variables, here are the two helper functions to help debug the contract in remix or to verify the values:

    // STRING / BYTE CONVERSION
    /**
     * @dev Helper Function to convert string to bytes32 format
     * @param _source is the string which needs to be converted
     * @return result is the bytes32 representation of that string
     */
    function stringToBytes32(string memory _source) 
    public pure 
    returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(_source);
        string memory tempSource = _source;
        
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
    
        assembly {
            result := mload(add(tempSource, 32))
        }
    }
    
    /**
     * @dev Helper Function to convert bytes32 to string format
     * @param _x is the bytes32 format which needs to be converted
     * @return result is the string representation of that bytes32 string
     */
    function bytes32ToString(bytes32 _x) 
    public pure 
    returns (string memory result) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(_x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (uint j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        
        result = string(bytesStringTrimmed);
    }


