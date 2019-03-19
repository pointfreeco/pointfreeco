import Tagged

public typealias EmailAddress = Tagged<(email: (), String), String>
public typealias EmailLocalPart = Tagged<(localPart: (), String), String>
