import Foundation

// Enums whose raw value is their English display text. The raw values stay the values that
// Codable, `.comp` files, PSD keys and asset names already use; only the UI reads `displayName`.
extension AdjustmentKind: LocalizedDisplayName {}
extension FilterKind: LocalizedDisplayName {}
extension LayerEffectKind: LocalizedDisplayName {}
extension BackgroundQuality: LocalizedDisplayName {}
extension LevelsChannel: LocalizedDisplayName {}
extension LevelsSample: LocalizedDisplayName {}
extension LevelsAuto: LocalizedDisplayName {}
extension ColorRange: LocalizedDisplayName {}
extension HueSampleMode: LocalizedDisplayName {}
extension ShapeKind: LocalizedDisplayName {}
extension ShapeLineStyle: LocalizedDisplayName {}
extension ShapeLineCap: LocalizedDisplayName {}
extension GradientStyle: LocalizedDisplayName {}
extension GradientShape: LocalizedDisplayName {}
extension DitherStyle: LocalizedDisplayName {}
extension DitherPixelShape: LocalizedDisplayName {}
extension DitherColors: LocalizedDisplayName {}
extension CameraRawWhiteBalance: LocalizedDisplayName {}
extension CameraRawGlowStyle: LocalizedDisplayName {}
extension CameraRawVignetteStyle: LocalizedDisplayName {}
extension CameraRawScopeMode: LocalizedDisplayName {}
extension CameraRawCurvePage: LocalizedDisplayName {}
extension CameraRawPointChannel: LocalizedDisplayName {}
extension CameraRawMixerPage: LocalizedDisplayName {}
extension CameraRawMixerTab: LocalizedDisplayName {}
extension CameraRawGradePage: LocalizedDisplayName {}
extension CameraRawUprightMode: LocalizedDisplayName {}
extension CameraRawProjection: LocalizedDisplayName {}
extension CameraRawProcessVersion: LocalizedDisplayName {}
extension CameraRawGroup: LocalizedDisplayName {}
extension WandMode: LocalizedDisplayName {}
extension LassoKind: LocalizedDisplayName {}
extension SelectionMode: LocalizedDisplayName {}
extension EditorSession.SelectionAmountOperation: LocalizedDisplayName {}
extension BrushToolMode: LocalizedDisplayName {}
extension BlurToolMode: LocalizedDisplayName {}
extension SpotHealingMode: LocalizedDisplayName {}
extension TrimBasedOn: LocalizedDisplayName {}
extension ExportFormat: LocalizedDisplayName {}
extension GridAppearance.Preset: LocalizedDisplayName {}
extension GridAppearance.Style: LocalizedDisplayName {}
