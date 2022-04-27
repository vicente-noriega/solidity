pragma abicoder               v2;

contract C {
    function f() public pure returns(string[5] calldata) {
        return ["h", "e", "l", "l", "o"];
    }
}
// ----
// TypeError 6359: (122-147): Return argument type inline_array(literal_string "h", literal_string "e", literal_string "l", literal_string "l", literal_string "o") is not implicitly convertible to expected type (type of first return variable) string calldata[5] calldata.
