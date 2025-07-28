//
//  CongestionWidgetLiveActivity.swift
//  CongestionWidget
//
//  Created by 최희진 on 7/28/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct CongestionWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct CongestionWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CongestionWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension CongestionWidgetAttributes {
    fileprivate static var preview: CongestionWidgetAttributes {
        CongestionWidgetAttributes(name: "World")
    }
}

extension CongestionWidgetAttributes.ContentState {
    fileprivate static var smiley: CongestionWidgetAttributes.ContentState {
        CongestionWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: CongestionWidgetAttributes.ContentState {
         CongestionWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: CongestionWidgetAttributes.preview) {
   CongestionWidgetLiveActivity()
} contentStates: {
    CongestionWidgetAttributes.ContentState.smiley
    CongestionWidgetAttributes.ContentState.starEyes
}
