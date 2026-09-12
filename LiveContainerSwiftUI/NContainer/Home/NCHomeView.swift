import SwiftUI

struct NCHomeView: View {
    @EnvironmentObject private var sharedModel: SharedModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("NContainer")
                        .font(.largeTitle.bold())
                        .padding(.horizontal)
                    if sharedModel.apps.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "square.stack.3d.up")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                            Text("No Apps")
                                .font(.headline)
                            Text("インストールしたアプリがここに表示されます。")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 48)
                    } else {
                        NCAppGrid()
                    }
                    NCDockView()
                        .padding(.horizontal)
                        .padding(.top, 8)
                }
                .padding(.vertical)
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
