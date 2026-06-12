import SwiftUI

// MARK: - Brand colors (disciplined teal-green palette)
extension Color {
    static let dewsCalm   = Color(red: 0.06, green: 0.43, blue: 0.34)  // teal-green, primary
    static let dewsCalmBg = Color(red: 0.88, green: 0.96, blue: 0.93)  // light teal surface
    static let dewsDone   = Color(red: 0.11, green: 0.62, blue: 0.46)  // checked state
    static let dewsAlert  = Color(red: 0.64, green: 0.18, blue: 0.18)  // alert red, emergency only
    static let dewsAmber  = Color(red: 0.73, green: 0.46, blue: 0.09)  // warning amber
}

// MARK: - Language
// LEARNING SHORTCUT: a simple in-code dictionary instead of Apple's
// Localizable.strings system. Easy to learn now, easy to migrate later.
enum Lang: String { case en, zh }

struct L {
    let lang: Lang
    func t(_ en: String, _ zh: String) -> String { lang == .en ? en : zh }
}

// MARK: - Checklist model
struct ChecklistItem: Identifiable, Codable {
    var id = UUID()
    var titleEN: String
    var titleZH: String
    var done: Bool
}

// MARK: - Root: dashboard + navigation
struct ContentView: View {
    @AppStorage("language") private var languageRaw = Lang.en.rawValue
    private var lang: Lang { Lang(rawValue: languageRaw) ?? .en }
    private var loc: L { L(lang: lang) }

    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    // Intro line
                    VStack(alignment: .leading, spacing: 4) {
                        Text(loc.t("Be ready for anything",
                                   "为任何情况做好准备"))
                            .font(.title2).fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(loc.t("Everything here works with no signal.",
                                   "这里的一切都无需信号即可使用。"))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Three MVP cards
                    NavigationLink {
                        StayReadyView(loc: loc)
                    } label: {
                        DashCard(icon: "checklist",
                                 title: loc.t("Stay ready", "保持准备"),
                                 subtitle: loc.t("Tips and your checklist",
                                                 "贴士和你的清单"),
                                 tint: .dewsCalm)
                    }

                    NavigationLink {
                        EmergencyView(loc: loc)
                    } label: {
                        DashCard(icon: "exclamationmark.triangle.fill",
                                 title: loc.t("Emergency", "紧急情况"),
                                 subtitle: loc.t("What to do right now",
                                                 "现在该怎么做"),
                                 tint: .dewsAlert)
                    }

                    NavigationLink {
                        NearbyView(loc: loc)
                    } label: {
                        DashCard(icon: "mappin.and.ellipse",
                                 title: loc.t("Nearby help", "附近的帮助"),
                                 subtitle: loc.t("Shelters, water, hospitals",
                                                 "避难所、水、医院"),
                                 tint: .dewsAmber)
                    }
                }
                .padding()
            }
            .navigationTitle("DEWS")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(languageRaw: $languageRaw, loc: loc)
            }
        }
    }
}

// MARK: - Dashboard card
struct DashCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let tint: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(tint)
                .frame(width: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.secondary.opacity(0.2))
        )
    }
}

// MARK: - MVP 3 + tips: Stay ready
struct StayReadyView: View {
    let loc: L

    private var tips: [String] {
        loc.lang == .en ? [
            "Keep shoes by your bed. Earthquakes scatter broken glass, and you'll move faster if your feet are protected.",
            "Store water in advance: aim for 4 litres per person per day, enough for three days.",
            "Pick a family meeting point outside your home, in case you can't get back inside.",
            "Charge a power bank weekly. In an outage, a phone is your link to help and information."
        ] : [
            "在床边放一双鞋。地震会让玻璃碎片散落一地，保护好双脚你就能更快行动。",
            "提前储水：每人每天约 4 升，足够三天使用。",
            "在家外面选一个家庭集合点，以防你无法回到屋内。",
            "每周给充电宝充电。停电时，手机是你联系求助和获取信息的纽带。"
        ]
    }

