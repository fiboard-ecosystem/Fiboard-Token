// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Fiboard is ERC20 {
    uint8 private constant _decimals = 6;
    uint256 private constant TOTAL_SUPPLY = 10_000_000_000 * 10**_decimals;

    // Addresses
    address public constant PRIVATE_SALE = 0x75bFE29AA774AB1c50aA1586F5F72ed387f0C998;
    address public constant STRATEGIC_SALE = 0xB264cE0DE816772Aa42D86138D190a57Eee44c57;
    address public constant OPERATION = 0x510668C9e44ce72fd86f5Dd2A9501d24921cBfE4;
    address public constant ECOSYSTEM_DEV = 0x1B6505D3d4868E446f57Fa561fABCa0b8Bad61bd;
    address public constant KOLS_PARTNERSHIPS = 0xb4669f1c77BffFE45212Ddfc0D759D7bF1E5b20e;
    address public constant TEAM_ADVISORS = 0xf2E1A404B3aD8531b4B17f4B11aC4347C65C2A5D;
    address public constant STAKING_REWARDS = 0xCe2e33E270B618C8A4505387dC597cBD51eeb3b0;
    address public constant LIQUIDITY_RESERVE = 0x20Ff67b5a2C46324983E0ae5A58970A78e8161ec;
    address public constant MARKETING_COMMUNITY = 0x7Cc3cC838eB1a4A089E0928dB7aa63E211b33150;
    address public constant FACTORIES_DEV = 0x9c0ce199f99FA3c3358e614E8276b302bFCCBA19;
    address public constant PUBLIC_SALE = 0x45eAb3cda1960Bef80bE144db236CDb7558fdE83;

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
