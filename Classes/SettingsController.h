//
//  SettingsController.h
//  gMapsDataiPhone
//
//  Created by Michael Weisman on 16/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsController : UITableViewController <UITextFieldDelegate> {
	UITextField *userName;
	UITextField *password;
//	IBOutlet UIButton *saveButton;
    
    NSOperationQueue *operationQueue;
    
    UIActivityIndicatorView *spinner;
    UILabel *loadingLabel;
}

@property (nonatomic, retain, readonly) UITextField *userName;
@property (nonatomic, retain, readonly) UITextField *password;

- (void)save;

@end
