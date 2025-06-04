// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract FBD_Public_Sale_MultiSigWallet {
    string public WalletName = "PUBLIC_SALE";
    address public wallet1 = 0xe66f998fE964604E88C30091137c987Cd9841aA8;
    address public wallet2 = 0x45eAb3cda1960Bef80bE144db236CDb7558fdE83;
    address public wallet3 = 0x7C71Fd77180EB2f581C0041b602b2A176DE131de;
    address[3] public signers = [wallet1,wallet2,wallet3];
    uint public txCount;

    struct Transaction {
        address to;
        uint256 value;
        address token; // address(0) for BNB
        bool executed;
        uint8 approvals;
        mapping(address => bool) approvedBy;
    }

    mapping(uint => Transaction) public transactions;

    modifier onlySigner() {
        require(isSigner(msg.sender), "Not authorized");
        _;
    }

    function isSigner(address _addr) internal view returns (bool) {
        return (_addr == signers[0] || _addr == signers[1] || _addr == signers[2]);
    }

    function submitTransaction(address _to, uint256 _value, address _token) external onlySigner returns (uint) {
        uint txId = txCount;
        Transaction storage txn = transactions[txId];
        txn.to = _to;
        txn.value = _value;
        txn.token = _token;
        txn.executed = false;
        txn.approvals = 0;
        txCount++;
        approveTransaction(txId); // auto-approve by sender
        return txId;
    }

    function approveTransaction(uint _txId) public onlySigner {
        Transaction storage txn = transactions[_txId];
        require(!txn.executed, "Already executed");
        require(!txn.approvedBy[msg.sender], "Already approved");

        txn.approvedBy[msg.sender] = true;
        txn.approvals++;

        if (txn.approvals == 3) {
            executeTransaction(_txId);
        }
    }

    function executeTransaction(uint _txId) internal {
        Transaction storage txn = transactions[_txId];
        require(!txn.executed, "Already executed");
        require(txn.approvals == 3, "Not enough approvals");

        txn.executed = true;

        if (txn.token == address(0)) {
            // BNB transfer
            (bool sent, ) = txn.to.call{value: txn.value}("");
            require(sent, "BNB transfer failed");
        } else {
            // ERC20 transfer
            require(IERC20(txn.token).transfer(txn.to, txn.value), "Token transfer failed");
        }
    }

    receive() external payable {} // to receive BNB
}
