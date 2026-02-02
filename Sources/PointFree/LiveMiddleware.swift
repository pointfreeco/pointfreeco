import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreeDependencies
import PointFreeRouter
import Prelude
import Views

func liveMiddleware(
  _ conn: Conn<StatusLineOpen, Void>,
  route: Live
) async -> Conn<ResponseEnded, Data> {
  switch route {
  case .current:
    return await currentLivestream(conn)
  }
}

private func currentLivestream(
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.livestreams) var livestreams: [Livestream]
  @Dependency(\.date.now) var now
  let activeLivestream = livestreams.first(where: \.isActive)
  let isLive = livestreams.first(where: \.isLive) != nil

  let image: String
  if isLive {
    // Live
    image = "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/f6a70e6f-5224-44ca-9910-5db242830300/public"
  } else if let activeLivestream, let scheduledAt = activeLivestream.scheduledAt {
    if scheduledAt.timeIntervalSince(now) <= 12 * 60 * 60 {
      // Starting soon
      image = "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/e487c270-5f5f-481e-3aac-65a5975ed700/public"
    } else {
      // Scheduled
      image = "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/f41dfcdc-3772-47af-bada-38e805bd5900/public"
    }
  } else {
    // Default
    image = "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/20cf9cfd-6c6b-4a72-9673-78325ea32d00/public"
  }

  return
    conn
    .writeStatus(.ok)
    .respondV2(
      layoutData: SimplePageLayoutData(
        description: isLive
          ? """
          We are livestreaming right now! Tune in to hear us discuss topics from episodes,
          explore our open source libraries, and take questions from our viewers.
          """
          : """
          Point-Free Live is a periodic livestream where we discuss topics from episodes, explore
          our open source libraries, and take questions from our viewers.
          """,
        image: image,
        style: .base(.minimal(.black)),
        title: "🔴 Point-Free Live"
      )
    ) {
      LiveView()
    }
}
