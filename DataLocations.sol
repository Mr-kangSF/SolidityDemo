// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract DataLocations {
    uint256[] public arr;
    // 不声明默认是private
    mapping(uint256 => address) map;

    struct MyStruct {
        uint256 foo;
    }

    mapping(uint256 => MyStruct) myStructs;

    function f() public {
        _f(arr, map, myStructs[1]);
    }

    // 此处_arr可以声明为storage是因为类型为引用类型
    function _f(
        uint256[] storage _arr,
        mapping(uint256 => address) storage _map,
        MyStruct storage _myStruct
    ) internal {
        // do something with storage variables
    }

    function g(uint256[] memory _arr) public returns (uint256[] memory) {
        // do something with memory array
    }

    // calldata用于存储函数参数和返回值，是只读的，不能被修改。它通常用于处理外部函数调用传入的数据
    function h(uint256[] calldata _arr) external {
        // 下面的会报错
        // _arr[0] = 1;
    }
}
