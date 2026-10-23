# Compositor 简体中文本地化 PRD

| 项目 | 内容 |
|---|---|
| 文档版本 | v1.0 |
| 日期 | 2026-10-23 |
| 状态 | 待实施 |
| 产品 | Compositor（macOS 图像编辑器） |
| 代码仓库 | `runlinxin-arch/Compositor`（fork，本地 `~/Compositor`） |
| 上游仓库 | `robbietilton/Compositor` |
| 本文档仓库 | `compositer汉化包`（GitHub 项目根目录） |
| 目标语言 | 简体中文（zh-Hans） |

---

## 1. 背景

Compositor 是一款免费开源的 macOS 图像编辑器，定位为 Photoshop 的替代品，使用 SwiftUI + AppKit 编写。当前应用**仅提供英文界面**，上游 README 明确说明暂不接受翻译 PR。

用户希望在自己的 fork 中提供完整的简体中文界面，并能在应用内切换语言。经代码调查确认：

- Compositor **没有插件或扩展 API**，无法通过外挂插件实现翻译。
- 仓库当前**没有任何本地化设施**（无 `.xcstrings` / `.strings` / `.lproj`）。
- 约 **700–900 条**用户可见字符串，其中大量通过 `String` 变量、枚举 `rawValue`、三元表达式和字符串拼接传递，不会自动本地化。
- 部分英文标题同时承担**逻辑键**职责（快捷键 ID、混合模式反查、右键菜单识别、命令面板导航），直接翻译会导致功能损坏。

因此，本项目以**编译进 fork 的语言包**方式实现，不是运行时插件。

## 2. 目标与成功标准

### 2.1 产品目标

1. 提供覆盖全部用户可见界面的简体中文体验。
2. 用户可在 **跟随系统 / 简体中文 / English** 之间切换，重启后生效。
3. 中文术语与大陆版 Photoshop 保持一致，降低专业用户的理解成本。
4. 不破坏既有项目文件（`.comp`）、快捷键配置和英文界面行为。

### 2.2 成功标准

- 中文模式下，菜单、工具、面板、设置、弹窗、提示、错误和导入报告**无遗漏英文**（明确排除项除外）。
- 语言切换写入应用偏好，重启后完整生效；切回英文/跟随系统同样有效。
- 现有 `.comp` 项目可正常打开、保存；混合模式、调整图层、采样方式等持久化值不变。
- 已有快捷键自定义配置继续有效。
- 英文单元测试全部通过；中文界面通过逐屏人工验收。
- 英文模式行为与改动前一致。

## 3. 用户与使用场景

### 3.1 目标用户

- 中文母语的设计师、修图师、摄影后期用户。
- 熟悉 Photoshop 中文版术语，但不熟悉英文界面。
- 使用 macOS 26+、Apple Silicon Mac。

### 3.2 典型场景

| 场景 | 期望 |
|---|---|
| 首次启动（系统为中文） | 界面显示中文；新建文档默认名为中文 |
| 系统为英文但希望用中文 | 在设置中选“简体中文”，重启后完整中文 |
| 中文用户切回英文对照教程 | 设置选“English”，重启后完整英文 |
| 打开旧的英文项目 | 工程内容、图层名、混合模式保持不变 |
| 使用快捷键/命令面板 | 快捷键沿用；⌘F 可用中文或英文关键词找到命令 |
| 导入 PSD/PDF | 转换报告与错误提示为中文 |

## 4. 已确认的产品决策

| 决策 | 结论 |
|---|---|
| 语言切换方式 | 应用内切换：跟随系统 / 简体中文 / English；重启生效 |
| 术语风格 | 大陆 Photoshop 术语 |
| 翻译范围 | 全部用户可见文本（含 tooltip、错误、导入报告） |
| 新建默认名称 | 使用中文（未命名、图层 1、背景…）；已有项目名称不动 |
| 命令面板搜索 | 中文标题 + 英文别名；不做拼音搜索 |
| 品牌名 | “Compositor” 不翻译 |
| 插件形态 | 无插件 API；以编译进 fork 的语言包实现 |

