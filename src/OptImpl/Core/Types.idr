module OptImpl.Core.Types

%default total

||| Stable zero-based index into the append-only event log.
public export
record MessageId where
  constructor MkMessageId
  value : Nat

||| Event kind recorded in the durable log.
||| Model thoughts/reasoning are intentionally not representable here.
public export
data EventKind
  = User
  | Talk
  | Tool
  | Echo
  | Note
  | Work

public export
Eq EventKind where
  User == User = True
  Talk == Talk = True
  Tool == Tool = True
  Echo == Echo = True
  Note == Note = True
  Work == Work = True
  _ == _ = False

public export
Show EventKind where
  show User = "user"
  show Talk = "talk"
  show Tool = "tool"
  show Echo = "echo"
  show Note = "note"
  show Work = "work"

||| Timestamp representation is deliberately abstract at the first algebra pass.
||| Storage/API modules can later refine this to a parsed ISO timestamp.
public export
record Timestamp where
  constructor MkTimestamp
  iso8601 : String

||| Verbatim text payload after any adapter-level capping.
public export
record Payload where
  constructor MkPayload
  text : String

||| One append-only log event.
public export
record Event where
  constructor MkEvent
  id : MessageId
  kind : EventKind
  payload : Payload
  sizeBytes : Nat
  timestamp : Timestamp

||| Positive power-of-two width for a tree/view range.
||| The proof is represented computationally for now; future passes can refine
||| this into a stronger dependent representation.
public export
record Width where
  constructor MkWidth
  value : Nat

||| Half-open range [start, start + width).
public export
record Range where
  constructor MkRange
  start : MessageId
  width : Width

||| Summary text stored in a summary-tree node.
public export
record SummaryText where
  constructor MkSummaryText
  line : String

||| Built summary-tree node.
public export
record Node where
  constructor MkNode
  range : Range
  summary : SummaryText
  sizeBytes : Nat
