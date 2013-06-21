#import <UIKit/UIKit.h>

@interface T9ViewController : UIViewController <UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UILabel *outputLabel;

- (IBAction) editingChanged:(id)sender;

@end