## 5. 范围

### 5.1 范围内

- 应用菜单栏与所有菜单项
- 工具名、工具提示、工具参数面板
- 图层面板、图层右键菜单、图层样式/调整/滤镜面板
- 新建画布、画布大小、图像大小、裁切、网格等表单
- 导出为、保存/打开面板标题与提示
- 所有 NSAlert、确认框、错误提示
- LocalizedError 错误描述
- PSD/PDF 导入与转换报告
- 快捷键设置面板及其校验提示
- 命令面板（⌘F）界面与搜索别名
- VoiceOver 无障碍标签
- 新建文档/图层的默认名称
- 语言设置界面
- Finder 可见的应用显示名（品牌保持英文）

### 5.2 范围外

- 向上游提交翻译 PR（上游当前政策不允许）
- 翻译 README、docs、发布说明
- Windows/Linux 非官方移植版
- 拼音搜索
- 自动翻译用户已有图层名、项目名、导入文件名、PSD 内部名称
- 运行时热切换语言（不做，采用重启方案）
- 可动态加载的第三方语言包/插件框架

## 6. 功能需求

### FR-01 语言设置（P0）

- 在应用菜单提供“设置…”（⌘,），内含“语言”选项。
- 选项：跟随系统、简体中文、English。
- 选择后提示“重启 Compositor 后生效”，提供“退出 Compositor”。
- 选择持久化；重启后按选择加载对应语言。
- “跟随系统”移除应用级语言覆盖，交由 macOS 系统语言或系统“按 App 设置语言”决定。
- 语言名称使用自身语言显示（简体中文 / English），不翻译。

**验收**：三种选项均可切换；`defaults read com.wonderassembly.compositor AppleLanguages` 与选择一致；跟随系统时该键不存在。

### FR-02 本地化资源与 zh-Hans 注册（P0）

- 新增 String Catalog：`Compositor/Localizable.xcstrings`，源语言 `en`。
- 工程 `knownRegions` 增加 `zh-Hans`；`Info.plist` 声明 `CFBundleLocalizations = [en, zh-Hans]`。
- 构建产物包含 `zh-Hans.lproj` 本地化资源。
- 键采用英文源文本；确需区分上下文时使用语义键 + 英文默认值。

**验收**：构建后 `Compositor.app/Contents/Resources/zh-Hans.lproj` 存在且可读取。

### FR-03 菜单与应用外壳（P0）

- 翻译应用菜单、文件、编辑、选择、图像、滤镜、图层、视图、窗口、帮助中的所有自定义项。
- 动态菜单标题（撤销/重做、最后一个滤镜、合并方式、删除效果）随状态正确显示中文。
- “打开最近使用”“清空菜单”等动态项本地化。
- 菜单快捷键字符（⌘Z 等）保持不变。

**验收**：中文模式下菜单栏显示“文件 / 编辑 / 图像 / 滤镜 / 图层 / 选择 / 视图”；撤销/重做名称随操作显示中文。

### FR-04 工具与工具提示（P0）

- 工具名：移动/变换、选框、套索、魔棒、裁剪、画笔、污点修复画笔、仿制图章、涂抹/模糊/液化、渐变、形状、文字、吸管、抓手、缩放。
- 工具提示中的操作说明（拖拽、按住 Shift、Tab 切换等）完整翻译。
- 工具参数面板的模式名同步翻译。

**验收**：悬停每个工具显示中文提示；切换工具模式时标题正确。

### FR-05 面板与表单（P0）

