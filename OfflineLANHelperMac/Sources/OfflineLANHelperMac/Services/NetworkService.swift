import Foundation
import Darwin
import Combine

struct LANAddress: Identifiable, Hashable {
    var id: String { "\(interface)-\(ip)" }
    let interface: String
    let ip: String
}

final class NetworkService: ObservableObject {
    @Published var hostname: String = Host.current().localizedName ?? ProcessInfo.processInfo.hostName
    @Published var addresses: [LANAddress] = []

    var primaryIP: String {
        addresses.first?.ip ?? ""
    }

    init() {
        refresh()
    }

    func refresh() {
        hostname = Host.current().localizedName ?? ProcessInfo.processInfo.hostName
        var found: [LANAddress] = []

        var interfaces: UnsafeMutablePointer<ifaddrs>?
        if getifaddrs(&interfaces) == 0, let first = interfaces {
            defer { freeifaddrs(interfaces) }
            var cursor: UnsafeMutablePointer<ifaddrs>? = first

            while let current = cursor {
                let item = current.pointee
                cursor = item.ifa_next

                guard let address = item.ifa_addr, address.pointee.sa_family == UInt8(AF_INET) else {
                    continue
                }

                var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                let result = getnameinfo(
                    address,
                    socklen_t(address.pointee.sa_len),
                    &host,
                    socklen_t(host.count),
                    nil,
                    0,
                    NI_NUMERICHOST
                )

                guard result == 0 else {
                    continue
                }

                let ip = String(cString: host)
                guard Self.isPrivateIPv4(ip) else {
                    continue
                }

                let name = String(cString: item.ifa_name)
                found.append(LANAddress(interface: name, ip: ip))
            }
        }

        var unique: [String: LANAddress] = [:]
        for address in found {
            unique[address.ip] = address
        }
        addresses = unique.values.sorted { lhs, rhs in
            let leftScore = Self.preferenceScore(lhs.ip)
            let rightScore = Self.preferenceScore(rhs.ip)
            if leftScore != rightScore {
                return leftScore < rightScore
            }
            return lhs.ip < rhs.ip
        }
    }

    private static func isPrivateIPv4(_ ip: String) -> Bool {
        let parts = ip.split(separator: ".").compactMap { Int($0) }
        guard parts.count == 4 else {
            return false
        }
        if parts[0] == 10 {
            return true
        }
        if parts[0] == 192 && parts[1] == 168 {
            return true
        }
        if parts[0] == 172 && (16...31).contains(parts[1]) {
            return true
        }
        return false
    }

    private static func preferenceScore(_ ip: String) -> Int {
        if ip.hasPrefix("192.168.") {
            return 0
        }
        if ip.hasPrefix("10.") {
            return 1
        }
        if ip.hasPrefix("172.") {
            return 2
        }
        return 3
    }
}
