//
//  AlertPrompt.m
//  gMapsDataiPhone
//
//  Created by Michael Weisman on 26/07/09.
//  Copyright 2009 Michael Weisman. All rights reserved.
//

#import "AlertPrompt.h"

@implementation AlertPrompt
@synthesize alertTextField;
	//@synthesize enteredText;
- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okayButtonTitle
{
    
    if (self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okayButtonTitle, nil])
    {
        UITextField *theTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)]; 
        [theTextField setBackgroundColor:[UIColor whiteColor]]; 
        theTextField.keyboardType=UIKeyboardTypeEmailAddress;
        theTextField.autocorrectionType=UITextAutocorrectionTypeNo;
        theTextField.textColor=[UIColor blackColor];
        theTextField.placeholder=@"username@gmail.com";
        theTextField.autocapitalizationType=UITextAutocapitalizationTypeNone;
        theTextField.returnKeyType = UIReturnKeyDone;
        theTextField.delegate = self;
        [self addSubview:theTextField];
        self.alertTextField = theTextField;
        [theTextField release];
        CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 130.0); 
        [self setTransform:translate];
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)show
{
    [alertTextField becomeFirstResponder];
    [super show];
}
- (NSString *)enteredText
{
    return alertTextField.text;
}
- (void)dealloc
{
    [alertTextField release];
    [super dealloc];
}
@end