- 图层面板、混合模式列表、不透明度、蒙版操作。
- 调整/滤镜面板：色阶、曲线、色相/饱和度、色彩范围、曝光度、黑白、色彩平衡、渐变映射、颗粒、模糊、噪点等。
- Camera Raw 全部页签与滑杆：光线、颜色、颜色分级、效果、曲线、颜色混合器、细节、光学、几何、校准。
- 导出为：格式、尺寸、质量、位深、颜色、页码、循环、透明度、帧、背景等。
- 新建画布、画布大小、图像大小、裁切、网格设置。
- 快捷键设置面板。

**验收**：逐面板截图无英文残留；固定宽度控件不被截断。

### FR-06 AppKit 界面（P0）

- 图层右键菜单所有 `NSMenuItem`。
- 浮动面板标题。
- NSPopUpButton 中的混合模式显示名。
- NSAlert 标题、正文、按钮。
- 保存/打开面板标题与提示。
- 无障碍标签、tooltip。

**验收**：右键菜单、弹窗、面板标题均为中文；混合模式选择功能正常。

### FR-07 错误与导入报告（P1）

- 11 个 `LocalizedError` 文件的 `errorDescription`。
- PSD/PDF 转换报告、图层/文字/矢量转换说明。
- 导入失败、保存失败、外部修改冲突、更新失败等提示。

**验收**：制造常见错误（打开损坏文件、保存到只读位置、导入不支持的 PSD 特性）时提示为中文。

### FR-08 枚举显示层（P0）

- 所有作为界面文本的枚举增加 `displayName`，`rawValue` 保持不变。
- 覆盖：混合模式、调整类型、滤镜类型、图层效果、Camera Raw 各枚举、色阶通道、颜色范围、采样方式、形状类型、导出格式等。
- 持久化枚举（`LayerBlendMode`、`AdjustmentKind` 等）的 rawValue 不得修改。

**验收**：旧 `.comp` 文件打开/保存后 `blendMode`、`adjustment` 等字段值不变；界面显示中文。

### FR-09 快捷键设置（P1）

- 命令名、分组名、冲突/保留提示翻译为中文。
- 既有用户自定义快捷键配置继续有效，无需迁移。
- 快捷键字符与特殊键标签（Delete、Return、Esc 等）可本地化，但按键值不变。

**验收**：升级后原有自定义快捷键仍生效；快捷键设置面板为中文。

### FR-10 命令面板（P1）

- 面板界面、空状态、提示文案翻译。
- 中文标题可直接模糊搜索。
- 每个命令保留英文别名（如输入 `lasso` 可找到“套索”）。
- 不列出命令面板自身；Window/Help/Services 通过结构化方式排除，不依赖英文标题。
- 命令执行仍能正确定位菜单项。

**验收**：中文输入与英文别名均可命中和执行命令；混合模式/缩放等菜单命令执行正常。

### FR-11 新建默认名称（P2）

- 新建文档：未命名、未命名 2、未命名 3…
- 新建图层：图层 1、图层 2…
- 背景层：背景
- 组：组 1、组 2…
- 形状：矩形 1、椭圆 1、直线 1…
- PDF 导入页：第 1 页、第 2 页…
- 蒙版：图层蒙版
- 复制后缀：“ 拷贝”

**验收**：中文模式新建文档/图层得到中文默认名；旧项目名称不被改写；同名去重逻辑正确。

### FR-12 复数与格式串（P1）

- “还有 N 个标签页”“N 帧”“单数/复数提示”等改为 String Catalog 的复数/格式条目。
- 中文无复数变化，使用单一 `other` 形式；英文保留 one/other。
- 占位符支持位置参数（`%1$@`、`%2$lld`）以适应中文语序。

**验收**：不同数量下文案正确；无 `%` 占位符裸露。

### FR-13 Info.plist 元数据（P2）

- 应用显示名保持 “Compositor”。
- `CFBundleLocalizations` 声明 en / zh-Hans。
- 文档类型名（`CFBundleTypeName`、`UTTypeDescription`）无法通过 `InfoPlist.strings` 选择性本地化，保留英文并在发布说明中注明。