    @AppStorage("tipIndex") private var tipIndex = 0
    @AppStorage("checklistData") private var checklistData = Data()
    @State private var items: [ChecklistItem] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Tip card
                HStack(alignment: .top) {
                    Text(tips[min(tipIndex, tips.count - 1)])
                        .font(.subheadline)
                        .foregroundStyle(Color.dewsCalm)
                    Spacer()
                    Button {
                        tipIndex = (tipIndex + 1) % tips.count
                    } label: {
                        Image(systemName: "xmark").foregroundStyle(Color.dewsCalm)
                    }
                }
                .padding()
                .background(Color.dewsCalmBg)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(loc.t("Tip \(tipIndex + 1) of \(tips.count) · dismissed tips are saved",
                           "第 \(tipIndex + 1) / \(tips.count) 条 · 已关闭的贴士会被保存"))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .center)

                // Checklist
                VStack(alignment: .leading, spacing: 8) {
                    Label(loc.t("Readiness checklist", "准备清单"),
                          systemImage: "checklist")
                        .font(.headline)

                    ForEach($items) { $item in
                        Button {
                            item.done.toggle()
                            saveItems()
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: item.done ? "checkmark.square.fill" : "square")
                                    .foregroundStyle(item.done ? Color.dewsDone : Color.secondary)
                                Text(loc.lang == .en ? item.titleEN : item.titleZH)
                                    .strikethrough(item.done)
                                    .foregroundStyle(item.done ? Color.secondary : Color.primary)
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary.opacity(0.2)))
            }
            .padding()
        }
        .navigationTitle(loc.t("Stay ready", "保持准备"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadItems)
    }

    private func loadItems() {
        if let decoded = try? JSONDecoder().decode([ChecklistItem].self, from: checklistData),
           !decoded.isEmpty {
            items = decoded
        } else {
            items = [
                ChecklistItem(titleEN: "Set emergency contacts", titleZH: "设置紧急联系人", done: false),
                ChecklistItem(titleEN: "Choose a meeting point", titleZH: "选择集合地点", done: false),
                ChecklistItem(titleEN: "Pack a go-bag", titleZH: "准备应急包", done: false)
            ]
            saveItems()
        }
    }

    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            checklistData = encoded
        }
    }
}

// MARK: - MVP 1: Emergency mode
struct EmergencyView: View {
    let loc: L
    @State private var selected: String? = nil   // "quake", "flood", "fire"

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                Text(loc.t("What's happening?", "发生了什么？"))
                    .font(.title3).fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(loc.t("Tap one. Large buttons, no menus.",
                           "点击一个。大按钮，无菜单。"))
                    .font(.footnote).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                bigButton(key: "quake",
                          label: loc.t("Earthquake", "地震"),
                          icon: "waveform.path", color: .dewsAlert)
                bigButton(key: "flood",
                          label: loc.t("Flood", "洪水"),
                          icon: "drop.fill", color: Color(red: 0.10, green: 0.37, blue: 0.65))
                bigButton(key: "fire",
                          label: loc.t("Wildfire", "野火"),
                          icon: "flame.fill", color: .dewsAmber)

