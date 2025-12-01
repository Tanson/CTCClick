import Foundation

// 获取应用组的UserDefaults
let groupDefaults = UserDefaults(suiteName: "group.cn.tanson.CTCClick")!

// 初始化默认的actions配置
let actions = [
    ["id": "copy-path", "name": "Copy Path", "enabled": true, "idx": 0, "icon": "doc.on.doc"],
    ["id": "delete-direct", "name": "Delete Direct", "enabled": true, "idx": 1, "icon": "trash"],
    ["id": "airdrop", "name": "AirDrop", "enabled": true, "idx": 4, "icon": "paperplane"],
    ["id": "hide", "name": "Hide", "enabled": true, "idx": 2, "icon": "eye.slash"],
    ["id": "unhide", "name": "Unhide", "enabled": true, "idx": 3, "icon": "eye"]
]

// 初始化默认的新建文件类型配置
let newFiles = [
    ["ext": ".txt", "name": "TXT", "enabled": true, "idx": 1, "icon": "icon-file-txt", "id": UUID().uuidString],
    ["ext": ".md", "name": "Markdown", "enabled": true, "idx": 2, "icon": "icon-file-md", "id": UUID().uuidString],
    ["ext": ".json", "name": "JSON", "enabled": true, "idx": 0, "icon": "icon-file-json", "id": UUID().uuidString]
]

// 编码并保存
let encoder = PropertyListEncoder()

do {
    let actionsData = try encoder.encode(actions)
    groupDefaults.set(actionsData, forKey: "actions")
    
    let newFilesData = try encoder.encode(newFiles)
    groupDefaults.set(newFilesData, forKey: "fileTypes")
    
    // 设置空的常用目录和应用列表
    groupDefaults.set(Data(), forKey: "commonDirs")
    groupDefaults.set(Data(), forKey: "apps")
    
    groupDefaults.synchronize()
    print("配置初始化成功")
} catch {
    print("配置初始化失败: \(error)")
}
