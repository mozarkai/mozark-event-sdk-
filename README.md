## Installation :  
  Via cocoapods : 


    pod 'MozarkEventsSDK'
    


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

## Finish sending events :   
To successfully complete the scenario, you must call the endSendEvents method at the end so that our sdk that you have finished sending the events


    capturedEvent.endSendEvents()
    
------
