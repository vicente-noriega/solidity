contract C {
    function f() private pure {}
    function a() public {
        uint x;
        uint y;
        (x, y) = [f(), f()];
    }
}
// ----
// TypeError 5604: (122-125): Array component cannot be empty.
// TypeError 9656: (121-131): Unable to deduce nameable type for array elements. Try adding explicit type conversion for the first element.
