//
//  MapViewController.m
//  ZaHunter
//
//  Created by ETC ComputerLand on 8/6/14.
//  Copyright (c) 2014 cmeats. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>

@interface MapViewController () <MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *pizaMappView;

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.pizaMappView.delegate = self;

    for (NSDictionary *location in self.locations) {
        MKMapItem *mapItem = location[@"mapItem"];

        MKPointAnnotation *annotation = [MKPointAnnotation new];
        annotation.coordinate = mapItem.placemark.coordinate;
        annotation.title = location[@"name"];

        [self.pizaMappView addAnnotation:annotation];
    }
    
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    pin.canShowCallout = YES;
    //pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    pin.image = [UIImage imageNamed:@"pizza"];

    return pin;

}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
