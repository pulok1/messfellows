/// Lifecycle of a monthly settlement. Closing a month freezes its settlement
/// so later edits to that month's data don't silently change a result
/// someone has already been paid against.
enum SettlementStatus { open, closed }
