// Station ALMA-7, Part II: The Teleporter Incident

// ===== STARTER DATA (not modified) =====

func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// ===== END OF STARTER DATA =====


// Level 1

enum Deck: String, CaseIterable {
    case bridge, lab, cargo, medbay, engine

    var evacuationPriority: Int {
        switch self {
        case .bridge: return 1
        case .medbay: return 2
        case .lab: return 3
        case .engine: return 4
        case .cargo: return 5
        }
    }
}

for deck in Deck.allCases {
    print(deck.rawValue, deck.evacuationPriority)
}

enum AlarmLevel: Int {
    case green = 0
    case yellow, orange, red

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let step = mass / 500
        let clamped = min(step, AlarmLevel.red.rawValue)
        return AlarmLevel(rawValue: clamped) ?? .red
    }
}

print(AlarmLevel.level(forTotalMass: 0))
print(AlarmLevel.level(forTotalMass: 940))
print(AlarmLevel.level(forTotalMass: 4000))


// Level 2

enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}

func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line)
    guard let tag = parts.first else { return .unknown(raw: line) }
    switch tag {
    case "crate":
        guard parts.count == 3, let id = Int(parts[1]), let massKg = Int(parts[2]) else {
            return .unknown(raw: line)
        }
        return .crate(id: id, massKg: massKg)
    case "container":
        guard parts.count == 3, let massKg = Int(parts[2]) else {
            return .unknown(raw: line)
        }
        return .container(code: parts[1], massKg: massKg)
    case "livestock":
        guard parts.count == 4, let count = Int(parts[2]), let massPerUnitKg = Int(parts[3]) else {
            return .unknown(raw: line)
        }
        return .livestock(species: parts[1], count: count, massPerUnitKg: massPerUnitKg)
    default:
        return .unknown(raw: line)
    }
}

print(parseEntry("crate:101:120"))
print(parseEntry("livestock:lab mice:12:2"))
print(parseEntry("???-corrupted-line"))

func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case .crate(_, let massKg): return massKg
    case .container(_, let massKg): return massKg
    case .livestock(_, let count, let massPerUnitKg): return count * massPerUnitKg
    case .unknown: return 0
    }
}

var manifestEntries: [ManifestEntry] = []
for line in rawManifest {
    manifestEntries.append(parseEntry(line))
}

var totalMass = 0
var unknownCount = 0
for entry in manifestEntries {
    totalMass += mass(of: entry)
    if case .unknown = entry {
        unknownCount += 1
    }
}

print("total mass:", totalMass, "unknown lines:", unknownCount)

let A = totalMass


// Level 3

struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(_ amount: Int) {
        oxygen = max(oxygen - amount, 0)
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }

    static func rookie(named name: String) -> CrewSnapshot {
        CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

var crewRoster: [CrewSnapshot] = []
for record in crewData {
    guard let deck = Deck(rawValue: record.deck) else {
        print("Unknown deck for \(record.name): \(record.deck)")
        continue
    }
    crewRoster.append(CrewSnapshot(name: record.name, deck: deck, oxygen: record.oxygen))
}

print(crewRoster)

func find(_ name: String, in roster: [CrewSnapshot]) -> CrewSnapshot? {
    for member in roster {
        if member.name == name { return member }
    }
    return nil
}

// value semantics demo

var original = CrewSnapshot.rookie(named: "TestOne")
var copy = original
copy.oxygen = 10
print("copy: before", original.oxygen, "after copy edited:", original.oxygen, copy.oxygen)

func tryToDrain(_ member: CrewSnapshot) -> CrewSnapshot {
    var m = member
    m.oxygen = 0
    return m
}
let beforePlain = original.oxygen
let resultPlain = tryToDrain(original)
print("plain param: before", beforePlain, "original after:", original.oxygen, "result:", resultPlain.oxygen)

func drain(_ member: inout CrewSnapshot) {
    member.oxygen = 0
}
let beforeInout = original.oxygen
drain(&original)
print("inout: before", beforeInout, "original after:", original.oxygen)


// Level 4

final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    // classes never get a free memberwise init like structs do, so this one
    // has to be written by hand
    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    func load(_ crew: CrewSnapshot) -> Bool {
        guard occupant == nil, chargeLevel >= 20 else { return false }
        occupant = crew
        return true
    }

    func fire() -> CrewSnapshot? {
        guard let passenger = occupant else { return nil }
        occupant = nil
        chargeLevel -= 20
        return passenger
    }

    deinit {
        print("Pod \(id) deinitialized")
    }
}

let pod = TeleportPod(id: "P-1", chargeLevel: 100)

if let timur = find("Timur", in: crewRoster),
   let dana = find("Dana", in: crewRoster),
   let nurlan = find("Nurlan", in: crewRoster) {

    pod.load(timur)
    pod.fire()
    print(pod.chargeLevel)

    pod.load(dana)
    pod.fire()
    print(pod.chargeLevel)

    pod.load(nurlan)
    pod.fire()
    print(pod.chargeLevel)

    pod.fire() // empty pod, nothing to spend
    print(pod.chargeLevel)
}

