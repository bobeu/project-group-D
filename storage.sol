pragma solidity ^0.6.0;

contract ConStorage {

  enum MemberState {beginner, intermediate, certified}

  enum AssignmentStatus {Closed, Open, Completed, Cancelled}

  enum StudentStatus {inactive, active}

  enum Grades{none, Good, Great, Outstanding, Epic, Legendary}

  MemberState level = MemberState.beginner;
  StudentStatus status = StudentStatus.inactive;
  Grades currentGrade = Grades.none;

  uint grading = 0;
  uint ratings = 0;
  uint studentId = 1100;
  //uint adminId = 2200;
  string msg_1 = "activated";
  string msg_2 = "deactivated";
  uint16 maxAdmin;
  uint adminIndex; //for getting the number of admin
  uint instructorIndex = 0;
  uint assignmentCount; //for getting assignment.
  bool signed;

  struct Students{
      bytes32 f_Name;
      bytes32 l_Name;
      string commendation;
      uint assignmentIndex;
      bool activated;
      bytes32 email;
      uint id;
      uint8 rating;
      Grades grade;
      mapping(uint => Assignment) assignments;
      string githubLink;
      string project;
    }

  struct Admins{
      bytes32 name;
      uint id;
      bool isActivated;
      bool authorised;
    }

  struct Instructor {
      bytes32 f_name;
      bytes32 l_name;
      uint id;

  }

  struct Assignment{
      uint index;
      string link;
      AssignmentStatus status;
  }

  //address payable owner;

  Students[] public studentList;
  address[] public adminList;
  Instructor[] instructorList;
  Assignment[] public links;
  string[] public projectLink;


  mapping(address => Students) internal students; // maps student address to student struct
  
  mapping(address => Admins) public admins; //maps admin address to admin struct
  
  mapping(uint => mapping(address => Admins)) adminReverseMapping; //maps adminIndex of the admins to the address.]
  
  mapping(address => Instructor) public instructors; //maps instructor address to its struct
  
  mapping(uint => address) public instructorCount; //reversemap of instructors address to uint 
  
  mapping(uint => mapping(address => Students)) studentCount; //maps studentIndex of the admins to the address.
  
  mapping(uint => Students) indexList;  //maps student email to index
  
  mapping(bytes32 => Students) public commentList;
  
  // mapping(bytes32 => bool) public isAdminList;
  
  mapping(uint16 => Assignment) assignments;
  
  mapping(address => bool) public isAdmin;
  
  mapping(address => bool) public isAStudent;
  
  mapping(uint => Admins) adminCount;
  
  mapping(address => uint) public balanceOf; //tracks balances in addresses
  
  mapping(bytes32 => Students) gsByEm;
  
    // mapping(address => bool) public isMember;
    
  mapping(address => mapping(uint => Grades)) grades;
  
  mapping(address => MemberState)public studentLevel;
}
