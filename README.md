## Installation :  
To integrate MozarkEventsSDK into a new project we have 4 possible steps:
#### 1 - Install cocoapods
If cocoapods is not installed on your Mac try typing this command in the terminal : 
 
     sudo gem install cocoapods
 
#### 2- Generate podfile

    pod init
logically you will have a new file called Podfile generated in your project tree

#### 3- Prepare Podfile
You are just invited to add two lines in the podfile:

    source 'https://github.com/CocoaPods/Specs.git'
    And
    pod 'MozarkEventsSDK'
here is an example of the structure of a podfile    

    source 'https://github.com/CocoaPods/Specs.git'
    target 'test_Project' do
     use_frameworks!
     pod "MozarkEventsSDK"
    end
    
#### 4- Load MozarkEventsSDK

     pod install


## Use :
Import  **MozarkEventsSDK** and also **MozarkEventConstants**
**MozarkEventConstants** is an sdk used to define allowed event names for an application, it will be loaded automatically with the **MozarkEventsSDK**

    import MozarkEventConstants
    import MozarkEventsSDK
    
Initalise sdk object : 

    static let capturedEvent = MozarkEvents()
    
As you can set other optional parameters : 
    
    static let capturedEvent = MozarkEvents(sendRealTimeEvents: false, eventURL: "https://development-api.mozark.ai", applicationName: "default_ios_app_name", applicationId: "com.hotstar.mobile", applicationVersion: "1.0")
You can set **sendRealTimeEvents** to **true** if you want to send scanned events every 5 seconds  
    
## track event :    
We can send an event without value like this : 

       static let eventConstant : EventConstants  = EventConstants()  // Get authorized event names
       static let journeyConstant : JourneyConstants  = JourneyConstants() // Get authorized journey names
       capturedEvent.trackEvent(eventName: eventConstant.startEventTrue, journeyName: journeyConstant.start)
  
As we can send an event with value like this

      static let eventConstant : EventConstants  = EventConstants()  // Get authorized event names
      static let journeyConstant : JourneyConstants  = JourneyConstants() // Get authorized journey names
       capturedEvent.trackMetric(eventName: eventConstant.transactionAmount, eventValue: "20", journeyName: journeyConstant.moneyTransfer)
The tracked events will be sent automatically if you have reached the batch size and if you have not yet reached the batch size they will be sent after a batch timeout
## Start journey :
The start journey method will push a start event to detect the start of a new journey, we will put it for example in the setup method which is executed each new test

    override func setUp() {
        super.setUp()
        capturedEvent.starNewJourney()
    }
    
## end journey :
The end journey method will push an end event to detect the end of a journey, we will put it for example in the teardown method which is executed at the end of each test,as we will give the possibility to synchronize the events with the server if they are not yet sent.

    override func tearDown() {
        super.tearDown()
        capturedEvent.endJourneyAndSendItsRemainingEvents { success in
        }
    }
We can use **expectation** to be sure that our events are well synchronized like this : 

    override func tearDown() {
        super.tearDown()
        let endEventExpection = expectation(description: "endEvent")
        var endEventSuccess = false
        FiveGMark.capturedEvent.endJourneyAndSendItsRemainingEvents { success in
            endEventSuccess = success
            endEventExpection.fulfill()
        }
        waitForExpectations(timeout: 10) { _ in
            XCTAssert(endEventSuccess == true,"Problem with send end event")
        }
    }
## Finish sending events :   
To successfully complete the scenario, you must call the endSendEvents method at the end so that our sdk that you have finished sending the events and reset values.


    override class func tearDown() {
        capturedEvent.endSendEvents()
    }
    
## How to release a new version

To publish a new version, you must:
1 - Increment the **spec.version** attribute in the MozarkEventsSDK.podspec file
2 - Push the code to branch **main**
3 - Create a new tag that corresponds to the version number, for exemple tag number is 2.1 => **git tag 2.1**                  
4 - Push the tag => **git push origin 2.1**
5 - Check if MozarkEventsSDK.podspec file is valid  => **pod lib lint MozarkEventsSDK.podspec --allow-warnings**
6- Publish update : **pod trunk push  MozarkEventsSDK.podspec --allow-warnings**  
------


