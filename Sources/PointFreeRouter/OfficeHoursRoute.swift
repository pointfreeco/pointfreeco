import Cloudflare
import Models
import URLRouting

public enum OfficeHoursRoute: Equatable {
  case index
  case officeHour(cloudflareVideoID: Cloudflare.Video.ID)
}

struct OfficeHoursRouter: ParserPrinter {
  var body: some Router<OfficeHoursRoute> {
    OneOf {
      Route(.case(OfficeHoursRoute.officeHour(cloudflareVideoID:))) {
        Path {
          Rest().map(.string.representing(Cloudflare.Video.ID.self))
        }
      }
      Route(.case(OfficeHoursRoute.index))
    }
  }
}
