/// Shared parameter records for `.family` providers. Dart records have
/// structural equality out of the box, which is exactly what
/// `StreamProvider.family`/`Provider.family` need to cache correctly.
typedef DateParams = ({String messId, DateTime date});
typedef MonthParams = ({String messId, int year, int month});
typedef MemberParams = ({String messId, String memberId});
