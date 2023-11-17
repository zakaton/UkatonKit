var isWatch: Bool {
    #if os(watchOS)
    true
    #else
    false
    #endif
}
