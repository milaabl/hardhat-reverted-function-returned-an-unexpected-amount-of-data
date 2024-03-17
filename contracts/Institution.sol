// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./Certification.sol";

error NotOwner();

contract Institution {
    // State Variables
    address public owner;

    // Mappings
    mapping(address => Institute) public institutes; // Institutes Mapping
    mapping(address => Course[]) public instituteCourses; // Courses Mapping

    // Events
    event instituteAdded(string _instituteName);

    // Modifier
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    struct Course {
        string course_name;
        // Other attributes can be added
    }

    struct Institute {
        string institute_name;
        string institute_acronym;
        string institute_link;
    }

    function stringToBytes32(
        string memory source
    ) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
        assembly {
            result := mload(add(source, 32))
        }
    }

    function addInstitute(
        address _address,
        string memory _institute_name,
        string memory _institute_acronym,
        string memory _institute_link,
        Course[] memory _institute_courses
    ) public onlyOwner {
        bytes memory tempEmptyStringNameTest = bytes(
            institutes[_address].institute_name
        );
        require(
            tempEmptyStringNameTest.length == 0,
            "Institute with token already exists"
        );
        require(
            _institute_courses.length > 0,
            "Atleast one course must be added"
        );
        institutes[_address] = Institute(
            _institute_name,
            _institute_acronym,
            _institute_link
        );
        for (uint256 i = 0; i < _institute_courses.length; i++) {
            instituteCourses[_address].push(_institute_courses[i]);
        }

        emit instituteAdded(_institute_name);
    }

    // Called by Institutions
    // function getInstituteData()
    //     public
    //     view
    //     returns (string memory, string memory, string memory, Course[] memory)
    // {
    //     Institute memory temp = institutes[msg.sender];
    //     bytes memory tempEmptyStringNameTest = bytes(temp.institute_name);
    //     require(
    //         tempEmptyStringNameTest.length > 0,
    //         "Institute account does not exist!"
    //     );
    //     return (
    //         temp.institute_name,
    //         temp.institute_acronym,
    //         temp.institute_link,
    //         instituteCourses[msg.sender]
    //     );
    // }

    // Called by Smart Contracts
    function getInstituteData(
        address _address
    )
        public
        view
        returns (string memory instituteName, string memory instituteAcronym, string memory instituteLink, Course[] memory courses)
    {
        require(
            Certification(msg.sender).owner() == owner,
            "Incorrect smart contract & authorizations!"
        );

        Institute memory temp = institutes[_address];
        bytes memory tempEmptyStringNameTest = bytes(temp.institute_name);
        require(
            tempEmptyStringNameTest.length > 0,
            "Institute does not exist!"
        );


        instituteName = temp.institute_name;
        instituteAcronym = temp.institute_acronym;
        instituteLink = temp.institute_link;
        courses = instituteCourses[_address];
    }

    function checkInstitutePermission(
        address _address
    ) public view returns (bool) {
        Institute memory temp = institutes[_address];
        bytes memory tempEmptyStringNameTest = bytes(temp.institute_name);
        if (tempEmptyStringNameTest.length > 0) {
            return true;
        } else {
            return false;
        }
    }
}
