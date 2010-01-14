//
//  MapItemsController.m
//  gMapsDataiPhone
//
//  Created by Michael Weisman on 27/07/09.
//  Copyright 2009 Michael Weisman. All rights reserved.
//

#import "MapItemsController.h"
#import "MapViewController.h"

@interface MapItemsController (Internal)
- (void)showLoadingIndicators;
- (void)hideLoadingIndicators;

- (void)beginLoadingItemList;
- (void)synchronousItemList;
- (void)didFinishLoadingItemListWithResults;

-(void)parseMapListXMLFileData:(NSData *)XMLData;
@end

@implementation MapItemsController

@synthesize mapIDURL;

- (void)loadView {
    [super loadView];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount:1];
    [self showLoadingIndicators];
    [self beginLoadingItemList];
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


- (void)dealloc {
    [mapIDURL release];
    [title release];
    [operationQueue release];
    [spinner release];
    [loadingLabel release];
    [mapItems release];
    [currentItem release];
    [itemName release];
    [itemCoordinates release];
    [super dealloc];
}

-(void)showLoadingIndicators{
    if (!spinner) {
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        
        loadingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        loadingLabel.font = [UIFont systemFontOfSize:20];
        loadingLabel.textColor = [UIColor grayColor];
        loadingLabel.text = @"Loading Items...";
        [loadingLabel sizeToFit];
        
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

-(void)beginLoadingItemList {
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchronousMapItem) object:nil];
    [operationQueue addOperation:operation];
    [operation release];
}

-(void)synchronousMapItem {
    NSString *authToken = [NSString stringWithString:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"]];
    NSString *userName = [NSString stringWithString:[[NSUserDefaults standardUserDefaults] valueForKey:@"user_preference"]];
    if (authToken == nil) {
        mapItems = nil;
        UIAlertView *noLoginInfo = [[UIAlertView alloc] initWithTitle:@"No Login Information"message:@"You have not set up an account. Please go to the Settings App and enter your Google Account login"delegate:self cancelButtonTitle:@"OK"otherButtonTitles:nil];
        [noLoginInfo show];
        [noLoginInfo release];
        [self hideLoadingIndicators];
    } else if (userName == nil) {
        UIAlertView *noUser = [[UIAlertView alloc] initWithTitle:@"No Username" message:@"You have not entered a username" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [noUser show];
        [noUser release];
        [self hideLoadingIndicators];
    } else {
        NSMutableURLRequest *mapListRequest = [NSMutableURLRequest requestWithURL:mapIDURL];
        [mapListRequest setValue:[NSString stringWithFormat:@"GoogleLogin auth=%@",authToken] forHTTPHeaderField:@"Authorization"];
        NSData *responseData;
        NSURLResponse *response;
        NSError *error;
        responseData = [NSURLConnection sendSynchronousRequest:mapListRequest returningResponse:&response error:&error];
        //NSString *dataAsString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
        //NSLog(dataAsString);
        mapItems = [[NSMutableArray alloc] init];
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
            [self performSelectorOnMainThread:@selector(didFinishLoadingItemListWithResults) withObject:nil waitUntilDone:NO];
            //NSLog(@"%@",mapsList);
        }
    }
}

-(void)didFinishLoadingItemListWithResults {
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
    //NSLog(elementName);
    if ([elementName isEqualToString:@"Placemark"]) {
        currentItem = [[NSMutableDictionary alloc] init];        
        itemName = [[NSMutableString alloc] init];
        itemCoordinates = [[NSMutableArray alloc] init];
    }
    
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if ([currentElement isEqualToString:@"name"]){
        [itemName appendString:string];
    } else if ([currentElement isEqualToString:@"coordinates"]) {
        [itemCoordinates addObject:[string componentsSeparatedByString:@" "]];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"Placemark"]){
        [currentItem setObject:itemName forKey:@"itemName"];
        [currentItem setObject:itemCoordinates forKey:@"itemCoordiantes"];
        
        [mapItems addObject:currentItem];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [mapItems count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
	// Configure the cell.
    NSInteger row = [indexPath row];
    NSString *itemTitle = [[mapItems objectAtIndex:row] objectForKey:@"itemName"];
    cell.textLabel.text = itemTitle;
    return cell;
}





// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Navigation logic may go here -- for example, create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController animated:YES];
	// [anotherViewController release];
    MapViewController *itemMap = [[MapViewController alloc] init];
    itemMap.viewTitle = [[mapItems objectAtIndex:indexPath.row] objectForKey:@"itemName"];
    itemMap.itemInformation = [mapItems objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:itemMap animated:YES];
    [itemMap release];
}


@end
