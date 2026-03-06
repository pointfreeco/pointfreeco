import Cloudflare
import Dependencies
import Foundation
import HttpPipeline
import Prelude

func cloudflareStreamWebhookMiddleware(
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  guard validateCloudflareSignature(conn) else {
    return conn.writeStatus(.badRequest).respond(text: "Invalid signature.")
  }

  guard
    let body = conn.request.httpBody,
    let payload = try? JSONDecoder().decode(CloudflareStreamWebhookPayload.self, from: body),
    payload.readyToStream,
    payload.status.state == "ready"
  else {
    return conn.writeStatus(.ok).respond(text: "OK")
  }

  @Dependency(CloudflareClient.self) var cloudflare
  @Dependency(\.fireAndForget) var fireAndForget

  let videoID = Cloudflare.Video.ID(rawValue: payload.uid)
  await withErrorReporting {
    _ = try await cloudflare.generateCaption(videoID, "en")
  }

  return conn.writeStatus(.ok).respond(text: "OK")
}

struct CloudflareStreamWebhookPayload: Decodable {
  let uid: String
  let readyToStream: Bool
  let status: Status

  struct Status: Decodable {
    let state: String
  }
}

private func validateCloudflareSignature(
  _ conn: Conn<StatusLineOpen, Void>
) -> Bool {
  @Dependency(\.envVars.cloudflare.streamWebhookSecret) var webhookSecret

  guard
    let signatureHeader = conn.request.value(forHTTPHeaderField: "Webhook-Signature"),
    let payload = conn.request.httpBody.map({ String(decoding: $0, as: UTF8.self) })
  else {
    return false
  }

  let pairs = signatureHeader
    .split(separator: ",")
    .map { $0.split(separator: "=", maxSplits: 1) }

  guard
    let timePair = pairs.first(where: { $0.first == "time" }),
    let timeString = timePair.last.map(String.init),
    let sig1Pair = pairs.first(where: { $0.first == "sig1" }),
    let signature = sig1Pair.last.map(String.init),
    let expectedSignature = hexDigest(
      value: "\(timeString).\(payload)",
      asciiSecret: webhookSecret
    )
  else {
    return false
  }

  let constantTimeSignature =
    signature.count == expectedSignature.count
    ? signature
    : String(repeating: " ", count: expectedSignature.count)

  return zip(constantTimeSignature.utf8, expectedSignature.utf8).reduce(true) {
    $0 && $1.0 == $1.1
  }
}
