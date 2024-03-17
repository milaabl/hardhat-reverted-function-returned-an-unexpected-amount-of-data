// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./Institution.sol";

error Institution__NotExist();

contract Certification {
    // State Variables
    address public owner;
    Institution public institution;

    // Mapping
    mapping(bytes32 => Certificate) public certificates;

    // Events
    event certificateGenerated(bytes32 _certificateID);
    event certificateRevoked(bytes32 _certificateID);

    // Modifier
    modifier checkInstitution() {
        if (institution.checkInstitutePermission(msg.sender) == false) {
            revert Institution__NotExist();
        }
        _;
    }

    constructor(Institution _institution) {
        owner = msg.sender;
        institution = _institution;
    }

    struct Certificate {
        // Individual Info
        string candidate_name;
        string course_name;
        string creation_date;
        // Institute Info
        string institute_name;
        string institute_acronym;
        string institute_link;
        // Revocation status
        bool revoked;
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

    // Generate Certificate
    function generateCertificate(
        string memory _id,
        string memory _candidate_name,
        uint256 _courseIndex,
        string memory _creationDate
    ) public checkInstitution {
        bytes32 bytes_id = stringToBytes32(_id);
        bytes memory tempEmptyStringNameTest = bytes(
            certificates[bytes_id].candidate_name
        );

        require(
            tempEmptyStringNameTest.length == 0,
            "Certificate Already Exist"
        );

        (
            string memory institute_name,
            string memory institute_acronym,
            string memory institute_link,
            Institution.Course[] memory _institute_course
        ) = institution.getInstituteData(msg.sender);
        require(
            _courseIndex >= 0 && _courseIndex < _institute_course.length,
            "Invalid Course Index"
        );
        string memory _course_name = _institute_course[_courseIndex]
            .course_name;
        bool revoked_status = false;
        certificates[bytes_id] = Certificate(
            _candidate_name,
            _course_name,
            _creationDate,
            institute_name,
            institute_acronym,
            institute_link,
            revoked_status
        );

        emit certificateGenerated(bytes_id);
    }

    function revokeCertificate(string memory _id) public checkInstitution {
        bytes32 bytes_id = stringToBytes32(_id);
        bytes memory tempEmptyStringTest = bytes(
            certificates[bytes_id].creation_date
        );

        require(tempEmptyStringTest.length > 0, "Certificate not Found");

        certificates[bytes_id].revoked = true;
        emit certificateRevoked(bytes_id);
    }
}
