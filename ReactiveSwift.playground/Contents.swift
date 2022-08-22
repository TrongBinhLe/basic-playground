// ReactiveSwift : https://medium.com/@hsusmita4/conquering-reactiveswift-signal-and-observer-part-3-8b7da35fe33a

import UIKit
import ReactiveSwift



/**************Signal and Observer********/
/*
 Signal
 In Functional Reactive Programming (FRP), we model our systems as time varying functions. This simply means that we define how the system is going to behave as the time passes. In contrast to Imperative Programming, where we manage state of a system at a given point of time, in FRP, here we deal with the changes in the state over a period of time. This concept of “change over time” is beautifully captured in the notion of Signal. A Signal is defined as a stream of events, where each Event represents the state of a system at a given point of time. An Event, the basic unit of a Signal, can be of one of the following kinds:
 Value: valid information of any type
 Failed: indicates that the stream has finished with an error
 Completed: indicates the successful end of a stream, where no further events will be emitted
 Interrupted: indicates that event production has been interrupted
 A Signal continues to send a stream of events of type “Value” until it encounters an event of type “Failed/Completed/Interrupted”. Once the signal emits an event of type “Error/Completed/Interrupted”, it stops sending any value.
 
 
 Observer
 In order to observe the events emitted by a Signal, ReactiveSwift provides a primitive called Observer. An Observer is a simple wrapper around a closure of type (Event) -> Void. It encapsulates the information the behaviour of the system in response to events emitted by a Signal. Suppose we want to observe a Signal emitting integer values. We would define an Observer as follows:
 let observer = Signal<Int, NoError>.Observer { (event) in
     switch event {
     case let .value(v):
         print("value = \(v)")
     case let .failed(error):
         print("error = \(error)")
     case .completed:
         print("completed")
     case .interrupted:
         print("interrupted")
     }
 }
 Now, we are clear about how to create an Observer, Now let’s learn how to create and observe a signal.
 
 /*
 How does it work?
 When we create a signal through pipe, we get a tuple of <output: Signal, input: Observer>. The input (of type Observer) represents all the subscribers of the signal. When we want to send an event to signal, we invoke send(value:Value) of the input. This will trigger send of all the subscribed observer and the closure associated with the observers will be executed.
 */

 */
//Create an observer
let signalObserver = Signal<Int, NoError>.Observer(
value: { value in
    print("Time elapsed = \(value)")
}, completed: {
    print("completed")
}, interrupted: {
    print("interrupted")
})
//Create an a signal
let (output, input) = Signal<Int, NoError>.pipe()
//Send value to signal
for i in 0..<10 {
    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0 *  Double(i)) {
  input.send(value: i)  // input: Observer
 }
}
//Observe the signal
output.observe(signalObserver) // output : Signal


/****SIGNALPRODUCER**/

// As the name implies, a SignalProducer is something that produces a Signal. Basically, a SignalProducer encapsulates a deferred and repeatable work which when started generates a Signal.'

/*We created a signal which emits an integer on every 5 seconds for next 50 seconds. Then we observed those integers and printed the time elapsed. Let’s suppose, now we want this to start on a button tap. However, as an observer, we can only observe the signal, we can’t make it start or stop. For this kind of scenario, a SignalProducer is a good fit.*/



//Creating a SignalProducer
let signalProducer: SignalProducer<Int, NoError> =
 SignalProducer { (observer, lifetime) in
    for i in 0..<10 {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0 *  Double(i)) {
      observer.send(value: i)
      if i == 9 { //Mark completion on 9th iteration
        observer.sendCompleted()
      }
    }
  }
}
/*
 Here, A SignalProducer is initialized with a closure that is executed when start method of the SignalProducer is invoked. This closure accepts an observer of type Signal.Observer<Int, NoError> and a lifetime of type Lifetime. The observer is used to send values. The lifetime gives us an opportunity to cancel ongoing work if the observation is stopped.
 
 */

//Creating an observer
let signalObserver = Signal<Int, NoError>.Observer (
value: { value in
     print("Time elapsed = \(value)")
}, completed: {
     print("completed")
}, interrupted: {
     print("interrupted")
})
//Start a SignalProducer
signalProducer.start(signalObserver)


