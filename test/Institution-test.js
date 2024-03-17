const { assert, expect } = require("chai");
const { ethers } = require("hardhat");

describe("Institution Contract", function () {
  let mockOwner_acc,
    mockInstitute_acc,
    mockInvalid_acc,
    mockInstitute,
    mockInstitute_course,
    institution,
    certification;

  beforeEach(async function () {
    const accounts = await ethers.getSigners();
    mockOwner_acc = accounts[0];
    mockInstitute_acc = accounts[1];
    mockInvalid_acc = accounts[2];

    mockInstitute = {
      institute_name: "Heritage Institute of Technology",
      institute_acronym: "HITK",
      institute_link: "www.heritageit.edu",
    };

    mockInstitute_course = [
      {
        course_name: "Computer Science and Engineering",
        course_code: "CSE",
      },
      {
        course_name: "Electronics and Communication Engineering",
        course_code: "ECE",
      },
      {
        course_name: "Computer Science and Business Studies",
        course_code: "CSBS",
      },
    ];

    const Institution = await ethers.getContractFactory("Institution");
    institution = await Institution.deploy({
      from: mockOwner_acc,
    });

    institution_address = await institution.getAddress();

    const Certification = await ethers.getContractFactory("Certification");
    certification = await Certification.deploy(await institution.getAddress(), {
      from: mockOwner_acc,
    });
  });

  describe("Deployment of Institution Contract", () => {
    it("It has correct owner", async function () {
      const instituteContract_owner = await institution.owner();
      assert.equal(instituteContract_owner, mockOwner_acc.address);
    });
  });

  describe("Adding institute", () => {
    it("Only owner can add Institute, others cannot add", async function () {
      const attackerConnectedAccounts = await institution.connect(
        mockInvalid_acc
      );
      await expect(
        attackerConnectedAccounts.addInstitute(
          mockInstitute_acc.address,
          mockInstitute.institute_name,
          mockInstitute.institute_acronym,
          mockInstitute.institute_link,
          mockInstitute_course
        )
      ).to.be.revertedWithCustomError(attackerConnectedAccounts, "NotOwner");
    });

    it("Adds an institute with valid details", async function () {
      const receipt = await institution.addInstitute(
        mockInstitute_acc.address,
        mockInstitute.institute_name,
        mockInstitute.institute_acronym,
        mockInstitute.institute_link,
        mockInstitute_course,
        { from: mockOwner_acc }
      );

      const { events, logs } = await receipt.wait();

      // console.log(logs[0].fragment.name);
      // console.log(logs[0].args._instituteName);

      assert.equal(logs.length, 1);
      assert.equal(logs[0].fragment.name, "instituteAdded");
      assert.equal(logs[0].args._instituteName, mockInstitute.institute_name);
    });

    it("Fails if Institute already existed", async function () {
      // const institution2 = await Institution.new({ from: mockOwner_acc });
      const receipt = await institution.addInstitute(
        mockInstitute_acc.address,
        mockInstitute.institute_name,
        mockInstitute.institute_acronym,
        mockInstitute.institute_link,
        mockInstitute_course,
        { from: mockOwner_acc }
      );

      await expect(
        institution.addInstitute(
          mockInstitute_acc.address,
          mockInstitute.institute_name,
          mockInstitute.institute_acronym,
          mockInstitute.institute_link,
          mockInstitute_course,
          { from: mockOwner_acc }
        )
      ).to.be.revertedWith("Institute with token already exists");
    });

    it("Checks atleast one course is added or not", async function () {
      await expect(
        institution.addInstitute(
          mockInstitute_acc.address,
          mockInstitute.institute_name,
          mockInstitute.institute_acronym,
          mockInstitute.institute_link,
          [],
          { from: mockOwner_acc }
        )
      ).to.be.revertedWith("Atleast one course must be added");
    });
  });

  describe("Fetching Institute Data", () => {
    it("Only owner can request for Institute Data", async function () {
      const institute_data = await institution.getInstituteData(
        mockInstitute_acc.address
        // { from: await certification.getAddress() }
      );
      assert.equal(institute_data[0], mockInstitute.institute_name);
      assert.equal(institute_data[1], mockInstitute.institute_acronym);
      assert.equal(institute_data[2], mockInstitute.institute_link);

      const formattedInstituteCoursesData = institute_data[3].map((x) => {
        return { course_name: x.course_name };
      });
      assert.equal(
        JSON.stringify(formattedInstituteCoursesData),
        JSON.stringify(mockInstituteCourses),
        "the courses of the institute is incorrect"
      );
    });
  });
});
