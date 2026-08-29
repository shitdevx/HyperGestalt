import SwiftUI

struct LogView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        ScrollView {
            Text(state.log_output.isEmpty ? "Waiting for exploit..." : state.log_output)
                .font(.system(size: 11, design: .monospaced))
                .multilineTextAlignment(.leading)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
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
