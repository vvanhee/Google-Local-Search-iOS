# Google-Local-Search-iOS

Some iOS (Objective-C) classes for implementing [Google's Local Search API JSON interface][GoogleLocalSearchAPI], particularly for use in iPhone / iPad apps.

## Usage

#### Dependencies

This code depends on [stig's JSON Framework for Objective C][JSONFramework].  Make sure to copy these files into your project, or it won't work.

This project also depends on a very small piece (GTMNSString+URLArguments) of the [Google Toolbox for Mac][GTM], which I've included.

#### GoogleLocalConnection class

Here's some sample Objective-C code showing how to use the classes in your viewController.  Before implementing this, make sure you have linked to the mapkit framework and imported MapKit.h.  You'll also need to set up an MKMapView named mapView (to allow region biasing of the search) and a UITextField and UITextFieldDelegate (to get the address or business name from user input).  

After copying the files from this git repository into your project, you should also add the following lines to your MyMapViewController.h:
    #import "GoogleLocalConnection.h"  

    @class GoogleLocalObject;

    GoogleLocalConnection *googleLocalConnection;

Also add the delegate protocol to your @interface line in MyMapViewController.h:
    @interface MyMapViewController : UIViewController <...,GoogleLocalConnectionDelegate> {

and in MyMapViewController.m, add:
    #import "GoogleLocalObject.h"
    #import "GTMNSString+URLArguments.h"

setup: 
    googleLocalConnection = [[GoogleLocalConnection alloc] initWithDelegate:self]; 

Implement the following in your textFieldShouldReturn method:

    [googleLocalConnection getGoogleObjectsWithQuery:textField.text andMapRegion:[mapView region] andNumberOfResults:8 addressesOnly:YES];

*The addressesOnly boolean above tells the class to only give locations if they correspond to a street address (rather than a city or other region).  Maximum number of results is 8.*

*Time passes and one of the delegate methods will be called...*

delegate methods:

    - (void) googleLocalConnection:(GoogleLocalConnection *)conn didFinishLoadingWithGoogleLocalObjects:(NSMutableArray *)objects andViewPort:(MKCoordinateRegion)region
    {
        if ([objects count] == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No matches found near this location" message:@"Try another place name or address (or move the map and try again)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
        else {
            id userAnnotation=mapView.userLocation;
            [mapView removeAnnotations:mapView.annotations];
            [mapView addAnnotations:objects];
            if(userAnnotation!=nil)
            [mapView addAnnotation:userAnnotation];
            [mapView setRegion:region];
        }
    }

    - (void) googleLocalConnection:(GoogleLocalConnection *)conn didFailWithError:(NSError *)error
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error finding place - Try again" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }


 [GoogleLocalSearchAPI]: http://code.google.com/apis/maps/documentation/localsearch/jsondevguide.html
 [JSONFramework]: https://github.com/stig/json-framework
 [GTM]: http://code.google.com/p/google-toolbox-for-mac/