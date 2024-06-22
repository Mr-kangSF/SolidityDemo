// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;

contract HelloWorld {
  string storeMsg;
  /**
   * @dev Prints Hello World string
   */
  function print() public pure returns (string memory) {
    return "Hello World!";
  }

  function set(string memory message) public {
    storeMsg = message;
  }

  function get() public view returns (string memory){
    return storeMsg;
  }
}
