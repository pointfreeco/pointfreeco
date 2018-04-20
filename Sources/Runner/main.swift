import PointFree

// Bootstrap

_ = try! PointFree
  .bootstrap()
  .run
  .perform()
  .unwrap()
