// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract MultiSigWallet {
    // 当前合约的多个owner
    address[] public owners;
    // 记录当前owner是否已经添加
    mapping(address => bool) public isOwner;
    // 记录当前交易执行需要的最低owner确认数量
    uint256 public required;
    // 记录交易信息
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool exected; // 记录是否执行
    }
    Transaction[] public transactions;
    // 记录交易id被多个owner批准的情况
    mapping(uint256 => mapping(address => bool)) public approved;
    // 事件
    event Deposit(address indexed sender, uint256 amount);
    // 提交当前交易创建的情况
    event Submit(uint256 indexed txId);
    // 记录交易被批准的情况
    event Approve(address indexed owner, uint256 indexed txId);
    // 记录交易不被批准的情况
    event Revoke(address indexed owner, uint256 indexed txId);
    // 记录交易执行情况
    event Execute(uint256 indexed txId);

    // receive
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    // 函数修改器
    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }
    // 校验交易ID是否存在
    modifier txExists(uint256 _txId) {
        require(_txId < transactions.length, "tx doesn't exist");
        _;
    }
    // 校验当前交易ID是否批准执行
    modifier notApproved(uint256 _txId) {
        require(!approved[_txId][msg.sender], "tx already approved");
        _;
    }
    // 校验当前交易ID是否已经执行
    modifier notExecuted(uint256 _txId) {
        require(!transactions[_txId].exected, "tx is exected");
        _;
    }

    // 构造函数
    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "owner required");
        require(
            _required > 0 && _required <= _owners.length,
            "invalid required number of owners"
        );
        for (uint256 index = 0; index < _owners.length; index++) {
            address owner = _owners[index];
            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner is not unique"); // 如果重复会抛出错误
            isOwner[owner] = true;
            owners.push(owner);
        }
        required = _required;
    }

    // 获取余额
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // 提交交易数据
    function submit(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyOwner returns (uint256) {
        // 使用发出的交易数量值作为签名的凭据 ID
        transactions.push(
            Transaction({to: _to, value: _value, data: _data, exected: false})
        );
        emit Submit(transactions.length - 1);
        return transactions.length - 1;
    }

    // 批准当前交易
    function approv(uint256 _txId)
        external
        onlyOwner
        txExists(_txId)
        notApproved(_txId)
        notExecuted(_txId)
    {
        approved[_txId][msg.sender] = true;
        // 每次修改状态变量都需要抛出事件
        emit Approve(msg.sender, _txId);
    }

    // 执行当前交易
    function execute(uint256 _txId)
        external
        onlyOwner
        txExists(_txId)
        notExecuted(_txId)
    {
        // 足够数量的 approve 后，才允许真正执行
        require(getApprovalCount(_txId) >= required, "approvals < required");
        Transaction storage transaction = transactions[_txId];
        transaction.exected = true;
        (bool sucess, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(sucess, "tx failed");
        // 每次修改状态变量都需要抛出事件
        emit Execute(_txId);
    }

    // 获取当前交易id被多少个owner确认
    function getApprovalCount(uint256 _txId)
        public
        view
        returns (uint256 count)
    {
        for (uint256 index = 0; index < owners.length; index++) {
            if (approved[_txId][owners[index]]) {
                count += 1;
            }
        }
        return count;
    }

    // 将当前交易改为不被批准
    // 允许批准的交易，在没有真正执行前取消
    function revoke(uint256 _txId)
        external
        onlyOwner
        txExists(_txId)
        notExecuted(_txId)
    {
        require(approved[_txId][msg.sender], "tx not approved");
        approved[_txId][msg.sender] = false;
        // 每次修改状态变量都需要抛出事件
        emit Revoke(msg.sender, _txId);
    }
}
