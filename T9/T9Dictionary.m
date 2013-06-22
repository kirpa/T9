#import "T9Dictionary.h"
#import "T9TreeNode.h"

@implementation T9Dictionary

const int cTreeDepth = 4;
const int cMaxSearchResults = 3;

@synthesize dictionary = _dictionary;

#pragma mark Utility methods

- (BOOL) canUsePreviousPreffixFor:(NSString *) currentDigits
{
    if (!_prevoiusDigits)
        return NO;
    
    if ([currentDigits length] > [_prevoiusDigits length])
    {
        return [currentDigits hasPrefix:_prevoiusDigits];
    }
    else
    {
        return NO;
    }
    
}

- (int) getLastPossibleWordForCharacters:(const unichar *) characters atOffset:(int) offset from:(int) index
{
    return [_dictionary count] - 1;
    
//  TODO: optimize range end
    
    for (int i = index; i < [_dictionary count]; i++)
    {
        NSString *word = [_dictionary objectAtIndex:i];
        if ([word length] <= offset)
            return i;
        
        unichar charAtOffset = [word characterAtIndex:offset];
        BOOL match = NO;
        for (int j = 0; j < cMaxCharsForDigit; j++)
        {
            if (charAtOffset == characters[j])
            {
                match = YES;
                break;
            }
        }
        if (!match)
        {
            return i;
        }
    }
    return [_dictionary count] - 1;
}

- (int) getFirstWordForCharacters:(const unichar *) characters atOffset:(int) offset inRange:(int) start ending:(int) end
{
    for (int index = start; index <= end; index++)
    {
        NSString *word = [_dictionary objectAtIndex:index];
        if ([word length] <= offset)
            continue;
        unichar charAtOffset = [word characterAtIndex:offset];
        for (int i = 0; i < cMaxCharsForDigit; i++)
        {
            if (charAtOffset == characters[i])
            {
                return index;
            }
        }
    }
    
    return cUnsetIndex;
}

- (NSArray *) getMatchingWordsForDigits:(NSString *) wordStart inRangeStart:(int) start end:(int) end
{
    NSMutableArray *array = [NSMutableArray array];
    int preffixLastChar = [wordStart length] - 1;
    for (int i = start; i <= end; i++)
    {
        if ([array count] == cMaxSearchResults)
            break;
        
        NSString *word = [_dictionary objectAtIndex:i];
        int lastChar = [word length] - 1;
        int offset = 0;
        BOOL run = YES;
        while (run)
        {
            unichar charAtOffset = [word characterAtIndex:offset];
            const unichar *allowedChars = [T9TreeNode getCharsForDigit:[wordStart characterAtIndex:offset] - '0'];
            BOOL match = NO;
            for (int j = 0; j < cMaxCharsForDigit; j++)
            {
                if (charAtOffset == allowedChars[j])
                {
                    match = YES;
                    break;
                }
            }
            
            if (match && offset < lastChar && offset < preffixLastChar)
            {
                offset++;
            }
            else
            {
                run = NO;
            }
            
        }
        
        if (offset == preffixLastChar)
            [array addObject:word];
    }
    
    return array;
}

- (NSArray *) searchWordsStartingWith:(NSString *) wordStart withOffset:(int) offset fromIndex:(int) index
{
    NSLog(@"search digits, offset, index: %@, %d %d", wordStart, offset, index);
    if (offset >= [wordStart length])
        return nil;
    
    BOOL wordFound;
    const unichar *allowedChars = [T9TreeNode getCharsForDigit:[wordStart characterAtIndex:offset] - '0'];
    int rangeEnd = [self getLastPossibleWordForCharacters:allowedChars atOffset:offset from:index];
    while (offset < [wordStart length])
    {
        allowedChars = [T9TreeNode getCharsForDigit:[wordStart characterAtIndex:offset] - '0'];
        int wordOffset = [self getFirstWordForCharacters:allowedChars atOffset:offset inRange:index ending:rangeEnd];
        if (wordOffset != cUnsetIndex )
        {
            index = wordOffset;
            offset++;
            wordFound = YES;
        }
        else
        {
            wordFound = NO;
            break;
        }
    }
    
    if (wordFound)
    {
        _previousIndex = index;
        _prevoiusDigits = wordStart;
        return [self getMatchingWordsForDigits:wordStart inRangeStart:index end:rangeEnd];
    }
    else
        return nil;
}