let C = pod.chargeLevel

// reference semantics demo

let podRef1 = TeleportPod(id: "Ref", chargeLevel: 50)
let podRef2 = podRef1
podRef2.chargeLevel = 5
print("class: podRef1", podRef1.chargeLevel, "podRef2", podRef2.chargeLevel)

var snapA = CrewSnapshot.rookie(named: "ValueTest")
var snapB = snapA
snapB.oxygen = 1
print("struct: snapA", snapA.oxygen, "snapB", snapB.oxygen)
// classes share one instance (both variables point at the same object),
// structs copy their whole value on assignment (each variable is independent)


// Level 5

final class Station {
    let callSign: String

    var hullIntegrity: Int {
        willSet {
            print("hullIntegrity changing from \(hullIntegrity) to \(newValue)")
        }
        didSet {
            if hullIntegrity > 100 {
                hullIntegrity = 100
            } else if hullIntegrity < 0 {
                hullIntegrity = 0
            }
        }
    }

    var oxygenByDeck: [Deck: Int] = [:]

    lazy var fullDiagnostics: String = {
        print("Running full scan...")
        return "Diagnostics complete for \(callSign)"
    }()

    var totalOxygen: Int {
        var sum = 0
        for value in oxygenByDeck.values {
            sum += value
        }
        return sum
    }

    var averageOxygen: Int {
        get {
            return totalOxygen / oxygenByDeck.count
        }
        set {
            for deck in oxygenByDeck.keys {
                oxygenByDeck[deck] = newValue
            }
        }
    }

    init(callSign: String, hullIntegrity: Int, deckReadings: [(deck: String, oxygen: Int)]) {
        self.callSign = callSign
        self.hullIntegrity = hullIntegrity
        for reading in deckReadings {
            if let deck = Deck(rawValue: reading.deck) {
                oxygenByDeck[deck] = reading.oxygen
            } else {
                print("Unknown deck in readings: \(reading.deck)")
            }
        }
    }
}

let station = Station(callSign: "ALMA-7", hullIntegrity: 80, deckReadings: deckReadings)
let B = station.averageOxygen
print("starting averageOxygen:", B)

print(station.fullDiagnostics)
print(station.fullDiagnostics) // second access, "Running full scan..." should NOT print again

station.hullIntegrity = 130
print(station.hullIntegrity)
station.hullIntegrity = -40
print(station.hullIntegrity)
station.hullIntegrity = 55
print(station.hullIntegrity)
// setting hullIntegrity inside didSet re-triggers didSet, but only one extra
// time: once the clamp assigns 100 (or 0), that value is already inside
// 0...100, so the next didSet call finds nothing to clamp and doesn't
// assign again -> the recursion stops after a single bounce, not forever.


// Level 6 (analysis only, nothing here is meant to run)

/*
Report 1:
var roster = crewRoster
for var member in roster {
    member.oxygen -= 10
}
print(roster[0].oxygen)

Expected: crew members lose oxygen.
Actual: roster[0].oxygen is unchanged.
Rule: CrewSnapshot is a struct. "member" in a for-in loop is a fresh copy of
each element, not a reference into the array. Mutating "member" only changes
that local copy; the array itself is untouched.
Fix: mutate through the array's own indices instead of a copied loop variable.

var roster2 = crewRoster
for index in roster2.indices {
    roster2[index].oxygen -= 10
}
print(roster2[0].oxygen)


Report 2:
let podA = TeleportPod(id: "A", chargeLevel: 100)
let podB = podA
podB.chargeLevel = 0
print(podA.chargeLevel)

Expected: podA stays at 100.
Actual: podA.chargeLevel is also 0.
Rule: TeleportPod is a class. "let podB = podA" copies the reference, not the
object -- podA and podB point at the same instance, so mutating one mutates
both. "let" only stops you reassigning what podB points to, not what it points at.
Fix: if two independent pods were intended, create a second instance instead
of aliasing the first one.

let podA2 = TeleportPod(id: "A", chargeLevel: 100)
let podB2 = TeleportPod(id: "A-copy", chargeLevel: podA2.chargeLevel)
podB2.chargeLevel = 0
print(podA2.chargeLevel) // 100, truly independent now


Report 3:
struct Logbook {
    var entries: [String] = []
    func add(_ entry: String) {
        entries.append(entry)
    }
}

This one does not compile. add() calls entries.append(), which mutates a
stored property, but the method isn't marked mutating. Struct instance
methods treat self as immutable by default, so this fails with something
like "cannot use mutating member on immutable value: 'self' is immutable".
Fix: mark the method mutating.

struct FixedLogbook {
    var entries: [String] = []
    mutating func add(_ entry: String) {
        entries.append(entry)
    }
}


Report 4:
let snapshot = CrewSnapshot.rookie(named: "Dana")
snapshot.oxygen = 40
-- this line does not compile: CrewSnapshot is a struct, so "let" freezes
   the entire value, every property included. You can't reassign any part
   of a let struct.

let pod = TeleportPod(id: "B", chargeLevel: 50)
pod.chargeLevel = 10
-- this line compiles fine: TeleportPod is a class, so "let" only freezes
   the reference itself (you can't point pod elsewhere), not the var
   properties of the object it refers to.

Fix for the struct half: use var if you intend to mutate it.
var snapshot2 = CrewSnapshot.rookie(named: "Dana")
snapshot2.oxygen = 40 // now compiles
*/