/*
 Suppose we want to interrupt the SignalProducer after 10 seconds. To do so, we have to dispose of it after 10 seconds.
 
 */


//Start a SignalProducer
let disposable = signalProducer.start(signalObserver)
//Dispose after 10 seconds
DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
     disposable.dispose()
}

//According to our current implementation, even though the observer is disposed after 10 seconds the SignalProducer keeps on emitting the integers for 50 seconds. When constructing a SignalProducer, it’s important to free up resources and stop ongoing tasks if it is interrupted. So let’s get that fixed.
let signalProducer: SignalProducer<Int, NoError> =
SignalProducer { (observer, lifetime) in
    for i in 0..<10 {
       DispatchQueue.main.asyncAfter(deadline: .now() + 5.0 *   Double(i)) {
       guard !lifetime.hasEnded else {
          observer.sendInterrupted()
          return
       }
       observer.send(value: i)
       if i == 9 {
          observer.sendCompleted()
       }
     }
  }
}
//We will check hasEnded property of lifetime and send an interruption event as sendInterrupted.


/****Property********/


/*A Property is an observable container which emits its value whenever its value is changed. It conforms to PropertyProtocol which itself has the following properties:
value: Represents the current value
producer: A SignalProducer which sends the current value followed by the subsequent changes. This completes when the Property deinitializes or has no further change.
signal: A Signal which sends the subsequent changes, not the current value. This completes when the Property deinitializes or has no further change.*/

//Create a signalProducer
let signalProducer: SignalProducer<Int, NoError> = SignalProducer { (observer, lifetime) in
    let now = DispatchTime.now()
    for index in 0..<10 {
        let timeElapsed = index * 5
        DispatchQueue.main.asyncAfter(deadline: now + Double(timeElapsed)) {
            guard !lifetime.hasEnded else {
                observer.sendInterrupted()
                return
            }
            observer.send(value: timeElapsed)
            if index == 9 {
                observer.sendCompleted()
            }
        }
    }
}
//So let’s define a Property.

let property = Property(initial: 0, then: signalProducer)


//As mentioned earlier, a Property has the properties signal and producer, both of which can be observed, but with a key difference being that a signal does not emit the current value, only subsequent changes to that value.
property.producer.startWithValues { value in
    print("[Observing SignalProducer] Time elapsed = \(value)")
}

/* OutPut:
[Observing SignalProducer] Time elapsed = 0
[Observing SignalProducer] Time elapsed = 0
[Observing SignalProducer] Time elapsed = 5
[Observing SignalProducer] Time elapsed = 10
[Observing SignalProducer] Time elapsed = 15
[Observing SignalProducer] Time elapsed = 20
[Observing SignalProducer] Time elapsed = 25
[Observing SignalProducer] Time elapsed = 30
[Observing SignalProducer] Time elapsed = 35
[Observing SignalProducer] Time elapsed = 40
[Observing SignalProducer] Time elapsed = 45
*/

property.signal.observeValues { value in
    print("[Observing Signal] Time elapsed = \(value)")
}

/* Output
[Observing Signal] Time elapsed = 0
[Observing Signal] Time elapsed = 5
[Observing Signal] Time elapsed = 10
[Observing Signal] Time elapsed = 15
[Observing Signal] Time elapsed = 20
[Observing Signal] Time elapsed = 25
[Observing Signal] Time elapsed = 30
[Observing Signal] Time elapsed = 35
[Observing Signal] Time elapsed = 40
[Observing Signal] Time elapsed = 45
*/


//*********MutableProperty**************
//A MutableProperty is an observable container which emits a value on change just like a Property, but can also be directly mutated. Like Property, it also conforms to thePropertyProtocol.
//A MutableProperty can be initialized with an initial value like this:
let mutableProperty = MutableProperty(1)
mutableProperty.value = 3

mutableProperty <~ signalProducer

//Here, it means that the value of the mutableProperty is dictated by the signalProducer. We will discuss more about bindings in subsequent articles.
