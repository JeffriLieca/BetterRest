//
//  ContentView.swift
//  BetterRest
//
//  Created by Jeffri Lieca H on 23/12/24.
//

import CoreML
import SwiftUI


//struct ContentView: View {
//    @State private var sleepAmount = 8.0
//    @State private var wakeUp = Date.now
//    
//    
//    
//    var body: some View {
//        
//        VStack {
//            Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12,step: 0.25)
//            DatePicker("Please enter a date", selection: $wakeUp, in: Date.now...)
//                .labelsHidden()
//            DatePicker("", selection: $wakeUp)
//            Text(Date.now.formatted(date: .long, time: .shortened))
//
//        }
//        .padding()
//    }
//    func exampleDates() {
//        // create a second Date instance set to one day in seconds from now
//        let tomorrow = Date.now.addingTimeInterval(86400)
//
//        // create a range from those two
//        let range = Date.now...tomorrow
//    }
//}

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var coffeeAmountIndex = 0
    @State private var alertTitle = "a"
    @State private var alertMessage = "b"
    @State private var showingAlert = false
    private var recommendation : String {
        let recomendationString = makeRecommendation(wakeUp: wakeUp, sleepAmount: sleepAmount, coffeeAmount: Double(coffeeAmountIndex+1))
        return recomendationString
    }
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("When do you want to wake up?"){
                    //                    Text("When do you want to wake up?")
                    //                        .font(.headline)
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                }
                
                Section("Desired amount of sleep") {
//                    VStack(alignment: .leading, spacing: 0) {
//                        Text("Desired amount of sleep")
//                            .font(.headline)
                        
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
//                    }
                }
                
                Section("Daily coffee intake"){
                    //                Text("Daily coffee intake")
                    //                    .font(.headline)
                    Picker("Number of cups", selection: $coffeeAmountIndex) {
                        ForEach( 1 ..< 21 ) {
                            Text("^[\($0) cup](inflect: true)")
                        }
                    }

//                    Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 1...20)
                }
                
//                Text("**Bold** and *italic* text with [a link](https://swift.org)")
                Section{
//                    Text(makeRecommendation(wakeUp: wakeUp, sleepAmount: sleepAmount, coffeeAmount: Double(coffeeAmountIndex+1)))
                    VStack{
                        Text("Recommendation :")
                        Text(recommendation)
                            .foregroundStyle(.purple)
                    }
                        .font(.largeTitle.bold())
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
            }
            .navigationTitle("BetterRest")
//            .toolbar {
//                Button("Calculate", action: calculateBedtime)
//            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
        
    }
    
    func makeRecommendation(wakeUp: Date, sleepAmount: Double, coffeeAmount: Double) -> String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: coffeeAmount)
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            return "Sleep at \(sleepTime.formatted(date: .omitted, time: .shortened))"
        } catch {
            return "Sorry, there was a problem calculating your bedtime."
        }
    }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is…"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        showingAlert = true
    }
}

#Preview {
    ContentView()
}
