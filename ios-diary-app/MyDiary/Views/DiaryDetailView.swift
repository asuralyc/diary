import SwiftUI

struct DiaryDetailView: View {
    @EnvironmentObject var diaryStore: DiaryStore
    @Environment(\.dismiss) var dismiss
    
    let entry: DiaryEntry
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false
    @State private var showingShareSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                EntryHeader(entry: entry)
                
                // Title
                if !entry.title.isEmpty {
                    Text(entry.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                }
                
                // Content
                Text(entry.content)
                    .font(.body)
                    .lineSpacing(4)
                    .multilineTextAlignment(.leading)
                
                // Tags
                if !entry.tags.isEmpty {
                    TagsView(tags: entry.tags)
                }
                
                // Metadata
                EntryMetadata(entry: entry)
                
                Spacer(minLength: 50)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingEditView = true
                    } label: {
                        Label("編輯", systemImage: "pencil")
                    }
                    
                    Button {
                        showingShareSheet = true
                    } label: {
                        Label("分享", systemImage: "square.and.arrow.up")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("刪除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            WriteEntryView(editingEntry: entry)
        }
        .alert("確認刪除", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("刪除", role: .destructive) {
                diaryStore.deleteEntry(entry)
                dismiss()
            }
        } message: {
            Text("確定要刪除這篇日記嗎？此操作無法復原。")
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(entry: entry)
        }
    }
}

// MARK: - Entry Header
struct EntryHeader: View {
    let entry: DiaryEntry
    
    var body: some View {
        VStack(spacing: 16) {
            // Date
            Text(entry.date, style: .date)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Mood and Weather
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text(entry.mood.emoji)
                        .font(.system(size: 40))
                    
                    Text(entry.mood.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(entry.mood.color)
                }
                
                if let weather = entry.weather {
                    VStack(spacing: 8) {
                        Text(weather.emoji)
                            .font(.system(size: 32))
                        
                        Text(weather.title)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

// MARK: - Tags View
struct TagsView: View {
    let tags: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("標籤")
                .font(.headline)
                .fontWeight(.semibold)
            
            FlowLayout(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.indigo.opacity(0.1))
                        .foregroundColor(.indigo)
                        .cornerRadius(16)
                }
            }
        }
    }
}

// MARK: - Entry Metadata
struct EntryMetadata: View {
    let entry: DiaryEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("字數")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(entry.content.count) 字")
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("建立時間")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(entry.createdAt, format: .dateTime.day().month().year().hour().minute())
                        .fontWeight(.medium)
                }
                
                if entry.modifiedAt != entry.createdAt {
                    HStack {
                        Text("最後編輯")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(entry.modifiedAt, format: .dateTime.day().month().year().hour().minute())
                            .fontWeight(.medium)
                    }
                }
            }
            .font(.subheadline)
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let entry: DiaryEntry
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let shareText = generateShareText()
        let activityController = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        return activityController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    
    private func generateShareText() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.dateStyle = .full
        
        var shareText = "\(formatter.string(from: entry.date))\n"
        shareText += "心情：\(entry.mood.emoji) \(entry.mood.title)\n"
        
        if let weather = entry.weather {
            shareText += "天氣：\(weather.emoji) \(weather.title)\n"
        }
        
        shareText += "\n"
        
        if !entry.title.isEmpty {
            shareText += "\(entry.title)\n\n"
        }
        
        shareText += entry.content
        
        if !entry.tags.isEmpty {
            shareText += "\n\n標籤：\(entry.tags.joined(separator: "、"))"
        }
        
        return shareText
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    let spacing: CGFloat
    
    init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        
        for (index, subview) in subviews.enumerated() {
            let origin = CGPoint(
                x: result.frames[index].origin.x + bounds.origin.x,
                y: result.frames[index].origin.y + bounds.origin.y
            )
            subview.place(at: origin, proposal: .unspecified)
        }
    }
}

struct FlowResult {
    let size: CGSize
    let frames: [CGRect]
    
    init(in maxWidth: CGFloat, subviews: LayoutSubviews, spacing: CGFloat) {
        var currentPosition = CGPoint.zero
        var lineHeight: CGFloat = 0
        var maxY: CGFloat = 0
        var frames: [CGRect] = []
        
        for subview in subviews {
            let subviewSize = subview.sizeThatFits(.unspecified)
            
            if currentPosition.x + subviewSize.width > maxWidth && currentPosition.x > 0 {
                // Move to next line
                currentPosition.x = 0
                currentPosition.y += lineHeight + spacing
                lineHeight = 0
            }
            
            let frame = CGRect(origin: currentPosition, size: subviewSize)
            frames.append(frame)
            
            currentPosition.x += subviewSize.width + spacing
            lineHeight = max(lineHeight, subviewSize.height)
            maxY = max(maxY, currentPosition.y + lineHeight)
        }
        
        self.frames = frames
        self.size = CGSize(width: maxWidth, height: maxY)
    }
}

#Preview {
    NavigationView {
        DiaryDetailView(entry: DiaryEntry(
            date: Date(),
            title: "預覽日記",
            content: "這是一個預覽用的日記內容",
            mood: .happy,
            weather: .sunny,
            tags: ["預覽"],
            createdAt: Date(),
            modifiedAt: Date()
        ))
        .environmentObject(DiaryStore())
    }
}
