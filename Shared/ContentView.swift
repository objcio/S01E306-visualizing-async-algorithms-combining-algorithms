import SwiftUI

struct RunView: View {
    var algorithm: Stream
    @State var sample1 = sampleInt
    @State var sample2 = sampleString
    @State var result: [Event]? = nil
    @State private var loading = false
    
    var duration: TimeInterval {
        (sample1 + sample2 + (result ?? [])).lazy.map { $0.time }.max() ?? 1
    }
    
    var body: some View {
        VStack {
            TimelineView(events: $sample1, duration: duration)
            TimelineView(events: $sample2, duration: duration)
            TimelineView(events: .constant(result ?? []), duration: duration)
                .drawingGroup()
                .opacity(loading ? 0.5 : 1)
                .animation(.default, value: result)
        }
        .padding(20)
        .task(id: sample1 + sample2) {
            loading = true
            result = await run(algorithm: algorithm, StreamContext(events1: sample1, events2: sample2))
            loading = false
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Merge") {
                    RunView(algorithm: .merge(.input1, .input2))
                }
                NavigationLink("Combine Latest") {
                    RunView(algorithm: .combineLatest(.input1, .input2))
                }
                NavigationLink("Testing") {
                    RunView(algorithm: .zip(.adjacentPairs(.input1), .input2))
                }
            }
            .listStyle(.sidebar)
        }
    }
}
