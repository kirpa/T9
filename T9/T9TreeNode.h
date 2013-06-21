#import <Foundation/Foundation.h>

static const int cMaxCharsForDigit = 4;
static const int cUnsetIndex = -1;

typedef enum
{
    nctZero = 0,
    nctOne,
    nctTwo,
    nctThree,
    nctFour,
    nctFive,
    nctSix,
    nctSeven,
    nctEight,
    nctNine,
    nctTotalNums
} NumberCharsType;

@interface T9TreeNode : NSObject
{
    T9TreeNode      *_subnodes[nctTotalNums];
    NumberCharsType _type;
    int             _indices[cMaxCharsForDigit];
}

@property (assign, nonatomic) T9TreeNode *parentNode;
@property (readonly, nonatomic) int *indices;

+ (const unichar *) getCharsForDigit:(NumberCharsType) digit;
+ (NumberCharsType) getTypeForChar:(unichar) character;
+ (int) getInstanceCount;

- (id) initWithType:(NumberCharsType) type;
- (T9TreeNode *) subnodeForType:(NumberCharsType) type;
- (void) addSubnode:(T9TreeNode *) node forType:(NumberCharsType) type;
- (BOOL) setIndex:(int) index forCharacter:(unichar) character;

@end
