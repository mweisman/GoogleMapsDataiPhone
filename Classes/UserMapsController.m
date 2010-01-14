//
//  UserMapsController.m
//  gMapsDataiPhone
//
//  Created by Michael Weisman on 18/07/09.
//  Copyright 2009 Michael Weisman. All rights reserved.
//

#import "UserMapsController.h"
#import "MapInfoController.h"
#import "WholeMapView.h"

@interface UserMapsController (Internal)
- (void)showLoadingIndicators;
- (void)hideLoadingIndicators;

- (void)beginLoadingMapList;
- (void)synchronousMapList;
- (void)didFinishLoadingMapListWithResults;

-(void)parseMapListXMLFileData:(NSData *)XMLData;
@end


@implementation UserMapsController
@synthesize userName;

- (void)viewDidLoad {
    [super viewDidLoad];
    mapSearchBar = [[UISearchBar alloc] initWithFrame:self.tableView.bounds];
    mapSearchBar.delegate = self;
    [mapSearchBar sizeToFit];
    self.tableView.tableHeaderView = mapSearchBar;
    operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount:1];
    [self showLoadingIndicators];
    [self beginLoadingMapList];
//    [self.tableView setEditing:YES animated:YES];
//    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.view = self.tableView;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    if(self.editing != editing) {
		[super setEditing:editing animated:animated];
		[self.tableView setEditing:editing animated:animated];
		NSArray *indexPaths = [NSArray arrayWithObject:
							   [NSIndexPath indexPathForRow:
								mapsList.count inSection:0]];
		if(YES == editing) {
			[self.tableView insertRowsAtIndexPaths:indexPaths 
							 withRowAnimation:UITableViewRowAnimationLeft];
		} else {
			[self.tableView deleteRowsAtIndexPaths:indexPaths 
							 withRowAnimation:UITableViewRowAnimationLeft];
		}
	}
}

-(void)showLoadingIndicators{
    if (!spinner) {
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        
        loadingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        loadingLabel.font = [UIFont systemFontOfSize:20];
        loadingLabel.textColor = [UIColor grayColor];
        loadingLabel.backgroundColor = [UIColor clearColor];
        loadingLabel.text = @"Loading Maps...";
        [loadingLabel sizeToFit];
        
        //spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        
        static CGFloat bufferWidth = 8.0;
        
        CGFloat totalWidth = spinner.frame.size.width + bufferWidth + loadingLabel.frame.size.width;
        
        CGRect spinnerFrame = spinner.frame;
        spinnerFrame.origin.x = (self.view.bounds.size.width - totalWidth) / 2.0;
        spinnerFrame.origin.y = (self.view.bounds.size.height - spinnerFrame.size.height) / 2.0;
        spinner.frame = spinnerFrame;
        [self.view addSubview:spinner];
        
        CGRect labelFrame = loadingLabel.frame;
        labelFrame.origin.x = (self.view.bounds.size.width - totalWidth) / 2.0 + spinnerFrame.size.width + bufferWidth;
        labelFrame.origin.y = (self.view.bounds.size.height - labelFrame.size.height) / 2.0;
        loadingLabel.frame = labelFrame;
        [self.view addSubview:loadingLabel];
        
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

- (void)alertViewCancel:(UIAlertView *)alertView {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)beginLoadingMapList {
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchronousMapList) object:nil];
    [operationQueue addOperation:operation];
    [operation release];
}

