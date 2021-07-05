import Foundation
import RxDataSources

final class Acronym: Codable {
  var id: UUID?
  var short: String
  var long: String
  var user: AcronymUser

  init(short: String, long: String, userID: UUID) {
    self.short = short
    self.long = long
    let user = AcronymUser(id: userID)
    self.user = user
  }
}

extension Acronym: IdentifiableType {
  var identity: String {
    self.id?.uuidString ?? "0"
  }
}

extension Acronym: Equatable {
  static func == (lhs: Acronym, rhs: Acronym) -> Bool {
    lhs.id == rhs.id
  }
}

final class AcronymUser: Codable {
  var id: UUID

  init(id: UUID) {
    self.id = id
  }
}