- (NSArray *) wordsForDigits:(NSString *) digits
{
    int length = [digits length];
    T9TreeNode *node = _rootNode;
    int scannedDepth = 0;
    
    for (scannedDepth = 0; scannedDepth < length; scannedDepth++)
    {
        int digit = [digits characterAtIndex:scannedDepth] - '0';
        T9TreeNode *nextNode = [node subnodeForType:digit];
        if (nextNode)
        {
            node = nextNode;
        }
        else
        {
            break;
        }
    }
    
    if ((length > cTreeDepth && scannedDepth < cTreeDepth) || node == _rootNode)
    {
        // node not found, word does not exist in vocabulary
        NSLog(@"word is not found");
        return nil;
    }
    
    int startIndex = cUnsetIndex;
    for (int i = cMaxCharsForDigit - 1; i >= 0; i--)
        if (node.indices[i] != cUnsetIndex)
        {
            startIndex = node.indices[i];
            if ([self canUsePreviousPreffixFor:digits] &&
                startIndex < _previousIndex)
            {
                NSLog(@"can use prev");
                startIndex = _previousIndex;
            }
            else
            {
                NSLog(@"no use prev");
            }
        }
    
    if (startIndex == cUnsetIndex)
    {
        // debug check, shouldn't happen normally
        NSLog(@"Indices are unset for node: %@", node);
        return nil;
    }
    
    return [self searchWordsStartingWith:digits withOffset:scannedDepth - 1 fromIndex:startIndex];
}

- (T9TreeNode *) createNodeForChar:(unichar) character withIndex:(int) index
{
    NumberCharsType nextNodeType = [T9TreeNode getTypeForChar:character];
    T9TreeNode *result = [[T9TreeNode alloc] initWithType:nextNodeType];
    [result setIndex:index forCharacter:character];
    return result;
}

- (T9TreeNode *) getNodeForDigits:(NSString *) digits withIndex:(int) index
{
    T9TreeNode *node = _rootNode;
    for (int i = 0; i < [digits length]; i++)
    {
        unichar character = [digits characterAtIndex:i];
        NumberCharsType nextNodeType = [T9TreeNode getTypeForChar:character];
        T9TreeNode *newNode = [node subnodeForType:nextNodeType];
        if (!newNode)
        {
            newNode = [self createNodeForChar:character withIndex:index];
            [newNode setIndex:index forCharacter:character];
            [node addSubnode:newNode forType:nextNodeType];
        }
        node = newNode;
    }
    
    return node;
}

- (void) buildIndexTreeForVocabulary
{
    T9TreeNode *currentNode = _rootNode = [[T9TreeNode alloc] initWithType:nctZero];
    int currentDepth = -1;
    NSString *currentPreffix;
    for (int i=0; i < [_dictionary count]; i++)
    {
        NSString *word = [_dictionary objectAtIndex:i];
        int lastCharIndex = [word length] - 1;
        if (currentDepth < cTreeDepth - 1 && lastCharIndex > currentDepth)
        {
            // need to go deeper in index tree and create child for current node
            currentDepth++;
            while (currentDepth < cTreeDepth - 1 && lastCharIndex > currentDepth)
            {
                // might need to repeat it if the first word in new index range is even longer
                currentDepth++;
            }
            currentPreffix = [word substringToIndex:currentDepth + 1];
            currentNode = [self getNodeForDigits:currentPreffix withIndex:i];
            // skipping rest of the code
            continue;
        }
        else if (lastCharIndex < currentDepth)
        {
            // current word is shorter than index, going up a level or few levels
            while (lastCharIndex < currentDepth)
            {
                currentDepth--;
            }
            currentPreffix = [word substringToIndex:currentDepth + 1];
            currentNode = [self getNodeForDigits:currentPreffix withIndex:i];
        }
               
        // String length is ok and we're at maximum depth level for current word.
        // Checking if we've left current character bounds if not - do nothing, index is already saved before
        
        if (![word hasPrefix:currentPreffix])
        {
            // we've left current character bounds. Trying to save index for next character in current node
            currentPreffix = [word substringToIndex:currentDepth + 1];
            unichar character = [word characterAtIndex:currentDepth];
            if (![currentNode setIndex:i forCharacter:character])
            {
                // we've left current node bounds too. Need to create new node
                currentNode = [self getNodeForDigits:currentPreffix withIndex:i];
            }
        }
    }
}

- (void) readVocabulary
{
    // TODO: requires twice memory right now, should change it to line-by-line reading
    // NSString could be too slow, if so -  change to some other type of strings

    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"wordsEn" ofType:@"txt"];
    NSError *err;
    NSString *lines = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&err];
    if (err)
    {
        NSLog(@"Error reading vocabulary file: %@", err);
    }
    
    self.dictionary = [lines componentsSeparatedByString:@"\r\n"];
}

#pragma mark Object lifecycle

-(id) init
{
    if (self = [super init])
    {
        // 
        
//        [self readVocabulary];
    }
    
    return self;
}

- (void) dealloc
{
}

@end
