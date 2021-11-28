import CustomDump
import SnapshotTesting

extension Snapshotting where Format == String {
  public static var customDump: Snapshotting {
    return SimplySnapshotting.lines.pullback {
      var dump = ""
      CustomDump.customDump($0, to: &dump)
      return dump
    }
  }
}
