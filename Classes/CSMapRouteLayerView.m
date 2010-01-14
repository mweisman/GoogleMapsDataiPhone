//
//  CSMapRouteLayerView.m
//  mapLines
//
//  Created by Craig on 4/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CSMapRouteLayerView.h"
#import "AnnotationCreator.h"
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>


@implementation CSMapRouteLayerView
@synthesize mapView   = _mapView;
@synthesize points    = _points;
@synthesize lineColor = _lineColor;

-(id) initWithRoute:(NSArray*)routePoints mapView:(MKMapView *)mapView
{
	self = [super initWithFrame:CGRectMake(0, 0, mapView.frame.size.width, mapView.frame.size.height)];
    //self = [super initWithFrame:mapViewFrame];
	[self setBackgroundColor:[UIColor clearColor]];
    
    [self setPoints:routePoints];
    [self setMapView:mapView];
    [self setUserInteractionEnabled:NO];
	//[self.mapView addSubview:self];
    
    
	
	return self;
}


- (void)drawRect:(CGRect)rect
{
    for (NSArray *feature in self.points){
        // only draw our lines if we're not int he moddie of a transition and we 
        // acutally have some points to draw. 
        if(!self.hidden && nil != feature && feature.count > 0)
        {
            CGContextRef context = UIGraphicsGetCurrentContext(); 
            
            if(nil == self.lineColor)
                //self.lineColor = [UIColor blueColor];
                self.lineColor = [UIColor colorWithRed:0.649 green:0.185 blue:0.964 alpha:0.6];
            
            CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
            CGContextSetRGBFillColor(context, 0.649, 0.185, 0.964, 1.000);// 0.0, 0.0, 1.0, 1.0);
//            CGColorCreateGenericRGB(0.649, 0.185, 0.964, 1.000)
        
            CGContextSetLineWidth(context, 5.0);
            
            for(int idx = 0; idx < feature.count; idx++)
            {
                CLLocation* location = [feature objectAtIndex:idx];
                CGPoint point = [_mapView convertCoordinate:location.coordinate toPointToView:self];
                
                if(idx == 0)
                {
                    // move to the first point
                    CGContextMoveToPoint(context, point.x, point.y);
                } else {
                    CGContextAddLineToPoint(context, point.x, point.y);
                }
            }
            
            CGContextStrokePath(context);
        }
    }
}


/*#pragma mark mapView delegate functions
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
	// turn off the view of the route as the map is chaning regions. This prevents
	// the line from being displayed at an incorrect positoin on the map during the
	// transition. 
	self.hidden = YES;
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	// re-enable and re-poosition the route display. 
	self.hidden = NO;
	[self setNeedsDisplay];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    MKAnnotationView *view = nil;
    if (annotation != self.mapView.userLocation){
        view = [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"point"];
        if(view == nil) {
            view = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"point"] autorelease];
        }
        [(MKPinAnnotationView *)view setAnimatesDrop:YES];
        [(MKPinAnnotationView *)view setPinColor:MKPinAnnotationColorPurple];
        [view setCanShowCallout:YES];
        [view setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeInfoLight]];
        //UIImage *image = [UIImage imageWithContentsOfFile:@"/Users/mike/Development/googlemapsdataiphone/gMapsDataiPhone/pin.png"];
        //[view setImage:image];
    }
    return view;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
//    CLLocationCoordinate2D locationOfPin = [self.mapView convertPoint:view.annotation.coordinate toCoordinateFromView:mapView];
//    NSString *locationString = [NSString stringWithFormat:@"%d, %d",locationOfPin.latitude, locationOfPin.longitude];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:view.annotation.title message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}*/

-(void) dealloc
{
    [super dealloc];
	[_points release];
	//[_mapView release];
    //[mapTools release];
}

@end
