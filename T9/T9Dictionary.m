#import "T9Dictionary.h"
#import "T9TreeNode.h"

@implementation T9Dictionary

const int cTreeDepth = 4;
const int cMaxSearchResults = 3;

@synthesize dictionary = _dictionary;

#pragma mark Utility methods

- (int) getWordCountForCharacters:(const unichar *) characters atOffset:(int) offset fromIndex:(int) index
{
    int foundWords = 0;
    while (index < [_dictionary count])
    {
        NSString *word = [_dictionary objectAtIndex:index];
        if ([word length] <= offset)
            break;
        
        unichar charAtOffset = [word characterAtIndex:offset];
        BOOL matched = NO;
        for (int i = 0; i < cMaxCharsForDigit; i++)
        {
            if (charAtOffset == characters[i])
            {
                matched = YES;
                foundWords++;
                index++;
                break;
            }
        }
        if (!matched)
            break;
    }
    return foundWords;
}

- (NSArray *) searchWordsStartingWith:(NSString *) wordStart withOffset:(int) offset fromIndex:(int) index
{
    int matchedWords = 0;
    NSLog(@"search digits, offset, index: %@, %d %d", wordStart, offset, index);
        
    while (offset < [wordStart length])
    {
        index += matchedWords;
        const unichar *allowedChars = [T9TreeNode getCharsForDigit:[wordStart characterAtIndex:offset] - '0'];
        matchedWords = [self getWordCountForCharacters:allowedChars atOffset:offset fromIndex:index];
        if (matchedWords > 0)
        {
            offset++;
        }
        else
            break;
    }
    
    if (matchedWords > 0)
    {
        NSRange range;
        range.location = index;
        range.length = MIN (matchedWords, cMaxSearchResults);
        return [_dictionary subarrayWithRange:range];
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
        NSLog(@"digi value is: %d", digit);
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
            startIndex = node.indices[i];
    
    if (startIndex == cUnsetIndex)
    {
        // debug check, shouldn't happen normally
        NSLog(@"Indices are unset for node: %@", node);
        return nil;
    }
    
    return [self searchWordsStartingWith:digits withOffset:scannedDepth - 1 fromIndex:startIndex];
}

- (T9TreeNode *) getNodeForParent:(T9TreeNode *) parent forChar:(unichar) character withIndex:(int) index
{
    NumberCharsType nextNodeType = [T9TreeNode getTypeForChar:character];
    T9TreeNode *nextNode = [parent subnodeForType:nextNodeType];
    if (!nextNode)
    {
        // node is empty, creating new one
        nextNode = [[T9TreeNode alloc] initWithType:nextNodeType];
        [parent addSubnode:nextNode forType:nextNodeType];
    }
    [nextNode setIndex:index forCharacter:character];
    return nextNode;
}

- (void) buildIndexTreeForVocabulary
{
    T9TreeNode *currentNode = _rootNode = [[T9TreeNode alloc] initWithType:nctZero];
    int currentDepth = -1;
    unichar currentPreffix[cTreeDepth] = {'a', 'a', 'a', 'a'};
    for (int i=0; i < [_dictionary count]; i++)
    {
        NSString *word = [_dictionary objectAtIndex:i];
        int lastCharIndex = [word length] - 1;
        if (currentDepth < cTreeDepth - 1 && lastCharIndex > currentDepth)
        {
            // need to go deeper in index tree and create child for current node
            currentDepth++;
            unichar character = [word characterAtIndex:currentDepth];
            currentNode = [self getNodeForParent:currentNode forChar:character withIndex:i];
            while (currentDepth < cTreeDepth - 1 && lastCharIndex > currentDepth)
            {
                // might need to repeat it if the first word in new index range is even longer
                currentDepth++;
                character = [word characterAtIndex:currentDepth];
                currentNode = [self getNodeForParent:currentNode forChar:character withIndex:i];
            }
            currentPreffix[currentDepth] = character;
            // skipping rest of the code
            continue;
        }
        else if (lastCharIndex < currentDepth)
        {
            // current word is shorter than index, going up a level or few levels
            while (lastCharIndex < currentDepth)
            {
                currentDepth--;
                currentNode = currentNode.parentNode;
            }
            currentPreffix[currentDepth] = [word characterAtIndex:currentDepth];
        }
               
        // String length is ok and we're at maximum depth level for current word.
        // Checking if we've left current character bounds if not - do nothing, index is already saved before
        
        unichar character = [word characterAtIndex:currentDepth];
        if (character != currentPreffix[currentDepth])
        {
            // we've left current character bounds. Trying to save index for next character in current node
            
            if (![currentNode setIndex:i forCharacter:character])
            {
                // we've left current node bounds too. Need to create sibling for current node
                // or go up a level. Or few levels, creating a loop for cuch a case
                BOOL run = YES;
                while (run)
                {
                    run = NO;
                    if (currentDepth == 0 || character == currentPreffix[currentDepth - 1])
                    {
                        //we're either at top level, or previous node is still ok, creating sibling
                        currentPreffix[currentDepth] = character;                           
                        currentNode = [self getNodeForParent:currentNode.parentNode forChar:character withIndex:i];
                    }
                    else
                    {
                        //go up for a level, repeating
                        currentDepth--;
                        currentNode = currentNode.parentNode;
                        run = YES;
                    }
                }
            }
            currentPreffix[currentDepth] = character;
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
