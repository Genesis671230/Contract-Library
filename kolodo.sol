// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Kaleidoken is ERC721, Ownable {

    uint public constant PRICE = 0.000001 ether;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("MyToken", "MTK") {}

      function _baseURI() internal pure override returns (string memory) {
        return "ipfs://<--Your Piniata IPFS JSON Folder CID-->/";
    }

    function safeMint() public payable {
         require(msg.value >= PRICE, "Not enough ether to purchase NFTs.");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
    }

    function withdraw() public payable onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");

        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }

}





// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Gig {


    uint256 public _jobIds;

    enum ProjectStatus{ACTIVE,PENDING,COMPLETE}

    struct JobDetails{
        string title;
        uint256 deadline;
        uint256 price;
        bool applied;
        address hiredFreelancer;
        ProjectStatus status;
    }

  

    mapping(uint256 => JobDetails) public JobsRegistry;
    mapping(address => bool) private whiteListFreelancer;


   
    function whitelistF() external {
        whiteListFreelancer[msg.sender] = true;
    }


    function PostJob(string memory _title,uint256 _deadline, uint256 _price) public payable {
        require(msg.value >= _price,"Insufficient Balance");
        _jobIds++;
        uint256 time = block.timestamp + (_deadline + 1 days);
        JobsRegistry[_jobIds] = JobDetails(_title,time,_price,false,address(0x0),ProjectStatus.ACTIVE);

    }

    function applyForJob(uint256 _jobid) external {
        require( whiteListFreelancer[msg.sender] == true,"Only whitelisted freelancers can apply");
        require(JobsRegistry[_jobid].status == ProjectStatus.ACTIVE,"The Job is not active");
        JobsRegistry[_jobid].applied = true;        
        JobsRegistry[_jobid].hiredFreelancer = msg.sender;
        JobsRegistry[_jobid].status = ProjectStatus.PENDING;
    }

    function completeJob(uint256 _jobid) external {
        require(JobsRegistry[_jobid].hiredFreelancer == msg.sender,"Only active freelancer can withdraw funds");
        require(block.timestamp < JobsRegistry[_jobid].deadline,"Deadline is over");
        require(JobsRegistry[_jobid].status == ProjectStatus.PENDING,"The Job is not active");
        JobsRegistry[_jobid].status = ProjectStatus.COMPLETE;
        payable(msg.sender).transfer(JobsRegistry[_jobid].price);

    }

    function listJobs() external view  returns(JobDetails[] memory ){
        JobDetails[] memory list = new JobDetails[](_jobIds);
        for(uint256 i = 1;i<=_jobIds;i++ ){
            list[i - 1] = JobsRegistry[i];
        }
        return list;
    }
}
