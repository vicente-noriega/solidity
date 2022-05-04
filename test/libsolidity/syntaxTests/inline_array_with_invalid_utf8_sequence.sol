contract C { 
        function f1() external pure returns (string[2] memory rdatas) {
                rdatas = [hex'c0a80101'];
        }
}
// ----
// TypeError 7407: (111-126): Type inline_array(literal_string hex"c0a80101") is not implicitly convertible to expected type string memory[2] memory.
