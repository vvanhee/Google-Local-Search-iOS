# Google-Local-Search-iOS

If you use this code, [please upvote my response on Stack Overflow](http://stackoverflow.com/questions/3385924/integerating-google-maps-data-api-with-iphone-and-performing-search/4931857#4931857) about how to use Google Local Search.  Thanks!

Some iOS (Objective-C) classes for implementing [Google's Local Search API JSON interface][GoogleLocalSearchAPI], particularly for use in iPhone / iPad apps.  This allows you to find businesses / other locations by name or address using Google's Local Search API JSON interface (in Objective C, for iPhone SDK).  This interface also allows geocoding any address (so it works as a forward geocoder).  The iOS SDK only includes reverse geocoding, so this is potentially a very useful class.  

Note that this API has been unfortunately deprecated by Google in late 2010, so it will stop working around late 2013.

A detailed guide to implementing this (for the novice) is also available on the [Tot a Go Go iPhone App Blog][TAGGBlogPost].

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

setup (I do this in viewDidLoad of MyMapViewController.m, and I release it in viewDidUnload): 
    googleLocalConnection = [[GoogleLocalConnection alloc] initWithDelegate:self]; 

Implement the following in your textFieldShouldReturn method:

    [googleLocalConnection getGoogleObjectsWithQuery:textField.text andMapRegion:[mapView region] andNumberOfResults:4 addressesOnly:YES andReferer:@"http://mysuperiorsitechangethis.com"];

*The addressesOnly boolean above tells the class to only give locations if they correspond to a street address (rather than a city or other region).  Maximum number of results is 4.*

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

*The above will give you a NSMutableArray of GoogleLocalObjects which you can use at will (to annotate your map, for example, as illustrated above).  See the GoogleLocalObject class for details about the variables these objects contain -- briefly, they contain a CLLocationCoordinate2d coordinate with latitude and longitude, the full address, a subtitle which is set to the address by default, and a phone number for the business if available.*
 
    - (void) googleLocalConnection:(GoogleLocalConnection *)conn didFailWithError:(NSError *)error
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error finding place - Try again" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }


 [GoogleLocalSearchAPI]: http://code.google.com/apis/maps/documentation/localsearch/jsondevguide.html
 [JSONFramework]: https://github.com/stig/json-framework
 [GTM]: http://code.google.com/p/google-toolbox-for-mac/
 [TAGGBlogPost]: http://www.totagogo.com/2011/02/08/google-local-search-ios-code/