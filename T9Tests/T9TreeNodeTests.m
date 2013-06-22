#import "T9TreeNodeTests.h"
#import "T9TreeNode.h"

@implementation T9TreeNodeTests

- (void)setUp
{
    [super setUp];
    _treeNode = [[T9TreeNode alloc] initWithType:nctZero];
}

- (void)tearDown
{
    _treeNode = nil;
    [super tearDown];
}

- (void) testDefaultIndices
{
    int *indices = _treeNode.indices;
    for (int i = 0; i < cMaxCharsForDigit; i++)
    {
        STAssertEquals(indices[i], cUnsetIndex, @"Default index should be unset");
    }
}

- (void) testEnums
{
    STAssertEquals(nctTwo, 2, @"NumberCharsType enum to integer conversion failed");
    STAssertEquals(nctThree, 3, @"NumberCharsType enum to integer conversion failed");
    STAssertEquals(nctFour, 4, @"NumberCharsType enum to integer conversion failed");
    STAssertEquals(nctFive, 5, @"NumberCharsType enum to integer conversion failed");
    STAssertEquals(nctSix, 6, @"NumberCharsType enum to integer conversion failed");
    STAssertEquals(nctSeven, 7, @"NumberCharsType enum to integer conversion failed");
    STAssertEquals(nctEight, 8, @"NumberCharsType enum to integer conversion failed");
    STAssertEquals(nctNine, 9, @"NumberCharsType enum to integer conversion failed");
}

- (void) testTypesForChars
{
    STAssertEquals([T9TreeNode getTypeForChar:'a'], nctTwo, @"Character to type conversion failed");
    STAssertEquals([T9TreeNode getTypeForChar:'d'], nctThree, @"Character to type conversion failed");
    STAssertEquals([T9TreeNode getTypeForChar:'i'], nctFour, @"Character to type conversion failed");
    STAssertEquals([T9TreeNode getTypeForChar:'j'], nctFive, @"Character to type conversion failed");
    STAssertEquals([T9TreeNode getTypeForChar:'n'], nctSix, @"Character to type conversion failed");
    STAssertEquals([T9TreeNode getTypeForChar:'r'], nctSeven, @"Character to type conversion failed");
    STAssertEquals([T9TreeNode getTypeForChar:'u'], nctEight, @"Character to type conversion failed");
    STAssertEquals([T9TreeNode getTypeForChar:'z'], nctNine, @"Character to type conversion failed");
}

@end