### FR-14 无障碍（P1）

- 所有 `.accessibilityLabel`、`setAccessibilityLabel` 翻译为中文。
- 无障碍 identifier（如 `zoomStatus`、`layerFilterAll`）保持不变，保证 UI 测试稳定。

**验收**：VoiceOver 朗读中文标签；UI 测试仍可通过 identifier 定位控件。

### FR-15 翻译审计工具（P1）

- 提供 `scripts/check-localization.py`：
  - en 与 zh-Hans 键覆盖率；
  - 空值/未翻译检测（含白名单）；
  - 占位符数量、类型、顺序一致性；
  - `L("…")` 运行时键与枚举 rawValue 的覆盖检查。
- 输出可读报告，非零退出码表示失败。

**验收**：审计脚本在完整 catalog 上通过；删除任一翻译可被检出。

## 7. 非功能需求

| 类别 | 要求 |
|---|---|
| 兼容性 | 不修改任何 Codable / `.comp` / UTI / 文件扩展名 / asset 名 / UserDefaults 键 |
| 数据安全 | 不翻译已有用户数据；不改变保存文件内容 |
| 确定性测试 | 单元测试与 UI 测试固定使用英文启动参数 |
| 性能 | 本地化查找不引入可感知启动或交互延迟 |
| 可维护性 | 英文源文本为键；术语表统一；新增字符串默认进入 catalog |
| 可访问性 | 中文标签 + 稳定 identifier 并存 |
| 可回退 | 英文模式与改动前行为一致；语言设置可恢复“跟随系统” |

## 8. 技术方案要点

### 8.1 本地化机制

- 使用 **String Catalog**（`Localizable.xcstrings`），由 Xcode 编译为各语言 `.strings`。
- SwiftUI 字面量 `Text("…")`、`Button("…")`、`.help("…")` 自动本地化，尽量不改。
- 非字面量/`String` 路径使用统一助手：

```swift
func L(_ key: String) -> String
func L(_ key: String, _ args: CVarArg...) -> String
```

- 插值优先使用 `String(localized: "Undo \(name)")`，确保键与占位符被正确提取。
- 枚举显示通过 `displayName`，`rawValue` 保持持久化语义。

### 8.2 语言切换

- 设置项持久化在 `appLanguage`。
- 写入应用域 `AppleLanguages`：`["zh-Hans"]` / `["en"]` / 删除（跟随系统）。
- 重启后 `Bundle.main` 与 AppKit 菜单按新语言加载。
- 不使用 `.environment(\.locale)` 作为替代，因为它不会切换 Bundle/AppKit 文案。

### 8.3 身份解耦（必须先行）

| 位置 | 现状 | 改造 |
|---|---|---|
| `ShortcutDefinition` | `id = group:title`，title 既显示又持久化 | 保留英文 title 作为稳定 ID，新增 `displayTitle` / `displayGroup` |
| `BlendModePicker` | 按标题反查枚举 | 使用 `representedObject` |
| 图层右键菜单 | 按 `"Add Mask"` 标题识别 | 使用 `NSUserInterfaceItemIdentifier` |
| 命令面板排除项 | 按英文标题集合跳过 | 用 `NSApp.windowsMenu/helpMenu/servicesMenu` 或 action 结构化判断 |
| 画布扩展/图像单位/裁切比例 | String 参与逻辑判断 | 改为枚举或稳定 key，显示层再本地化 |
| 色阶 Gamma 字段 | `name == "Gamma"` 控制范围 | 保留英文内部 key，仅显示本地化 |

### 8.4 关键文件

- `Compositor/Localizable.xcstrings`（新增）
- `Compositor/UI/Localization.swift`（新增，`L` 与 `LocalizedDisplayName`）
- `Compositor/UI/LanguageSettings.swift`（新增）
- `Compositor/CompositorApp.swift`（Settings scene、菜单）
- `Compositor/UI/KeyboardShortcuts.swift`
- `Compositor/UI/CommandPalette.swift`、`CommandPaletteView.swift`
- `Compositor/UI/BlendModePicker.swift`
- `Compositor/UI/NativeLayerList.swift`
- `Compositor/ContentView.swift`
- 各面板/表单/IO 文件（按阶段处理）

