// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Fiboard is ERC20 {
    uint8 private constant _decimals = 6;
    uint256 private constant TOTAL_SUPPLY = 10_000_000_000 * 10**_decimals;

    // Addresses
    address public constant PRIVATE_SALE = 0xd51d414a4f8d25b9Bd68474b3863E5f69E6e68aA;
    address public constant STRATEGIC_SALE = 0xE41Ec92f244Ea135E31Bb46820F645763d3d009D;
    address public constant OPERATION = 0x783A7dffC5956216895A40D732bB1fbbe8754961;
    address public constant ECOSYSTEM_DEV = 0x44490DD8064A031Cf6D3B45C10f2d82d53F254b9;
    address public constant KOLS_PARTNERSHIPS = 0x43D01407CaF638276319c35975183DCEC1a87F49;
    address public constant TEAM_ADVISORS = 0x48A2441bfB0315b1325960E8adB94e5C9Ae6aC37;
    address public constant STAKING_REWARDS = 0x4e88d3F06606135A85bE1E8946E8344Ee0D9Ac2C;
    address public constant LIQUIDITY_RESERVE = 0xEc7341c1366909478a26A0c012FdEE5FDe679F9e;
    address public constant MARKETING_COMMUNITY = 0x5B618b706665F3B483749f73d16584c153D95f17;
    address public constant FACTORIES_DEV = 0xE1C0886f63a6b4A45eee91Fefa0e08E89bFe568A;
    address public constant PUBLIC_SALE = 0xc07d3D54f6F972Ecd2A9a462cD5D31647d99Dd93;

    // MultiSig
    mapping(address => bool) public isMultiSigEnabled;
    mapping(address => mapping(address => bool)) public multiSigSigners;
    mapping(address => uint256) public multiSigRequiredSignatures;

    struct TransferRequest {
        address from;
        address to;
        uint256 amount;
        uint256 approvals;
        mapping(address => bool) approvedBy;
        bool executed;
    }

    mapping(uint256 => TransferRequest) public transferRequests;
    uint256 public requestCount;

    constructor() ERC20("Fiboard", "FBD") {
        _mint(PRIVATE_SALE, (TOTAL_SUPPLY * 3) / 100);
        _mint(STRATEGIC_SALE, (TOTAL_SUPPLY * 2) / 100);
        _mint(OPERATION, (TOTAL_SUPPLY * 6) / 100);
        _mint(ECOSYSTEM_DEV, (TOTAL_SUPPLY * 7) / 100);
        _mint(KOLS_PARTNERSHIPS, (TOTAL_SUPPLY * 10) / 100);
        _mint(TEAM_ADVISORS, (TOTAL_SUPPLY * 10) / 100);
        _mint(STAKING_REWARDS, (TOTAL_SUPPLY * 10) / 100);
        _mint(LIQUIDITY_RESERVE, (TOTAL_SUPPLY * 12) / 100);
        _mint(MARKETING_COMMUNITY, (TOTAL_SUPPLY * 12) / 100);
        _mint(FACTORIES_DEV, (TOTAL_SUPPLY * 13) / 100);
        _mint(PUBLIC_SALE, (TOTAL_SUPPLY * 15) / 100);
    }

    function decimals() public pure override returns (uint8) {
        return _decimals;
    }

    function enableMultiSig(address[] memory _signers, uint256 _required) external {
        require(!isMultiSigEnabled[msg.sender], "Already enabled");
        require(_signers.length >= _required, "Signers less than required");
        require(_signers.length > 1, "Signers less than 1");
        require(_required > 0, "At least 1 signer required");

        isMultiSigEnabled[msg.sender] = true;
        multiSigRequiredSignatures[msg.sender] = _required;

        for (uint256 i = 0; i < _signers.length; i++) {
            multiSigSigners[msg.sender][_signers[i]] = true;
        }
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(!isMultiSigEnabled[msg.sender], "MultiSig enabled address must use request/approve transfer");
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(!isMultiSigEnabled[sender], "MultiSig enabled address must use request/approve transfer");
        return super.transferFrom(sender, recipient, amount);
    }

    // Create transfer request
    function requestTransfer(address _to, uint256 _amount) external returns (uint256) {
        require(isMultiSigEnabled[msg.sender], "Sender not multisig-enabled");
        require(_to != address(0), "Invalid recipient");

        TransferRequest storage r = transferRequests[requestCount];
        r.from = msg.sender;
        r.to = _to;
        r.amount = _amount;

        requestCount++;
        return requestCount - 1;
    }

    // Approve transfer
    function approveTransfer(uint256 _requestId) external {
        TransferRequest storage r = transferRequests[_requestId];
        require(!r.executed, "Already executed");
        require(multiSigSigners[r.from][msg.sender], "Not an authorized signer");
        require(!r.approvedBy[msg.sender], "Already approved");

        r.approvals++;
        r.approvedBy[msg.sender] = true;

        if (r.approvals >= multiSigRequiredSignatures[r.from]) {
            r.executed = true;
            _transfer(r.from, r.to, r.amount);
        }
    }
}
