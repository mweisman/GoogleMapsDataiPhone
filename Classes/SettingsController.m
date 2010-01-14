//
//  SettingsController.m
//  gMapsDataiPhone
//
//  Created by Michael Weisman on 16/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SettingsController.h"

@interface SettingsController (Internal)
- (void)showLoadingIndicators;
- (void)hideLoadingIndicators;

- (void)beginLoadingAuthentication;
- (void)synchronousAuthentication;
- (void)didFinishLoadingAuthenticationWithResults;
@end

@implementation SettingsController
@synthesize userName,password;

-(id)initWithStyle:(UITableViewStyle)style {
	if (self = [super initWithStyle:style]) {
		
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
    operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount:1];
}

-(void)viewDidAppear:(BOOL)animated {    
    self.title = @"Settings";
    self.editing = NO;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *header;
    if (section == 0) {
        header = [NSString stringWithString:@"User Name:"];
    } else if (section == 1) {
        header = [NSString stringWithString:@"Password:"];
    }
    return header;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *footer;
    if (section == 1) {
        footer = [NSString stringWithString:@"Enter your Google Account information above"];
    } else {
        footer = nil;
    }
    return footer;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //UITextField *textField = [[self.settingsFields objectAtIndex: indexPath.section] valueForKey:kViewKey];
    
    // Set up the cell...
    if (indexPath.section == 0) {
        [cell.contentView addSubview:self.userName];
    } else {
        [cell.contentView addSubview:self.password];
    }
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}

- (void)dealloc {
    [loadingLabel release];
    [spinner release];
    [operationQueue release];
    [userName release];
    [password release];
    [super dealloc];

}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == userName) {
        [password becomeFirstResponder];
    } else if (textField == password) {
        [self save];
    }
    return NO;
}

- (void)save{
    [password resignFirstResponder];
    [userName resignFirstResponder];
    [self showLoadingIndicators];
    [self beginLoadingAuthentication];
}

-(void)showLoadingIndicators{
    if (!spinner) {
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        
        loadingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        loadingLabel.font = [UIFont systemFontOfSize:20];
        loadingLabel.textColor = [UIColor grayColor];
        loadingLabel.backgroundColor = [UIColor clearColor];
        loadingLabel.text = @"Authenticating...";
        [loadingLabel sizeToFit];
        
        static CGFloat bufferWidth = 8.0;
        
        CGFloat totalWidth = spinner.frame.size.width + bufferWidth + loadingLabel.frame.size.width;
        CGRect spinnerFrame = spinner.frame;
        spinnerFrame.origin.x = (self.view.bounds.size.width - totalWidth) / 2.0;
        spinnerFrame.origin.y = (self.view.bounds.size.height - spinnerFrame.size.height) / 2.0;
        //spinnerFrame.origin.x = 0;
        //spinnerFrame.origin.y = 0;
        spinner.frame = spinnerFrame;
        //[self.view addSubview:spinner];
        
        CGRect labelFrame = loadingLabel.frame;
        labelFrame.origin.x = (self.view.bounds.size.width - totalWidth) / 2.0 + spinnerFrame.size.width + bufferWidth;
        labelFrame.origin.y = (self.view.bounds.size.height - labelFrame.size.height) / 2.0;
        //labelFrame.origin.x = spinnerFrame.size.width + bufferWidth;
        //labelFrame.origin.y = 0;
        loadingLabel.frame = labelFrame;
        //[self.view addSubview:loadingLabel];
        
        UIView *loadingView = [[[UIView alloc] init] autorelease];
//        CGRect loadingViewFrame = loadingView.frame;
        //loadingViewFrame.origin.x = (self.view.bounds.size.height - spinnerFrame.size.height) / 2.0;
        //loadingViewFrame.origin.y = (self.view.bounds.size.height - spinnerFrame.size.height) / 2.0;
//        loadingView.frame = loadingViewFrame;
        loadingView.superview.backgroundColor = [UIColor blackColor];
//        loadingView.alpha = 0.66;
        [loadingView addSubview:spinner];
        [loadingView addSubview:loadingLabel];
        
        [self.view addSubview:loadingView];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
    }
}

- (void)hideLoadingIndicators
{
    if (spinner) {
        [spinner stopAnimating];
        [spinner removeFromSuperview];
        [spinner release];
        spinner = nil;
        
        [loadingLabel removeFromSuperview];
        [loadingLabel release];
        loadingLabel = nil;
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

-(void)beginLoadingAuthentication{
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchronousAuthentication) object:nil];
    [operationQueue addOperation:operation];
    [operation release];
    NSLog(@"begin Loading");
}

-(void)synchronousAuthentication {
    NSLog(@"Synchronus loading");
    NSURL *authURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.google.com/accounts/ClientLogin?Email=%@&Passwd=%@&service=local",userName.text,password.text]];
	NSString *authResponseString = [NSString stringWithContentsOfURL:authURL];
	NSArray *authRequestArray = [authResponseString componentsSeparatedByString:@"\n"];
    NSString *authToken = [[authRequestArray objectAtIndex:2] substringFromIndex:5];
    
    if (authToken == nil) {
        UIAlertView *badAuth = [[UIAlertView alloc] initWithTitle:@"Error Authenticating"message:@"There was an error authenticating with Google. Perhaps an incorrect Userame or Password?"delegate:self cancelButtonTitle:@"OK"otherButtonTitles:nil];
        [badAuth show];
        [badAuth release];
        [self hideLoadingIndicators];
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		[userDefaults setObject:userName.text forKey:@"user_preference"];
        NSLog(@"%@",[userDefaults objectForKey:@"user_preference"]);
		[userDefaults setObject:password.text forKey:@"pass_preference"];
		[userDefaults setObject:authToken forKey:@"token"];
        [userDefaults synchronize];
        NSLog(@"done loading");
        [self performSelectorOnMainThread:@selector(didFinishLoadingAuthenticationWithResults) withObject:nil waitUntilDone:NO];
        [self hideLoadingIndicators];
        [self.navigationController popViewControllerAnimated:YES];
	}
}

-(void)didFinishLoadingAuthenticationWithResults {
    //[loginInformation writeToFile:@"loginInormation.plist" atomically:YES];
    //[NSUserDefaults standardUserDefaults];
    NSLog(@"finished Loading");
}

-(UITextField *)userName {
    if (userName == nil){
        userName=[[[UITextField alloc]initWithFrame:CGRectMake(5, 10, 290, 70)] autorelease];
        userName.delegate=self;
        userName.keyboardType=UIKeyboardTypeEmailAddress;
        userName.autocorrectionType=UITextAutocorrectionTypeNo;
        userName.textColor=[UIColor blackColor];
        userName.placeholder=@"username@gmail.com";
        userName.autocapitalizationType=UITextAutocapitalizationTypeNone;
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user_preference"] != nil) {
            userName.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_preference"];
        }
    }
    return userName;
}

-(UITextField *)password {
    if (password == nil) {
        password=[[[UITextField alloc]initWithFrame:CGRectMake(5, 10, 290, 70)] autorelease];
        password.delegate=self;
        password.keyboardType=UIKeyboardTypeDefault;
        password.autocorrectionType=UITextAutocorrectionTypeNo;
        password.textColor=[UIColor blackColor];
        password.placeholder=@"Password";
        password.secureTextEntry=YES;
        password.returnKeyType=UIReturnKeyDone;
        password.autocapitalizationType=UITextAutocapitalizationTypeNone;
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"pass_preference"] != nil) {
            password.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"pass_preference"];
        }
    }
    return password;
}

@end