## 9. 风险与缓解

| 风险 | 影响 | 缓解 |
|---|---|---|
| 漏翻 String 路径 | 界面中英混杂 | 审计脚本 + 逐屏截图 + helper 参数统一改 `LocalizedStringKey` |
| 英文标题仍被当逻辑键 | 快捷键、混合模式、右键菜单、命令面板失效 | Phase 1 先解耦，再翻译；结构性 ID |
| 修改 rawValue | `.comp` 不兼容、资源名失效 | 代码规范：显示只用 `displayName` |
| 占位符错位/丢失 | 崩溃或文案错乱 | 位置参数 + 审计脚本校验 |
| 测试在中文系统失败 | CI/本地测试红 | scheme 与 UI 测试强制 `en`；优先 identifier |
| 中文截断 | 控件显示不全 | 逐屏视觉 QA，必要时调整宽度/换行 |
| 上游合并冲突 | 升级成本 | 本地化改动集中、文档化；合并时按模块解决 |
| Finder 文档类型名无法本地化 | 打开面板仍有英文类型名 | 列入已知限制，不阻塞验收 |

## 10. 实施阶段

| 阶段 | 内容 | 退出标准 |
|---|---|---|
| Phase 0 | Localization 助手、catalog 骨架、knownRegions、语言设置、测试强制英文 | 构建成功，设置窗口可用 |
| Phase 1 | 身份解耦（快捷键、混合模式、右键菜单、命令面板、单位/比例/Gamma） | 英文行为完全不变 |
| Phase 2 | 枚举 `displayName` 与显示点替换 | 旧项目兼容，显示层就绪 |
| Phase 3 | 菜单、状态栏、工具栏、标签页、命令面板文案 | 中文菜单与工具可用 |
| Phase 4 | 面板、表单、控件与 tooltip | 主要编辑面板中文完整 |
| Phase 5 | AppKit、弹窗、错误、撤销名、PSD/PDF 报告 | 弹窗与报告中文完整 |
| Phase 6 | 默认名称、复数、格式串 | 新建项目中文默认名正确 |
| Phase 7 | 翻译全量 catalog（术语表统一） | 审计脚本通过 |
| Phase 8 | 测试、逐屏 QA、截断修复 | 验收清单全部通过 |

## 11. 验收清单

- [ ] 工程可构建，`zh-Hans.lproj` 存在。
- [ ] 设置中三种语言选项可切换并持久化。
- [ ] 选择简体中文并重启后，菜单栏显示“文件 / 编辑 / 图像 / 滤镜 / 图层 / 选择 / 视图”。
- [ ] 菜单、工具提示、图层面板、右键菜单、所有表单、弹窗均为中文。
- [ ] Camera Raw、导出为、快捷键设置、PSD/PDF 导入报告为中文。
- [ ] 中文模式下打开旧 `.comp` 项目，图层名与混合模式值不变。
- [ ] 自定义快捷键升级后仍生效。
- [ ] 命令面板支持中文搜索与英文别名，命令可执行。
- [ ] 新建文档/图层得到中文默认名。
- [ ] 切回 English 后界面与改动前一致。
- [ ] 英文单元测试全部通过。
- [ ] `scripts/check-localization.py` 通过。
- [ ] 逐屏截图 QA 无英文残留、无明显截断。

## 12. 术语表（大陆 Photoshop）

### 12.1 核心界面

