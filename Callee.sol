// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Callee {
    event FunctionCalled(string);

    function foo() external payable {
        emit FunctionCalled("this is foo");
    }

    // 你可以注释掉 receive 函数来模拟它没有被定义的情况
    receive() external payable {
        emit FunctionCalled("this is receive");
    }

    // 你可以注释掉 fallback 函数来模拟它没有被定义的情况
    fallback() external payable {
        emit FunctionCalled("this is fallback");
    }
}

// 注意： 记得在部署的时候给 Caller 合约转账一些 Wei，比如 100
contract Caller {
    // 转账给外部合约需要知道外部合约的地址
    address payable callee;

    // 所有涉及转账相关的函数和变量都需要声明成payable
    constructor() payable {
        callee = payable(address(new Callee()));
    }

    // 通过调用transfer转账函数触发接收转账合约的receive函数
    function transferReceive() external {
        callee.transfer(1);
    }

    // 通过调用send转账函数触发接收转账合约的receive函数
    function sendReveive() external {
        bool success = callee.send(1);
        require(success, "Fail to send Ether");
    }

    // 通过调用call转账函数触发接收转账合约的receive函数
    // 注意receive函数只有在纯转账的情况下才会被调用
    function callReceive() external {
        (bool success, bytes memory data) = callee.call{value: 1}("");
        require(success, "Fail to send Ether");
    }

    // 触发foo函数
    function callFoo() external {
        (bool success, bytes memory data) = callee.call{value: 1}(
            abi.encodeWithSignature("foo()")
        );
        require(success, "Fail to send Ether");
    }

    // 触发fallback函数，因为funcNotExit() 在Callee没有定义
    function callFallBack() external {
        (bool success, bytes memory data) = callee.call{value: 1}(
            abi.encodeWithSignature("funcNotExit()")
        );
        require(success, "Fail to send Ether");
    }
}
