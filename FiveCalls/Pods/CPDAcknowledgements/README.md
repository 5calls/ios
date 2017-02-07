# CPDAcknowledgements

[![Version](http://cocoapod-badges.herokuapp.com/v/CPDAcknowledgements/badge.png)](http://cocoadocs.org/docsets/CPDAcknowledgements)
[![Platform](http://cocoapod-badges.herokuapp.com/p/CPDAcknowledgements/badge.png)](http://cocoadocs.org/docsets/CPDAcknowledgements)

## What is CPDAcknowledgements

CPDAcknowledgements is a collection of View Controllers for iOS projects in order to easily provide acknowledgements for the libraries used in your apps.

<img width=33% src="Web/acknowledgements.png">
<img width=33% src="Web/contribution.png">
<img width=33% src="Web/library.png">

It exposes an API which allows you to easily add individual contributors, and libraries. You can also customise the style of the pages with ease.

``` objc
CPDContribution *orta = [[CPDContribution alloc] initWithName:@"Orta" websiteAddress:@"http://orta.github.io" role:@"Behind a wheel"];
orta.avatarAddress = @"https://1.gravatar.com/avatar/f116cb3be23153ec08b94e8bd4dbcfeb?d=https%3A%2F%2Fidenticons.github.com%2F243e8373034964abf7c8a8e57d4df724.png&r=x&s=86";

CPDContribution *fabio = [[CPDContribution alloc] initWithName:@"Fabio Pelosin" websiteAddress:@"http://twitter.com/fabiopelosin" role:@"Back Seat Driver"];
fabio.avatarAddress = @"https://0.gravatar.com/avatar/b6dde1a78e6215a592768c1e78a54adc?d=https%3A%2F%2Fidenticons.github.com%2Fbdc4e72be51d566c2fc9564ed8182611.png&r=x&s=86";

CPDContribution *kyle = [[CPDContribution alloc] initWithName:@"Kyle Fuller" websiteAddress:@"http://twitter.com/kylefuller" role:@"Somewhere in the boot"];
NSArray *contributors = @[orta, fabio, kyle];

CPDAcknowledgementsViewController *acknowledgementsViewController = [[CPDAcknowledgementsViewController alloc] initWithStyle:nil acknowledgements:nil contributions:contributors];
UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:acknowledgementsViewController];
```

## Demo Project

To run the example project; clone the repo, and run `pod install` from the Project directory first or run `pod try CPDAcknowledgements`

## Installation

CPDAcknowledgements will be available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

``` ruby
pod "CPDAcknowledgements"
```

You will need to have the `plugin "cocoapods-acknowledgements"` inside your Podfile, this is what the demo project's Podfile looks like, for example.

``` ruby
plugin 'cocoapods-acknowledgements'

target "Demo Project" do
	pod "CPDAcknowledgements", :path => "../CPDAcknowledgements.podspec"

	# These pods are used only for giving us some data
	pod "ORStackView"
	pod "IRFEmojiCheatSheet"

	target "Demo ProjectTests" do
    inherit! :search_paths

    pod 'Specta',      '~> 1.0'
    pod 'Expecta',     '~> 1.0'
    pod 'OCMockito',   '~> 1.0'
  end
end
```



## Author

Orta Therox, orta.therox@gmail.com
Fabio Pelosin, fabio.pelosin@gmail.com

### Acknowledgements

Inspiration taken from [@orta/life#12](https://github.com/orta/life/issues/12) and [VTAcknowledgementsViewController](https://github.com/vtourraine/VTAcknowledgementsViewController).

## License

CPDAcknowledgements is available under the MIT license. See the LICENSE file for more info.
