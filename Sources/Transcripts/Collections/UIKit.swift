extension Episode.Collection {
  public static let uiKit = Self(
    blurb: #"""
      SwiftUI may be all the rage these days, but that doesn't mean you won't occassionally need
      to dip your toes into the UIKit waters. Whether it be due to access some functionality not
      yet available in SwiftUI, or for performance reasons (`UICollectionView` 😍), you will
      eventually find yourself subclassing `UIViewController`, and then the question becomes:
      what is the most modern way to do this?
      """#,
    sections: [
      .init(
        alternateSlug: nil,
        blurb: #"""
          SwiftUI may be all the rage these days, but that doesn't mean you won't occassionally need
          to dip your toes into the UIKit waters. Whether it be due to access some functionality not
          yet available in SwiftUI, or for performance reasons (`UICollectionView` 😍), you will
          eventually find yourself subclassing `UIViewController`, and then the question becomes:
          what is the most modern way to do this?
          """#,
        coreLessons: [
          .init(episode: .ep281_modernUIKit),
          .init(episode: .ep282_modernUIKit),
        ],
        isFinished: false,
        isHidden: false,
        related: [],
        title: "Modern UIKit",
        whereToGoFromHere: nil
      )
    ],
    title: "UIKit"
  )
}
