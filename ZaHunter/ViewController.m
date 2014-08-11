//
//  ViewController.m
//  ZaHunter
//
//  Created by ETC ComputerLand on 8/6/14.
//  Copyright (c) 2014 cmeats. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MapViewController.h"

@interface ViewController () <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate>

@property CLLocationManager *locationManager;
@property NSMutableArray *locations;
@property (strong, nonatomic) IBOutlet UITableView *locationsTableView;

@property MKMapItem *lastMapItem;

@property NSInteger expectedTravelTime;

@property NSUInteger maxCount;
@property int locationCount;
@property (strong, nonatomic) IBOutlet UITabBarItem *tabBar1;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tabBarController.delegate = self;

    self.locations = [NSMutableArray new];

    self.maxCount = 4;
    self.locationCount = 1;
    self.expectedTravelTime = 0;

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    [self.locationManager startUpdatingLocation];

}

-(void)findPizzariaLocations: (CLLocation *)location
{
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];

    request.naturalLanguageQuery = @"pizza";
    request.region = MKCoordinateRegionMakeWithDistance(location.coordinate, 10000.0f, 10000.0f);
//    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(1, 1));
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];


    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {

        NSPredicate *business = [NSPredicate predicateWithFormat:@"business.uID != 0"];
        NSMutableArray *itemsWithBusinesses = [response.mapItems mutableCopy];
        [itemsWithBusinesses filterUsingPredicate:business];


        for (MKMapItem *mapItem in itemsWithBusinesses) {
            [self getDistanceToPizzaria:mapItem];

        }
    }];
}

-(void)getDistanceToPizzaria: (MKMapItem *)mapItem
{


    MKDirectionsRequest *request = [MKDirectionsRequest new];

    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = mapItem;
    request.transportType = MKDirectionsTransportTypeWalking;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (self.locationCount > self.maxCount) {
            return;
        }
        MKRoute *route = response.routes.firstObject;

        // If first stop then time is from current location
        if (self.locationCount == 1) {
            self.expectedTravelTime += route.expectedTravelTime+50;
            self.lastMapItem = mapItem;
        } else { //otherwise calc distance from last stop
            [self getDistanceFromLastPizzaria:mapItem];
            self.lastMapItem = mapItem;
        }

        NSDictionary *locationInfo = @{@"mapItem": mapItem, @"distance": [NSString stringWithFormat:@"%f", route.distance]};
        [self.locations addObject:locationInfo];
        [self.locationsTableView reloadData];
        self.locationCount++;
    }];


}

-(void)getDistanceFromLastPizzaria: (MKMapItem *)mapItem
{
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.source = mapItem;
    request.destination = self.lastMapItem;
    request.transportType = MKDirectionsTransportTypeWalking;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        MKRoute *route = response.routes.firstObject;
        self.expectedTravelTime += route.expectedTravelTime+50;
        [self.locationsTableView reloadData];
    }];
}




#pragma mark - CLLocationManagerDelagate

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error = %@", error);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations) {
        [self findPizzariaLocations: location];
        [self.locationManager stopUpdatingLocation];
        break;
    }
}

#pragma mark - Table View Delagate

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.locations.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    MKMapItem *mapItem = self.locations[indexPath.row][@"mapItem"];
    cell.textLabel.text = mapItem.name;
    cell.detailTextLabel.text = self.locations[indexPath.row][@"distance"];

    return cell;
}

-(UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UILabel *footerLabel = [UILabel new];
    footerLabel.text = [NSString stringWithFormat:@"%i", self.expectedTravelTime];
    return footerLabel;
}

#pragma mark - Tab Bar Controller Delagate

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(MapViewController *)viewController
{
    viewController.locations = self.locations;
    return YES;
}


@end
