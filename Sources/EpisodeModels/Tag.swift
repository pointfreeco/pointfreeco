public struct Tag: Equatable, Hashable {
  public var name: String
  
  public init(name: String) {
    self.name = name
  }
  
  public static let all = (
    algebra: Tag(name: "Algebra"),
    dsl: Tag(name: "DSL"),
    generics: Tag(name: "Generics"),
    html: Tag(name: "HTML"),
    math: Tag(name: "Math"),
    polymorphism: Tag(name: "Polymorphism"),
    programming: Tag(name: "Programming"),
    serverSideSwift: Tag(name: "Server-Side Swift"),
    swift: Tag(name: "Swift")
  )
  
  public static func ==(lhs: Tag, rhs: Tag) -> Bool {
    return lhs.name == rhs.name
  }
  
  public var hashValue: Int {
    return self.name.hashValue
  }
}