// Level 7

final class FlightRecorder {
    // private: nobody outside this type can read, replace, or clear the array directly
    private var entries: [String] = []

    // private(set): outside code can read isSealed, but can never assign to it directly
    private(set) var isSealed = false

    // fileprivate: lets other code in this same file (like the free function below)
    // see the raw entries, without exposing them to other files or modules
    fileprivate var rawEntries: [String] {
        entries
    }

    var entryCount: Int {
        entries.count
    }

    var transcript: String {
        var result = ""
        for entry in entries {
            result += entry + "\n"
        }
        return result
    }

    func log(_ entry: String) {
        guard !isSealed else {
            print("Recorder is sealed, cannot log: \(entry)")
            return
        }
        entries.append(entry)
    }

    func seal() {
        isSealed = true
    }
}

func auditTranscript(of recorder: FlightRecorder) -> String {
    "Audit: \(recorder.rawEntries.count) raw entries on file"
}

let recorder = FlightRecorder()
recorder.log("liftoff")
recorder.log("orbit achieved")
print(recorder.entryCount)
recorder.seal()
recorder.log("this should be blocked")
print(recorder.entryCount)
print(auditTranscript(of: recorder))

// Attempts to break it from outside, left as comments with the errors they produce:
// recorder.entries.append("hack")
// error: 'entries' is inaccessible due to 'private' protection level
// recorder.isSealed = false
// error: cannot assign to property: 'isSealed' setter is inaccessible


// Finale

let D = AlarmLevel.level(forTotalMass: A).rawValue
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("INTEGRITY CODE: \(integrityCode)")


// Bonus

var keptReference: TeleportPod?
print("before do block")
do {
    let podY = TeleportPod(id: "DoBlockPod", chargeLevel: 10)
    keptReference = podY
    print("inside do block")
}
print("after do block, pod still alive because keptReference holds it")
keptReference = nil
print("after clearing keptReference, pod should now deinit")
// deinit fires on the "keptReference = nil" line, not at the end of the do
// block, because that's the line where the LAST strong reference to the pod
// goes away -- as long as keptReference held it, the object stayed alive.

func samePod(_ a: TeleportPod, _ b: TeleportPod) -> Bool {
    a === b
}

let podI1 = TeleportPod(id: "I1", chargeLevel: 10)
let podI2 = podI1
let podI3 = TeleportPod(id: "I1", chargeLevel: 10)

print(samePod(podI1, podI2))
print(samePod(podI1, podI3))
// === can't be used on CrewSnapshot because it's a struct: value types have
// no identity or address to compare, every copy is just an independent
// value. Comparing two CrewSnapshots for "sameness" can only mean comparing
// their stored data (Equatable), never asking if they're "the same instance".


// Defense questions
/*
1. CrewSnapshot is a struct with no custom init, so Swift generates a
   memberwise init for free. TeleportPod is a class, and classes never get
   a free memberwise init -- only structs do -- so its init had to be written by hand.

2. mutating lets a struct's instance method reassign self or its stored
   properties; without it, self is treated as a let constant inside the
   method. Classes never need it because a class's reference (self) can't
   be reassigned anyway, and its var properties live independently on the
   heap -- mutating them doesn't require special permission from the method.

3. For a struct declared with let, let freezes the whole value -- no
   property can be reassigned, because the value and its properties are one
   unit in that storage slot. For a class declared with let, let freezes
   only the reference -- you can't point it at a different object, but the
   object's own var properties can still be changed through that reference.

4. A lazy property must be var because its value is computed once, on first
   access, and then written into storage -- a let constant can never be
   written to after init. Behaviour changes, not just performance: if some
   code path never touches fullDiagnostics, "Running full scan..." never
   prints at all -- the side effect only happens if the property is actually accessed.

5. FlightRecorder's entries array is fine as private, since only the type
   itself needs it. But rawEntries has to be fileprivate instead, because
   auditTranscript(of:) is a free function outside the class (though in the
   same file) -- private would block that function too, fileprivate opens
   access to the whole file without exposing it to other files or modules.

Bonus: deinit fires on the line where the last strong reference disappears
-- in the do-block demo that's "keptReference = nil", not the end of the
do block, since keptReference kept the object alive past the block's scope.
=== can't be used on CrewSnapshot because structs have no identity -- every
copy is an independent value with no address to compare, so there's no
"same instance" question to ask, only "same content" (Equatable).
*/
