import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreeDependencies
import PointFreeRouter
import Prelude
import Views

func officeHoursMiddleware(
  _ conn: Conn<StatusLineOpen, OfficeHoursRoute>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.database) var database
  do {
    switch conn.data {
    case let .officeHour(cloudflareVideoID: cloudflareVideoID):
      let officeHour = try await database.fetchOfficeHour(cloudflareVideoID: cloudflareVideoID)
      return await officeHourMiddleware(officeHour: officeHour, conn: conn.map(const(())))

    case .index:
      return await officeHoursIndexMiddleware(conn.map(const(())))
    }
  } catch {
    return routeNotFoundMiddleware(conn)
  }
}

private func officeHourMiddleware(
  officeHour: OfficeHour,
  conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.subscriberState) var subscriberState

  guard subscriberState.isMaxSubscriber else {
    return conn.redirect(to: .officeHours()) {
      $0.flash(.error, "You must be a Point-Free Max subscriber to watch office hours.")
    }
  }

  return conn
    .writeStatus(.ok)
    .respondV2(
      layoutData: SimplePageLayoutData(
        description: officeHour.blurb,
        image: officeHour.posterURL,
        title: officeHour.title
      )
    ) {
      OfficeHourDetail(officeHour: officeHour)
    }
}

private func officeHoursIndexMiddleware(
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.database) var database
  do {
    let officeHours = try await database.fetchOfficeHours()

    return
      conn
      .writeStatus(.ok)
      .respondV2(
        layoutData: SimplePageLayoutData(
          description: """
            Periodic livestreams exclusively for Point-Free Max subscribers.
            """,
          title: "Point-Free Office Hours"
        )
      ) {
        OfficeHoursIndex(officeHours: officeHours)
      }
  } catch {
    return routeNotFoundMiddleware(conn)
  }
}
