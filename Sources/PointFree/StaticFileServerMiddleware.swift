import HttpPipeline
import Prelude
import Foundation

// todo: move to httppipeline

public func staticFileServer(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data>
  )
  -> Middleware<StatusLineOpen, ResponseEnded, Data, Data> {

    let currentFile = #file
    let rootDir = URL(fileURLWithPath: currentFile)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()

    return { conn in
      let fileManager = FileManager.default
      guard
        let filePath = conn.request.url.map({
          rootDir
            .appendingPathComponent("public")
            .appendingPathComponent($0.path)
            .path
        }),
        fileManager.fileExists(atPath: filePath)
        else { return middleware(conn.map(const(unit))) }

      let fileUrl = URL(fileURLWithPath: filePath)
      guard let data = try? Foundation.Data(contentsOf: fileUrl)
        else { return middleware(conn.map(const(unit))) }

      return conn
        |> writeStatus(.ok)
        >=> writeHeader("Content-Length", String(data.count))
        >=> writeHeader("Content-Type", "application/octet-stream")
        >=> closeHeaders
        >=> send(data)
        >=> end
    }
}
