import SwiftUI

struct NCHomeView: View {
    @EnvironmentObject private var sharedModel: SharedModel

    private enum Route: String, Identifiable {
        case appLibrary, sources, tweaks, plugins, fullscreen
        var id: String { rawValue }
    }

    @State private var route: Route?

    private struct DismissToolbar: ViewModifier {
        @Environment(\.dismiss) private var dismiss

        func body(content: Content) -> some View {
            content.toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Label("戻る", systemImage: "chevron.backward")
                    }
                    .accessibilityLabel("前の画面に戻る")
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("NContainer")
                        .font(.largeTitle.bold())
                        .padding(.horizontal)
                    NCStatusView()
                        .padding(.horizontal)
                    quickActions
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
                            route = .appLibrary
                        } label: {
                            Label("App Library", systemImage: "list.bullet.rectangle")
                        }
                        Button {
                            route = .sources
                        } label: {
                            Label("SideStore Sources", systemImage: "books.vertical")
                        }
                        Button {
                            route = .tweaks
                        } label: {
                            Label("Tweak Manager", systemImage: "wrench.and.screwdriver")
                        }
                        if NCBetaFeatures.isEnabled(.fullscreenApps) {
                            Button {
                                route = .fullscreen
                            } label: {
                                Label("Fullscreen Apps", systemImage: "arrow.up.left.and.arrow.down.right")
                            }
                        }
                        if NCBetaFeatures.isEnabled(.pluginSystem) {
                            Button {
                                route = .plugins
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
                        route = .appLibrary
                    } label: {
                        Label("Import IPA", systemImage: "doc.badge.plus")
                    }
                    .accessibilityLabel("IPAを取り込む。App Libraryの追加ボタンを開きます")
                }
            }
            .fullScreenCover(item: $route) { route in
                destination(for: route)
            }
        }
    }

    private var quickActions: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            actionButton("App Library", systemImage: "list.bullet.rectangle", route: .appLibrary)
            actionButton("Sources", systemImage: "books.vertical", route: .sources)
            actionButton("Tweak Manager", systemImage: "wrench.and.screwdriver", route: .tweaks)
            actionButton("Plugin Manager", systemImage: "puzzlepiece.extension", route: .plugins)
            if NCBetaFeatures.isEnabled(.fullscreenApps) {
                actionButton("Fullscreen", systemImage: "arrow.up.left.and.arrow.down.right", route: .fullscreen)
            }
        }
        .padding(.horizontal)
    }

    private func actionButton(_ title: String, systemImage: String, route: Route) -> some View {
        Button { self.route = route } label: {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.medium))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 11)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func destination(for route: Route) -> some View {
        switch route {
        case .appLibrary:
            LCAppListView().modifier(DismissToolbar())
        case .sources:
            LCSourcesView().modifier(DismissToolbar())
        case .tweaks:
            LCTweaksView().modifier(DismissToolbar())
        case .plugins:
            NavigationView { NCPluginManagerView().modifier(DismissToolbar()) }
        case .fullscreen:
            NavigationView { LCMultitaskSettingView().modifier(DismissToolbar()) }
        }
    }
}
