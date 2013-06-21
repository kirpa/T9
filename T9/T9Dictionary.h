#import <Foundation/Foundation.h>

@class T9TreeNode;

@interface T9Dictionary : NSObject
{
    NSArray     *_dictionary;
    T9TreeNode  *_rootNode;
}

@property (retain, nonatomic) NSArray *dictionary;

- (void) readVocabulary;
- (void) buildIndexTreeForVocabulary;
- (NSArray *) wordsForDigits:(NSString *) digits;


@end