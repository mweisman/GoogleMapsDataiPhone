//
//  WholeMapView.h
//  gMapsDataiPhone
//
//  Created by Michael Weisman on 01/08/09.
//  Copyright 2009 Michael Weisman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CSMapRouteLayerView.h"


@interface WholeMapView : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate> {
    MKMapView *mapView;
    NSMutableArray *mapAnnotations;
    NSMutableArray *mapPolygons;
    NSMutableArray *mapPolyLines;
    
    NSURL *mapDataURL;
    NSString *title;
    NSMutableArray *mapItems;
    //NSDictionary *currentElementAttributeDict;
    NSMutableDictionary *currentItem;
    NSMutableString *itemName;
    NSMutableArray *itemCoordinates;
    NSString *currentElement;
    
    NSOperationQueue *operationQueue;
    
    UIActivityIndicatorView *spinner;
    UILabel *loadingLabel;
    
    NSString *viewTitle;
    UIToolbar *mapTools;
    CSMapRouteLayerView *routeView;
    CLLocationManager *locationManager;
}
@property (nonatomic, retain) NSURL *mapDataURL;
@property (nonatomic, retain) NSString *viewTitle;

-(void)swapMapType;
-(void)zoomToLocation;

@end
