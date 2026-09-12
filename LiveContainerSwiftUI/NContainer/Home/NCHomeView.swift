import SwiftUI

struct NCHomeView: View {
    @EnvironmentObject private var sharedModel: SharedModel
    @State private var showAppLibrary = false
    @State private var showSources = false
    @State private var showTweaks = false
    @State private var showPlugins = false
    @State private var showFullscreenSettings = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("NContainer")
                        .font(.largeTitle.bold())
                        .padding(.horizontal)
                    NCStatusView()
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
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button {
                            showAppLibrary = true
                        } label: {
                            Label("App Library", systemImage: "list.bullet.rectangle")
                        }
                        Button {
                            showSources = true
                        } label: {
                            Label("SideStore Sources", systemImage: "books.vertical")
                        }
                        Button {
                            showTweaks = true
                        } label: {
                            Label("Tweak Manager", systemImage: "wrench.and.screwdriver")
                        }
                        if NCBetaFeatures.isEnabled(.fullscreenApps) {
                            Button {
                                showFullscreenSettings = true
                            } label: {
                                Label("Fullscreen Apps", systemImage: "arrow.up.left.and.arrow.down.right")
                            }
                        }
                        if NCBetaFeatures.isEnabled(.pluginSystem) {
                            Button {
                                showPlugins = true
                            } label: {
                                Label("Plugin Manager", systemImage: "puzzlepiece.extension")
                            }
                        }
                    } label: {
                        Label("Tools", systemImage: "square.grid.2x2")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAppLibrary = true
                    } label: {
                        Label("Import IPA", systemImage: "doc.badge.plus")
                    }
                    .accessibilityLabel("IPAを取り込む。App Libraryの追加ボタンを開きます")
                }
            }
            .sheet(isPresented: $showAppLibrary) {
                LCAppListView()
            }
            .sheet(isPresented: $showSources) {
                LCSourcesView()
            }
            .sheet(isPresented: $showTweaks) {
                LCTweaksView()
            }
            .sheet(isPresented: $showPlugins) {
                NavigationView {
                    NCPluginManagerView()
                }
            }
            .sheet(isPresented: $showFullscreenSettings) {
                NavigationView {
                    LCMultitaskSettingView()
                }
            }
        }
    }
}