| English | 中文 |
|---|---|
| Layer | 图层 |
| Layer Mask | 图层蒙版 |
| Clipping Mask | 剪贴蒙版 |
| Blend Mode | 混合模式 |
| Opacity | 不透明度 |
| Fill | 填充 |
| Adjustment Layer | 调整图层 |
| Levels | 色阶 |
| Curves | 曲线 |
| Hue/Saturation | 色相/饱和度 |
| Color Balance | 色彩平衡 |
| Black & White | 黑白 |
| Gradient Map | 渐变映射 |
| Exposure | 曝光度 |
| Highlights / Shadows / Whites / Blacks | 高光 / 阴影 / 白色 / 黑色 |
| Texture / Clarity / Dehaze | 纹理 / 清晰度 / 去朦胧 |
| Vibrance / Saturation | 自然饱和度 / 饱和度 |
| Vignette | 晕影 |
| Grain | 颗粒 |
| Sharpen / Noise Reduction | 锐化 / 降噪 |
| Lens Correction | 镜头校正 |
| Transform | 变换 |
| Crop | 裁剪 |
| Canvas Size / Image Size | 画布大小 / 图像大小 |
| Trim | 裁切 |
| Select / Deselect / Inverse | 选择 / 取消选择 / 反选 |
| Feather / Expand / Contract | 羽化 / 扩展 / 收缩 |
| Color Range | 色彩范围 |
| Magic Wand | 魔棒 |
| Object Selection | 对象选择 |
| Lasso / Polygonal Lasso | 套索 / 多边形套索 |
| Marquee | 选框 |
| Move | 移动 |
| Brush / Eraser | 画笔 / 橡皮擦 |
| Spot Healing Brush | 污点修复画笔 |
| Clone Stamp | 仿制图章 |
| Gradient / Shape / Type | 渐变 / 形状 / 文字 |
| Eyedropper / Hand / Zoom | 吸管 / 抓手 / 缩放 |
| Foreground / Background Color | 前景色 / 背景色 |
| Duplicate Layer | 复制图层 |
| Layer via Copy | 通过拷贝的图层 |
| Group / Ungroup | 组 / 取消编组 |
| Merge Down / Merge Layers | 向下合并 / 合并图层 |
| Rasterize | 栅格化 |
| Layer Style | 图层样式 |
| Stroke / Drop Shadow | 描边 / 投影 |
| Inner Shadow / Outer Glow / Inner Glow | 内阴影 / 外发光 / 内发光 |
| Color Overlay | 颜色叠加 |
| Cancel / OK | 取消 / 确定 |

### 12.2 混合模式

正常、变暗、正片叠底、颜色加深、线性加深、变亮、滤色、颜色减淡、线性减淡（添加）、叠加、柔光、强光、亮光、线性光、点光、实色混合、差值、排除、减去、划分、色相、饱和度、颜色、明度。

### 12.3 保持英文

Compositor、Photoshop、Adobe、CMYK、RGB、HSL、ICC、sRGB、Display P3、PSD、PSB、PDF、GIF、PNG、JPEG、TIFF、EXR、HEIC、WebP、SVG、DPI、px、K、EV、Camera Raw、GPU。

## 13. 不翻译清单

- 所有枚举 `rawValue` 与 Codable / `.comp` 键
- UTI、文件扩展名、资源名、SF Symbol 名
- UserDefaults 键、通知名、`FloatingPanelController(name:)`
- 无障碍 identifier、快捷键字符
- 用户数据：已有图层名、项目名、导入文件名、PSD 图层名、字体名、ICC 配置名
- 调试日志、Metal/PSD 内部诊断文本
- 品牌名与第 12.3 节技术名词

## 14. 开放问题

1. 上游若未来开放翻译 PR，是否将本地方案整理为可合并的补丁？（当前不阻塞）
2. 是否发布带中文的独立 Release/DMG？（需用户后续决定签名与分发方式）
3. Finder 文档类型名的本地化需调整文档类型定义方式，当前列为已知限制。

---

*本文档为“compositer汉化包”项目的 PRD，后续实现与验收以此为准。*
