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
                    if NCBetaFeatures.isEnabled(.nStatus) {
                        NCStatusView()
                            .padding(.horizontal)
                    }
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
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        NavigationLink {
                            LCAppListView()
                        } label: {
                            Label("App Library", systemImage: "list.bullet.rectangle")
                        }
                        NavigationLink {
                            LCSourcesView()
                        } label: {
                            Label("SideStore Sources", systemImage: "books.vertical")
                        }
                        NavigationLink {
                            LCTweaksView()
                        } label: {
                            Label("Tweak Manager", systemImage: "wrench.and.screwdriver")
                        }
                        if NCBetaFeatures.isEnabled(.fullscreenApps) {
                            NavigationLink {
                                LCMultitaskSettingView()
                            } label: {
                                Label("Fullscreen Apps", systemImage: "arrow.up.left.and.arrow.down.right")
                            }
                        }
                        if NCBetaFeatures.isEnabled(.pluginSystem) {
                            NavigationLink {
                                NCPluginManagerView()
                            } label: {
                                Label("Plugin Manager", systemImage: "puzzlepiece.extension")
                            }
                        }
                    } label: {
                        Label("Tools", systemImage: "square.grid.2x2")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        LCAppListView()
                    } label: {
                        Label("Import IPA", systemImage: "doc.badge.plus")
                    }
                    .accessibilityLabel("IPAを取り込む。App Libraryの追加ボタンを開きます")
                }
            }
        }
    }
}