                if let sel = selected {
                    steps(for: sel)
                }
            }
            .padding()
        }
        .navigationTitle(loc.t("Emergency", "紧急情况"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func bigButton(key: String, label: String, icon: String, color: Color) -> some View {
        Button {
            selected = key
        } label: {
            HStack {
                Image(systemName: icon)
                Text(label).fontWeight(.semibold)
                Spacer()
            }
            .font(.title3)
            .foregroundStyle(.white)
            .padding()
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    @ViewBuilder
    private func steps(for key: String) -> some View {
        let lines: [(String, String)] = {
            switch key {
            case "quake":
                return loc.lang == .en ? [
                    ("Step 1 · now", "Drop to the ground before it knocks you down."),
                    ("Step 2", "Cover your head and neck under a sturdy table."),
                    ("Step 3", "Hold on until the shaking fully stops.")
                ] : [
                    ("第 1 步 · 立即", "在被震倒前主动趴下。"),
                    ("第 2 步", "在坚固的桌子下护住头和颈部。"),
                    ("第 3 步", "抓牢，直到摇晃完全停止。")
                ]
            case "flood":
                return loc.lang == .en ? [
                    ("Step 1 · now", "Move to higher ground immediately."),
                    ("Step 2", "Never walk or drive through moving water."),
                    ("Step 3", "Avoid downed power lines and report them.")
                ] : [
                    ("第 1 步 · 立即", "立刻转移到高地。"),
                    ("第 2 步", "切勿涉水或驾车穿过流动的水。"),
                    ("第 3 步", "远离倒下的电线并上报。")
                ]
            default:
                return loc.lang == .en ? [
                    ("Step 1 · now", "Leave early. Don't wait to see the fire."),
                    ("Step 2", "Cover nose and mouth to reduce smoke inhalation."),
                    ("Step 3", "Follow official evacuation routes only.")
                ] : [
                    ("第 1 步 · 立即", "尽早撤离。不要等到看见火才走。"),
                    ("第 2 步", "捂住口鼻，减少吸入烟雾。"),
                    ("第 3 步", "只走官方撤离路线。")
                ]
            }
        }()

        VStack(spacing: 8) {
            ForEach(lines, id: \.0) { line in
                VStack(alignment: .leading, spacing: 3) {
                    Text(line.0).font(.caption).foregroundStyle(Color.dewsAmber)
                    Text(line.1).font(.body).foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.dewsAmber.opacity(0.12))
                .overlay(Rectangle().frame(width: 3).foregroundStyle(Color.dewsAmber),
                         alignment: .leading)
            }
        }
        .padding(.top, 4)
    }
}

// MARK: - MVP 2: Nearby help (simple list version, no map/GPS yet)
struct NearbyView: View {
    let loc: L

    struct Place: Identifiable {
        let id = UUID()
        let icon: String
        let nameEN: String
        let nameZH: String
        let detailEN: String
        let detailZH: String
        let color: Color
    }

    private var places: [Place] {
        [
            Place(icon: "house.fill",
                  nameEN: "Riverside Community Hall", nameZH: "河滨社区中心",
                  detailEN: "Shelter · 400m north · enter from Oak St",
                  detailZH: "避难所 · 向北 400 米 · 从橡树街进入", color: .dewsCalm),
            Place(icon: "cross.fill",
                  nameEN: "Central Hospital", nameZH: "中心医院",
                  detailEN: "Hospital · 1.2km east · 24-hour A&E",
                  detailZH: "医院 · 向东 1.2 公里 · 24 小时急诊", color: .dewsAlert),
            Place(icon: "drop.fill",
                  nameEN: "Park water point", nameZH: "公园供水点",
                  detailEN: "Water · 600m south · standpipe near gate",
                  detailZH: "供水 · 向南 600 米 · 大门附近的水龙头", color: Color(red: 0.10, green: 0.37, blue: 0.65)),
            Place(icon: "bolt.fill",
                  nameEN: "Library charging station", nameZH: "图书馆充电站",
                  detailEN: "Power · 800m west · open 9am-6pm",
                  detailZH: "电力 · 向西 800 米 · 上午9点至下午6点开放", color: .dewsAmber)
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(loc.t("Saved offline · works without data.",
                           "已离线保存 · 无需数据即可使用。"))
                    .font(.footnote).foregroundStyle(.secondary)

                ForEach(places) { p in
                    HStack(spacing: 14) {
                        Image(systemName: p.icon)
                            .font(.title3).foregroundStyle(p.color).frame(width: 32)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(loc.lang == .en ? p.nameEN : p.nameZH)
                                .font(.headline)
                            Text(loc.lang == .en ? p.detailEN : p.detailZH)
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.secondary.opacity(0.2)))
                }

                Text(loc.t("Map view coming soon.", "地图视图即将推出。"))
                    .font(.caption).foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 4)
            }
            .padding()
        }
        .navigationTitle(loc.t("Nearby help", "附近的帮助"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Settings (language)
struct SettingsView: View {
    @Binding var languageRaw: String
    let loc: L
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(loc.t("Language", "语言")) {
                    Picker(loc.t("Language", "语言"), selection: $languageRaw) {
                        Text("English").tag(Lang.en.rawValue)
                        Text("中文").tag(Lang.zh.rawValue)
                    }
                    .pickerStyle(.inline)
                }
            }
            .navigationTitle(loc.t("Settings", "设置"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(loc.t("Done", "完成")) { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
