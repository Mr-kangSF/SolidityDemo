// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Array {
    uint256[] public arr;
    uint256[] public arr2 = [1, 2, 3];

    uint256[10] public myFixedSizeArr;

    function get(uint256 i) public view returns (uint256) {
        return arr[i];
    }

    function getArr() public view returns (uint256[] memory) {
        return arr;
    }

    function push(uint256 i) public {
        // Append to array
        // This will increase the array length by 1.
        arr.push(i);
    }

    function pop() public {
        // Remove last element from array
        // This will decrease the array length by 1
        arr.pop();
    }

    function getLength() public view returns (uint256) {
        return arr.length;
    }

    function remove(uint256 index) public {
        // Delete does not change the array length.
        // It resets the value at index to it's default value,
        // in this case 0
        delete arr[index];
    }

    function examples() external pure {
        // create array in memory, only fixed size can be created
        uint256[] memory a = new uint256[](5);
    }
}
