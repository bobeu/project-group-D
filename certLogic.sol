pragma solidity ^0.6.0;

import "browser/certStorage.sol";
import "github/OpenZeppelin/openzeppelin-contracts/contracts/access/Roles.sol";
import "github/OpenZeppelin/openzeppelin-contracts/contracts/ownership/Ownable.sol";
import "github/OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol";

contract Certificate is ConStorage, Roles, Ownable, SafeMath {
    
    using Roles for Roles.Role;//declaring using Role library
    using SafeMath for uint256; //declaring using SafeMath library
      
    
    Roles.Role adminn; // holds Admins Roles
    Roles.Role owners; //Holds Owner Roles
    Roles.Role student; //holds the Roles for students 
    Roles.Role instructor;
    
    event newStudent(bytes32 _fName, bytes32 indexed _lName, string _gitLink);
    
    //event upgradeparticip(address _msgsender, uint _id, uint testScores);
    
    event newAdmin(address indexed _admin, bytes32 _name, string msg_1); //triggers when new admin added.
    
    event removeAdmin(address indexed, uint _maxAdminIndex); //triggers when admins is removed
    
    event adminLimitChangge(uint adminLimitChange); //triggers change in admins limit index
    
    //event awardCertific(address _awardee, MemberState _names, uint _id);
    
    event adminRoleAdded(address indexed adminAlc);//fires when an admin role is added.
    
    event adminRoleRemoved(address indexed adminAlc);//fires when Owner removed admin role
    
    event adminRenounceRole(address indexed msgSender); //fires when admin renounces role
    
    event newInstructor(address indexed _address, bytes32 _fname, bytes32 _lname);
    
    event instructorRoleAdded(address indexed instructorAlc); //fires when instructor role is added
    
    event instructorRoleRemoved(address indexed instructorAlc);//fires when Owner removes an instructor from role
    
    event ratedStudent(address indexed _addr, uint _rating);//fires when a student is rated
    
    event studentNamesChange(address indexed addr, bytes2 _newFName, bytes32 _newLName); //when student's name (s) are changed

    event studentNameUpdated(bytes32 indexed _fname, bytes32 indexed _lname, bytes32 _newEmail); //when student's email is changed

    event donation(address indexed msg_sender, uint amount); //when donation to the contract address is made

    event newCommend(bytes32 studentEmail, string _newComment); //when a student receiives a commendation

    event adminListChange(uint maxAdmin); //emits when admin threshold ups or down

    // event studentNameUpdated(bytes32 indexed _fname, bytes32 indexed _lname, bytes32 _email);
    
    event StudentEmailUpdated(bytes32 _email, bytes32 _newEmail); //Fires off when student email is updated
    
    event AssignmentAdded(bytes32 _email, AssignmentStatus _taskStatus);//Assignment for student added.
    
    event AssignmentUpdated(uint _index); //We use this to watch when the status of assignment is updated by the admin or instructor 

    event reactivateAstudent(address _addr, bytes32 name, string msg_1);//pops up when a student is deactivated

    event reactivateAnAdmin(address _address, bytes32 name, string msg_1);//pops up when admin is reactivated

    event deactivateAstudent(bytes32 indexed _fname, bytes32 indexed _lname, bytes32 _email, string msg_2); //pops up when a student is deactivated
    
    event deactivateAnAdmin(address indexed _address, bytes32 name, string msg_2); //pops up when admin is deactivated

    //event certifiedStudent(uint indexed f_Name, bytes32 email, Students _commendation); //while student is certified @dev note at emit student grade here. 
    //removed for testing purpose.
    


    // constructor() public {
    //     owner = msg.sender;
        
    //}
    //only owner can call certain function
    // modifier onlyOwner {
    //     require(owner.has(msg.sender), "Not an owner account");
    //     _;
    // }
    //only owner or admins can call certain function.
    
    modifier onlyOwnerOrAdmin() {
    require(owners.has(msg.sender) || adminn.has(msg.sender), "Not an authorized account.");
        _;
    }
    
    modifier notEmptyAddress(address _addr) {
        require(_addr != address(0), "ADDRESS CANNOT BE EMPTY.");
        _;
    }
    modifier onlyInstructorOrAdmin() {
        require(instructor.has(msg.sender) || adminn.has(msg.sender), "Not an authorized account.");
        _;
    }
    modifier onlyOwnerInstructorOrAdmin() {
        require(instructor.has(msg.sender) || adminn.has(msg.sender) || owners.has(msg.sender), "Not an authorized account.");
        _;
    }

    modifier onlyValidStudent(address _addr) {
        require(isAStudent[_addr] == true);

        _;

    }

   
    function giveAdminRole(address alc) public onlyOwner returns(bool success) {
        _giveAdminRole(alc);
        
        return true;
    }
    function _giveAdminRole(address alc) internal {
        require(owners.has(msg.sender));
        return adminn.add(alc);

        emit adminRoleAdded(alc);
    }

    function verifyAdmin(address alc) public view returns(bool) {
        return adminn.has(alc);
    }
    function renounceAdmin(address alc) public returns(bool) {
        require(adminn.has(alc), "Not An Admin Account.");
        _removeAdmin(msg.sender);
    }
    function _removeAdmin(address alc) internal {
        adminn.remove(alc);

        emit adminRoleRemoved(alc);
    } 
    function remmoveAdminRole(address alc) public onlyOwner returns(bool success) {
        _removeAdmin(alc);
    }

    function addInstructorsRole(address alc) public onlyOwner returns(bool success) {
        _addInstructorRole(alc);
    }
    function _addInstructorRole(address alc) internal {
        require(owners.has(msg.sender) || adminn.has(msg.sender), "Function reserved for special addresses.");
        return instructor.add(alc);

        emit instructorRoleAdded(alc);
    }
    function _removeInstructorRole(address alc) internal {
        require(owners.has(msg.sender) || adminn.has(msg.sender), "Function reserved for special addresses.");
        instructor.remove(alc);

        emit instructorRoleRemoved(alc);
    } 
    function removeInstructorRole(address alc) public onlyOwner returns(bool success) {
        _removeAdmin(alc);
    }
    function isInstructor(address alc) public view returns(bool) {
        return instructor.has(alc);
    }
    
    
    //add admin(list restricted to 2)
    function addAdmin(address _addr, bytes32 _name) public onlyOwner notEmptyAddress(_addr) returns(bool, string memory) {
        adminIndex++;
        require(!(adminList.length > 2), "Can have only 2 Admins.");
        Admins storage _admin  = admins[_addr];
        _admin.name = _name;
        _admin.id = adminIndex;
        _admin.isActivated = true;
        _admin.authorised = true;
        if(_admin.id > 0) { //check if the entry already exist
            revert();
        }else { //add new entry
            adminList.push(_addr);
            uint adminListIndex = adminList.length - 1;
            _admin.id = adminListIndex + 1;   
        }
        return(true, msg_1);
        
        emit newAdmin(_addr, _name, msg_1);
    }

    function checkinInstructor(address _addr, bytes32  _fname, bytes32 _lname) public onlyOwnerOrAdmin notEmptyAddress(_addr) returns(bool, string memory) {
        require(_addr != address(0), "ADDRESS CANNOT BE ZERO");
        instructorIndex++;
        Instructor storage _instructor = instructors[_addr];
        _instructor.f_name = _fname;
        _instructor.l_name = _lname;
        _instructor.id = instructorIndex;
        instructorList.push(_instructor);
        
        return(true, msg_1);
        
        emit newInstructor(_addr, _fname, _lname);    
    
    }

    function removeAdmins(address _addr) external onlyOwnerOrAdmin {
        Admins storage admin = admins[_addr];
        require(admin.id != 0, "CANNOT BE AN EMPTY ID");
        require(admin.id <= adminList.length, "ID DOES EXIST.");
        uint adminListIndex = admin.id - 1;
        uint lastId = adminList.length -1;
        admins[adminList[lastId]].id = adminListIndex + 1;
        adminList[adminListIndex] = adminList[lastId];
        adminList.length--;
        delete admins[_addr]; 
    }
    
    function changeAdminLimit() internal returns(uint) {
        if(maxAdmin > 2 || maxAdmin < 2)  {
            
            emit adminListChange(maxAdmin, maxAdmin);
        }
    }

    // function _renounceOwnership() internal { //@dev owner can renounce ownership, afterwards set to empty address but an internal
    // //function
    //     owner = address(0);
    // }

    function renounce() external onlyOwner{
        if(renounceOwnership()) {
            for (uint i = 0; i < adminList.length; i++) {
                while(i) {
                    uint rotate = add(now, 2419200);
                    if(rotate) {
                        address(0) = adminList[i];
                        adminList[i] = owner;
                    }
                }continue;
            }return true;
        }
    }

    function transferOwner(address _newOwner) external onlyOwnerOrAdmin {
        if(msg.sender == owner) {
            owner = _newOwner; 
        }else if(msg.sender != owner) {
            require(admins[msg.sender] == owner, "ONLY ADMIN ADDRESS IS ALLOWED");
            owner = _newOwner;
        }else {
            revert;
        }
        
        
    }

    function checkIfAdmin(address _addr) public returns(bool) {
        return isAdmin[_addr];
    }

    function getAdminById(uint _id) external pure returns(bytes32, bool, bool) {
        return (adminReverseMapping[_id].name, adminReverseMapping[_id].isActivated, adminReverseMapping[_id].authorised);
    }
    
     //get number of admins in list
    function countAdmin() public view returns(uint) {
        return uint(adminList.length);
    }
    //returns number of students in a list
    function getNumberOfStudents() public view returns(uint) {
        return uint(studentList.length);
    }
    
    function getStudentByEmailIdOrAddr(bytes32 _email, uint _id) public view returns(bytes32, bytes32, bytes32, uint, bool, uint, uint, uint, uint, uint, string memory) {
        if(_email) {
            return (gsByEm[_email].f_Name, gsByEm[_email].l_Name, gsByEm[_email]._commendation, gsByEm[_email].assignmentIndex, gsByEm[_email].active, gsByEm[_email].assignmentCount, gsByEm[_email].id, gsByEm[_email].rating, gsByEm[_email].grade, gsByEm[_email].assignments, gsByEm[_email].githubLink);
        }else if(_id) {
            return(indexList[_id].f_Name, indexList[_id].l_Name, indexList[_id]._commendation, indexList[_id].assignmentIndex, indexList[_id].active, indexList[_id].assignmentCount, indexList[_id].email, indexList[_id].rating, indexList[_id].grade, indexList[_id].assignments, indexList[_id].githubLink);
        }
      
    }
    function sendReward(address _to, uint _amt) public returns(bool) {
        require(balanceOf[msg.sender] > 0 && _amt > 0.005 ether, "Balance Not Enough Or Amount Lower Than 0.005 ether.");
        uint amt = msg.value;
        balanceOf(msg.sender).sub(_amt);
        balanceOf(_to).add(_amt);
        
        emit donation(msg.sender, _amt);
    }

    function _rateStudent (address _addr, uint _id, uint _testScores, uint _assignmt, uint _punctuality) external onlyInstructorOrAdmin onlyValidStudent(_addr) notEmptyAddress(_addr) returns(uint) {
        require(_addr == students[_addr] && status == StudentStatus(1), "THIS IS NOT A STUDENT ACCOUNT OR STUDENT INACTIVE.");
        require(!(_testScores > 20) && (!_assignmt > 10) && (!_punctuality > 2), "Test, assignment, punctuality cannot be above : 20, 10, 2.");
        grades[_addr][_id] = grading;
        uint _rating = students.rating;
        uint ratings = SafeMath.div(add(add(_testScores, _assignmt), _punctuality), 10);
        if(ratings >= 3) {
            _rating = ratings;
            students.grade = Grades(2); 
        } else if(ratings < 3 && ratings > 1) {
            _rating = ratings;
            students.grade = Grades(1);
        }else {
            _rating = ratings;
            students.grade = Grades(0);
        }
        return(_rating);
        
        emit ratedStudent(_addr, _rating);
        
        
    }
    // function gradeStudent(address _addr, uint _id, uint _testScores, uint _assignmt) external onlyInstructorOrAdmin onlyValidStudents(address) returns(uint) {
    //     _rateStudent(_addr, _id, _testScores, _assignmt);
    //     uint cumRating;
    //     cumRating = rating;
    //     if(cumRating)
    // }
    
    function donateEth(uint amount) public payable {
        require(balanceOf[msg.sender] > 0 && amount > 0.005 ether, "Balance Not Enough Or Amount Lower Than 0.005 ether.");
        amount = msg.value;
        balanceOf[msg.sender].sub(amount);
        balanceOf(this).add(amount);
        
        emit donation(msg.sender, amount);
    }

    function withdrawEth(address _addr, uint _amount) external onlyOwner {
        uint amount = msg.value;
        _addr.transfer(_amount);

    }
    // function () external payable{
    //     require(msg.value >= 0.5 ether, "Thank You, but you can only donate above 0.05 ether.");
    //     
    //     balanceOf[msg.sender] -= amount;
    // }

    //add student to list
    function addStudent( 
        address _addr,
        bytes32  _fName, 
        bytes32  _lName, 
        string memory _commendation, 
        uint _index, 
        bytes32 _email,  
        uint _grade,
        bytes32 _gitLink
        ) public onlyOwnerOrAdmin notEmptyAddress(_addr) returns(string memory) {
        studentCount[_addr].id = studentId++;
        isAStudent[_addr] == false;
        Students memory _student = students[_addr];
        _student.f_Name = _fName;
        _student.l_Name = _lName;
        _student.commendation = _commendation;
        _student.assignmentIndex = _index;
        _student.activated = true;
        _student.email = _email;
        _student.assignmentCount = 0; 
        _student.rating = 0;
        _student.grade = currentGrade;
        _student.assignments = AssignmentStatus.Closed;
        _student.githubLink = _gitLink;
        _student.project = " ";
        if(_student.email > 0) {
            return;
        }else {
            studentList.push(_student);
            level = MemberState(level);
            status = StudentStatus(1);
            isAStudent[_addr] == true;
        }
        
        
        return string(abi.encodePacked(_fName, _gitLink, "is activated"));

        emit newStudent(_fName, _lName, _gitLink);
    }

    function changeStudentName(address _addr, bytes32 _newFName, bytes32 _newLName) public onlyOwnerOrAdmin notEmptyAddress(_addr) returns(bool success) {
        require(_newFName != students.f_name && _newLName != students.l_name, "NAME CANNOT BE THE SAME");
        if(_newFName) {
            students[_addr].f_Name = _newFName;
            _newLName = students[_addr].l_Name;
        } else if(_newLName) {
            students[_addr].l_Name = _newLName;
            _newFName = students[_addr].f_Name;
        }else {
            students[_addr].f_Name = _newFName;
            students[_addr].l_Name = _newLName;
        }
        
        return true;

        emit studentNamesChange(_addr, _newFName, _newLName);
    }

    function changeStudentEmail(address _addr, bytes32 _newEmail) public onlyOwnerOrAdmin onlyValidStudent(_addr) notEmptyAddress(_addr) returns(bool success) {
        students[_addr].email = _newEmail; 
        return true;
    }


    function changeStudentCommendation(bytes32 _email, string calldata _newCommendation)external onlyOwnerInstructorOrAdmin returns(bool success) {
        commentList[_email].commendation = _newCommendation; 
        return true;

        emit newCommend(_email, _newCommendation);
    }

    function _calcAndFetchAssignmentIndex(address _addr) public onlyOwnerOrAdmin notEmptyAddress(_addr) returns(string memory) {
         
        return true;
    }

    function addAssignment(string calldata _link) external onlyInstructorOrAdmin returns(bool) {
        assignmentCount ++;
        AssignmentStatus stat = AssignmentStatus.Open;
        Assignment storage _assignment = assignments[assignmentCount];
        _assignment.link = _link;
        _assignment.index = assignmentCount;
        _assignment.status = stat;
        Assignment.push(_assignment);
        signed = true;
        
        uint _defaultDuration = 604800; //@dev setting default time for Assignment to return too close after 7 days
        uint duration = add(now, _defaultDuration);
        if(duration) {
            stat = Assignment.mul(status, 0);
            signed == false;
            return stat;
        }
        return true;
        
    }
    
    function updateAssignmentStatus(uint8 _index) public onlyOwnerInstructorOrAdmin returns(uint, uint, uint, bool) {
        require(links.length != 0, "ASSIGNMENT LIST CANNOT BE EMPTY");
        require(!(_index > 3), "STATUS THRESHOLD EXCEEDED");
        
        if(_index == 1) {
            AssignmentStatus stat = AssignmentStatus.Open;
            signed = true;
            return stat;
        }if(_index == 2) {
            AssignmentStatus stat = AssignmentStatus.Completed;
            signed = true;
            return stat;
        }else if(_index == 3) {
            AssignmentStatus stat = AssignmentStatus.Cancelled;
            signed == false;
            return stat;
        }else {
            stat = AssignmentStatus.Closed;
            return false;
        }
        emit StudentEmailUpdated(_index);
        return true;

    }
    //@params get assignment info
    function getAssignmentInfo(uint _assignmentIndx) public returns(string memory, AssignmentStatus) {
        return (assignmentCount[_assignmentIndx].link, assignmentCount[_assignmentIndx].status);

    }
    //@params get assignment info
    function getAssignmentInfo(uint _assignmentIndx) public returns(string memory, AssignmentStatus) {
        return (assignmentCount[_assignmentIndx].link, assignmentCount[_assignmentIndx].status);

    }


    //reactivate student
    function reActivateStudent(address _addr) public onlyOwnerOrAdmin notEmptyAddress(_addr) returns(string memory) {
        Students storage _student = students[_addr];
        _student.activated = true;
        status = StudentStatus(status + 1);
        return msg_1;

        emit reactivateAstudent(_addr, msg_1);
    }
    //deactivate student
    function deactivateStudent(address _addr) public onlyOwnerOrAdmin notEmptyAddress(_addr) returns(string memory) {
        require(isAStudent[_addr] == true, "Student Is Already Deactivated.");
        Students storage _student = students[_addr];
        _student.activated = false;
        status = StudentStatus(SafeMath.mul(status, 0));
        return msg_2;

        emit deactivateAstudent(_addr, msg_2);
    }

    function getStudentGitLink(address _addr) external pure returns(string memory) {
        return(students[_addr].githubLink);
    }
    

    function activateAdmin(address _addr) public onlyOwner returns(string memory) {
        require(isAdmin[_addr] == false, "Admin Is Active Already");
        isAdmin[_addr] = true;
        Admins storage _admin;
        _admin.isActivated = true;
        return msg_1;

        emit reactivateAnAdmin(_addr, msg_1);
    } 
    function deactivateAdmin(address _addr) public onlyOwner returns(string memory) {
        require(isAdmin[_addr] == true, "Admin Is Inactive Already");
        isAdmin[_addr] = false;
        Admins storage _admin;
        _admin.isActivated = false;
        return msg_2;

        emit deactivateAnAdmin(_addr, msg_2);
    }

    function submitProject(address _addr, string memory _projectLink) public notEmptyAddress(_addr) returns(bool success) {
        require(students.has(msg.sender), "ONLY STUDENT CAN SUBMIT PROJECT");
        students[_addr].project = _projectLink;
        projectLink.push(_projectLink);

        return true;
    
    }


    function certify( address _addr, uint _studentId) external onlyOwnerOrAdmin notEmptyAddress(_addr) onlyValidStudent(_addr) returns(bool success) {
      require(isAStudent[_addr] == true, "STUDENT IDENTIFICATION MISSING.");
      _generateCertificate(studentId);
      
      
      return true;
       
    }
    
    function _generateCertificate(uint _studentId) internal returns(bytes32, bytes32, string memory, bytes32, uint, string memory, string memory) {
        
        return(
            studentCount[_studentId].f_Name, studentCount[_studentId], 
            l_Name, studentCount[_studentId].commendation, 
            studentCount[_studentId].email, 
            studentCount[_studentId].grade, 
            studentCount[_studentId].githubLink, 
            studentCount[_studentId].projectLink);
        
    }
    
    
}
