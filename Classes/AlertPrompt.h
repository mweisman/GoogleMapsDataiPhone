//
//  AlertPrompt.h
//  gMapsDataiPhone
//
//  Created by Michael Weisman on 26/07/09.
//  Copyright 2009 Michael Weisman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertPrompt : UIAlertView <UITextFieldDelegate>
{
    UITextField *alertTextField;
}
@property (nonatomic, retain) UITextField *alertTextField;
@property (readonly) NSString *enteredText;
- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle;
@end
