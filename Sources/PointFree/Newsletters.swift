import HttpPipeline
import Foundation
import Prelude
import Tuple

let expressUnsubscribeMiddleware: Middleware<StatusLineOpen, ResponseEnded, T4<Database.User?, Database.User.Id, Database.EmailSetting.Newsletter, Prelude.Unit>, Data> =

  { conn in

    let (_, userId, newsletter) = lower(conn.data)

    let tmp = AppEnvironment.current.database.fetchEmailSettingsForUserId(userId)
      .map { settings in
        settings.filter(^\.newsletter != newsletter)
      }
//      .flatMap { }

    fatalError()
}
