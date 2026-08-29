import SwiftUI

struct LogView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                Text(state.log_output.isEmpty ? "Waiting for exploit..." : state.log_output)
                    .font(.system(size: 11, design: .monospaced))
                    .multilineTextAlignment(.leading)
                    .padding(8)
                    .id("log")
            }
            .onChange(of: state.log_output) { _, _ in
                withAnimation { proxy.scrollTo("log", anchor: .bottom) }
            }
        }
        .contextMenu {
            Button {
                UIPasteboard.general.string = state.log_output
            } label: {
                Label("Copy Logs", systemImage: "doc.on.doc")
            }
        }
    }
}
