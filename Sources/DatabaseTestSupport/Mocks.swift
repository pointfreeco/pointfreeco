import Database
import Either
import Models
import ModelsTestSupport
import Optics
import PointFreePrelude
import PostgreSQL
import Prelude

extension Client {
  public static let mock = Client(
    addUserIdToSubscriptionId: { _, _ in pure(unit) },
    createEnterpriseAccount: { _, _, _ in pure(.mock) },
    createEnterpriseEmail: { _, _ in pure(.mock) },
    createFeedRequestEvent: { _, _, _ in pure(unit) },
    createSubscription: { _, _ in pure(.mock) },
    deleteEnterpriseEmail: { _ in pure(unit) },
    deleteTeamInvite: const(pure(unit)),
    execute: { _, _ in throwE(unit) },
    fetchAdmins: unzurry(pure([])),
    fetchEmailSettingsForUserId: const(pure([.mock])),
    fetchEnterpriseAccountForDomain: const(pure(.mock)),
    fetchEnterpriseAccountForSubscription: const(pure(.none)),
    fetchEnterpriseEmails: unzurry(pure([.mock])),
    fetchEpisodeCredits: const(pure([])),
    fetchFreeEpisodeUsers: { pure([.mock]) },
    fetchSubscriptionById: { pure(.some(.mock |> \.id .~ $0)) },
    fetchSubscriptionByOwnerId: { pure(.some(.mock |> \.userId .~ $0)) },
    fetchSubscriptionTeammatesByOwnerId: const(pure([.mock])),
    fetchTeamInvite: const(pure(.mock)),
    fetchTeamInvites: const(pure([])),
    fetchUserByGitHub: const(pure(.mock)),
    fetchUserById: { pure(.mock |> \.id .~ $0) },
    fetchUsersSubscribedToNewsletter: { _, _ in pure([.mock]) },
    fetchUsersToWelcome: const(pure([.mock])),
    incrementEpisodeCredits: const(pure([])),
    insertTeamInvite: { _, _ in pure(.mock) },
    migrate: unzurry(pure(unit)),
    redeemEpisodeCredit: { _, _ in pure(unit) },
    registerUser: { _, _ in pure(.some(.mock)) },
    removeTeammateUserIdFromSubscriptionId: { _, _ in pure(unit) },
    sawUser: const(pure(unit)),
    updateStripeSubscription: const(pure(.mock)),
    updateUser: { _, _, _, _, _ in pure(unit) },
    upsertUser: { _, _ in pure(.some(.mock)) }
  )
}
