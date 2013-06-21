#import "T9TreeNode.h"

@implementation T9TreeNode

static const unichar unusedSlot = 'X';
static const unichar charTable[nctTotalNums][cMaxCharsForDigit] =
{
    {unusedSlot, unusedSlot, unusedSlot},
    {unusedSlot, unusedSlot, unusedSlot},
    {'a', 'b', 'c', unusedSlot},
    {'d', 'e', 'f', unusedSlot},
    {'g', 'h', 'i', unusedSlot},
    {'j', 'k', 'l', unusedSlot},
    {'m', 'n', 'o', unusedSlot},
    {'p', 'q', 'r', 's'},
    {'t', 'u', 'v', unusedSlot},
    {'w', 'x', 'y', 'z'}
};

static int instanceCount = 0;

#pragma mark Utility methods

+ (const unichar *) getCharsForDigit:(NumberCharsType) digit
{
    return charTable[digit];
}

+ (int) getInstanceCount
{
    return instanceCount;
}

+ (NumberCharsType) getTypeForChar:(unichar) character
{
    for (int i = nctTwo; i < nctTotalNums; i++)
        for (int j = 0; j < cMaxCharsForDigit; j++)
            if (charTable[i][j] == character)
                return i;
    
    NSLog(@"%@: no type detected, wrong character specified: %c", [self class], character);
    return nctZero;
}

#pragma mark Data storage methods

- (BOOL) setIndex:(int) index forCharacter:(unichar) character
{
    const unichar *table = charTable[_type];
    for (int i = 0; i < cMaxCharsForDigit; i++)
    {
        if (table[i] == character)
        {
            if (_indices[i] == cUnsetIndex)
                _indices[i] = index;
            return YES;
        }
    }
    return NO;
}

- (int *) indices
{
    return _indices;
}

#pragma mark Tree methods

- (void) addSubnode:(T9TreeNode *) node forType:(NumberCharsType) type
{
    _subnodes[type] = [node retain];
    node.parentNode = self;
}

- (T9TreeNode *) subnodeForType:(NumberCharsType) type
{
    if (type == nctZero || type == nctOne || type == nctTotalNums)
    {
        NSLog(@"Wrong subnode type requested: %d", type);
        return nil;
    }
    
    return _subnodes[type];
}

#pragma mark Object lifecycle

- (id) initWithType:(NumberCharsType) type
{
    if (self = [super init])
    {
        instanceCount++;
        _type = type;
        for (int i = 0; i < cMaxCharsForDigit; i++)
            _indices[i] = cUnsetIndex;
    }
    
    return self;
}

- (id) init
{
    NSLog(@"Wrong initializer for class: %@", [self class]);
    return nil;
}

- (void) dealloc
{
    instanceCount--;
    for (int i = 0; i < nctTotalNums; i++)
        [_subnodes[i] release];
    [super dealloc];
}

@end
