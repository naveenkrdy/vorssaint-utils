// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import SwiftUI

/// Compact playback stays beside the camera and never grows a second row.
struct NotchMusicStrip: View {
    @ObservedObject var service: NotchService
    @ObservedObject private var music = NotchMusicService.shared
    @ObservedObject private var l10n = L10n.shared

    private var geometry: NotchGeometry { service.compactActivityGeometry }

    private var outerInset: CGFloat {
        max(12, min(NotchLayout.shoulder, geometry.compactActivityContentHeight * 0.28) + 4)
    }

    private var artworkSide: CGFloat {
        max(0, min(26, geometry.menuBarHeight - 6, geometry.compactActivityWingWidth - outerInset - 8))
    }

    private var title: String { music.playback?.track.title ?? FeatureStrings.radialMenu(l10n.language).mediaNowPlaying }
    private var artist: String? {
        guard let artist = music.playback?.track.artist?.trimmingCharacters(in: .whitespaces), !artist.isEmpty else { return nil }
        return artist
    }
    /// A simulated camera has room for the track even when its wings disappear.
    private var fillsCameraGap: Bool { !geometry.isNotched && geometry.compactActivityCameraGap >= 56 }
    private var showsArtist: Bool { geometry.compactActivityContentHeight >= 28 }
    private var barHeight: CGFloat { min(16, max(8, geometry.compactActivityContentHeight - 12)) }

    var body: some View {
        Button { service.open(.music) } label: {
            HStack(spacing: 0) {
                HStack(spacing: 8) {
                    if geometry.compactActivityWingWidth >= 44 {
                        Group {
                            if let image = music.artwork {
                                Image(nsImage: image).resizable().scaledToFill()
                            } else {
                                Color.black.overlay { Image(systemName: "music.note").foregroundStyle(.secondary) }
                            }
                        }
                        .frame(width: artworkSide, height: artworkSide)
                        .clipShape(RoundedRectangle(cornerRadius: artworkSide * 0.28, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: artworkSide * 0.28, style: .continuous)
                                .strokeBorder(.white.opacity(0.14), lineWidth: 0.5)
                        }
                    }
                }
                .padding(.leading, outerInset)
                .padding(.trailing, 8)
                // Keep the wings spread out while clearing the curved edges.
                .frame(width: geometry.compactActivityWingWidth, alignment: .leading)
                .clipped()
                Group {
                    if fillsCameraGap { trackLabel } else { Color.clear }
                }
                .frame(width: geometry.compactActivityCameraGap, height: geometry.compactActivityContentHeight)
                .clipped()
                HStack {
                    if geometry.compactActivityWingWidth >= 44 {
                        NotchEqualizerBars(isPlaying: music.playback?.isPlaying == true,
                                           bars: 7, barWidth: 1.8,
                                           height: barHeight,
                                           tint: music.artworkTint?.color ?? .white)
                    }
                }
                .padding(.leading, 8)
                .padding(.trailing, outerInset)
                .frame(width: geometry.compactActivityWingWidth, alignment: .trailing)
            }
            .frame(height: geometry.compactActivityContentHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel([title, music.playback?.track.artist].compactMap { $0 }.joined(separator: ", "))
        .accessibilityHint(FeatureStrings.notch(l10n.language).open)
        .help(title)
    }

    private var trackLabel: some View {
        VStack(spacing: 1) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .lineLimit(1)
                .truncationMode(.tail)
            if showsArtist, let artist {
                Text(artist)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.white.opacity(0.62))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
        .padding(.horizontal, geometry.compactMusicLabelInset)
        .frame(maxWidth: .infinity)
        .accessibilityHidden(true)
    }
}
