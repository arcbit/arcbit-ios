SwiftTryCatch
=============

Adds try/catch support for Swift

Simple wrapper built around Objective-C to achieve the same result.

##Usage

###1. Create bridging header.
- When prompted with "Would you like to configure an Objective-C bridging header?" press Yes.
- Go to bridging header and add:
````#import "SwiftTryCatch.h"````

###2. Use
````
SwiftTryCatch.try({ () -> Void in
        //try something
     }, catch: { (error) -> Void in
        //handle error
     }, finally: { () -> Void in
        //close resources
})
````
