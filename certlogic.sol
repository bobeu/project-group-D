pragma solidity ^0.6.1;

import "browser/500storage";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/access/Roles.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract Certificate is ConStorage, Ownable, Roles, SafeMath {
    
    using Roles for Roles.Role;//declaring using Role library
    using SafeMath for uint;
    //using Ownable for  
    
    Roles.Role admins; // holds Admins Roles
    Roles.Role owner; //Holds Owner Roles
    Roles.Role students; //holds the Roles for students 
    Roles.Role instructors;
    
    event studentAdded(bytes32 _fname, bytes32 indexed _lName,bytes32 _commendation, string msg_1);
    //event upgradeparticip(address _msgsender, uint _id, uint testScores);
    event adminAdded(address indexed _admin, uint _maxAdminIndex); //triggers when new admin added.
    event removeAdmin(address indexed, uint _maxAdminIndex); //triggers when admins is removed
    event adminLimitChangge(uint adminLimitChange); //triggers change in admins limit index
    event donateEth(address _sender, uint _value); 
    //event awardCertific(address _awardee, MemberState _names, uint _id);
    event adminRoleAdded(address indexed adminAlc);//fires when an admin role is added.
    event adminRoleRemoved(address indexed adminAlc);//fires when Owner removed admin role
    event adminRenounceRole(address indexed msgSender); //fires when admin renounces role
    event instructorRoleAdded(address indexed instructorAlc); //fires when instructor role is added
    event instructorRoleRemoved(address indexed instructorAlc);//fires when Owner removes an instructor from role
    event rateStudent(address indexed _address, uint _ratings);//fires when a student is rated
    event studentNamesChange(address indexed addr, bytes2 _newFName, bytes32_newLName); //when student's name (s) are changed

    event studentNameUpdated(bytes32 indexed _fname, bytes32 indexed _lname, bytes32 _newEmail); //when student's email is changed

    event donation(address indexed msg_sender, uint amount); //when donation to the contract address is made

    event newCommend(bytes32 studentEmail, string _newComment); //when a student receiives a commendation

    event adminListChange(uint maxAdmin); //emits when admin threshold ups or down

    // event studentNameUpdated(bytes32 indexed _fname, bytes32 indexed _lname, bytes32 _email);
    event StudentEmailUpdated(bytes32 _email, bytes32 _newEmail); //Fires off when student email is updated
    event AssignmentAdded(bytes32 _email, AssignmentStatus _taskStatus);//Assignment for student added.
    event AssignmentUpdated(bytes32 _email, uint _index); //We use this to watch when the status of assignment is updated by the admin or instructor 

    event reactivateAStudent(address _address, bytes32 name, string msg_1);//pops up when a student is deactivated

    event reactivateAnAdmin(address _address, bytes32 name, string msg_1);//pops up when admin is reactivated

    event deactivateAStudent(bytes32 indexed _fname, bytes32 indexed _lname, bytes32 _email, string msg_2); //pops up when a student is deactivated
    event deactivateAnAdmin(address indexed _address, bytes32 name, string msg_2); //pops up when admin is deactivated

    event certifiedStudent(uint indexed studentId, address indexed addr, Grade grade, Students _commendation); //while student is certified


    constructor(address _owner) public {
        owner = _owner;
        maxAdmin = 2;
    }
    //only owner can call certain function
    modifier onlyOwner {
        require(owner.has(msg.sender), "Not an owner account");
        _;
    }
    //only owner or admins can call certain function.
    modifier onlyOwnerOrAdmin() {
        require(owner.has(msg.sender) || admins.has(msg.sender), "Not an authorized account.");
        _;
    }
    modifier notEmptyAddress(address _addr) {
        require(addr != address(0), "ADDRESS CANNOT BE EMPTY.");
        _;
    }
    modifier onlyInstructorOrAdmin() {
        require(instructors.has(msg.sender) || admins.has(msg.sender), "Not an authorized account.");
        _;
    }
    modifier onlyOwnerInstructorOrAdmin() {
        require(instructors.has(msg.sender) || admins.has(msg.sender) || owner.has(msg.sender), "Not an authorized account.");
        _;
    }

    // modifier onlyNonOwnerAdmins(address _addr) {
    //     _;

    // }

    // modifier onlyNonExistentStudents(string memory _email) {
    //     _;
    // }

    modifier onlyValidStudents(address _addr) {
        require(isAStudent[_addr] == true);

        _;

    }

    // modifier notDeactivated() {
    //     _;

    // }

   
    function giveAdminRole(address alc) public onlyOwner returns(bool success) {
        return _giveAdminRole(alc) == 1;
    }
    function _giveAdminRole(address alc) internal {
        require(owner.has(msg.sender));
        return admins.add(alc);

        emit adminRoleAdded(alc);
    }

    function isAdmin(address alc) public view returns(bool) {
        return admins.has(alc);
    }
    function renounceAdmin(address alc) public returns(bool) {
        require(admins.has(alc), "Not An Admin Account.");
        _removeAdmin(msg.sender);
    }
    function _removeAdmin(address alc) internal {
        admins.remove(alc);

        emit adminRoleRemoved(alc);
    } 
    function remmoveAdminRole(address alc) public onlyOwner returns(bool success) {
        _removeAdmin(alc);
    }

    function addInstructorsRole(address alc) public onlyOwner returns(bool success) {
        _addInstructorRole(alc);
    }
    function _addInstructorRole(address alc) internal {
        require(owner.has(msg.sender) || admins,has(meg.sender), "Function reserved for special addresses.");
        return instructors.add(alc);

        emit instructorRoleAdded(alc);
    }
    function _removeInstructorRole(address alc) internal {
        require(owner.has(msg.sender) || admins,has(meg.sender), "Function reserved for special addresses.");
        instructors.remove(alc);

        emit instructorRoleRemoved(alc);
    } 
    function removeInstructorRole(address alc) public onlyOwner returns(bool success) {
        _removeAdmin(alc);
    }
    function isInstructor(address alc) public view returns(bool) {
        return instructors.has(alc);
    }
    // constructor(address _owner) public payable {
    //     _owner = msg.sender;
    //     isAdminList[msg.sender] = true;
    // }
    
    //add admin(list restricted to 2)
    function addAdmin(address _addr) public onlyOwner notEmptyAddress(_addr) returns(bool, string) {
        //adminCount[id] = adminId++;
        require(!(adminList.length > 2), "Can have only 2 Admins.");
        Admins storage _admin  = admins(_addr);
        //_admin.id = adminReverseMapping[adminId]++;
        _admin.isActivated = true;
        _admin.isAuthorised = true;
        if(_admin.id > 0) { //chech if the entry already exist
            return;
        }else { //add new entry
            adminList.push(_addr);
            uint adminListIndex = adminList.length - 1;
            _admin.id = adminListIndex + 1;   
        }
        return(true, msg_1);
        
        emit newAdmin(_address, _name, msg_1);
    }

    function checkinInstructor(address _addr, bytes32 storage _fname, bytes32 storage _lname) public onlyAdminOrOwner notEmptyAddress(_addr) returns(bool, string) {
        require(_addr != address(0), "ADDRESS CANNOT BE ZERO");
        instructorCount[_addr] = instructorIndex[id]++; 
        Instructors storage _instructor = instructors(_addr);
        _instructor.f_name = _fname;
        _instructor.l_name = _lname;

        if(_instructor.id > 0) { //chech if the entry already exist
            return;
        }else { //add new entry
            instructorList.push(_instructor);
        }
        
        return(true, msg_1);
        
        emit newAdmin(_address, _name, msg_1);    
    }

    function removeAdmin(address _addr) external onlyOwnerOrNonOwner {
        Admins storage admin = admins[addr];
        require(admin.id != 0, "CANNOT BE AN EMPTY ID");
        require(admin.id <= adminList.length, "ID DOES EXIST.");
        uint adminListIndex = admin.id - 1;
        uint lastId = adminList.length -1;
        admins[adminList[lastId]].id = adminListIndex + 1;
        adminList[adminListIndex] = adminList[lastId];
        keyList.length--;
        delete admins[_addr]; 
    }
    
    function changeAdminLimit() internal returns(uint) {
        if(maxAdmin > 2 || maxAdmin < 2)  {
            emit adminListChange(maxAdmin, maxAdmin);
        }
    }

    function _renounceOwnership() internal {
        owner = address(0);
    }

    function renounceOwnership(_renounceOwnership) external pure onlyOwner{
        if(_renounceOwnership()) {
            for(i = 0, i < adminList.length, i++) {
                while(i) {
                    uint rotate = add(now, 2419200);
                    if(rotate) {
                        address(0) = adminList[i];
                    }
                }continue;
            }return true;
        }
    }

    function transferOwership(address _addr) external onlyOwner {
        require(isAdmin[_addr] == true, "ONLY ADMIN ADDRESS IS ALLOWED");
        owner = _addr;
    }

    function checkIfAdmin(address _addr) public returns(bool) {
        return isAdmin[_addr];
    }

    function getAdminById(uint _id) external pure returns(address, uint, bool, bool) {
        return (adminReverseMapping[_id].address, adminReverseMapping[_id].isActivated, adminReverseMapping[_id].authorised);
    }
    
     //get number of admins in list
    function countAdmin() public view returns(uint) {
        return uint(adminList.length);
    }
    //returns number of students in a list
    function getNumberOfStudents() public view returns(uint) {
        return uint(studentList.length);
    }
    
    function getStudentByEmailIdOrAddr(bytes32 _email, uint _id) public view returns(bytes32, bytes32, bytes32, uint, bool;, uint, uint, uint, Grade, uint, string) {
        if(_email) {
            return (gsByEm[_email].f_Name, gsByEm[_email].l_Name, gsByEm[_email]._commendation, gsByEm[_email].assignmentIndex, gsByEm[_email].active, gsByEm[_email].assignmentCount, gsByEm[_email].id, gsByEm[_email].rating, gsByEm[_email].grade, gsByEml[_email].assignments, gsByEm[_email].githubLink);
        }else if(_id) {
            return(indexList[_id].f_Name, indexList[_id].l_Name, indexList[_id]._commendation, indexList[_id].assignmentIndex, indexList[_id].active, indexList[_id].assignmentCount, indexList[_id].email, indexList[_id].rating, indexList[_id].grade, indexList[_id].assignments, indexList[_id].githubLink);
        }
      
    }
    function sendReward(address _to, uint _amt) public returns(bool) {
        require(balances[msg.sender] > 0 && amount > 0.005 ether, "Balance Not Enough Or Amount Lower Than 0.005 ether.");
        uint amt = msg.value;
        balanceOf(msg.sender).sub(amt);
        balanceOf(_to).add(amount);
        
        emit donation(msg.sender, amount);
    }

    function rateStudent(address _addr, uint _id, uint _testScores, uint _assignmt) public onlyInstructorOrAdmin onlyValidStudent(address _addr) notEmptyAddress (_addr) returns(bool) {
      require(_addr == students[_addr], "THIS IS NOT A STUDENT ACCOUNT");
      _rateStudent(_addr, _id, _testScores, _assignmt);

      return true;
    }

    function rateStudent (address _addr, uint _id, uint _testScores, uint _assignmt) external onlyInstructorOrAdmin onlyValidStudent(address _addr) notEmptyAddress(_addr) returns(uint) {
        require(status == StudentStatus(1), "NOT A STUDENT OR STUDENT INACTIVE.")
        require(!(_testscores > 20) && (!_assignmt > 10) && (!_punctuality > 2), "Test, assignment, punctuality cannot be above : 20, 10, 2.");
        grades[addr][_id] = grading;
        uint testScores = _testscores;
        uint assignmt = _assignmt;
        uint _rating = students.rating;
        _rating = div(add(add(_testscores, _assignmt), _punctuality), 10);
        if(_rating >= 3) {
            rating = _rating;
            students.grade = Grades(2); 
        } else if(_rating < 3 && _rating > 1) {
            rating = _rating;
            students.grade = Grades(1);
        }else {
            rating = _rating;
            students.grade = Grades(0);
        }
        return(rating);
      }
        emit rateStudent(_addr, rating);
        
    }function gradeStudent(address _addr, uint _id, uint _testScores, uint _assignmt) external onlyInstructorOrAdmin onlyValidStudents(_addr) returns(uint) {
        _rateStudent(_addr, _id, _testScores, _assignmt);
        uint cumRating;
        cumRating = rating;
        if(cumRating  )
    }
    function donateEth(uint amount) public payable {
        require(balances[msg.sender] > 0 && amount > 0.005 ether, "Balance Not Enough Or Amount Lower Than 0.005 ether.");
        uint amount = msg.value;
        balanceOf[msg.sender].sub(amount);
        balanceOf(this).add(amount);
        
        emit donation(msg.sender, amount);
    }

    function withdrawEth(address _addr, uint _amount) external onlyOwnerOrNon {
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
        bytes32 storage _fName, 
        bytes32 storage _lName, 
        string callData _commendation, 
        uint _index, 
        bytes32 storage _email,  
        Grade _grade;
        bytes32 storage _gitLink,
        ) public onlyAdminsOrOwner notEmptyAddress(address _addr) returns(string) {
        studentCount[id] = studentId++;
        isAStudent[_addr] == false;
        Students memory _student = students[_addr];
        _student.f_Name = _fName;
        _student.l_Name = _lName;
        _student.commendation = _commendation
        _student.assignmentIndex = _index;
        _student.activated = true;
        _student.email = _email;
        _student.assignmentCount = 0; 
        _student.rating = 0;
        _student.grade = currentGrade;
        _student.assignments = taskStatus;
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
        
        
        return string(abi.encodePacked(_fname, id, "is activated"));

        emit newStudent(f_Name, l_Name, id);
    }

    function changeStudentName(address _addr, bytes32 _newFName, bytes32 _newLName) public onlyAdminOrOWner notEmptyAddress(_addr) returns(bool success) {
        require(_newFName != students.f_name && _newLName != students.l_name, "NAME CANNOT BE THE SAME")
        if(_newFName) {
            students[_addr].f_Name = _newFName;
            _newLName = students[addr].l_Name;
        } else if(__newLName) {
            students[_addr].l_Name = _newLName;
            _newFName = students[addr].f_Name;
        }else {
            students[_addr].f_Name = _newFName;
            students[_addr].l_Name = _newLName;
        }
        
        returns true;

        emit studentNamesChange(_addr, _newFName, _newLName);
    }

    function changeStudentEmail(address _addr, bytes32 _newEmail) public onlyOwnerOrAdmin onlyValidStudents(_addr) notEmptyAddress(_addr) returns(bool success) {
        students[addr].email = _newEmail; 
        return true;
    }


    function changeStudentCommendation(bytes32 _email, string callData _commendation) {
        onlyOwnerInstructorOrAdmin notEmptyAddress(_addr) returns(bool success) {
        commentList[_email].commendation = _commendation; 
        return true;

        emit newCommend(_email, _commendation);
    }

    function _calcAndFetchAssignmentIndex(address _addr, string callData _commendation) {
        onlyOwnerOrAdmin notEmptyAddress(_addr) returns(bool success) {
        students[addr].commendation = _commendation; 
        return true;
    }
    }

    function addAssignment(string callData _link) external onlyInstructorOrAdmin returns(bool) {
        assignmentIndex ++;
        Assignment aStatus;
        Assignment _assignment = assignmentCount[assignmentIndex];
        _assignment.link = _link;
        _assignment.status = AssignmentStatus(aStatus + 1);
        Assignment.push(_assignment);
        uint duration = add(now, 604800);
        if(duration) {
            Assignment.status = Assignment.mul(status, 0);
        }
        return true;
    }

    function updateAssignmentStatus(uint _index) external onlyInstructorOrAdmin {
        require(!(_index > 3), "STATUS THRESHOLD EXCEEDED")
        Assignment _assignment;
        _assignment.status = AssignmentStatus(_index);

    }

    function getAssignmentInfo(uint _assignmentIndx) public returns(string, AssignmentStatus) {
        return (assignmentCount[_assignmentIndx].link, assignmentCount[_assignmentIndx].status);

    // }


    //reactivate student
    function reActivateStudent(address _addr) public onlyOwnerOrAdmin notEmptyAddress(_addr) returns(string) {
        Students storage _student = students[_addr];
        _student.activated = true;
        status = StudentStatus(status + 1);
        return msg_1;

        emit reactivateAstudent(_addr, msg_1);
    }
    //deactivate student
    function deactivateStudent(address _addr) public onlyAdminsOrOwner notEmptyAddress(_addr) returns(string) {
        require(isAStudent[addr] == true, "Student Is Already Deactivated.");
        Students storage _student = students[_addr];
        _student.activated = false;
        status = StudentStatus(mul(status, 0));
        return msg_2;

        emit deactivateAstudent(_addr, msg_2);
    }

    function getStudentGitLink(address _addr) external pure returns(string) {
        return(students[_addr].githubLink);
    }
    

    function activateAdmin(address _addr) public onlyOwnerOrNon returns(string) {
        require(isAdmin[_addr] == false, "Admin Is Active Already");
        isAdmin[_addr] = true;
        Admins storage _admin;
        _admin.isActivated = true;
        return msg_1;

        emit reactivateAnAdmin(_addr, msg_1);
    } 
    function deactivateAdmin(address _address) public onlyOwnerOrNon returns(string) {
        require(isAdmin[_addr] == true, "Admin Is Inactive Already");
        isAdmin[_addr] = false;
        Admins storage _admin;
        _admin.isActivated = false;
        return msg_2;

        emit deactivateAnAdmin(_addr, msg_2);
    }

    function createProjectTask(string storage _pLink) public onlyInstructorOrAdmin returns(bool success) {
      projectLink.push(_pLink);
      return true;
    }

    function submitProject(address _addr, string _projectLink) public notEmptyAddress(_addr) returns(bool success) {
        require(student.has(msg.sender), "ONLY STUDENT CAN SUBMIT PROJECT");
        students[addr].project = _projectLink;

        return true;
    
    }


    function awardCertificate(address _addr) external onlyOwnerOrAdmin onlyValidStudents(_addr) returns(byte32, uint, byte32, uint) {
      require(owner.has(msg.sender) || adminsList.has(msg.sender), "ONLY OWNER OR ADMIN IS ALLOWED");
      
      return createCertificate(_student, _id);
    }
    function certify(uint _studentId, address _addr) external onlyOwnerOrAdmin onlyValidStudents(_addr) returns(string) {
        return _generateCertificate(_studentId);

        emit certifiedStudent(studentId, addr, grade, commendation);
        
    }

    function _generateCertificate(uint _studentId) internal {
        return string(abi.encodePacked(studentCount[_studentId].f_Name,studentCount[_studentId].f_Name "has completed the said program having the following: ", studentCount[_studentId].commendation, studentCount[_studentId].email, studentCount[_studentId].grade, studentCount[_studentId].githubLink, studentCount[_studentId].projectLink, studentCount[_studentId].address);
    }

}
