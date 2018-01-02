import ApplicativeRouter
import HttpPipeline
import Foundation
import Prelude
import Tuple

let expressUnsubscribeMiddleware =
{ (conn: Conn<StatusLineOpen, T4<Database.User?, Database.User.Id, Database.EmailSetting.Newsletter, Prelude.Unit>>) -> IO<Conn<StatusLineOpen, Prelude.Unit>> in

  let (_, userId, newsletter) = lower(conn.data)

  return AppEnvironment.current.database.fetchEmailSettingsForUserId(userId)
    .map { settings in settings.filter(^\.newsletter != newsletter) }
    .flatMap { settings in
      AppEnvironment.current.database.updateUser(userId, nil, nil, settings.map(^\.newsletter))
    }
    .run
    .map(const(conn.map(const(unit))))
  }
  >-> redirect(to: .secretHome)