-(void)synchronousMapList {
    NSString *authToken = [NSString stringWithString:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"]];
    if (authToken == nil) {
     mapsList = nil;
     UIAlertView *noLoginInfo = [[UIAlertView alloc] initWithTitle:@"No Login Information"message:@"You have not set up an account. Please go to the Settings App and enter your Google Account login"delegate:self cancelButtonTitle:@"OK"otherButtonTitles:nil];
     [noLoginInfo show];
     [noLoginInfo release];
     [self hideLoadingIndicators];
 } else if (self.userName == nil) {
     UIAlertView *noUser = [[UIAlertView alloc] initWithTitle:@"No Username" message:@"You have not entered a username" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
     [noUser show];
     [noUser release];
     [self hideLoadingIndicators];
 } else {
     self.title = [[[NSArray arrayWithObject:[userName componentsSeparatedByString:@"@"]] objectAtIndex:0] objectAtIndex:0];
     NSURL *mapListUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/maps/feeds/maps/%@/full",self.userName]];
     NSMutableURLRequest *mapListRequest = [NSMutableURLRequest requestWithURL:mapListUrl];
     [mapListRequest setValue:[NSString stringWithFormat:@"GoogleLogin auth=%@",authToken] forHTTPHeaderField:@"Authorization"];
     NSData *responseData;
     NSURLResponse *response;
     NSError *error;
     responseData = [NSURLConnection sendSynchronousRequest:mapListRequest returningResponse:&response error:&error];
     mapsList = [[NSMutableArray alloc] init];
     //NSString *textResponse = [[[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding] autorelease];
     //NSLog(textResponse);
     NSData *invalid = [@"Invalid id format" dataUsingEncoding:NSASCIIStringEncoding];
     if (responseData == invalid) {
         UIAlertView *invalidUserName = [[UIAlertView alloc] initWithTitle:@"Invalid User Name" message:@"You have entered an invalid User Name" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [invalidUserName show];
         [invalidUserName release];
         [self hideLoadingIndicators];
     } else {
         [self parseMapListXMLFileData:responseData];
         [self hideLoadingIndicators];
         [self performSelectorOnMainThread:@selector(didFinishLoadingMapListWithResults) withObject:nil waitUntilDone:NO];
         //NSLog(@"%@",mapsList);
     }
 }
}

-(void)didFinishLoadingMapListWithResults {
    searchArray = [mapsList mutableCopy];
    [self.tableView reloadData];
}

-(void) parseMapListXMLFileData:(NSData *)XMLData {
    NSXMLParser *parseMapList = [[[NSXMLParser alloc] initWithData:XMLData] autorelease];
    [parseMapList setDelegate:self];
    [parseMapList setShouldProcessNamespaces:NO];
    [parseMapList setShouldReportNamespacePrefixes:NO];
    [parseMapList setShouldResolveExternalEntities:NO];
    [parseMapList parse];
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    currentElement = [elementName copy];
    NSDictionary *currentElementAttributeDict = [[[NSDictionary alloc] initWithDictionary:attributeDict] autorelease];
    if ([elementName isEqualToString:@"entry"]) {
        mapListDict = [[NSMutableDictionary alloc] init];
        publishElement = [[NSMutableString alloc] init];
        updatedElement = [[NSMutableString alloc] init];
        titleElement = [[NSMutableString alloc] init];
        contentElement = [[NSMutableString alloc] init];
        editLinkElement = [[NSMutableString alloc] init];
        nameAuthorElement = [[NSMutableString alloc] init];
        idElement = [[NSMutableString alloc] init];
    }
    if ([elementName isEqualToString:@"link"]) {
        if ([[currentElementAttributeDict objectForKey:@"rel"] isEqualToString:@"edit"]){
            [editLinkElement appendString:[currentElementAttributeDict objectForKey:@"href"]];
        }
    }
    if ([elementName isEqualToString:@"content"]) {
        [contentElement appendString:[currentElementAttributeDict objectForKey:@"src"]];
    }

}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if ([currentElement isEqualToString:@"published"]){
        [publishElement appendString:string];
    } else if ([currentElement isEqualToString:@"updated"]) {
        [updatedElement appendString:string];
    } else if ([currentElement isEqualToString:@"title"]) {
        [titleElement appendString:string];
    } else if ([currentElement isEqualToString:@"name"]) {
        [nameAuthorElement appendString:string];
    } else if ([currentElement isEqualToString:@"id"]) {
        [idElement appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"entry"]){
        [mapListDict setObject:publishElement forKey:@"published"];
        [mapListDict setObject:updatedElement forKey:@"updated"];
        [mapListDict setObject:titleElement forKey:@"mapTitle"];
        [mapListDict setObject:nameAuthorElement forKey:@"mapAuthorName"];
        [mapListDict setObject:contentElement forKey:@"contentLink"];
        [mapListDict setObject:editLinkElement forKey:@"editLink"];
        [mapListDict setObject:idElement forKey:@"mapID"];
                
        [mapsList addObject:mapListDict];
    }
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [searchArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
    NSUInteger row = [indexPath row];
    
    cell.textLabel.text = [[searchArray objectAtIndex:row] objectForKey:@"mapTitle"];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    //[cell setEditingStyle:UITableViewCellEditingStyleDelete];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WholeMapView *viewOfMapData = [[WholeMapView alloc] init];
    viewOfMapData.mapDataURL = [NSURL URLWithString:[[searchArray objectAtIndex:indexPath.row] objectForKey:@"contentLink"]];
    viewOfMapData.viewTitle = [[searchArray objectAtIndex:indexPath.row] objectForKey:@"mapTitle"];
    [self.navigationController pushViewController:viewOfMapData animated:YES];
    [viewOfMapData release];
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
    MapInfoController *inforForThisMap =  [[MapInfoController alloc] initWithStyle:UITableViewStyleGrouped];
    inforForThisMap.mapInformation = [searchArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:inforForThisMap animated:YES];
    [inforForThisMap release];
}

- (void)dealloc {
    [loadingLabel release];
    [spinner release];
    [operationQueue release];
    [mapsList release];
	[mapListDict release];
    [currentElement release];
    //[currentElementAttributeDict release];
    [publishElement release];
    [updatedElement release];
    [titleElement release];
    [idElement release];
    [contentElement release];
    [editLinkElement release];
    [nameAuthorElement release];
    [mapSearchBar release];
    [searchArray release];
    [super dealloc];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [searchArray removeAllObjects];
    NSString *query = searchBar.text;
    //searchBar.showsCancelButton = YES;
	
	if (query.length == 0)
	{
		// Only search if we have a non-zero length query string
		[searchArray addObjectsFromArray:mapsList];
	}
	else
	{
		for (NSDictionary *mapDict in mapsList) {
			NSRange range = [[mapDict objectForKey:@"mapTitle"] rangeOfString:query options:NSCaseInsensitiveSearch];
            
			if (range.length > 0)
				[searchArray addObject:mapDict];
		}
	}
    [self.tableView reloadData];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = nil;
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    return YES;
}

-(void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"swipe");
}

@end

