contract C {
    uint8[1][] array1 = [[1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16]];
    int8[2][] array2 = [[1, 2], [3, 4], [5, 6]];
    uint16[][2] array3 = [[1, 2, 3],[4, 5, 6, 7, 8, 9, 10, 11, 12, 13]];
    uint8[][2][] array4 = [[[1, 2, 3], [4, 5]], [[6], [7]], [[8, 9, 10, 11], [12, 13, 14, 15, 16]]];

    function test1() public returns (uint8[1][] memory) {
        return array1;
    }

    function test2() public returns (int8[2][] memory) {
        return array2;
    }

    function test3() public returns (uint16[][2] memory) {
        return array3;
    }

    function test4() public returns (uint8[][2][] memory) {
        return array4;
    }

}

// ====
// compileViaYul: also
// ----
// test1() -> 0x20, 0x10, 0x01, 0x02, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0x10
// test2() -> 0x20, 0x03, 0x01, 0x02, 3, 4, 5, 6
// test3() -> 0x20, 0x40, 0xc0, 0x03, 1, 2, 3, 10, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13
// test4() -> 0x20, 0x03, 0x60, 0x0180, 0x0240, 0x40, 0xc0, 3, 1, 2, 3, 2, 4, 5, 0x40, 0x80, 1, 6, 1, 7, 0x40, 0xe0, 4, 8, 9, 10, 11, 5, 12, 13, 14, 15, 0x10
