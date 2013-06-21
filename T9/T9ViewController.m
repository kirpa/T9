#import "T9ViewController.h"
#import "T9Dictionary.h"
#import "T9TreeNode.h"

@interface T9ViewController ()
{
    UIView                      *_fadeView;
    UIActivityIndicatorView     *_activityIndicator;
    NSCharacterSet              *_disallowedCharacters;
    T9Dictionary                *_dictionary;
}

@end

@implementation T9ViewController

#pragma mark Vocabulary

- (void) createDictionary
{
    NSLog(@"creating dict...");
    _dictionary = [[T9Dictionary alloc] init];
    NSDate *timeStart = [NSDate date];
    [_dictionary readVocabulary];
    NSTimeInterval timeEnd = [[NSDate date] timeIntervalSinceDate:timeStart];
    NSLog(@"vocabulary read in: %f", timeEnd);
    timeStart = [NSDate date];
    [_dictionary buildIndexTreeForVocabulary];
    timeEnd = [[NSDate date] timeIntervalSinceDate:timeStart];
    NSLog(@"index tree built in: %f", timeEnd);
    NSLog(@"tree nodes count: %d", [T9TreeNode getInstanceCount]);
    NSLog(@"words count: %d", _dictionary.dictionary.count);
    NSLog(@"... done");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeFade];
    });
    
}

- (void) updateResultForDigits:(NSString *) digits
{
//    if ([digits length] > 0)
    {
        NSArray *words = [_dictionary wordsForDigits:digits];
        NSLog(@"words are: %@", words);
        self.outputLabel.text = [words componentsJoinedByString:@"\n"];
    }
}

#pragma mark UITextFieldDelegate

- (IBAction) editingChanged:(id)sender
{
    UITextField *textField = (UITextField *)sender;
    [self updateResultForDigits:textField.text];
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSRange charsRange = [string rangeOfCharacterFromSet:_disallowedCharacters];
    if (charsRange.location == NSNotFound)
    {
        return YES;
    }
    else
        return NO;
}

#pragma mark UI

- (void) showFade
{
    if (!_fadeView)
    {
        UIView *parentView = [UIApplication sharedApplication].keyWindow;
        CGSize screenSize = parentView.frame.size;
        _fadeView = [[UIView alloc] initWithFrame:parentView.frame];
        _fadeView.backgroundColor = [UIColor blackColor];
        _fadeView.alpha = 0.5;
        
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicator.center = CGPointMake(screenSize.width / 2, screenSize.height / 2);
        [_activityIndicator startAnimating];
        [_fadeView addSubview:_activityIndicator];
        [parentView addSubview:_fadeView];
    }
}

- (void) removeFade
{
    [_fadeView removeFromSuperview];
    [_activityIndicator stopAnimating];
    _activityIndicator = nil;
    _fadeView = nil;
}

#pragma mark Object lifecycle

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showFade];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                       [self createDictionary];
                   });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSCharacterSet *allowedCharacters = [NSCharacterSet characterSetWithCharactersInString:@"23456789"];
    _disallowedCharacters = [allowedCharacters invertedSet];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    [self removeFade];
}

@end
